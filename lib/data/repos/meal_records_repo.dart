import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/data/models/meal/meal_record_model.dart';
import '../../core/constants/firebase_constants.dart';

class MealRecordsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<MealRecordModel> get _mealRecordsCollection {
    return _firestore
        .collection(FirebaseConstants.mealRecordsCollection)
        .withConverter<MealRecordModel>(
          fromFirestore:
              (snapshot, _) =>
                  MealRecordModel.fromMap(snapshot.id, snapshot.data()!),
          toFirestore: (mealRecord, _) => mealRecord.toMap(),
        );
  }

  // Save a meal record
  Future<void> saveMealRecord(MealRecordModel mealRecord) async {
    await _mealRecordsCollection.doc(mealRecord.uid).set(mealRecord);
  }

  // Fetch all meal records for a specific user and date
  Future<List<MealRecordModel>> fetchMealRecordsByUserAndDate({
    required String userUid,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot =
        await _mealRecordsCollection
            .where('userUid', isEqualTo: userUid)
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
            .orderBy('createdAt', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
