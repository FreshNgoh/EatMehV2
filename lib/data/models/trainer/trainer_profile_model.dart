class TrainerProfile {
  final List<String> certifications;
  final int yearsOfExperience;
  final double rating;
  final List<String> trainees;

  TrainerProfile({
    required this.certifications,
    required this.yearsOfExperience,
    this.rating = 0.0,
    this.trainees = const [],
  });

  factory TrainerProfile.fromMap(Map<String, dynamic> map) {
    return TrainerProfile(
      certifications: List<String>.from(map['certifications'] ?? []),
      yearsOfExperience: map['yearsOfExperience'] as int,
      rating: map['rating']?.toDouble() ?? 0.0,
      trainees: List<String>.from(map['trainees'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'certifications': certifications,
      'yearsOfExperience': yearsOfExperience,
      'rating': rating,
      'trainees': trainees,
    };
  }
}
