// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/data/models/excercise_model.dart';
import 'package:fitquest/data/sources/local/caching_service.dart';
import 'package:fitquest/domain/repo/abstract_repos/auth_repository.dart';
import 'package:fitquest/domain/repo/abstract_repos/data_store_repository.dart';
import 'package:fitquest/domain/repo/local_store_repository.dart';
import 'package:fitquest/domain/repo/remote_store_repository.dart';
import 'package:fitquest/domain/usecases/exercise_usecases/update.dart';

class GetAllExercisesUsecase {
  final LocalStoreRepository _local;
  final RemoteStoreRepository _remote;
  final AuthRepository _authRepository;
  final CachingService _cachingService;

  GetAllExercisesUsecase(
      {required LocalStoreRepository local,
      required RemoteStoreRepository remote,
      required AuthRepository authRepository,
      required CachingService cachingService})
      : _local = local,
        _remote = remote,
        _authRepository = authRepository,
        _cachingService = cachingService;

  Future<List<ExerciseModel?>?> execute() async {
    User? user = await _authRepository.getCurrentUser();
    String id = user!.uid;
    try {
      HistoryTimestamp timestampData =
          await _cachingService.compareTimestampWithCurrentTime(id);
      var upToDateTimestamp = timestampData == HistoryTimestamp.newer;
      var outdatedTimestamp = timestampData == HistoryTimestamp.old;
      var noTimestamp = timestampData == HistoryTimestamp.none;

      updateCache(_cachingService, _local, _remote, id);

      List<ExerciseModel?> result = [];
      List<ExerciseModel?>? localData = upToDateTimestamp
          ? await _cachingService.getCachedHistory(id)
          : await _local.getAllExercises(id);

      List<ExerciseModel?>? remoteData = outdatedTimestamp || noTimestamp
          ? await _remote.getAllExercises(id)
          : await _local.getAllExercises(id);

      Set<ExerciseModel?> resultSet = Set.from(localData!)..addAll(remoteData!);
      result = resultSet.toList();

      outdatedTimestamp || noTimestamp
          ? await _cachingService.cacheHistory(id, result)
          : null;

      outdatedTimestamp || noTimestamp
          ? print('caching history')
          : print("updating exercises");
      return result;
    } on Exception catch (e) {
      // TODO
      await _local.getAllExercises(id);
      await _remote.getAllExercises(id);
    }
  }
}
