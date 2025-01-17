import 'package:fitquest/data/models/excercise_model.dart';

class RunExerciseModel extends ExerciseModel {
  RunExerciseModel({
    super.id,
    required super.userId,
    super.type = "run",
    required super.date,
    required super.duration,
    required super.distance,
    required super.route,
  });
}
