import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/data/models/user_model.dart';
import 'package:fitquest/data/sources/connectivity_service.dart';
import 'package:fitquest/domain/repo/abstract_repos/auth_repository.dart';
import 'package:fitquest/domain/usecases/exercise_usecases/register_user_usecase.dart';
import 'package:fitquest/presentation/widgets/exceptions/no_internet_exception.dart';
import 'package:flutter/material.dart';

class AuthViewmodel extends ChangeNotifier {
  final AuthRepository _repository;
  final RegisterUserUsecase _registerUserUsecase;
  final ConnectivityService _connectivityService;
  bool loggedIn = false;
  bool loading = false;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  AuthViewmodel(
      {required AuthRepository repository,
      required RegisterUserUsecase registerUserUsecase,
      required ConnectivityService connectivityService})
      : _repository = repository,
        _registerUserUsecase = registerUserUsecase,
        _connectivityService = connectivityService {
    _listenToConnection();
  }

  void _listenToConnection() {
    _connectivityService.connectivityStream.listen((ConnectivityResult result) {
      _isConnected = result != ConnectivityResult.none;
      notifyListeners();
    });
  }

  Future<User?> get currentUser async => await _repository.getCurrentUser();
  Future<bool> get getLoginStatus async => await _repository.isLoggedIn();

  Future<void> registerUser(UserModel payload) async {
    try {
      if (!isConnected) {
        throw NoInternetException("You need to be connected to the internet to register for the first time");
      }
      loading = true;
      await _registerUserUsecase.execute(payload);
      await signIn(payload);
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void rebuild() {
    notifyListeners();
  }

  Future<void> signIn(UserModel payload) async {
    try {
      if (!isConnected) {
        throw NoInternetException("You need to be connected to the internet to sign in");
      }
      loading = true;
      notifyListeners();
      await _repository.signIn(payload);
      notifyListeners();
    } on Exception {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      if (!isConnected) {
        throw NoInternetException("You need to be connected to the internet to sign in");
      }
      loading = true;
      notifyListeners();
      await _registerUserUsecase.executeGoogleAuth();
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (await getLoginStatus) {
      await _repository.signOut();
      notifyListeners();
    }
  }

  Future<void> updateUserInformation() async {}
}
