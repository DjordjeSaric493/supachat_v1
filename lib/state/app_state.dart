import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/models/message_model.dart';
import 'package:supachat_v1/models/room.dart';
import 'package:supachat_v1/models/user_model.dart';
import 'package:supachat_v1/models/room_participant_model.dart';

class AppState {
  static Stream<String?> authUserIdStream = supabase.auth.onAuthStateChange
      .map((authState) => authState.session?.user.id)
      .distinct()
      .shareValue();

  /// expected values:
  ///   - null
  ///   - [{ 'id: 'chat1', 'created_at': 2024-04-30, 'last_message': null }, { 'id': 'chat2', ... }]
  static Stream<List<Room>?> roomsStream =
      authUserIdStream.switchMap((authUserId) {
    if (authUserId == null) {
      return Stream.value(null);
    } else {
      return supabase
          .from('room') //
          .stream(primaryKey: ['id']).map((list) =>
              list.map((roomJson) => Room.fromJSON(roomJson)).toList());
    }
  }).shareValue();
/*unut
  static Stream<List<Message>?> msgStream =
      authUserIdStream.switchMap((authUserId) {
    if (authUserId == null) {
      return Stream.value(null);
    } else {
      return supabase
          .from('room') //
          .stream(primaryKey: ['id']) //
          .map((list) =>
              list.map((roomJson) => Room.fromJSON(roomJson)).toList());
    }
  }).shareValue(); */
  static Stream<List<Profile>?> profilesStream =
      authUserIdStream.switchMap((authUserId) {
    if (authUserId == null) {
      return Stream.value(null);
    } else {
      return supabase
          .from('profiles') //
          .stream(primaryKey: ['id']) //
          .map((list) => list
              .map((profileJson) => Profile.fromJSON(profileJson))
              .toList());
    }
  }).shareValue();

  static Stream<List<RoomParticipant>?> roomParStream =
      authUserIdStream.switchMap((authUserId) {
    if (authUserId == null) {
      return Stream.value(null);
    } else {
      return supabase
          .from('room_participants') //
          .stream(primaryKey: ['id']) //
          .map((list) => list
              .map((roomParJson) => RoomParticipant.fromJSON(roomParJson))
              .toList());
    }
  }).shareValue() as Stream<List<RoomParticipant>?>;
}
