import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal/meal_record_model.dart';
import '../../core/constants/firebase_constants.dart';

class MealRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _mealsCollection {
    return _firestore.collection(FirebaseConstants.mealRecordsCollection);
  }

  Future<String> createMealRecord(MealRecordModel meal) async {
    final doc = await _mealsCollection.add(meal.toMap());
    return doc.id;
  }

  Stream<List<MealRecordModel>> getUserMeals(String userId) {
    return _mealsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MealRecordModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  Future<List<MealRecordModel>> getMealsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot =
        await _mealsCollection
            .where('userId', isEqualTo: userId)
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .where(
              'createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate),
            )
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      return MealRecordModel.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();
  }

  Future<void> deleteMealRecord(String mealId) async {
    await _mealsCollection.doc(mealId).delete();
  }
}
