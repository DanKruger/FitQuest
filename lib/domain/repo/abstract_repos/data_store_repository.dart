import 'package:fitquest/data/models/excercise_model.dart';

abstract class DataStoreRepository {
  Future<void> saveExercise(ExerciseModel payload);
  Future<ExerciseModel?> getExerciseById(int id);
  Future<List<ExerciseModel?>?> getAllExercises(String userId);
  Future<void> deleteExerciseById(int id);
  Future<void> deleteAllExercises();
}
