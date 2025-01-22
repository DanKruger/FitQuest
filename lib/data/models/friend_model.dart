class FriendModel {
  final String friendId;
  final String status;
  final String firstName;
  final String lastName;

  FriendModel({
    required this.friendId,
    required this.status,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'status': status,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  static FriendModel fromJson(Map<String, dynamic> json) {
    return FriendModel(
      friendId: json['friendId'],
      status: json['status'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}
