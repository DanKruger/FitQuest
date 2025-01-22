import 'dart:convert';

import 'package:fitquest/data/models/friend_model.dart';
import 'package:fitquest/data/models/friend_request.dart';

class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  String? password;
  final List<FriendModel> friends;
  final List<FriendRequest> friendRequests;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    required this.friends,
    required this.friendRequests,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'email_address': email,
      'friends': jsonEncode(
        friends.map((friend) => friend.toJson()).toList(),
      ),
      'friendRequests': jsonEncode(
        friendRequests.map((req) => req.toString()).toList(),
      ),
    };
  }

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email_address'],
      friends: (json['friends'] as List<dynamic>)
          .map((friendjson) => FriendModel.fromJson(friendjson))
          .toList(),
      friendRequests: (json['friendRequests'] as List<dynamic>)
          .map((reqjson) => FriendRequest.fromJson(reqjson))
          .toList(),
    );
  }
}
