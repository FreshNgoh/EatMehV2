import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerApplication {
  final String uid;
  final String userId;
  final String name;
  final String age;
  final String specialization;
  final List<String> certificateUrls;
  final String experience;
  final String contactNumber;
  final String status; // "pending", "approved", "rejected"
  final String? rejectionReason;
  final Timestamp submittedAt;
  final Timestamp updatedAt;

  TrainerApplication({
    required this.uid,
    required this.userId,
    required this.name,
    required this.age,
    required this.specialization,
    required this.certificateUrls,
    required this.experience,
    required this.contactNumber,
    this.status = 'pending',
    this.rejectionReason,
    required this.submittedAt,
    required this.updatedAt,
  });

  factory TrainerApplication.fromMap(String id, Map<String, dynamic> map) {
    return TrainerApplication(
      uid: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? '',
      specialization: map['specialization'] ?? '',
      experience: map['experience'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      certificateUrls: List<String>.from(map['certificateUrls'] ?? []),
      status: map['status'] ?? 'pending',
      submittedAt: map['submittedAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
      rejectionReason: map['rejectionReason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'age': age,
      'specialization': specialization,
      'certificateUrls': certificateUrls,
      'experience': experience,
      'contactNumber': contactNumber,
      'status': status,
      'rejectionReason': rejectionReason,
      'submittedAt': submittedAt,
      'updatedAt': updatedAt,
    };
  }
}
