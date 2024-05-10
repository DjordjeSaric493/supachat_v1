import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supachat_v1/models/message_model.dart';
import 'package:supachat_v1/models/room.dart';
import 'package:supachat_v1/models/user_model.dart';
import 'package:supachat_v1/widgets/chat_bubble.dart';
import 'package:supachat_v1/widgets/chat_form.dart';
import 'package:supachat_v1/widgets/edit_title.dart';
import 'package:supachat_v1/widgets/invite_room.dart';

class ChatPageNew extends StatefulWidget {
  const ChatPageNew({super.key, required this.room});

  final Room room; //objekat klase Room ->dodaj u req

  @override
  State<ChatPageNew> createState() => _ChatPageNewState();
}

class _ChatPageNewState extends State<ChatPageNew> {
  List<Message>? _messages;

  final Map<String, Profile> _profileCache = {};

  StreamSubscription<List<Message>>? _messagesListener;

  late final msgStream = Supabase.instance.client
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('room_id', widget.room.id)
      .order('created_at')
      .map((maps) => maps.map(Room.fromJSON).toList());

  final _textController = TextEditingController();
  late final Stream<List<Message>> _msgStream;

  //FUTURE -nemoj za realtime steamove!! TODO:skontaj šta treba!!!

  //šminka
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          child: Text(
            widget.room.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return EditTitle(
                    roomId: widget.room.id,
                  );
                });
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return InviteUserDialog(roomId: widget.room.id);
                    });
              },
              icon: Icon(Icons.person_add)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messageList(),
            ),
            ChatForm(
              room: widget.room,
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageList() {
    if (_messages == null) {
      return const Center(
        child: Text('Loading...'),
      );
    }
    if (_messages!.isEmpty) {
      return const Center(
        child: Text('No one has started talking yet...'),
      );
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      reverse: true,
      itemCount: _messages!.length,
      itemBuilder: ((context, index) {
        final message = _messages![index];
        return Align(
          alignment: userId == message.senderId
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ChatBubble(
              userId: userId,
              message: message,
              profileCache: _profileCache,
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _messagesListener?.cancel();
    super.dispose();
  }
}
