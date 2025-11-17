import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/models/meal/meal_record_model.dart';
import 'package:eatmehv2/data/models/exercise/exercise_model.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/data/repos/meal_records_repo.dart';
import 'package:eatmehv2/data/repos/exercise_repo.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart';

// --- Light UI Colors ---
const Color kLightBackgroundColor = Colors.white;
const Color kLightCardColor = Color(0xFFF0F0F0);
const Color kTextPrimaryLight = Colors.black87;
const Color kTextSecondaryLight = Color(0xFF616161);

// --- Card Icon Colors ---
const Color kIconColor1 = Color(0xFFFF9800); // Orange for Calories
const Color kIconColor2 = Color(0xFF03A9F4); // Blue for Duration
const Color kIconColor3 = Color(0xFFF44336); // Red for Calories Burnt
const Color kIconColor4 = Color(0xFF9C27B0); // Purple for Users
const Color kGenderMale = Color(0xFF2196F3);
const Color kGenderFemale = Color(0xFFE91E63);

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final UserRepository _userRepo = UserRepository();
  final MealRecordsRepository _mealRepo = MealRecordsRepository();
  final ExerciseRepository _exerciseRepo = ExerciseRepository();

  // --- Full Data Lists ---
  List<UserModel> _allUsers = [];
  List<MealRecordModel> _allMeals = [];
  List<ExerciseRecordModel> _allExercises = [];

  // --- State Variables ---
  bool _isLoading = true;
  final numberFormat = NumberFormat.compact();

  // --- Statistics ---
  String _totalUsers = '0';
  Map<String, double> _genderPercentages = {};
  String _avgCalories = '0';
  String _totalDuration = '0';
  String _totalCaloriesBurnt = '0';
  Map<int, double> _userSignupsByMonth = {};

  // --- Filter State ---
  late int _selectedYear;
  late int _selectedMonth;
  final List<int> _years = [2023, 2024, 2025, 2026];
  List<String> _months = []; 

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
  }
  
  bool _didFetchData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetchData) {
      _months = context.loc.monthsList;
      _fetchAndProcessData();
      _didFetchData = true;
    }
  }

  // --- 1. DATA FETCHING & INITIAL PROCESSING ---
  Future<void> _fetchAndProcessData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final allData = await Future.wait([
        _userRepo.getAllUsers(),
        _mealRepo.fetchAllMealRecords(),
        _exerciseRepo.fetchAllExercises(),
      ]);

      _allUsers = allData[0] as List<UserModel>;
      _allMeals = allData[1] as List<MealRecordModel>;
      _allExercises = allData[2] as List<ExerciseRecordModel>;

      _processStaticData();
      _processFilteredData();

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.adminDataErrorLoad(e.toString()))),
      );
    }
  }

  /// Processes data that does *not* change with filters.
  void _processStaticData() {
    _totalUsers = _allUsers.length.toString();
    int maleCount = _allUsers.where((u) => u.gender == 'male').length;
    int femaleCount = _allUsers.where((u) => u.gender == 'female').length;
    int totalGendered = maleCount + femaleCount;

    if (totalGendered > 0) {
      _genderPercentages = {
        'Male': (maleCount / totalGendered) * 100,
        'Female': (femaleCount / totalGendered) * 100,
      };
    } else {
      _genderPercentages = {'Male': 0, 'Female': 0};
    }
  }

  /// Processes data *based on* the selected filters.
  void _processFilteredData() {
    final filteredMeals = _allMeals.where((meal) {
      final date = meal.createdAt.toDate();
      final monthMatches =
          (_selectedMonth == 13) || (date.month == _selectedMonth);
      return date.year == _selectedYear && monthMatches;
    }).toList();

    final filteredExercises = _allExercises.where((ex) {
      final date = ex.createdAt.toDate();
      final monthMatches =
          (_selectedMonth == 13) || (date.month == _selectedMonth);
      return date.year == _selectedYear && monthMatches;
    }).toList();
    
    _avgCalories = '0';
    if (filteredMeals.isNotEmpty) {
      double calSum = filteredMeals.fold(0, (sum, meal) => sum + meal.calories);
      _avgCalories = (calSum / filteredMeals.length).toStringAsFixed(0);
    }

    _totalDuration = '0 min';
    if (filteredExercises.isNotEmpty) {
      int durationSum =
          filteredExercises.fold(0, (sum, ex) => sum + ex.duration);
      if (durationSum > 60) {
        _totalDuration = '${(durationSum / 60).toStringAsFixed(1)} hr';
      } else {
        _totalDuration = '$durationSum min';
      }
    }

    _totalCaloriesBurnt = '0';
    if (filteredExercises.isNotEmpty) {
      int calBurntSum =
          filteredExercises.fold(0, (sum, ex) => sum + ex.caloriesBurnt);
      _totalCaloriesBurnt = numberFormat.format(calBurntSum);
    }

    Map<int, double> monthlyCounts = {
      1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0,
      7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0,
    };
    final usersThisYear = _allUsers.where((u) => u.createdAt.toDate().year == _selectedYear);
    for (final user in usersThisYear) {
      final month = user.createdAt.toDate().month;
      monthlyCounts[month] = (monthlyCounts[month] ?? 0) + 1;
    }
    _userSignupsByMonth = monthlyCounts;

    setState(() {});
  }

  // --- 2. BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // --- 1. TOTAL USERS CARD ---
                  _buildSectionHeader(loc.adminDataTotalUsers),
                  const SizedBox(height: 12),
                  _buildTotalUsersCard(loc),
                  const SizedBox(height: 24),

                  // --- 2. GENDER GRAPH ---
                  _buildSectionHeader(loc.adminDataUserGenders),
                  const SizedBox(height: 12),
                  _buildChartCard(
                    child: _buildGenderPieChart(),
                    legend: _buildPieChartLegend(loc),
                  ),
                  const SizedBox(height: 32),

                  // --- 3. FILTERS & STATS ---
                  _buildSectionHeader(loc.adminDataOverview),
                  const SizedBox(height: 12),
                  _buildFilterControls(loc),
                  const SizedBox(height: 16),
                  
                  // --- 4. HORIZONTALLY SCROLLING STATS CARDS ---
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildScrollableStatCard(
                          icon: Icons.local_fire_department,
                          value: _avgCalories,
                          label: loc.adminDataAvgCalories,
                          color: kIconColor1,
                        ),
                        _buildScrollableStatCard(
                          icon: Icons.timer,
                          value: _totalDuration,
                          label: loc.adminDataTotalDuration,
                          color: kIconColor2,
                        ),
                        _buildScrollableStatCard(
                          icon: Icons.fitness_center,
                          value: _totalCaloriesBurnt,
                          label: loc.adminDataCaloriesBurnt,
                          color: kIconColor3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- 5. NEW USERS OVERVIEW ---
                  _buildSectionHeader(loc.adminDataNewUsers),
                  const SizedBox(height: 12),
                  _buildLineChartCard(loc),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  // --- 3. HELPER WIDGETS ---

  /// Builds the top full-width "Total Users" card
  Widget _buildTotalUsersCard(AppLocalizations loc) {
    return CustomCard(
      child: Row(
        children: [
          Icon(Icons.group, size: 32, color: kIconColor4),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _totalUsers,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimaryLight,
                ),
              ),
              Text(
                loc.adminDataTotalUsers,
                style: const TextStyle(
                  fontSize: 16,
                  color: kTextSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Builds the Month/Year filter dropdowns
  Widget _buildFilterControls(AppLocalizations loc) {
    return CustomCard(
      // Removed redundant padding: CustomCard should handle its own padding
      child: Row(
        children: [
          // --- Month Dropdown ---
          Expanded(
            flex: 2,
            child: DropdownButton<int>(
              value: _selectedMonth,
              isExpanded: true,
              underline: Container(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedMonth = newValue);
                  _processFilteredData();
                }
              },
              items: [
                DropdownMenuItem<int>(
                  value: 13,
                  child: Text(loc.adminDataAllMonths, style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
                ..._months.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key + 1,
                    child: Text(entry.value),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // --- Year Dropdown ---
          Expanded(
            flex: 1,
            child: DropdownButton<int>(
              value: _selectedYear,
              isExpanded: true,
              underline: Container(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedYear = newValue);
                  _processFilteredData();
                }
              },
              items: _years.map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// A single card for the horizontally scrolling list
  Widget _buildScrollableStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: 160, // ADJUSTED WIDTH to prevent text truncation
      child: CustomCard(
        margin: const EdgeInsets.only(right: 12),
        // Removed padding: CustomCard should handle its own padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color: color),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kTextPrimaryLight,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: kTextSecondaryLight,
              ),
              // Removed overflow property
            ),
          ],
        ),
      ),
    );
  }

  /// Graph 1: Gender Pie Chart
  Widget _buildGenderPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: _genderPercentages.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value,
            color: entry.key == 'Male' ? kGenderMale : kGenderFemale,
            title: '${entry.value.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Legend for Gender Pie Chart
  Widget _buildPieChartLegend(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: kGenderMale, text: loc.adminDataMale),
        const SizedBox(width: 16),
        _LegendItem(color: kGenderFemale, text: loc.adminDataFemale),
      ],
    );
  }

  /// The header for the chart section
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: kTextPrimaryLight,
      ),
    );
  }

  /// Helper for wrapping charts in a Card
  Widget _buildChartCard(
      {required Widget child, Widget? legend, double? height}) {
    return CustomCard(
      // Removed redundant padding
      child: Column(
        children: [
          SizedBox(
            height: height ?? 150,
            child: child,
          ),
          if (legend != null) ...[
            const SizedBox(height: 16),
            legend,
          ],
        ],
      ),
    );
  }

  /// The card containing the line chart
  Widget _buildLineChartCard(AppLocalizations loc) {
    return CustomCard(
      // Removed redundant padding
      child: SizedBox(
        height: 260,
        child: LineChart(
          _buildLineChartData(loc),
        ),
      ),
    );
  }

  /// The data and styling for the line chart
  LineChartData _buildLineChartData(AppLocalizations loc) {
    final spots = <FlSpot>[];
    for (int i = 1; i <= 12; i++) {
      spots.add(FlSpot(i.toDouble(), _userSignupsByMonth[i] ?? 0));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: kTextSecondaryLight.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              String text;
              switch (value.toInt()) {
                case 1: text = loc.adminDataMonthJan; break;
                case 3: text = loc.adminDataMonthMar; break;
                case 5: text = loc.adminDataMonthMay; break;
                case 7: text = loc.adminDataMonthJul; break;
                case 9: text = loc.adminDataMonthSep; break;
                case 11: text = loc.adminDataMonthNov; break;
                default: return Container();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(text,
                    style: const TextStyle(
                        color: kTextSecondaryLight, fontSize: 12)),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value == meta.max || value == 0) return Container();
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                    color: kTextSecondaryLight, fontSize: 12),
                textAlign: TextAlign.left,
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: kIconColor2,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                kIconColor2.withOpacity(0.3),
                kIconColor2.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

/// A dedicated helper widget for the legend items
class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextSecondaryLight,
          ),
        ),
      ],
    );
  }
}