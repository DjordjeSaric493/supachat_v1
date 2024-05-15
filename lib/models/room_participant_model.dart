class RoomParticipant {
  RoomParticipant({
    required this.id,
    required this.roomId,
    required this.createdAt,
  });

  final String id; //id user

  final String roomId; //id room

  final DateTime createdAt;

  factory RoomParticipant.fromJSON(Map<String, dynamic> map) {
    return RoomParticipant(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      roomId: map['roomId'] ?? 'Undefied room id',
    );
  }
}
