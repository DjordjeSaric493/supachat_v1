import 'package:flutter/material.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/models/room.dart';
import 'package:supachat_v1/models/room_participant_model.dart';
import 'package:supachat_v1/pages/chat_page_new.dart';
import 'package:supachat_v1/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page_new.dart';

//------ prikaz lista chat-ova tj chat soba

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Route<Object?> route() {
    return MaterialPageRoute(
      builder: (context) => const HomeScreen(),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  //stream da proveri jel u sobi
  late final checkInStream = supabase
      .from('room_participants')
      .stream(primaryKey: ['profile_id', 'room_id']) //može kao složeni ključ!!
      // primarni ključ od tabele na osnovu toga radi query
      .eq('profile_id',
          supabase.auth.currentUser?.id ?? "") //da li može vrati praazan
      .map((maps) => maps.map(RoomParticipant.fromJSON).toList());

  late final roomStream = Supabase.instance.client
      .from('room')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((maps) => maps.map(Room.fromJSON).toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appbar
      appBar: AppBar(
        title: const Text('Chat Roomz'),
        actions: [
          IconButton(
            onPressed: () {
              Supabase.instance.client.auth.signOut();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const LoginPage();
              }));
            },
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout ',
          ),
        ],
      ),
      //pokušaj da skontam stream-ove
      //pokreni intancu za supabase (.from itd itd)

      //TODO (Rajko): Molim te vidi da li išta od ovoga ima smisla nisam još gotov da plačem ali tu sam negde...

      body: StreamBuilder<List<Room>?>(
        stream: roomStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: preloader,
            );
          }
          final rooms = snapshot.data;
          if (rooms!.isEmpty) {
            return const Center(
              child: Text('Create ur room'),
            );
          }
          //TODO: ovde si igraj sa participoants!!!
          return ListView.builder(
            itemCount: rooms.length, //kolko ima "soba"
            itemBuilder: (context, index) {
              final room = rooms[index];
              return StreamBuilder<List<RoomParticipant>>(
                stream: checkInStream,
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListTile(
                      title: Text(room.name),
                    );
                  }
                  final roomParticipants = snapshot.data ?? [];
                  final participants = snapshot.data!;
                  final participantCounter = participants
                      .where((participant) => participant.roomId == room.id)
                      .length;
                  final isUserInRoom = roomParticipants.any((roomParticipant) =>
                      roomParticipant.profileId ==
                          supabase.auth.currentUser?.id &&
                      roomParticipant.roomId == room.id);
                  return ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return ChatPageNew(room: room);
                          }),
                        );
                      },
                      title: Text(
                          '${room.name}  participants: ($participantCounter) '),
                      trailing: isUserInRoom
                          ? Icon(Icons.check, color: Colors.green[700])
                          : Icon(Icons.close, color: Colors.red));
                }),
              );
            },
          );
        },
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return const LoginPage();
            }),
          );
        },
      ),*/
    );
  }

  //ako nije autorizovan
  void unauth() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false);
  }
}
