import 'package:eatmehv2/core/constants/app_constants.dart';
import 'package:eatmehv2/core/theme/app_colors.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  DateTime selectedDate = DateTime.now();

  void _previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Date Navigation
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28),
                    onPressed: _previousDay,
                  ),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Row(
                      children: [
                        Text(
                          DateFormat('EEE, MMM d').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today_outlined, size: 20),
                      ],
                    ),
                  ),
                  // unable to click if selected date is today (can not go to future)
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 28),
                    onPressed:
                        selectedDate.isBefore(
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              ),
                            )
                            ? _nextDay
                            : null,
                    color:
                        selectedDate.isBefore(
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              ),
                            )
                            ? Colors.black
                            : Colors.grey.shade400,
                  ),
                ],
              ),
            ),

            // Main Stats Circle
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Circle
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 12,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        // Progress Circle
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: 0.35, // 35% progress
                            strokeWidth: 12,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        // Center Content
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_fire_department,
                                size: 40,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '487',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                                height: 1,
                              ),
                            ),
                            const Text(
                              'cal',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF718096),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Total Time Taken Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.access_time_filled_rounded,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '42 mins',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Exercise History Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.directions_run,
                        size: 20,
                        color: Color(0xFF2D3748),
                      ),
                      SizedBox(width: 6),
                      const Text(
                        'Exercise History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildExerciseHistoryItem(
                    'Morning Run',
                    '07:30 AM',
                    '245 cal',
                    Icons.directions_run,
                    const Color(0xFF14B8A6),
                  ),
                  _buildExerciseHistoryItem(
                    'Yoga Session',
                    '09:15 AM',
                    '120 cal',
                    Icons.self_improvement,
                    const Color(0xFF8B5CF6),
                  ),
                  _buildExerciseHistoryItem(
                    'Evening Walk',
                    '06:00 PM',
                    '122 cal',
                    Icons.directions_walk,
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddExerciseDialog();
        },
        backgroundColor: const Color(0xFF14B8A6),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Add Exercise',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildExerciseHistoryItem(
    String name,
    String time,
    String calories,
    IconData icon,
    Color color,
  ) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 4),
                Text(
                  calories,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog() {
    String? selectedExercise;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    Duration? duration;
    double? caloriesBurned;

    final durationTextController = TextEditingController();
    final caloriesTextController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Duration? calculateDuration(TimeOfDay start, TimeOfDay end) {
              final startMinutes = start.hour * 60 + start.minute;
              final endMinutes = end.hour * 60 + end.minute;
              final diff = endMinutes - startMinutes;
              if (diff <= 0) return null;
              return Duration(minutes: diff);
            }

            double? calculateCalories(String exercise, Duration duration) {
              final rate = AppConstants.calorieRatePerMinute[exercise];
              if (rate == null) return null;
              return rate * duration.inMinutes;
            }

            void updateComputedValues() {
              if (startTime != null && endTime != null) {
                duration = calculateDuration(startTime!, endTime!);
                if (duration != null) {
                  durationTextController.text =
                      '${duration!.inMinutes.toString()} minutes';
                  if (selectedExercise != null) {
                    caloriesBurned = calculateCalories(
                      selectedExercise!,
                      duration!,
                    );
                    caloriesTextController.text =
                        '${caloriesBurned!.toStringAsFixed(1)} cal';
                  }
                }
              }
            }

            Future<void> pickStartTime() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: startTime ?? TimeOfDay.now(),
              );
              if (picked != null) {
                setModalState(() {
                  startTime = picked;
                  updateComputedValues();
                });
              }
            }

            Future<void> pickEndTime() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: endTime ?? TimeOfDay.now(),
              );
              if (picked != null) {
                setModalState(() {
                  endTime = picked;
                  updateComputedValues();
                });
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Small drag indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Add Exercise',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Exercise Type Dropdown
                  const Text(
                    'Exercise Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    hint: const Text('Select exercise type'),
                    value: selectedExercise,
                    items:
                        AppConstants.calorieRatePerMinute.keys.map((exercise) {
                          final iconData =
                              AppColors.exerciseIconData[exercise]!['icon']
                                  as IconData;
                          final color =
                              AppColors.exerciseIconData[exercise]!['color']
                                  as Color;

                          return DropdownMenuItem<String>(
                            value: exercise,
                            child: Row(
                              children: [
                                Icon(iconData, color: color, size: 22),
                                const SizedBox(width: 12),
                                Text(exercise),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedExercise = value;
                        updateComputedValues();
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Start Time
                  const Text(
                    'Start Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTimePickerTile(
                    label:
                        startTime == null
                            ? 'Select start time'
                            : startTime!.format(context),
                    onTap: pickStartTime,
                  ),

                  const SizedBox(height: 16),

                  // End Time
                  const Text(
                    'End Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTimePickerTile(
                    label:
                        endTime == null
                            ? 'Select end time'
                            : endTime!.format(context),
                    onTap: pickEndTime,
                  ),

                  const SizedBox(height: 20),

                  // Duration field
                  TextField(
                    controller: durationTextController,
                    readOnly: true,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Duration (minutes)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.timer),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Calories field
                  TextField(
                    controller: caloriesTextController,
                    readOnly: true,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Calories Burned',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      final Map<String, dynamic> exerciseData = {
                        'exercise': selectedExercise ?? 'Not selected',
                        'startTime': startTime?.format(context) ?? 'N/A',
                        'endTime': endTime?.format(context) ?? 'N/A',
                        'duration': duration?.inMinutes ?? 0,
                        'caloriesBurned': caloriesBurned ?? 0,
                      };

                      print(jsonEncode(exerciseData));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Exercise',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimePickerTile({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF2D3748)),
            ),
            const Icon(Icons.access_time, color: Color(0xFF718096)),
          ],
        ),
      ),
    );
  }
}
