// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/data/sources/local/caching_service.dart';
import 'package:fitquest/domain/repo/abstract_repos/auth_repository.dart';
import 'package:fitquest/domain/repo/local_store_repository.dart';
import 'package:fitquest/domain/repo/remote_store_repository.dart';
import 'package:fitquest/domain/usecases/exercise_usecases/update.dart';

class DestroyExerciseUsecase {
  final RemoteStoreRepository _remote;
  final LocalStoreRepository _local;
  final AuthRepository _authRepository;
  final CachingService _cachingService;

  DestroyExerciseUsecase(
      {required RemoteStoreRepository remote,
      required LocalStoreRepository local,
      required AuthRepository authRepository,
      required CachingService cachingService})
      : _remote = remote,
        _local = local,
        _authRepository = authRepository,
        _cachingService = cachingService;

  Future<void> execute(int id) async {
    User? user = await _authRepository.getCurrentUser();
    String userId = user!.uid;
    await _local.deleteExerciseById(id); // Delete from local
    updateCache(_cachingService, _local, _remote, userId);
  }
}
