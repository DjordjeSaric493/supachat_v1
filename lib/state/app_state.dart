import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/models/room.dart';

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
          .stream(primaryKey: ['id']) //
          .map((list) {
        debugger;
        list.map((roomJson) => Room.fromJSON(roomJson)).toList();
      });
    }
  }).shareValue();
}
