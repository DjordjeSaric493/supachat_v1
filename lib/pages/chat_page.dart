import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/models/message_model.dart';
import 'package:supachat_v1/models/user_model.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supachat_v1/widgets/chat_bubble.dart';
import 'package:supachat_v1/widgets/message_bar.dart';
import 'package:rxdart/rxdart.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ChatPage(),
    );
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final Stream<List<Message>> _messagesStream;
  final Map<String, Profile> _profileCache = {};
  @override
  void initState() {
    //user auth
    final myUserId = supabase.auth.currentUser!.id;
    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) => maps
            .map((map) => Message.fromMap(map: map, myUserId: myUserId))
            .toList());
    super.initState();
  }

//TODO: Napravi kopiju i prepravi ga da dohvata sve chatove za ulogovanog usera

  static Stream<String?> authUserIdStream = supabase.auth.onAuthStateChange
      .map((authState) => authState.session?.user.id)
      .distinct()
      .shareValue();
/*
  static Stream<Map?> authProfile = authUserIdStream
      .switchMap(
        (authUserId) => authUserId == null
            ? Stream.value(null)
            : supabase
                .from('profile')
                .stream(primaryKey: ['id'])
                .eq('id', authUserId)
                .map((list) => list.firstOrNull),
      )
      .shareValue();
*/
//TODO: streamovi hvataju podatke iz baze i ne treba state management za to

  static Stream<List<Map>?> RoomsStream =
      authUserIdStream.switchMap((authUserId) {
    if (authUserId == null) {
      return Stream.value(null);
    } else {
      return supabase
          .from('chat')
          .stream(primaryKey: ['id'])
          .eq('user_id', authUserId)
          .map((list) => list.firstOrNull);
    }
  }).shareValue() as Stream<List<Map>?>;

  Future<void> _loadProfileCache(String profileId) async {
    if (_profileCache[profileId] != null) {
      return;
    }
    final data =
        await supabase.from('profiles').select().eq('id', profileId).single();
    final profile = Profile.fromMap(data);
    setState(() {
      _profileCache[profileId] = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: StreamBuilder<List<Message>>(
        stream: _messagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child:
                              Text('Oću li dočekati prelaz na ovu stranicu :)'),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];

                            _loadProfileCache(message.senderId);

                            return ChatBubble(
                              message: message,
                              profile: _profileCache[message.senderId],
                            );
                          },
                        ),
                ),
                const MessageBar(),
              ],
            );
          } else {
            return preloader;
          }
        },
      ),
    );
  }
}
