import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/models/user_exercise_model.dart';

const String USER_EXERCISE_COLLECTION_REF = "user_exercise";

class ExerciseService {
  final _fireStore = FirebaseFirestore.instance;
  late final CollectionReference<UserExerciseModel> _exerciseRef;

  ExerciseService() {
    _exerciseRef = _fireStore
        .collection(USER_EXERCISE_COLLECTION_REF)
        .withConverter<UserExerciseModel>(
          fromFirestore:
              (snapshot, _) => UserExerciseModel.fromMap(snapshot.data()!),
          toFirestore: (exercise, _) => exercise.toMap(),
        );
  }

  Future<void> saveExercise(UserExerciseModel exercise) async {
    try {
      await _exerciseRef.add(exercise);
    } catch (e, stackTrace) {
      print("🔥 Error saving exercise to Firestore: $e");
      print(stackTrace);
      // Optionally rethrow the error or handle it differently
      throw e;
    }
  }

  Stream<QuerySnapshot<UserExerciseModel>> getUserExercises(String uid) {
    return _exerciseRef
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<UserExerciseModel>> getCurrentMonthUserExercises(
    String uid, {
    DateTime? selectedMonth,
  }) {
    DateTime now = selectedMonth ?? DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    return _exerciseRef
        .where('uid', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
        .where('timestamp', isLessThan: endOfMonth)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot<UserExerciseModel>> getUserExercisesForDateRange(
    String uid,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _exerciseRef
        .where('uid', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .get();
  }
}
