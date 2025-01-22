import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fitquest/data/models/excercise_model.dart';
import 'package:fitquest/data/sources/connectivity_service.dart';
import 'package:fitquest/domain/usecases/exercise_usecases/destroy_exercise_usecase.dart';
import 'package:fitquest/domain/usecases/exercise_usecases/get_all_exercises_usecase.dart';
import 'package:fitquest/domain/usecases/exercise_usecases/save_excercise_usecase.dart';
import 'package:flutter/material.dart';

class ExcerciseViewmodel extends ChangeNotifier {
  final SaveExcerciseUsecase _saveExcerciseUsecase;
  final GetAllExercisesUsecase _getAllExercisesUsecase;
  final DestroyExerciseUsecase _destroyExerciseUsecase;
  final ConnectivityService _connectivityService;

  bool get isConnected => _isConnected;
  bool _isConnected = false;

  ExcerciseViewmodel(
      {required SaveExcerciseUsecase saveExcerciseUsecase,
      required GetAllExercisesUsecase getAllExercisesUsecase,
      required DestroyExerciseUsecase destroyExerciseUsecase,
      required ConnectivityService connectivityService})
      : _saveExcerciseUsecase = saveExcerciseUsecase,
        _getAllExercisesUsecase = getAllExercisesUsecase,
        _destroyExerciseUsecase = destroyExerciseUsecase,
        _connectivityService = connectivityService {
    _listenToConnection();
  }

  void _listenToConnection() {
    _connectivityService.connectivityStream.listen((ConnectivityResult result) {
      _isConnected = result != ConnectivityResult.none;
      notifyListeners();
    });
  }

  Future<void> saveExcercise(ExerciseModel payload) async {
    await _saveExcerciseUsecase.execute(payload);
    await _getAllExercisesUsecase.execute();
  }

  Future<List<ExerciseModel?>?> getAllExercises() async {
    var data = await _getAllExercisesUsecase.execute();
    return data;
  }

  void sync() async {
    await _getAllExercisesUsecase.executeSync();
    notifyListeners();
  }

  Future<void> destroyExercise(int id) async {
    await _destroyExerciseUsecase.execute(id);
    notifyListeners();
  }
}
