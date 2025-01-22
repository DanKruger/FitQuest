class FriendRequest {
  final String fromId;
  final String fromUser;
  final String forUser;
  final DateTime timestamp;

  FriendRequest({
    required this.fromId,
    required this.fromUser,
    required this.forUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      "fromId": fromId,
      "fromUser": fromUser,
      "forUser": forUser,
      "timestamp": timestamp.toIso8601String(),
    };
  }

  static FriendRequest fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      fromId: json['fromId'],
      fromUser: json['fromUser'],
      forUser: json['forUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
