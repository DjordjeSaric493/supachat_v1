import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/models/message_model.dart';
import 'package:supachat_v1/models/room.dart';
import 'package:supachat_v1/models/user_model.dart';
import 'package:supachat_v1/widgets/chat_bubble.dart';

class ChatPageNew extends StatefulWidget {
  const ChatPageNew({super.key, required this.room});

  final Room room; //objekat klase Room ->dodaj u req

  @override
  State<ChatPageNew> createState() => _ChatPageNewState();
}

class _ChatPageNewState extends State<ChatPageNew> {
  //
  List<Message>? _messages;
  final Map<String, Profile> _profileCache = {};

  StreamSubscription<List<Message>>? _messagesListener;
  final _textController = TextEditingController();

  @override
  void initState() {
    final _messagesListener = Supabase.instance.client
        .from('messages:room_id=eq.${widget.room.id}')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) => maps.map(Room.fromJSON).toList())
        .listen((messages) {
          setState(() {
            _messages = messages.cast<Message>();
          });
        });

    super.initState();
  }

  //šminka
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Expanded(
            child: TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type ur  message',
                fillColor: Colors.white,
                filled: true,
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final text = _textController.text;
              if (text.isEmpty) {
                return;
              }
              _textController.clear();
              final res =
                  await Supabase.instance.client.from('messages').insert({
                'room_id': widget.room, //vrednost iz id widgeta
                'profile_id': Supabase.instance.client.auth.currentUser?.id,
                //postavi id korisnika u kolonu profile_id .? da osiguram od null
                'content': text, //text
              });
              final error = res.error;
              if (error != null && mounted) {
                context.showErrorSnackBar(message: error.message);
              }
            },
            child: Icon(Icons.send),
          )
        ]));
  }
}
