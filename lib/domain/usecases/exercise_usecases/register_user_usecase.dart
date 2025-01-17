import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/data/models/user_model.dart';
import 'package:fitquest/data/sources/local/local_storage_service.dart';
import 'package:fitquest/data/sources/remote/firebase_auth_service.dart';
import 'package:fitquest/domain/repo/abstract_repos/auth_repository.dart';

class RegisterUserUsecase {
  final LocalStorageService _local;
  final FirebaseAuthService _remote;
  final AuthRepository _authRepository;

  RegisterUserUsecase(
      {required LocalStorageService local,
      required FirebaseAuthService remote,
      required AuthRepository authRepository})
      : _local = local,
        _remote = remote,
        _authRepository = authRepository;

  Future<User?> execute(UserModel payload) async {
    await _local.registerUser(payload);
    return await _remote.registerUser(payload);
  }

  Future<User?> executeGoogleAuth() async {
    try {
      // TODO check if internet connection then do this
      User? user = await _remote.signInWithGoogle();
      if (user != null) {
        List<String>? names = user.displayName?.split(" ");
        UserModel newPayload = UserModel(
          email: user.email!,
          firstName: names![0],
          lastName: names[1],
          password: "",
        );
        await _local.registerUser(newPayload);
      }
      return user;
    } on Exception catch (e) {
      throw Exception(
          'An error occurred when trying to register user with google $e');
    }
  }
}
