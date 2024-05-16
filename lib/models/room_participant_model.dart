class RoomParticipant {
  RoomParticipant({
    required this.profileId,
    required this.roomId,
    required this.createdAt,
  });

  final String profileId; //id user

  final String roomId; //id room

  final DateTime createdAt;

  factory RoomParticipant.fromJSON(Map<String, dynamic> map) {
    try {
      return RoomParticipant(
        profileId: map['profile_id'],
        createdAt: DateTime.parse(map['created_at']),
        roomId: map['room_id'],
      );
    } catch (e, st) {
      throw e.toString() + '\n' + st.toString();
    }
  }
}
