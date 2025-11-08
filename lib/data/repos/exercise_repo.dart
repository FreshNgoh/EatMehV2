import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import '../models/exercise/exercise_model.dart';

class ExerciseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<ExerciseRecordModel> get _exerciseRecordsCollection {
    return _firestore
        .collection(FirebaseConstants.exerciseRecordsCollection)
        .withConverter<ExerciseRecordModel>(
          fromFirestore:
              (snapshot, _) =>
                  ExerciseRecordModel.fromMap(snapshot.id, snapshot.data()!),
          toFirestore: (exerciseRecord, _) => exerciseRecord.toMap(),
        );
  }

  /// Save an ExerciseRecordModel
  Future<void> saveExercise(ExerciseRecordModel exercise) async {
    try {
      await _exerciseRecordsCollection.doc(exercise.uid).set(exercise);
    } catch (e) {
      throw Exception('Failed to save exercise: $e');
    }
  }

  /// Fetch exercise records for a specific user and date
  Future<List<ExerciseRecordModel>> fetchExercises({
    required String userUid,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot =
          await _exerciseRecordsCollection
              .where('userUid', isEqualTo: userUid)
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch exercises: $e');
    }
  }
}
