import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/data/models/friend_request.dart';

abstract class SocialRepository {
  Future<User?> get currentUser;
  Future<void> addFriend(String userId);
  Future<List<Map<String, dynamic>>> getAllFriends();
  Future<void> removeFriend(String id);
  Future<List<Map<String, dynamic>>> searchFriend(String query);
  Future<void> sendFriendRequest(String email);
  Future<void> acceptFriendRequest(String friendId);
  Stream<List<FriendRequest>> getFriendRequestsStream();
}
