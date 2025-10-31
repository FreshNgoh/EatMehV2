// lib/data/dummy_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/exercise/exercise_model.dart';
import 'models/meal/meal_record_model.dart';
import 'models/meal/nutrition_info_model.dart';
import 'models/story/story_model.dart';
import 'models/trainer/trainer_profile_model.dart';
import 'models/user/user_model.dart';
import 'models/user/user_settings_model.dart';
import 'models/user/user_status_model.dart';

class DummyData {
  // Current User
  static UserModel get currentUser => UserModel(
        uid: 'user1',
        username: 'JohnDoe',
        email: 'john@example.com',
        role: 'user',
        imageUrl: 'https://i.pravatar.cc/150?img=12',
        bio: 'Fitness enthusiast | Healthy eating lover',
        friends: ['user2', 'user3', 'user4'],
        createdAt: Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 180))),
        updatedAt: Timestamp.now(),
        status: UserStatus(
          currentWeight: 75.5,
          goalWeight: 70.0,
          height: 175.0,
          bmi: 24.7,
          statusEmoji: '😊',
          lastStatusUpdate: Timestamp.now(),
        ),
        settings: UserSettings(
          language: 'en',
          darkMode: false,
          notifications: true,
          showOnboarding: false,
        ),
      );

  // Trainer User
  static UserModel get trainerUser => UserModel(
        uid: 'trainer1',
        username: 'FitnessCoach',
        email: 'coach@example.com',
        role: 'trainer',
        imageUrl: 'https://i.pravatar.cc/150?img=33',
        bio: 'Certified Personal Trainer | Nutrition Expert',
        friends: ['user1', 'user5', 'user6'],
        createdAt: Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 365))),
        updatedAt: Timestamp.now(),
        trainerProfile: TrainerProfile(
          certifications: ['CPT', 'Nutrition Specialist', 'Sports Medicine'],
          specialization: 'Weight Loss & Muscle Gain',
          yearsOfExperience: 5,
          rating: 4.8,
          trainees: ['user1', 'user5', 'user6'],
        ),
      );

  // Friends List
  static List<UserModel> get friends => [
        UserModel(
          uid: 'user2',
          username: 'AliceSmith',
          email: 'alice@example.com',
          role: 'user',
          imageUrl: 'https://i.pravatar.cc/150?img=5',
          friends: ['user1', 'user3'],
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 120))),
          updatedAt: Timestamp.now(),
          status: UserStatus(
            currentWeight: 62.0,
            goalWeight: 58.0,
            height: 165.0,
            bmi: 22.8,
            statusEmoji: '😊',
            lastStatusUpdate: Timestamp.now(),
          ),
        ),
        UserModel(
          uid: 'user3',
          username: 'BobJohnson',
          email: 'bob@example.com',
          role: 'user',
          imageUrl: 'https://i.pravatar.cc/150?img=8',
          friends: ['user1', 'user2'],
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 90))),
          updatedAt: Timestamp.now(),
          status: UserStatus(
            currentWeight: 85.0,
            goalWeight: 75.0,
            height: 180.0,
            bmi: 26.2,
            statusEmoji: '😅',
            lastStatusUpdate: Timestamp.now(),
          ),
        ),
        UserModel(
          uid: 'user4',
          username: 'CarolWilson',
          email: 'carol@example.com',
          role: 'user',
          imageUrl: 'https://i.pravatar.cc/150?img=9',
          friends: ['user1'],
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 60))),
          updatedAt: Timestamp.now(),
          status: UserStatus(
            currentWeight: 58.0,
            goalWeight: 60.0,
            height: 160.0,
            bmi: 22.7,
            statusEmoji: '😊',
            lastStatusUpdate: Timestamp.now(),
          ),
        ),
      ];

  // Stories
  static List<StoryModel> get stories => [
        StoryModel(
          id: 'story1',
          userId: 'user2',
          username: 'AliceSmith',
          userImageUrl: 'https://i.pravatar.cc/150?img=5',
          type: 'meal',
          mediaUrl:
              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
          thumbnail:
              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200',
          caption: 'Healthy breakfast to start the day!',
          mealData: MealData(
            calories: 450,
            mealType: 'breakfast',
            foodItems: ['Oatmeal', 'Banana', 'Honey', 'Almonds'],
            recommendation:
                'Great balanced breakfast with complex carbs and protein!',
          ),
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(hours: 2))),
          expiresAt:
              Timestamp.fromDate(DateTime.now().add(const Duration(hours: 22))),
          views: ['user1'],
          viewCount: 1,
        ),
        StoryModel(
          id: 'story2',
          userId: 'user3',
          username: 'BobJohnson',
          userImageUrl: 'https://i.pravatar.cc/150?img=8',
          type: 'meal',
          mediaUrl:
              'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500',
          thumbnail:
              'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200',
          caption: 'Pizza night! 🍕',
          mealData: MealData(
            calories: 850,
            mealType: 'dinner',
            foodItems: ['Pizza', 'Cheese', 'Pepperoni'],
            recommendation:
                'High in calories. Consider a lighter meal tomorrow.',
          ),
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(hours: 5))),
          expiresAt:
              Timestamp.fromDate(DateTime.now().add(const Duration(hours: 19))),
          views: [],
          viewCount: 0,
        ),
        StoryModel(
          id: 'story3',
          userId: 'user4',
          username: 'CarolWilson',
          userImageUrl: 'https://i.pravatar.cc/150?img=9',
          type: 'meal',
          mediaUrl:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
          thumbnail:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200',
          caption: 'Fresh salad for lunch',
          mealData: MealData(
            calories: 320,
            mealType: 'lunch',
            foodItems: ['Mixed Greens', 'Tomatoes', 'Cucumber', 'Olive Oil'],
            recommendation:
                'Light and nutritious! Perfect for a healthy lunch.',
          ),
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(hours: 8))),
          expiresAt:
              Timestamp.fromDate(DateTime.now().add(const Duration(hours: 16))),
          views: ['user1', 'user2'],
          viewCount: 2,
        ),
      ];

  // Meal Records
  static List<MealRecordModel> get mealRecords => [
        MealRecordModel(
          id: 'meal1',
          userId: 'user1',
          imageUrl:
              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
          thumbnailUrl:
              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200',
          calories: 450,
          mealType: 'breakfast',
          foodItems: [
            FoodItem(name: 'Oatmeal', quantity: '1 cup', calories: 150),
            FoodItem(name: 'Banana', quantity: '1 medium', calories: 105),
            FoodItem(name: 'Honey', quantity: '1 tbsp', calories: 64),
            FoodItem(name: 'Almonds', quantity: '1 oz', calories: 131),
          ],
          nutritionInfo: NutritionInfo(
            protein: 12.5,
            carbs: 78.0,
            fat: 8.5,
            fiber: 10.0,
          ),
          recommendation:
              'Great balanced breakfast with complex carbs and protein!',
          isPublic: true,
          storyId: 'story1',
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(hours: 2))),
          updatedAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(hours: 2))),
        ),
        MealRecordModel(
          id: 'meal2',
          userId: 'user1',
          imageUrl:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
          thumbnailUrl:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200',
          calories: 380,
          mealType: 'lunch',
          foodItems: [
            FoodItem(name: 'Grilled Chicken', quantity: '150g', calories: 165),
            FoodItem(name: 'Mixed Greens', quantity: '2 cups', calories: 18),
            FoodItem(name: 'Cherry Tomatoes', quantity: '1 cup', calories: 27),
            FoodItem(
                name: 'Olive Oil Dressing', quantity: '2 tbsp', calories: 170),
          ],
          nutritionInfo: NutritionInfo(
            protein: 28.0,
            carbs: 12.0,
            fat: 22.0,
            fiber: 4.0,
          ),
          recommendation:
              'Perfect protein-rich lunch. Good balance of nutrients!',
          isPublic: false,
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1, hours: 6))),
          updatedAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1, hours: 6))),
        ),
        MealRecordModel(
          id: 'meal3',
          userId: 'user1',
          imageUrl:
              'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500',
          thumbnailUrl:
              'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200',
          calories: 720,
          mealType: 'dinner',
          foodItems: [
            FoodItem(name: 'Grilled Salmon', quantity: '200g', calories: 412),
            FoodItem(name: 'Brown Rice', quantity: '1 cup', calories: 218),
            FoodItem(name: 'Steamed Broccoli', quantity: '1 cup', calories: 55),
            FoodItem(
                name: 'Lemon Butter Sauce', quantity: '2 tbsp', calories: 35),
          ],
          nutritionInfo: NutritionInfo(
            protein: 45.0,
            carbs: 52.0,
            fat: 18.0,
            fiber: 6.0,
          ),
          recommendation:
              'Excellent dinner choice! Rich in omega-3 and protein.',
          isPublic: false,
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 2, hours: 19))),
          updatedAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 2, hours: 19))),
        ),
      ];

  // Exercise Records
  static List<ExerciseRecordModel> get exerciseRecords => [
        ExerciseRecordModel(
          id: 'exercise1',
          userId: 'user1',
          exerciseName: 'Morning Run',
          exerciseType: 'running',
          duration: 30,
          caloriesBurnt: 300,
          intensity: 'medium',
          notes: 'Felt great! 5km run',
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(hours: 10))),
        ),
        ExerciseRecordModel(
          id: 'exercise2',
          userId: 'user1',
          exerciseName: 'Gym Session',
          exerciseType: 'weightlifting',
          duration: 60,
          caloriesBurnt: 350,
          intensity: 'high',
          notes: 'Upper body workout',
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1, hours: 16))),
        ),
        ExerciseRecordModel(
          id: 'exercise3',
          userId: 'user1',
          exerciseName: 'Evening Yoga',
          exerciseType: 'yoga',
          duration: 45,
          caloriesBurnt: 180,
          intensity: 'low',
          notes: 'Relaxing session',
          createdAt: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 2, hours: 20))),
        ),
      ];

  // Trainer Applicants
  static List<Map<String, dynamic>> get trainerApplications => [
        {
          'id': 'app1',
          'userId': 'user5',
          'username': 'MikeFitness',
          'email': 'mike@example.com',
          'certifications': ['NASM-CPT', 'Precision Nutrition L1'],
          'specialization': 'Strength Training & Nutrition',
          'yearsOfExperience': 3,
          'status': 'pending',
          'submittedAt': DateTime.now().subtract(const Duration(days: 2)),
          'imageUrl': 'https://i.pravatar.cc/150?img=15',
        },
        {
          'id': 'app2',
          'userId': 'user6',
          'email': 'sarah@example.com',
          'username': 'SarahYoga',
          'certifications': ['RYT-200', 'Pilates Certification'],
          'specialization': 'Yoga & Flexibility Training',
          'yearsOfExperience': 4,
          'status': 'pending',
          'submittedAt': DateTime.now().subtract(const Duration(days: 5)),
          'imageUrl': 'https://i.pravatar.cc/150?img=20',
        },
      ];

  // Admin Users List
  static List<Map<String, dynamic>> get adminUsersList => [
        {
          'uid': 'user1',
          'username': 'JohnDoe',
          'email': 'john@example.com',
          'status': 'Active',
          'role': 'user',
          'joinDate': DateTime.now().subtract(const Duration(days: 180)),
        },
        {
          'uid': 'user2',
          'username': 'AliceSmith',
          'email': 'alice@example.com',
          'status': 'Active',
          'role': 'user',
          'joinDate': DateTime.now().subtract(const Duration(days: 120)),
        },
        {
          'uid': 'user3',
          'username': 'BobJohnson',
          'email': 'bob@example.com',
          'status': 'Suspended',
          'role': 'user',
          'joinDate': DateTime.now().subtract(const Duration(days: 90)),
        },
        {
          'uid': 'trainer1',
          'username': 'FitnessCoach',
          'email': 'coach@example.com',
          'status': 'Active',
          'role': 'trainer',
          'joinDate': DateTime.now().subtract(const Duration(days: 365)),
        },
      ];

  // Analytics Data
  static Map<String, dynamic> get analyticsData => {
        'totalUsers': 1234,
        'activeUsers': 892,
        'totalTrainers': 45,
        'pendingApplications': 12,
        'totalMeals': 15678,
        'totalExercises': 8945,
        'userGrowth': [
          {'month': 'Jan', 'users': 800},
          {'month': 'Feb', 'users': 850},
          {'month': 'Mar', 'users': 920},
          {'month': 'Apr', 'users': 1000},
          {'month': 'May', 'users': 1100},
          {'month': 'Jun', 'users': 1234},
        ],
      };

  // Recent Activities for Admin
  static List<Map<String, dynamic>> get recentActivities => [
        {
          'type': 'user_registered',
          'title': 'New user registered',
          'subtitle': 'john.doe@email.com',
          'time': DateTime.now().subtract(const Duration(minutes: 2)),
          'icon': 'person_add',
          'color': 'green',
        },
        {
          'type': 'trainer_applied',
          'title': 'Trainer application submitted',
          'subtitle': 'Jane Smith',
          'time': DateTime.now().subtract(const Duration(minutes: 15)),
          'icon': 'assignment',
          'color': 'blue',
        },
        {
          'type': 'content_reported',
          'title': 'User reported content',
          'subtitle': 'Inappropriate post',
          'time': DateTime.now().subtract(const Duration(hours: 1)),
          'icon': 'flag',
          'color': 'red',
        },
        {
          'type': 'milestone',
          'title': 'User reached goal',
          'subtitle': 'AliceSmith achieved weight goal',
          'time': DateTime.now().subtract(const Duration(hours: 3)),
          'icon': 'celebration',
          'color': 'orange',
        },
      ];

  // Notification List
  static List<Map<String, dynamic>> get notifications => [
        {
          'id': 'notif1',
          'type': 'friend_request',
          'title': 'New Friend Request',
          'body': 'Sarah wants to be your friend',
          'read': false,
          'createdAt': DateTime.now().subtract(const Duration(minutes: 30)),
        },
        {
          'id': 'notif2',
          'type': 'story_view',
          'title': 'Story View',
          'body': 'Alice viewed your story',
          'read': false,
          'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          'id': 'notif3',
          'type': 'meal_reminder',
          'title': 'Meal Reminder',
          'body': "Don't forget to log your lunch!",
          'read': true,
          'createdAt': DateTime.now().subtract(const Duration(hours: 4)),
        },
      ];
}
