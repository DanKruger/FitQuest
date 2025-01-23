import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/data/models/friend_request.dart';
import 'package:fitquest/data/sources/remote/firebase_social_service.dart';
import 'package:fitquest/domain/repo/abstract_repos/social_repository.dart';

class FirebaseSocialRepo implements SocialRepository {
  final FirebaseSocialService _firebaseSocialService;

  FirebaseSocialRepo({required FirebaseSocialService firebaseSocialService})
      : _firebaseSocialService = firebaseSocialService;

  @override
  Future<void> addFriend(String userId) async {
    // return await _firebaseSocialService.addFriend(userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllFriends() async {
    List<Map<String, dynamic>> data =
        await _firebaseSocialService.getAllFriends();

    for (var item in data) {
      var friendInfo =
          await _firebaseSocialService.searchFriendById(item['friendId']);
      item.addAll(friendInfo ?? {});
    }
    return data;
  }

  @override
  Future<void> removeFriend(String id) async {
    await _firebaseSocialService.removeFriend(id);
  }

  @override

  /// This will handle the logic of notifying the user of a new friend request
  Future<void> sendFriendRequest(String userId) async {
    return await _firebaseSocialService.sendFriendRequest(userId);
  }

  @override
  Future<List<Map<String, dynamic>>> searchFriend(String query) async {
    return await _firebaseSocialService.searchFriend(query: query);
  }

  @override
  Stream<List<FriendRequest>> getFriendRequestsStream() {
    return _firebaseSocialService.getFriendRequestsStream();
  }

  @override
  // TODO: implement currentUser
  Future<User?> get currentUser async => _firebaseSocialService.currentUser;

  @override
  Future<void> acceptFriendRequest(String friendId) async {
    await _firebaseSocialService.acceptFriendRequest(friendId);
  }
}
