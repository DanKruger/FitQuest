import 'package:fitquest/data/models/excercise_model.dart';
import 'package:fitquest/data/sources/data_store_service.dart';
import 'package:fitquest/domain/repo/abstract_repos/data_store_repository.dart';

class RemoteStoreRepository implements DataStoreRepository {
  final DataStoreService _service;

  RemoteStoreRepository({required DataStoreService remoteStorageService})
      : _service = remoteStorageService;

  @override
  Future<void> deleteAllExercises() {
    // TODO: implement deleteAllExercises
    throw UnimplementedError();
  }

  @override
  Future<void> deleteExerciseById(int id) async {
    await _service.deleteExerciseById(id);
  }

  @override
  Future<List<ExerciseModel?>?> getAllExercises(String userId) async {
    return await _service.getAllExercises(userId);
  }

  @override
  Future<ExerciseModel?> getExerciseById(int id) {
    // TODO: implement getExerciseById
    throw UnimplementedError();
  }

  @override
  Future<void> saveExercise(ExerciseModel payload) async {
    await _service.saveExercise(payload);
  }
}
