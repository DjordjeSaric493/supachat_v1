class Profile {
  Profile({
    required this.id,
    required this.username,
    required this.createdAt,
  });

  /// User ID of the profile
  final String id;

  /// Username of the profile
  final String username;

  /// Date and time when the profile was created
  final DateTime createdAt;

  factory Profile.fromJSON(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      username: map['username'] ?? 'Undefied name',
    );
  }
}
