import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatForm extends StatefulWidget {
  const ChatForm({
    Key? key,
    required this.roomId,
  }) : super(key: key);

  final String roomId;

  @override
  State<ChatForm> createState() => _ChatFormState();
}

class _ChatFormState extends State<ChatForm> {
  final _textController = TextEditingController();
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
                hintText: 'Type something',
                fillColor: Color.fromARGB(255, 255, 255, 255),
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
                'room_id': widget.roomId,
                'profile_id': Supabase.instance.client.auth.getUser(),
                'content': text,
              });

              final error = res.error;
              if (error != null && mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error.message)));
              }
            },
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
