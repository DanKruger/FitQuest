import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/data/models/user_model.dart';

abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
  Future<User?> signIn(UserModel payload);
  Future<User?> registerUser(UserModel payload);
  Future<void> signOut();
  Future<User?> signInWithGoogle();
}
