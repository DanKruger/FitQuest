import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:fitquest/data/models/friend_request.dart';

class FirebaseSocialService {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  User? get currentUser => _auth.currentUser;

  FirebaseSocialService() {
    _initFirebaseSocail();
  }
  void _initFirebaseSocail() async {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
  }

  Future<void> removeFriend(String friendId) async {
    try {
      User? currentUser = _auth.currentUser;
      String id = currentUser!.uid;

      DocumentSnapshot currentUserDoc =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      List<dynamic> friends = currentUserDoc['friends'];

      final matchingFriends = friends.where((friend) {
        return friend['friendId'] == friendId;
      }).toList();
      for (var friend in matchingFriends) {
        await FirebaseFirestore.instance.collection('users').doc(id).update({
          'friends': FieldValue.arrayRemove([friend]),
        });
      }

      DocumentSnapshot otherUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();
      List<dynamic> otherUserFriends = otherUserDoc['friends'];
      final otherUserMatchingFriends = otherUserFriends.where((friend) {
        return friend['friendId'] == id;
      }).toList();
      for (var friend in otherUserMatchingFriends) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .update({
          'friends': FieldValue.arrayRemove([friend]),
        });
      }
      _removeFriendRequest(friendId, id);
    } on Exception catch (e) {
      print('an error occurred when trying to remove a friend $friendId\n$e');
    }
  }

  Future<Map<String, dynamic>?> searchFriendById(String friendId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> data =
          await _firestore.collection('users').doc(friendId).get();
      return data.data();
    } on Exception catch (e) {
      print('an error occurred when searching for user by id $friendId\n$e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllFriends() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      List<dynamic>? friends = userDoc['friends'] as List<dynamic>?;
      if (friends == null || friends.isEmpty) {
        return [];
      }
      return friends
          .map((friend) => Map<String, dynamic>.from(friend))
          .toList();
    } on Exception catch (e) {
      throw Exception('an error occurred when trying to get friends');
    }
  }

  Future<List<Map<String, dynamic>>> searchFriend(
      {required String query}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> data =
          await _firestore.collection('users').get();

      final Set<Map<String, dynamic>> results = {};

      for (var doc in data.docs) {
        results.add(doc.data()..addAll({"user_id": doc.id}));
      }

      return results.toList(); // Convert Set to List
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Stream<List<FriendRequest>> getFriendRequestsStream() {
    User? currentUser = _auth.currentUser;
    return _firestore
        .collection('users')
        .doc(currentUser?.uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null || !data.containsKey('friendRequests')) {
        return [];
      }
      var beans = data['friendRequests'];
      print(beans);
      var ls = beans.map(
        (json) => FriendRequest.fromJson(
          json,
        ),
      );
      print(ls);
      final friendRequests = List<FriendRequest>.from(ls);
      return friendRequests;
    });
  }

  Future<void> sendFriendRequest(String userId) async {
    User? currentUser = _auth.currentUser;
    String id = currentUser!.uid;

    var userInfo = await _firestore.collection('users').doc(id).get();
    var currentUserName =
        "${userInfo.get("first_name")} ${userInfo.get("last_name")}";

    await _firestore.collection('users').doc(userId).update({
      'friendRequests': FieldValue.arrayUnion([
        {
          'fromId': id,
          'timestamp': DateTime.now().toLocal().toIso8601String(),
          "fromUser": currentUserName
        }
      ])
    });

    await _firestore.collection('users').doc(id).update({
      'friends': FieldValue.arrayUnion([
        {'friendId': userId, 'status': 'pending'}
      ])
    });
  }

  Future<void> acceptFriendRequest(String friendId) async {
    User? currentUser = _auth.currentUser;
    String id = currentUser!.uid;

    await _changeCurrentUserFriendStatus(id, friendId);
    await _changeOtherUserFriendStatus(friendId, id);
    await _removeFriendRequest(id, friendId);
  }

  Future<void> _removeFriendRequest(String id, String friendId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    List<dynamic> friendRequests = userDoc['friendRequests'];

    final matchingRequests = friendRequests.where((request) {
      return request['fromId'] == friendId;
    }).toList();
    for (var request in matchingRequests) {
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'friendRequests': FieldValue.arrayRemove([request]),
      });
    }
  }

  Future<void> _changeOtherUserFriendStatus(String friendId, String id) async {
    await _firestore.collection('users').doc(friendId).update({
      'friends': FieldValue.arrayRemove([
        {'friendId': id, 'status': 'pending'}
      ])
    });
    await _firestore.collection('users').doc(friendId).update({
      'friends': FieldValue.arrayUnion([
        {'friendId': id, 'status': 'accepted'}
      ])
    });
  }

  Future<void> _changeCurrentUserFriendStatus(
      String id, String friendId) async {
    await _firestore.collection('users').doc(id).update({
      'friends': FieldValue.arrayUnion([
        {'friendId': friendId, 'status': 'accepted'}
      ])
    });
  }
}
