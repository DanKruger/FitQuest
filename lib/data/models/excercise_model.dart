import 'dart:convert';

import 'package:latlong2/latlong.dart';

class ExerciseModel {
  int? id;
  final String userId;
  final String type; // e.g., "Run"
  final DateTime date;
  final int duration; // In seconds
  final double distance; // In meters
  final List<LatLng> route;

  set setId(newId) => id = newId;

  ExerciseModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.date,
    required this.duration,
    required this.distance,
    required this.route,
  });

  static ExerciseModel fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as int?,
      userId: json['userId'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: json['duration'] as int,
      distance: json['distance'] as double,
      route: (jsonDecode(json['route']) as List<dynamic>)
          .map((point) => LatLng(point['latitude'], point['longitude']))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExerciseModel) return false;
    return other.id == id &&
        other.userId == userId &&
        other.type == type &&
        other.date == date &&
        other.duration == duration &&
        other.distance == distance;
  }

  @override
  int get hashCode => Object.hash(id, userId, type, date, duration, distance);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'date': date.toIso8601String(),
      'duration': duration,
      'distance': distance,
      'route': jsonEncode(route
          .map((latLng) => {
                'latitude': latLng.latitude,
                'longitude': latLng.longitude,
              })
          .toList()),
    };
  }
}
