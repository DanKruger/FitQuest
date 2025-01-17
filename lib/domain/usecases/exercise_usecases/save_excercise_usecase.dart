// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/data/models/excercise_model.dart';
import 'package:fitquest/data/sources/local/caching_service.dart';
import 'package:fitquest/domain/repo/abstract_repos/auth_repository.dart';
import 'package:fitquest/domain/repo/abstract_repos/data_store_repository.dart';
import 'package:fitquest/domain/repo/local_store_repository.dart';
import 'package:fitquest/domain/repo/remote_store_repository.dart';
import 'package:fitquest/domain/usecases/exercise_usecases/update.dart';

class SaveExcerciseUsecase {
  final LocalStoreRepository _localRepo;
  final RemoteStoreRepository _remoteRepo;
  final AuthRepository _authRepository;
  final CachingService _cachingService;

  SaveExcerciseUsecase(
      {required LocalStoreRepository localRepo,
      required RemoteStoreRepository remoteRepo,
      required AuthRepository authRepository,
      required CachingService cachingService})
      : _localRepo = localRepo,
        _remoteRepo = remoteRepo,
        _authRepository = authRepository,
        _cachingService = cachingService;

  Future<void> execute(ExerciseModel payload) async {
    User? user = await _authRepository.getCurrentUser();
    String id = user!.uid;
    payload.setId = Random().nextInt(999999999);
    await _localRepo.saveExercise(payload); // Save excercise to local
    updateCache(_cachingService, _localRepo, _remoteRepo, id);
  }
}
