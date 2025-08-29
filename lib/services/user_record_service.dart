import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/models/user_records_model.dart';

const String USER_RECORD_COLLECTION_REF = "users";

class UserRecordService {
  final _fireStore = FirebaseFirestore.instance;

  late final CollectionReference<UserRecordsModel>
  _userRecordRef; // Specify the generic type here

  UserRecordService() {
    _userRecordRef = _fireStore
        .collection(USER_RECORD_COLLECTION_REF)
        .withConverter<UserRecordsModel>(
          // Get snapshot from firebase, returning them as user instance
          fromFirestore:
              (snapshots, _) => UserRecordsModel.fromMap(snapshots.data()!),
          toFirestore: (user, _) => user.toMap(),
        );
  }

  Stream<QuerySnapshot> getUserRecords() {
    return _userRecordRef.snapshots();
  }

  Stream<QuerySnapshot<UserRecordsModel>> getCurrentMonthUserRecords(
    String userUid, {
    DateTime? selectedMonth, // Added the optional selectedMonth parameter
  }) {
    DateTime now = selectedMonth ?? DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    return _userRecordRef
        .where('userUid', isEqualTo: userUid)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfMonth))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Modified to return a Query
  Query<UserRecordsModel> getFriendMonthUserRecordsQuery(
    String userUid, {
    DateTime? selectedMonth,
  }) {
    DateTime now = selectedMonth ?? DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    return _userRecordRef
        .where('userUid', isEqualTo: userUid)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfMonth))
        .orderBy('createdAt', descending: true);
  }

  Future<void> addUserRecord(UserRecordsModel userRecord) async {
    try {
      await _userRecordRef.add(userRecord);
    } catch (e) {
      log("🔥 Error writing user record to Firestore: $e");
    }
  }

  Future<QuerySnapshot<UserRecordsModel>> getUserRecordsForDateRange(
    String uid,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _userRecordRef
        .where('userUid', isEqualTo: uid)
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThanOrEqualTo: endDate)
        .get();
  }
}
