import 'package:fitquest/data/models/excercise_model.dart';
import 'package:fitquest/data/sources/local/local_storage_service.dart';
import 'package:fitquest/domain/repo/abstract_repos/data_store_repository.dart';

class LocalStoreRepository extends DataStoreRepository {
  final LocalStorageService _service;

  LocalStoreRepository({
    required LocalStorageService localStorageService,
  }) : _service = localStorageService;

  @override
  Future<void> deleteAllExercises() {
    // TODO: implement deleteAllExcercises
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
    // TODO: implement getExcerciseById
    throw UnimplementedError();
  }

  @override
  Future<void> saveExercise(ExerciseModel payload) async {
    await _service.saveExercise(payload);
  }
}
