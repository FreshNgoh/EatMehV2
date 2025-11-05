class FirebaseConstants {
  // Collection Names
  static const String usersCollection = 'users';
  static const String storiesCollection = 'stories';
  static const String mealRecordsCollection = 'meal_records';
  static const String exerciseRecordsCollection = 'exercise_records';
  static const String friendRequestsCollection = 'friend_requests';
  static const String consultationsCollection = 'consultations';
  static const String dietPlansCollection = 'diet_plans';
  static const String trainerApplicationsCollection = 'trainer_application';
  static const String notificationsCollection = 'notifications';
  static const String userAnalyticsCollection = 'user_analytics';

  // Storage Paths
  static const String userProfileImages = 'users/{userId}/profile_images';
  static const String storyMedia = 'users/{userId}/story_media';
  static const String mealImages = 'users/{userId}/meal_images';
  static const String trainerCertificates =
      'trainer_applications/{userId}/certificates';
  static const String trainerIdDocuments =
      'trainer_applications/{userId}/id_documents';
}
