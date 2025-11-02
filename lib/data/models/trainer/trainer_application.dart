import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerApplication {
  final String uid;
  final String userId;
  final List<String> certificateUrls;
  final String experience;
  final String status; // "pending", "approved", "rejected"
  final String? rejectionReason;
  final Timestamp submittedAt;
  final Timestamp updatedAt;

  TrainerApplication({
    required this.uid,
    required this.userId,
    required this.certificateUrls,
    required this.experience,
    this.status = 'pending',
    this.rejectionReason,
    required this.submittedAt,
    required this.updatedAt,
  });

  factory TrainerApplication.fromMap(String uid, Map<String, dynamic> map) {
    return TrainerApplication(
      uid: uid,
      userId: map['userId'],
      certificateUrls: List<String>.from(map['certificateUrls'] ?? []),
      experience: map['experience'],
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
      submittedAt: map['submittedAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'certificateUrls': certificateUrls,
      'experience': experience,
      'status': status,
      'rejectionReason': rejectionReason,
      'submittedAt': submittedAt,
      'updatedAt': updatedAt,
    };
  }
}
