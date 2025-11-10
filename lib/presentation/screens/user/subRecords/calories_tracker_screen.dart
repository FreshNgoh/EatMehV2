import 'dart:async';

import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:eatmehv2/utils/calorie_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eatmehv2/data/repos/calorie_tracker_repo.dart';

enum TimePeriod { daily, weekly, monthly }

class CaloriesTrackerPage extends StatefulWidget {
  const CaloriesTrackerPage({super.key});

  @override
  State<CaloriesTrackerPage> createState() => _CaloriesTrackerPageState();
}

class _CaloriesTrackerPageState extends State<CaloriesTrackerPage>
    with SingleTickerProviderStateMixin {
  TimePeriod _selectedPeriod = TimePeriod.daily;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _imageTimer;
  late CalorieTrackerRepository _calorieTrackerRepo;

  Map<String, double> _data = {'taken': 0.0, 'burnt': 0.0};
  bool _isLoading = true;
  String? _errorMessage;

  String _currentImagePath = '';

  @override
  void initState() {
    super.initState();
    _calorieTrackerRepo = CalorieTrackerRepository();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _loadCalorieData();
    _updateImage();
    _animationController.forward();

    // Automatically change image every few seconds
    _imageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateImage();
      _animationController
        ..reset()
        ..forward();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCalorieData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = context.read<AuthBloc>().state as Authenticated;
      final userUid = authState.user.uid;

      String period;
      switch (_selectedPeriod) {
        case TimePeriod.daily:
          period = 'daily';
          break;
        case TimePeriod.weekly:
          period = 'weekly';
          break;
        case TimePeriod.monthly:
          period = 'monthly';
          break;
      }

      final data = await _calorieTrackerRepo.fetchCaloriesByPeriod(
        userUid: userUid,
        date: DateTime.now(),
        period: period,
      );

      setState(() {
        _data = data;
        _isLoading = false;
        _updateImage();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  double get _avgTaken => _data['taken']!;
  double get _avgBurnt => _data['burnt']!;
  double get _netCalories =>
      CalorieUtils.calculateNetCalories(_avgTaken, _avgBurnt);

  // utils
  CalorieStatus get _calorieStatus =>
      CalorieUtils.getCalorieStatus(_netCalories);
  Color get _netCaloriesColor => CalorieUtils.getStatusColor(_netCalories);
  String get _statusText => CalorieUtils.getStatusText(_calorieStatus);

  String get _periodText {
    switch (_selectedPeriod) {
      case TimePeriod.daily:
        return 'Daily';
      case TimePeriod.weekly:
        return 'Weekly';
      case TimePeriod.monthly:
        return 'Monthly';
    }
  }

  void _updateImage() {
    _currentImagePath = CalorieUtils.getRandomStatusImage(_calorieStatus);
  }

  void _showPeriodSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Period',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildPeriodOption('Daily', TimePeriod.daily),
              _buildPeriodOption('Weekly', TimePeriod.weekly),
              _buildPeriodOption('Monthly', TimePeriod.monthly),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodOption(String label, TimePeriod period) {
    final isSelected = _selectedPeriod == period;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Colors.deepPurple : Colors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.deepPurple : Colors.black,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        _changePeriod(period);
      },
    );
  }

  void _changePeriod(TimePeriod period) {
    if (_selectedPeriod != period) {
      setState(() {
        _selectedPeriod = period;
        _animationController.reset();
      });
      _loadCalorieData().then((_) {
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if there's no data (both taken and burnt are 0)
    final hasNoData =
        !_isLoading &&
        _errorMessage == null &&
        _avgTaken == 0 &&
        _avgBurnt == 0;

    return Scaffold(
      body:
          _isLoading
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: CircularProgressIndicator(),
                ),
              )
              : _errorMessage != null
              ? SingleChildScrollView(
                child: Column(
                  children: [
                    //  Header Row
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                      child: GestureDetector(
                        onTap: _showPeriodSelector,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_periodText Net Calories',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.expand_more, size: 22),
                          ],
                        ),
                      ),
                    ),
                    Padding(
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
                              'Error loading records:\n$_errorMessage',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : hasNoData
              ? SingleChildScrollView(
                child: Column(
                  children: [
                    //  Header Row
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                      child: GestureDetector(
                        onTap: _showPeriodSelector,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_periodText Net Calories',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.expand_more, size: 22),
                          ],
                        ),
                      ),
                    ),
                    Padding(
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
                            const Text(
                              "No calorie records found for this period.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF403D39),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    //  Header Row
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                      child: GestureDetector(
                        onTap: _showPeriodSelector,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_periodText Net Calories',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.expand_more, size: 22),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Main Content
                    Column(
                      children: [
                        // Animated Image + Status
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 280,
                                      height: 280,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _netCaloriesColor
                                                .withOpacity(0.2),
                                            blurRadius: 20,
                                            spreadRadius: 15,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          _currentImagePath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Icon(
                                              CalorieUtils.getStatusIcon(
                                                _calorieStatus,
                                              ),
                                              size: 120,
                                              color: _netCaloriesColor,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      '${_netCalories.toInt()}',
                                      style: TextStyle(
                                        fontSize: 52,
                                        fontWeight: FontWeight.bold,
                                        color: _netCaloriesColor,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      'Cal',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _netCaloriesColor.withOpacity(
                                          0.7,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _netCaloriesColor.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _statusText,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _netCaloriesColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Stats Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.local_fire_department,
                                  label: 'Avg Cal taken',
                                  value: _avgTaken.toInt(),
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.directions_run,
                                  label: 'Avg Cal burnt',
                                  value: _avgBurnt.toInt(),
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Cal',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
