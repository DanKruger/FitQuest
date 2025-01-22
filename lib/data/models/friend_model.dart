class FriendModel {
  final String friendId;
  final String status;

  FriendModel({
    required this.friendId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'status': status,
    };
  }

  static FriendModel fromJson(Map<String, dynamic> json) {
    return FriendModel(
      friendId: json['friendId'],
      status: json['status'],
    );
  }
}
