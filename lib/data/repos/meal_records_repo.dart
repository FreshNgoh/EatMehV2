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

  Future<void> saveMealRecord(MealRecordModel mealRecord) async {
    await _mealRecordsCollection.doc(mealRecord.uid).set(mealRecord);
  }
}
