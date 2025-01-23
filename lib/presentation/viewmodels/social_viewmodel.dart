import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fitquest/data/models/friend_model.dart';
import 'package:fitquest/data/models/friend_request.dart';
import 'package:fitquest/data/sources/connectivity_service.dart';
import 'package:fitquest/domain/usecases/social_usecases/accept_friend_request_usecase.dart';
import 'package:fitquest/domain/usecases/social_usecases/add_friend_usecase.dart';
import 'package:fitquest/domain/usecases/social_usecases/get_all_friends_usecase.dart';
import 'package:fitquest/domain/usecases/social_usecases/remove_friends_usecase.dart';
import 'package:fitquest/domain/usecases/social_usecases/search_friends_usecase.dart';
import 'package:flutter/material.dart';

class SocialViewmodel extends ChangeNotifier {
  final SearchFriendsUsecase _searchFriendsUsecase;
  final AddFriendUsecase _addFriendUsecase;
  final AcceptFriendRequestUsecase _acceptFriendRequestUsecase;
  final GetAllFriendsUsecase _getAllFriendsUsecase;
  final RemoveFriendsUsecase _removeFriendsUsecase;
  final ConnectivityService _connectivityService;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void _listenToConnection() {
    _isConnected = true;
    _connectivityService.connectivityStream.listen((ConnectivityResult result) {
      _isConnected = result != ConnectivityResult.none;
      notifyListeners();
    });
  }

  bool _isSearching = false;
  Stream<List<FriendRequest>>? _friendRequestStream;

  SocialViewmodel(
      {required SearchFriendsUsecase searchFriendsUsecase,
      required AddFriendUsecase addFriendUsecase,
      required AcceptFriendRequestUsecase acceptFriendRequestUsecase,
      required GetAllFriendsUsecase getAllFriendsUsecase,
      required RemoveFriendsUsecase removeFriendsUsecase,
      required ConnectivityService connectivityService})
      : _searchFriendsUsecase = searchFriendsUsecase,
        _addFriendUsecase = addFriendUsecase,
        _acceptFriendRequestUsecase = acceptFriendRequestUsecase,
        _getAllFriendsUsecase = getAllFriendsUsecase,
        _removeFriendsUsecase = removeFriendsUsecase,
        _connectivityService = connectivityService {
    _listenToConnection();
  }

  Stream<List<FriendRequest>>? get friendRequestStream => _friendRequestStream;

  bool get isSearching => _isSearching;

  set isSearching(searching) => _isSearching = searching;
  Stream<List<FriendRequest>> friendRequestsStream() {
    if (friendRequestStream == null) {
      _friendRequestStream = _addFriendUsecase.listenToFriendRequests();
      return friendRequestStream!;
    }
    return friendRequestStream!;
  }

  Future<List<Map<String, dynamic>>?> searchUsers(String query) async {
    List<Map<String, dynamic>> data = [];
    try {
      _isSearching = true;
      notifyListeners();
      data = await _searchFriendsUsecase.execute(query);
      _isSearching = false;
      notifyListeners();
    } on Exception catch (e) {
      print('an error occurred when searching for users $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
    return data;
  }

  Future<void> acceptFriendRequest(String friendId) async {
    try {
      _acceptFriendRequestUsecase.execute(friendId);
    } catch (e) {
      print('an error occurred when trying to accept a friend request $e');
    }
  }

  Future<void> sendFriendRequest(String userId) async {
    try {
      await _addFriendUsecase.execute(userId);
      notifyListeners();
    } catch (e) {
      print('an error occurred when trying to send a friend request $e');
    }
  }

  Future<void> removeFriend(String friendId) async {
    await _removeFriendsUsecase.execute(friendId);
    notifyListeners();
  }

  List<FriendModel>? friends;

  Future<List<FriendModel>> getFriends() async {
    // TODO rewrite more good
    if (friends != null) {
      return Future.value(friends);
    } else {
      friends = await _getAllFriendsUsecase.execute();
      return Future.value(friends);
    }
  }

  void refreshFriends() async {
    var remote = await _getAllFriendsUsecase.execute();
    if (remote.length != friends?.length) {
      friends = remote;
    }
    notifyListeners();
  }
}
