import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/data/models/trainer/trainer_application.dart';
import 'package:eatmehv2/data/services/trainer_service.dart';

class TrainerRepository {
  final TrainerService _trainerService;
  TrainerRepository(this._trainerService);

  Future<void> applyAsTrainer({
    required String userId,
    required String name,
    required String age,
    required String specialization,
    required String experience,
    required String contactNumber,
    required File certificateFile,
  }) async {
    final now = DateTime.now();

    final certUrl = await _trainerService.uploadCertificate(
      certificateFile,
      userId,
    );

    final application = TrainerApplication(
      uid:
          FirebaseFirestore.instance.collection('trainer_application').doc().id,
      userId: userId,
      name: name,
      age: age,
      specialization: specialization,
      experience: experience,
      contactNumber: contactNumber,
      certificateUrls: [certUrl],
      submittedAt: Timestamp.fromDate(now),
      updatedAt: Timestamp.fromDate(now),
    );

    await _trainerService.submitApplication(application);
  }

  Future<TrainerApplication?> fetchApplicationByTrainer(String userId) async {
    return await _trainerService.getApplicationByUser(userId);
  }

  Future<void> approveApplication(String uid) async {
    await _trainerService.updateStatus(uid, 'approved');
  }

  Future<void> rejectApplication(String uid, String reason) async {
    await _trainerService.updateStatus(
      uid,
      'rejected',
      rejectionReason: reason,
    );
  }

  Future<List<TrainerApplication>> fetchAllApplications() async {
    return await _trainerService.getAllApplications();
  }
}
