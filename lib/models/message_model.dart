class Message {
  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  /// ID of the message
  final String id;

  /// ID of the user who posted the message
  final String senderId;

  /// Text content of the message
  final String content;

  /// Date and time when the message was created
  final DateTime createdAt;

//samo property koji je u bazi u fromJSON
  Message.fromJSON(
    Map<String, dynamic> map,
  )   : id = map['id'],
        senderId = map['profile_id'],
        content = map['content'],
        createdAt = DateTime.parse(map['created_at']);
}
