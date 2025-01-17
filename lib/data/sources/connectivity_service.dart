import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  ConnectivityResult _currentStatus = ConnectivityResult.none;

  ConnectivityResult get currentStatus => _currentStatus;

  // Stream for listeners
  final StreamController<ConnectivityResult> _connectivityStreamController =
      StreamController<ConnectivityResult>.broadcast();

  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityStreamController.stream;

  ConnectivityService() {
    _initialize();
  }

  void _initialize() {
    _subscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _currentStatus = result.last;
      _connectivityStreamController.add(result.last);
    });
  }

  void dispose() {
    _subscription.cancel();
    _connectivityStreamController.close();
  }
}
