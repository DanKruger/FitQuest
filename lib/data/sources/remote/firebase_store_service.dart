import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/data/models/excercise_model.dart';
import 'package:fitquest/data/sources/data_store_service.dart';

class FirebaseStoreService extends DataStoreService {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _collectionReference;

  FirebaseStoreService(FirebaseAuth auth) {
    _firestore = FirebaseFirestore.instance;
    _auth = auth;
    _collectionReference = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('exercises');
  }

  @override
  Future<void> deleteAllExercises() {
    // TODO: implement deleteAllExcercises
    throw UnimplementedError();
  }

  @override
  Future<void> deleteExerciseById(int id) async {
    try {
      await _collectionReference.doc(id.toString()).delete();
    } on Exception catch (e) {
      print('an error occurred when trying to delete an exercise $id\n$e');
    }
  }

  @override
  Future<List<ExerciseModel?>> getAllExercises(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _collectionReference.get();
      print(_collectionReference.path);
      List<ExerciseModel> exercises = [];
      for (var exercise in snapshot.docs) {
        exercises.add(ExerciseModel.fromJson(exercise.data()));
      }
      print(snapshot.docChanges);
      return exercises;
    } on Exception catch (e) {
      throw Exception(
          'An error occurred when trying to retrieve all exercises for user $userId from the network $e');
    }
  }

  @override
  Future<ExerciseModel?> getExerciseById(int id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> exercise =
          await _collectionReference.doc(id.toString()).get();
      if (!exercise.exists) return null;

      return ExerciseModel.fromJson(exercise.data()!);
    } on Exception catch (e) {
      throw Exception(
          'An error occurred when trying to retrieve an exercise from the network $e');
    }
  }

  @override
  Future<void> saveExercise(ExerciseModel payload) async {
    await _collectionReference.doc(payload.id.toString()).set(payload.toJson());
  }
}
