import 'package:flutter/material.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/models/room.dart';
import 'chat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//------ prikaz lista chat-ova tj chat soba

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appbar
      appBar: AppBar(
        title: const Text('Chat Rooms'),
        actions: [
          IconButton(
            onPressed: () {
              Supabase.instance.client.auth.signOut();
            },
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout ',
          ),
        ],
      ),
      //pokušaj da skontam stream-ove
      //pokreni intancu za supabase (.from itd itd)

      //TODO (Rajko): Molim te vidi da li išta od ovoga ima smisla nisam još gotov da plačem ali tu sam negde...
      //kako da ukinem ovo spelovanje kad kucam reči na srpskom?
      body: StreamBuilder<List<Room>?>(
        stream: Supabase.instance.client
            .from('room')
            .stream(primaryKey: ['id'])
            .order('created_at')
            .map((maps) => maps.map(Room.fromJSON).toList()),
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
          return ListView.builder(
            itemCount: rooms.length, //kolko ima "soba"
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ChatPage();
                  }));
                },
              );
            },
          );
        },
      ),
    );
  }
}