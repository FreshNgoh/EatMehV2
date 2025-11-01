import 'package:flutter/material.dart';
import '../../../../data/dummy_data.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/color_helper.dart';
import '../../../widgets/story/story_circles.dart';
import 'friend_requests_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    final friends = DummyData.friends;
    final stories = DummyData.stories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stories Section
        StoryCircles(stories: stories),

        const SizedBox(height: 16),

        // Friends Activity Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Friends' Activity",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FriendRequestsScreen(),
                    ),
                  );
                },
                child: const Text('Manage Friends'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Friends List
        Expanded(
          child: friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No friends yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FriendRequestsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Friends'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: friends.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final mealRecords = DummyData.mealRecords
                        .where((m) => m.userId == friend.uid)
                        .toList();
                    final latestMeal =
                        mealRecords.isNotEmpty ? mealRecords.first : null;

                    return _buildFriendCard(friend, latestMeal);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFriendCard(dynamic friend, dynamic latestMeal) {
    final calorieColor = latestMeal != null
        ? ColorHelper.getCalorieColor(latestMeal.calories)
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: () {
              _showFriendProfile(friend);
            },
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(friend.imageUrl ?? ''),
            ),
          ),
          const SizedBox(width: 16),

          // Friend Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      friend.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (latestMeal != null)
                      Text(
                        DateFormatter.getTimeAgo(
                          latestMeal.createdAt.toDate(),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (latestMeal != null)
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: calorieColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${latestMeal.calories}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: calorieColor,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'kcal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ColorHelper.getMealTypeColor(
                            latestMeal.mealType,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          latestMeal.mealType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: ColorHelper.getMealTypeColor(
                              latestMeal.mealType,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'No recent activity',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          // View Button
          if (latestMeal != null)
            IconButton(
              icon: Icon(
                Icons.visibility_outlined,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                _showMealDetail(latestMeal);
              },
            ),
        ],
      ),
    );
  }

  void _showFriendProfile(dynamic friend) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(friend.imageUrl ?? ''),
              ),
              const SizedBox(height: 16),
              Text(
                friend.username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                friend.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              if (friend.status != null) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      'BMI',
                      friend.status!.bmi.toStringAsFixed(1),
                    ),
                    _buildStatItem(
                      'Weight',
                      '${friend.status!.currentWeight.toStringAsFixed(1)} kg',
                    ),
                    _buildStatItem(
                      'Goal',
                      '${friend.status!.goalWeight.toStringAsFixed(1)} kg',
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showMealDetail(dynamic meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      meal.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Calories
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: ColorHelper.getCalorieColor(meal.calories),
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${meal.calories} kcal',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ColorHelper.getCalorieColor(meal.calories),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Food Items
                  const Text(
                    'Food Items:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...meal.foodItems.map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('• ${item.name} (${item.quantity})'),
                          Text(
                            '${item.calories} kcal',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  // Recommendation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            meal.recommendation,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
