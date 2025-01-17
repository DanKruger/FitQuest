import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapViewmodel extends ChangeNotifier {
  List<LatLng> route = [];
  bool _isTracking = false;
  double _totalDistance = 0.0;
  late StreamSubscription<Position> _positionStream;
  LatLng? _currentPosition;
  bool _isLoading = true;
  double initialZoom = 19.0;
  int _secondsElapsed = 0;
  bool _isRunning = false;
  Timer? _timer;

  MapViewmodel() {
    enableLocationService();
    getLocationPermission();
  }

  LatLng? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  bool get isRunning => _isRunning;
  bool get isTracking => _isTracking;
  int get secondsElapsed => _secondsElapsed;
  double get totalDistance => _totalDistance;

  @override
  void dispose() {
    if (_isTracking) {
      _positionStream.cancel();
    }
    super.dispose();
  }

  Future<void> enableLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _currentPosition = LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever

        return;
      }
    }
  }

  void pauseTimer() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  Future<void> saveRunData() async {}

  Future<void> startRunTracking() async {
    _isTracking = true;
    notifyListeners();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(
      (Position position) {
        _currentPosition = LatLng(
          position.latitude,
          position.longitude,
        );
        if (route.isNotEmpty) {
          // Calculate distance from the last point
          LatLng lastPosition = route.last;
          double distance = Geolocator.distanceBetween(
            lastPosition.latitude,
            lastPosition.longitude,
            position.latitude,
            position.longitude,
          );
          _totalDistance += distance;
        }
        route.add(_currentPosition!);
        notifyListeners();
      },
    );
  }

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      notifyListeners();
    });
    notifyListeners();
  }

  void stopTimer() {
    _isRunning = false;
    _timer?.cancel();
    _secondsElapsed = 0;
    notifyListeners();
  }

  void stopTracking() {
    _isTracking = false;
    _positionStream.cancel();
    _totalDistance = 0;
    route.clear();
    getCurrentLocation();
    notifyListeners();
  }

  void toggleTracking(bool resumed) {
    // _isTracking = resumed;
    if (resumed) {
      _positionStream.resume();
    } else {
      _positionStream.pause();
    }
    notifyListeners();
  }
}
