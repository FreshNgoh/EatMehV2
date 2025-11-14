import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/core/constants/app_constants.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import 'package:eatmehv2/core/theme/app_colors.dart';
import 'package:eatmehv2/data/models/exercise/exercise_model.dart';
import 'package:eatmehv2/data/repos/exercise_repo.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  DateTime selectedDate = DateTime.now();
  late ExerciseRepository _exerciseRepo;

  @override
  void initState() {
    super.initState();
    _exerciseRepo = ExerciseRepository();
  }

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
    final loc = context.loc;
    final authState = context.read<AuthBloc>().state as Authenticated;
    final userUid = authState.user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Set background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Date Navigation
            Container(
              // color: Colors.white,
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
                          DateFormat(
                            'EEE, MMM d',
                            loc.locale.languageCode,
                          ).format(selectedDate),
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

            // === FUTURE BUILDER TO LOAD FIREBASE DATA ===
            FutureBuilder<List<ExerciseRecordModel>>(
              future: _exerciseRepo.fetchExercises(
                userUid: userUid,
                date: selectedDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/error.png',
                            height: 200,
                            width: 200,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loc.recordError.replaceFirst(
                              '{error}',
                              snapshot.error.toString(),
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final exercises = snapshot.data ?? [];
                if (exercises.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/noData.png',
                            height: 200,
                            width: 200,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loc.exerciseNoData,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF403D39),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // === DYNAMIC STATS ===
                final totalCalories = exercises.fold<int>(
                  0,
                  (sum, e) => sum + e.caloriesBurnt,
                );
                final totalDuration = exercises.fold<int>(
                  0,
                  (sum, e) => sum + e.duration,
                );

                const calorieGoal = 1500; // dummy goal for now
                final progress = (totalCalories / calorieGoal).clamp(0.0, 1.0);

                return Column(
                  children: [
                    // === MAIN STATS CIRCLE ===
                    Container(
                      // color: Colors.white,
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
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFE2E8F0),
                                        ),
                                  ),
                                ),
                                // Progress Circle
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 12,
                                    backgroundColor: Colors.transparent,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
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
                                        color: const Color(
                                          0xFFF59E0B,
                                        ).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.local_fire_department,
                                        size: 40,
                                        color: Color(0xFFF59E0B),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '$totalCalories',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      loc.exerciseCal,
                                      style: const TextStyle(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.access_time_filled_rounded,
                                color: Color(0xFFF59E0B),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                loc.exerciseTotal,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$totalDuration ${loc.exerciseMins}',
                                style: const TextStyle(
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

                    // === EXERCISE HISTORY SECTION ===
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_run,
                                size: 20,
                                color: Color(0xFF2D3748),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                loc.exerciseHistory,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          for (final e in exercises)
                            _buildExerciseHistoryItem(
                              loc: loc,
                              // 'e.exerciseName' is the key, e.g., "exercise_running"
                              name: e.exerciseName,
                              startTime: DateFormat(
                                'hh:mm a',
                              ).format(e.startTime.toDate()),
                              endTime: DateFormat(
                                'hh:mm a',
                              ).format(e.endTime.toDate()),
                              duration: e.duration,
                              calories: e.caloriesBurnt,
                              icon:
                                  AppColors.exerciseIconData[e
                                          .exerciseName]?['icon']
                                      as IconData? ??
                                  Icons.fitness_center,
                              color:
                                  AppColors.exerciseIconData[e
                                          .exerciseName]?['color']
                                      as Color? ??
                                  Colors.blue,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddExerciseDialog(loc);
        },
        backgroundColor: const Color(0xFF14B8A6),
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          loc.exerciseAdd,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildExerciseHistoryItem({
    required AppLocalizations loc,
    required String name,
    required String startTime,
    required String endTime,
    required int duration,
    required int calories,
    required IconData icon,
    required Color color,
  }) {
    return CustomCard(
      child: Row(
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),

          // Exercise details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // --- FIX #1: Translate the key ---
                  loc.translate(name),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$startTime - $endTime',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calories tag
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
                  '$calories ${loc.exerciseCal}',
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

  void _showAddExerciseDialog(AppLocalizations loc) {
    String? selectedExercise;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    Duration? duration;
    double? caloriesBurned;

    final durationTextController = TextEditingController();
    final caloriesTextController = TextEditingController();
    bool isLoading = false;

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
                      '${duration!.inMinutes.toString()} ${loc.exerciseMins}';
                  if (selectedExercise != null) {
                    caloriesBurned = calculateCalories(
                      selectedExercise!,
                      duration!,
                    );
                    caloriesTextController.text =
                        '${caloriesBurned!.toStringAsFixed(1)} ${loc.exerciseCal}';
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

            Future<void> saveExerciseRecord() async {
              if (selectedExercise == null ||
                  startTime == null ||
                  endTime == null ||
                  duration == null ||
                  caloriesBurned == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.exerciseErrorFillFields)),
                );
                return;
              }

              setModalState(() => isLoading = true);

              try {
                final authState =
                    context.read<AuthBloc>().state as Authenticated;
                final userUid = authState.user.uid;

                final now = DateTime.now();
                final startDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  startTime!.hour,
                  startTime!.minute,
                );
                final endDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  endTime!.hour,
                  endTime!.minute,
                );

                final exerciseRecord = ExerciseRecordModel(
                  uid:
                      FirebaseFirestore.instance
                          .collection(
                            FirebaseConstants.exerciseRecordsCollection,
                          )
                          .doc()
                          .id,
                  userUid: userUid,
                  exerciseName: selectedExercise!,
                  duration: duration!.inMinutes,
                  caloriesBurnt: caloriesBurned!.toInt(),
                  createdAt: Timestamp.fromDate(now),
                  startTime: Timestamp.fromDate(startDateTime),
                  endTime: Timestamp.fromDate(endDateTime),
                );

                await ExerciseRepository().saveExercise(exerciseRecord);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.exerciseSaveSuccess)),
                );

                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      loc.exerciseSaveError.replaceFirst(
                        '{error}',
                        e.toString(),
                      ),
                    ),
                  ),
                );
              } finally {
                setModalState(() => isLoading = false);
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
                  // Drag indicator
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
                  Center(
                    child: Text(
                      loc.exerciseAdd,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Exercise Type Dropdown
                  Text(
                    loc.exerciseType,
                    style: const TextStyle(
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
                    hint: Text(loc.exerciseSelectType),
                    value: selectedExercise,
                    items:
                        AppConstants.calorieRatePerMinute.keys.map((
                          exerciseKey,
                        ) {
                          final iconData =
                              AppColors.exerciseIconData[exerciseKey]!['icon']
                                  as IconData;
                          final color =
                              AppColors.exerciseIconData[exerciseKey]!['color']
                                  as Color;

                          // --- FIX #2: Translate the key ---
                          final translatedName = loc.translate(exerciseKey);

                          return DropdownMenuItem<String>(
                            value: exerciseKey, // The value is the key
                            child: Row(
                              children: [
                                Icon(iconData, color: color, size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  translatedName,
                                ), // Show the translated name
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
                  Text(
                    loc.exerciseStartTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTimePickerTile(
                    label:
                        startTime == null
                            ? loc.exerciseSelectStart
                            : startTime!.format(context),
                    onTap: pickStartTime,
                  ),

                  const SizedBox(height: 16),

                  // End Time
                  Text(
                    loc.exerciseEndTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTimePickerTile(
                    label:
                        endTime == null
                            ? loc.exerciseSelectEnd
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
                      labelText: loc.exerciseDuration,
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
                      labelText: loc.exerciseCaloriesBurned,
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
                    onPressed: isLoading ? null : saveExerciseRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isLoading ? Colors.grey : const Color(0xFF14B8A6),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              loc.exerciseSaving,
                              style: const TextStyle(
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
