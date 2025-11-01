import 'package:flutter/material.dart';
import '../../../data/dummy_data.dart';

class TraineesScreen extends StatelessWidget {
  const TraineesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get trainees from dummy data
    final trainees = DummyData.friends.take(2).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Trainees',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF191919),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${trainees.length} Active',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Trainees List
        ...trainees.map((trainee) => _buildTraineeCard(context, trainee)),
      ],
    );
  }

  Widget _buildTraineeCard(BuildContext context, dynamic trainee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(trainee.imageUrl ?? ''),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainee.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      trainee.email,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Row
          if (trainee.status != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('BMI', trainee.status!.bmi!.toStringAsFixed(1)),
                _buildStat(
                  'Current',
                  '${trainee.status!.currentWeight!.toStringAsFixed(0)} kg',
                ),
                _buildStat(
                  'Goal',
                  '${trainee.status!.goalWeight!.toStringAsFixed(0)} kg',
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Viewing ${trainee.username} progress')),
                    );
                  },
                  icon: const Icon(Icons.analytics, size: 18),
                  label: const Text('Progress'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF191919),
                    side: const BorderSide(color: Color(0xFF191919)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Creating plan for ${trainee.username}')),
                    );
                  },
                  icon: const Icon(Icons.restaurant_menu, size: 18),
                  label: const Text('Diet Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF191919),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
