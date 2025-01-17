import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/data/models/user_model.dart';
import 'package:fitquest/data/sources/remote/firebase_auth_service.dart';
import 'package:fitquest/domain/repo/abstract_repos/auth_repository.dart';

class FirebaseAuthRepo implements AuthRepository {
  final FirebaseAuthService _service;
  FirebaseAuthRepo({required FirebaseAuthService service}) : _service = service;

  @override
  Future<User?> getCurrentUser() async {
    return _service.loggedInUser;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _service.isLoggedIn();
  }

  @override
  Future<User?> signIn(UserModel payload) async {
    return await _service.signIn(payload);
  }

  @override
  Future<void> signOut() async {
    return await _service.signOut();
  }

  @override
  Future<User?> registerUser(UserModel payload) async {
    return await _service.registerUser(payload);
  }

  @override
  Future<User?> signInWithGoogle() async {
    User? loggedInUser = await _service.signInWithGoogle();
    return loggedInUser;
  }
}
