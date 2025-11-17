import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';

class CalorieTrackerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch total calories taken and burnt for a specific time period
  Future<Map<String, double>> fetchCaloriesByPeriod({
    required String userUid,
    required DateTime date,
    required String period, // 'daily', 'weekly', 'monthly'
  }) async {
    try {
      DateTime startDate;
      DateTime endDate;

      if (period == 'daily') {
        startDate = DateTime(date.year, date.month, date.day);
        endDate = startDate.add(const Duration(days: 1));
      } else if (period == 'weekly') {
        // Get start of week (Monday)
        final weekday = date.weekday;
        startDate = DateTime(
          date.year,
          date.month,
          date.day,
        ).subtract(Duration(days: weekday - 1));
        endDate = startDate.add(const Duration(days: 7));
      } else {
        // monthly
        startDate = DateTime(date.year, date.month, 1);
        endDate = DateTime(date.year, date.month + 1, 1);
      }

      // Fetch meal records (calories taken)
      final mealSnapshot =
          await _firestore
              .collection(FirebaseConstants.mealRecordsCollection)
              .where('userUid', isEqualTo: userUid)
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where('createdAt', isLessThan: Timestamp.fromDate(endDate))
              .orderBy('createdAt', descending: true)
              .get();

      double totalCaloriesTaken = 0;
      for (var doc in mealSnapshot.docs) {
        totalCaloriesTaken += (doc.data()['calories'] as int).toDouble();
      }

      // Fetch exercise records (calories burnt)
      final exerciseSnapshot =
          await _firestore
              .collection(FirebaseConstants.exerciseRecordsCollection)
              .where('userUid', isEqualTo: userUid)
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where('createdAt', isLessThan: Timestamp.fromDate(endDate))
              .orderBy('createdAt', descending: true)
              .get();

      double totalCaloriesBurnt = 0;
      for (var doc in exerciseSnapshot.docs) {
        totalCaloriesBurnt += (doc.data()['caloriesBurnt'] as int).toDouble();
      }

      // Calculate averages based on period
      double avgTaken = totalCaloriesTaken;
      double avgBurnt = totalCaloriesBurnt;

      if (period == 'weekly') {
        avgTaken = totalCaloriesTaken / 7;
        avgBurnt = totalCaloriesBurnt / 7;
      } else if (period == 'monthly') {
        final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
        avgTaken = totalCaloriesTaken / daysInMonth;
        avgBurnt = totalCaloriesBurnt / daysInMonth;
      }

      return {'taken': avgTaken, 'burnt': avgBurnt};
    } catch (e) {
      throw Exception('Failed to fetch calorie data: $e');
    }
  }
}
