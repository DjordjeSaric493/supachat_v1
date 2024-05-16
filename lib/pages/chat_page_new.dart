import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/models/message_model.dart';
import 'package:supachat_v1/models/room.dart';
import 'package:supachat_v1/models/room_participant_model.dart';
import 'package:supachat_v1/models/user_model.dart';
import 'package:supachat_v1/state/app_state.dart';
import 'package:supachat_v1/widgets/chat_bubble.dart';
import 'package:supachat_v1/widgets/chat_form.dart';
import 'package:supachat_v1/widgets/edit_title.dart';

class ChatPageNew extends StatefulWidget {
  const ChatPageNew({super.key, required this.room});

  final Room room; //objekat klase Room ->dodaj u req

  @override
  State<ChatPageNew> createState() => _ChatPageNewState();
}

class _ChatPageNewState extends State<ChatPageNew> {
  late bool isUserInRoom;

  String userId = supabase.auth.currentUser!.id;
  //to bi moralo stream
  /* void _checkUserInRoom(String userId, String roomId) async {
    final response = await supabase
        .from('room_participant')
        .select()
        .eq('user_id', userId)
        .eq('room_id', roomId);

    setState(() {
      //TODO:pitaj Rajka
      isUserInRoom = response!=null &&response!.isNotEmpty; //response.data != null && response.data!.isNotEmpty;
    });
  }*/
  late final checkInStream = supabase
      .from('room_participants')
      .stream(primaryKey: ['profile_id', 'room_id']) //može kao složeni ključ!!
      // primarni ključ od tabele na osnovu toga radi query
      .eq('profile_id',
          supabase.auth.currentUser?.id ?? "") //da li može vrati praazan
      .map((maps) => maps.map(RoomParticipant.fromJSON).toList());
// room_id  participant_id  nije još u sobi
//  a       d1                      r1 ->vraća prazan niz nije ni u jednoj sobi
//  b       d1
  late final msgStream = Supabase.instance.client
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('room_id', widget.room.id)
      .order('created_at')
      .map((maps) => maps.map(Message.fromJSON).toList());
  //final _profileCache = <String, Profile>{};
  final _profileController = StreamController<Profile>();
  final _removeParticipantController = StreamController<String>();

//kontroler preko streamova
  Stream<Profile> get profileStream => _profileController.stream;

  /*Future<void> fetchProfile(String userId) async {
    if (_profileCache.containsKey(userId)) {
      return;
    }
    final res =
        await supabase.from('profiles').select().eq('id', userId).single();

    final data = res.data;
    if (data != null) {
      final profile = Profile.fromJSON(data);
      _profileCache[userId] = profile;
      _profileController.add(profile);
    }
  }*/

  //FUTURE -nemoj za realtime steamove!! TODO:skontaj šta treba!!!

  //šminka

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: checkInStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString()); //error snap u string
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final roomParticipants = snapshot.data ?? [];
          //provderi da li je u sobi  roomParticipants
          //ovo je za bool
          final isUserInRoom = roomParticipants.any((roomParticipant) =>
              roomParticipant.profileId == supabase.auth.currentUser?.id &&
              roomParticipant.roomId == widget.room.id);
          /*
          ako treba dalja provera 
          final isUserInRoom2 = roomParticipants
              .where((roomParticipant) => roomParticipant.id==userId);*/

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
                    onPressed: () {}, icon: const Icon(Icons.person_add)),
              ],
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _messageList(),
                  ),
                  //135-146 ako je u sobi prikaži chatForm u suprotnom baci elev button

                  if (isUserInRoom)
                    ChatForm(
                      room: widget.room,
                    )
                  else
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          addParticipant(userId);
                        },
                        child: const Text('JOIN ROOM'),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }

  Widget _messageList() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return StreamBuilder(
      stream: AppState.profilesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }
        final profiles = snapshot.data!; //ima data ->! (!=sig nije null)
        var profileMap = {for (Profile p in profiles) p.id: p};
        return StreamBuilder(
          stream: msgStream, //UMESTO CHATNEW._msg NIKAKO!!!
          builder: (context, msgSnapshot) {
            if (!msgSnapshot.hasData || msgSnapshot.data!.isEmpty) {
              return const SizedBox();
            }
            //
            final messages = msgSnapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              reverse: true,
              itemCount: messages.length,
              itemBuilder: ((context, index) {
                final message = messages![index];
                return Align(
                  alignment: userId == message.senderId
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ChatBubble(
                      userId: userId,
                      message: message,
                      profileCache: profileMap,
                    ),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _profileController.close();
    super.dispose();
  }

  Future<void> deleteParticipant(String userId) async {
    try {
      final response = await supabase
          .from('room_participants')
          .delete()
          .eq('room_id', widget.room.id)
          .eq('profile_id', userId);

      if (response.error != null) {
        throw Exception(response.error!.message);
      }
    } catch (error) {
      print('Error deleting participant: $error');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error deleting user with ID: $userId'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    ;
  }

  Future<void> addParticipant(String userId) async {
    try {
      final response = await supabase
          .from('room_participants')
          .insert({'room_id': widget.room.id, 'profile_id': userId});

      if (response.error != null) {
        throw Exception(response.error!.message);
      }
    } catch (error) {
      print('Error adding participant: $error');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error adding user with ID: $userId'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
