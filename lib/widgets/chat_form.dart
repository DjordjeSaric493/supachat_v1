import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supachat_v1/models/room.dart';

class ChatForm extends StatefulWidget {
  const ChatForm({
    super.key,
    required this.room,
  });

  //final String roomId;
  final Room room;
  @override
  State<ChatForm> createState() => _ChatFormState();
}

class _ChatFormState extends State<ChatForm> {
  late final msgStream = Supabase.instance.client
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('room_id', widget.room.id)
      .order('created_at')
      .map((maps) => maps.map(Room.fromJSON).toList());
  final TextEditingController _textController = TextEditingController();

  //kontrola mog stream-a
  /* final StreamController<String> _messageStreamController =
      StreamController<String>();*/

//lepo je staviti kod initstate ako ga imaš
  @override
  void dispose() {
    _textController.dispose();
    // _messageStreamController.close(); //možeš i bez ovoga
    super.dispose();
  }

  void _sendMessage() async {
    /* final text = _textController.text; // Dobijanje teksta iz kontrolera teksta
    if (text.isEmpty) {
      // Provera el tekst prazan
      return;
    }
    _textController.clear();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final res = await Supabase.instance.client.from('messages').insert({
      // Slanje poruke ka supabase (INSERT)
      'room_id': widget.room.id,
      'profile_id': userId,
      'content': text,
    });

    final error = res.error;  //property error od null ?? wtf djorjde

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error
              .message))); //prikaži snackbar sa tekstom (kao kad pukne auth)
    } else {
      _messageStreamController.sink.add(text); // šalji poruke itd itd
    }*/

    //await kod future-a u try catch blok!!! izbegnem ui
    try {
      final text =
          _textController.text; // Dobijanje teksta iz kontrolera teksta
      if (text.isEmpty) {
        // Provera el tekst prazan
        return;
      }
      _textController.clear();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final res = await Supabase.instance.client.from('messages').insert({
        // Slanje poruke ka supabase (INSERT)
        'room_id': widget.room.id,
        'profile_id': userId,
        'content': text,
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error
                .toString()))); //prikaži snackbar sa tekstom (kao kad pukne auth)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type something here',
                fillColor: Color.fromARGB(255, 255, 255, 255),
                filled: true,
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: _sendMessage,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
