import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/models/message_model.dart';
import 'package:supachat_v1/models/room.dart';
import 'package:supachat_v1/models/user_model.dart';
import 'package:supachat_v1/widgets/chat_bubble.dart';
import 'package:flutter/src/widgets/async.dart';

class ChatPageNew extends StatefulWidget {
  const ChatPageNew({super.key, required this.room});

  final Room room; //objekat klase Room ->dodaj u req

  @override
  State<ChatPageNew> createState() => _ChatPageNewState();
}

class _ChatPageNewState extends State<ChatPageNew> {
  final Map<String, Profile> _userProfileCache = {};

//TODO: bez petljanja sa costraints itd samo jednostavne poruke !!!!!!!

  final _textController = TextEditingController();
  late final Stream<List<Message>> _messagesStream;
  @override
  void initState() {
    _messagesStream = Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq(
            'room_id',
            widget.room
                .id) //ubacuješ posle stream-a, poredim kolonu u tabeli i vrednost
        .order('created_at')
        .map((maps) => maps.map(Message.fromJSON).toList());

    // _messagesListener.cancel(); ako ne stavim cancel vrteće u pozadini ->memory leak
    super.initState();
  }

  Future<void> _fetchProfile(String userId) async {
    if (_userProfileCache.containsKey(userId)) {
      return;
    }
    final getUser = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    final data = getUser.data;
    if (data != null) {
      setState(() {
        _userProfileCache[userId] = Profile.fromMap(data);
      });
    }
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
                hintText: 'Type ur message',
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
