import 'package:eatmehv2/data/models/trainer/trainer_profile_model.dart';
import 'package:flutter/material.dart';

class ProfileConsultTab extends StatefulWidget {
  final TrainerProfile trainerProfile;
  final String trainerUid;

  const ProfileConsultTab({
    super.key,
    required this.trainerProfile,
    required this.trainerUid,
  });

  @override
  State<ProfileConsultTab> createState() => _ProfileConsultTabState();
}

class _ProfileConsultTabState extends State<ProfileConsultTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          _buildStatCard(
            icon: Icons.workspace_premium,
            label: 'Certifications',
            value: widget.trainerProfile.certifications.length.toString(),
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            icon: Icons.work_outline,
            label: 'Experience',
            value: '${widget.trainerProfile.yearsOfExperience ?? 0} years',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            icon: Icons.star,
            label: 'Rating',
            value: widget.trainerProfile.rating.toStringAsFixed(1),
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            icon: Icons.people,
            label: 'Trainees',
            value: widget.trainerProfile.trainees.length.toString(),
            color: Colors.green,
          ),
          const SizedBox(height: 24),

          // Certifications Gallery
          if (widget.trainerProfile.certifications.isNotEmpty) ...[
            const Text(
              'Certifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: widget.trainerProfile.certifications.length,
              itemBuilder: (context, index) {
                final cert = widget.trainerProfile.certifications[index];
                return GestureDetector(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        cert.startsWith('http')
                            ? Image.network(
                              cert,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey[400],
                                    size: 32,
                                  ),
                                );
                              },
                            )
                            : Center(
                              child: Icon(
                                Icons.workspace_premium,
                                color: Colors.grey[400],
                                size: 32,
                              ),
                            ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 26),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
