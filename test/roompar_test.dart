import 'package:flutter_test/flutter_test.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/models/room_participant_model.dart';

void main() {
  //npr soba u kojoj jeste participant
  test('korisnik jeste u sobi', () {
    final currentUserId = 'f84e73d2-5602-4ee5-875?.profileId6-5da7f2964bce';
    final roomIdMock = '262d9d50-97f0-4e33-af4c-1e75f0f68e1c';
    final roomParticipants = [
      RoomParticipant(
        profileId: currentUserId, // pretpostavim da jeste u sobi
        roomId: '262d9d50-97f0-4e33-af4c-1e75f0f68e1c',
        createdAt: DateTime.parse('2024-05-16 07:20:46.107404+00'),
        username: '',
      ),
    ];

    final isUserInRoom = roomParticipants.any((roomParticipant) =>
        roomParticipant.profileId == currentUserId &&
        roomParticipant.roomId == roomIdMock);

    expect(isUserInRoom, true); // očekujem da vrati true
  });

  //soba u kojoj nije, ona sa Undefined name
  test('korisnik nije u sobi ', () {
    final currentUserId = 'f84e73d2-5602-4ee5-875?.profileId6-5da7f2964bce';
    final roomIdMock = '262d9d50-97f0-4e33-af4c-1e75f0f68e1c';
    final roomParticipants = [
      RoomParticipant(
        profileId: 'f84e73d2-5602-4ee5-875?.profileId6-5da7f2964bce',
        roomId: 'e340b65d-2386-4dd6-85cc-840717386bef',
        createdAt: DateTime.parse('2024-05-16 07:20:46.107404+00'),
        username: '',
      ),
    ];

    final isUserInRoom = roomParticipants.any((roomParticipant) =>
        roomParticipant.profileId == currentUserId &&
        roomParticipant.roomId == roomIdMock);

    expect(isUserInRoom, false); // očekujem da nije u sobi
  });
}
