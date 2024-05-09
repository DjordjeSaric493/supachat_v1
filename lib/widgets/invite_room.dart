import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/src/widgets/async.dart';

class InviteUserDialog extends StatefulWidget {
  const InviteUserDialog({
    Key? key,
    required this.roomId,
  }) : super(key: key);

  final String roomId;

  @override
  State<InviteUserDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteUserDialog> {
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Invite a user'),
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
              ),
            ),
            TextButton(
              onPressed: () async {
                final username = _textController.text;
                final getUser = await Supabase.instance.client
                    .from('profiles') //vataj iz tabele
                    .select()
                    .eq('username', username)
                    .single(); //jedan red po tabeli
                final data = getUser.data;
                final insertRes = await Supabase.instance.client
                    .from('room_participants')
                    .insert({
                  'room_id': widget.roomId,
                  'profile_id': data['id'],
                });
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.add_reaction),
            ),
          ],
        ),
      ],
    );
  }
}
