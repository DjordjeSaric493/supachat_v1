import 'package:flutter/material.dart';
import 'package:supachat_v1/models/message_model.dart';
import 'package:supachat_v1/models/user_model.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    required this.userId,
    required this.message,
    required this.profileCache,
  }) : super(key: key);

  final String? userId;
  final Message message;
  final Map<String, Profile> profileCache;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(4),
      color: userId == message.profileId ? Colors.grey[300] : Colors.blue[200],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profileCache[message.profileId]?.username ?? 'loading...',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            Text(
              message.content,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
