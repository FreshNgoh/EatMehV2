import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eatmehv2/data/models/trainer/trainer_application.dart';
import 'package:eatmehv2/data/services/trainer_application_service.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockStorage;
  late TrainerApplicationService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    service = TrainerApplicationService.test(
      firestore: fakeFirestore,
      storage: mockStorage,
    );
  });

  TrainerApplication buildApp({
    required String uid,
    required String userId,
    String status = 'pending',
    String experience = '1',
    List<String> certs = const [],
  }) {
    return TrainerApplication(
      uid: uid,
      userId: userId,
      name: "John",
      age: "20",
      specialization: "Fitness",
      experience: experience,
      contactNumber: "123",
      certificateUrls: certs,
      status: status,
      submittedAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
  }

  test('submitApplication adds a document', () async {
    final app = buildApp(uid: 'test-id-1', userId: 'user123');

    await service.submitApplication(app);

    final query =
        await fakeFirestore
            .collection(FirebaseConstants.trainerApplicationsCollection)
            .get();

    expect(query.docs.length, 1);
    expect(query.docs.first.data()['userId'], 'user123');
  });

  test('getApplicationByUser returns correct application', () async {
    final app = buildApp(uid: 'abc123', userId: 'u01', experience: '5');

    await fakeFirestore
        .collection(FirebaseConstants.trainerApplicationsCollection)
        .doc('abc123')
        .set(app.toMap());

    final result = await service.getApplicationByUser('u01');

    expect(result, isNotNull);
    expect(result!.experience, '5');
  });

  test('updateStatus updates status field', () async {
    final app = buildApp(uid: 'app990', userId: 'u02');

    await fakeFirestore
        .collection(FirebaseConstants.trainerApplicationsCollection)
        .doc('app990')
        .set(app.toMap());

    await service.updateStatus('app990', 'approved');

    final snap =
        await fakeFirestore
            .collection(FirebaseConstants.trainerApplicationsCollection)
            .doc('app990')
            .get();

    expect(snap['status'], 'approved');
  });

  test('uploadCertificate uploads file and returns URL', () async {
    final file = File('dummy.jpg');
    await file.writeAsString('test content');

    final url = await service.uploadCertificate(file, 'user123');

    expect(url.contains('user123'), true);

    await file.delete();
  });
}
