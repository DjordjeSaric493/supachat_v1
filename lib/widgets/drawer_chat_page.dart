import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/models/room.dart';
import 'package:supachat_v1/models/room_participant_model.dart';

class ChatRoomDrawer extends StatefulWidget {
  const ChatRoomDrawer({
    super.key,
    required this.room,
  });

  final Room room;
  @override
  State<ChatRoomDrawer> createState() => _ChatRoomDrawerState();
}

//stream koji ćemo koristiti za proveru korisnika
late final checkInStream = supabase
    .from('room_participants')
    .stream(primaryKey: ['profile_id', 'room_id']) //može kao složeni ključ!!
    .eq('profile_id',
        supabase.auth.currentUser?.id ?? "") //da li može vrati praazan
    .map((maps) => maps.map(RoomParticipant.fromJSON).toList());

late final roomStream = Supabase.instance.client
    .from('room')
    .stream(primaryKey: ['id'])
    .order('created_at')
    .map((maps) => maps.map(Room.fromJSON).toList());

class _ChatRoomDrawerState extends State<ChatRoomDrawer> {
  @override
  Widget build(BuildContext context) {
    /*na front-u mi je zamisao da ubacim 
    1) appBar: koji bi pokazvao naziv sobe i broj room_participant-a,
    2) listu:sa username 
    3) settings stranicu */
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
      ),
      body: StreamBuilder<List<Room>?>(
        stream: roomStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: LinearProgressIndicator(color: Colors.blue[600]),
            );
          }
          final rooms = snapshot.data;
          if (rooms!.isEmpty) {
            return const Center(
              child: Text('No info fetched'),
            );
          }
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return StreamBuilder<List<RoomParticipant>>(
                stream: checkInStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListTile(
                      title: Text('No info'),
                    );
                  }
                  final roomParticipants = snapshot.data ?? [];

                  //poenta vica: prikazati samo one koji su u sobi
                  final participantsInRoom = roomParticipants
                      .where(
                          (participant) => participant.roomId == widget.room.id)
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: participantsInRoom.length,
                    itemBuilder: (context, participantIndex) {
                      final participant = participantsInRoom[participantIndex];
                      return ListTile(
                        title: Text(participant.username),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
