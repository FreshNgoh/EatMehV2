import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import 'package:eatmehv2/data/models/trainer/trainer_application.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TrainerApplicationService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  // Default constructor
  TrainerApplicationService()
    : _firestore = FirebaseFirestore.instance,
      _storage = FirebaseStorage.instance;

  // Test constructor (mock Firebase)
  TrainerApplicationService.test({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  CollectionReference<TrainerApplication> get _trainerApplicationsCollection {
    return _firestore
        .collection(FirebaseConstants.trainerApplicationsCollection)
        .withConverter<TrainerApplication>(
          fromFirestore:
              (snapshot, _) =>
                  TrainerApplication.fromMap(snapshot.id, snapshot.data()!),
          toFirestore: (application, _) => application.toMap(),
        );
  }

  // Add a new trainer application
  Future<void> submitApplication(TrainerApplication application) async {
    await _trainerApplicationsCollection.add(application);
  }

  // Fetch all applications
  Future<List<TrainerApplication>> getAllApplications() async {
    final querySnapshot = await _trainerApplicationsCollection.get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  // Get a specific user’s application by userId
  Future<TrainerApplication?> getApplicationByUser(String userId) async {
    final query =
        await _trainerApplicationsCollection
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.data();
  }

  // Update application status (approve/reject/pending)
  Future<void> updateStatus(
    String uid,
    String status, {
    String? rejectionReason,
  }) async {
    await _trainerApplicationsCollection.doc(uid).update({
      'status': status,
      'rejectionReason': rejectionReason,
      'updatedAt': Timestamp.now(),
    });
  }

  // Get user application status
  Future<String> getApplicationStatus(String userId) async {
    final application = await getApplicationByUser(userId);
    if (application == null) return 'none';
    return application.status.toLowerCase();
  }

  // Upload certificate
  Future<String> uploadCertificate(File file, String userId) async {
    final ref = _storage
        .ref()
        .child('trainer_certificates')
        .child('$userId-${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // Get existing trainer profile from application form
  Future<Map<String, dynamic>?> getTrainerApplicationData(String userId) async {
    final application = await getApplicationByUser(userId);
    if (application == null) return null;

    return {
      'certifications': application.certificateUrls,
      'yearsOfExperience': application.experience,
    };
  }

  // Stream of pending applications
  Stream<List<TrainerApplication>> getPendingApplications() {
    return _trainerApplicationsCollection
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
