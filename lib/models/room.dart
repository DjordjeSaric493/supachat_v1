import 'dart:developer';

import 'message_model.dart';

class Room {
  Room({
    required this.id,
    required this.createdAt,
    required this.name,
    this.lastMessage,
  });

  /// ID of the room
  final String id;

  /// Date and time when the room was created
  final DateTime createdAt;

  //name of our room
  final String name;

  /// Latest message submitted in the room
  final Message? lastMessage;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a room object from room_participants table ->fromjson klasika
  factory Room.fromJSON(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      name: map['name'] ?? 'Untitled room',
      lastMessage: null,
    );
  }

  Room copyWith({
    String? id,
    DateTime? createdAt,
    Message? lastMessage,
  }) {
    return Room(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
