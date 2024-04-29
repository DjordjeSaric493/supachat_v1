import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/models/message_model.dart';
import 'package:supachat_v1/models/room.dart';
import 'package:supachat_v1/state/app_state.dart';
import 'package:supachat_v1/widgets/chat_bubble.dart';
import 'package:supachat_v1/widgets/message_bar.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ChatPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: StreamBuilder<List<Room>?>(
        stream: AppState.roomsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Are you signed in?'));
          }

          final rooms = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: rooms.isEmpty
                    ? const Center(child: Text('No rooms yet'))
                    : ListView.builder(
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          return ListTile(
                            title: Text('Chat: ${room.id}'),
                            subtitle: Text(
                                room.lastMessage?.content ?? 'no last message'),
                          );
                        },
                      ),
              ),
              // const MessageBar(),
            ],
          );
        },
      ),
    );
  }
}
