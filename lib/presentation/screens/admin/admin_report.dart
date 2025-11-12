import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// --- A more modern color palette ---
const Color contentColorBlue = Color(0xFF2196F3);
const Color contentColorPink = Color(0xFFE91E63);
const Color contentColorPurple = Color(0xFF9C27B0);
const Color mainGridLineColor = Color(0xFFEEEEEE); // Softer grid lines
const Color scaffoldBackgroundColor = Color(0xFFF5F5F5); // Light grey bg

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor, // Use the light grey background
      body: SingleChildScrollView(
        // Add padding around the whole screen
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BAR CHART ---
            _buildSectionHeader("Activity Overview"),
            const SizedBox(height: 12),
            // Wrap the chart in a styled Card
            Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: SizedBox(
                  height: 250,
                  child: _buildBeautifulBarChart(),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- PIE CHART ---
            _buildSectionHeader("User Demographics"),
            const SizedBox(height: 12),
            // Wrap this chart in a card too
            Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: _buildBeautifulPieChart(),
                    ),
                    const SizedBox(height: 16),
                    // A cleaner legend
                    _buildPieChartLegend(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper for the section headers
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // --- Beautiful Bar Chart ---
  Widget _buildBeautifulBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        // --- Titles (X and Y Axis Labels) ---
        titlesData: FlTitlesData(
          // Hide top and right titles
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          
          // Bottom (X-axis) titles
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                String text;
                switch (value.toInt()) {
                  case 0: text = 'M'; break;
                  case 1: text = 'T'; break;
                  case 2: text = 'W'; break;
                  case 3: text = 'T'; break;
                  case 4: text = 'F'; break;
                  case 5: text = 'S'; break;
                  case 6: text = 'S'; break;
                  default: text = '';
                }
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
              },
              reservedSize: 30,
            ),
          ),
          
          // Left (Y-axis) titles
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value % 2 == 0 && value != 0) {
                  return Text(
                    '${value.toInt()}k',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        
        // --- Grid and Border ---
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false, // Hide vertical lines
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: mainGridLineColor, // Use the soft grey color
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: false, // Hide the chart border
        ),
        
        // --- Bar Data ---
        barGroups: [
          _makeBarGroup(0, 5, color: contentColorBlue),
          _makeBarGroup(1, 7, color: contentColorBlue),
          _makeBarGroup(2, 4, color: contentColorBlue),
          _makeBarGroup(3, 8, color: contentColorPink), // Highlight
          _makeBarGroup(4, 6, color: contentColorBlue),
          _makeBarGroup(5, 7.5, color: contentColorBlue),
          _makeBarGroup(6, 5.5, color: contentColorBlue),
        ],
      ),
    );
  }

  // Helper for a single bar
  BarChartGroupData _makeBarGroup(int x, double y, {Color color = Colors.blue}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 20,
          // --- Add a gradient ---
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  // --- Beautiful Pie Chart (Donut Chart) ---
  Widget _buildBeautifulPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 4, // Space between sections
        centerSpaceRadius: 60, // This makes it a "donut" chart
        
        // --- Animate the chart ---
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Here you could add interactivity
          },
        ),
        
        // --- Sections Data ---
        sections: [
          PieChartSectionData(
            value: 40,
            color: contentColorBlue,
            title: '40%', // Show percentage
            radius: 40,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 30,
            color: contentColorPink,
            title: '30%',
            radius: 40,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 30,
            color: contentColorPurple,
            title: '30%',
            radius: 40,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // --- A cleaner, reusable legend widget ---
  Widget _buildPieChartLegend() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: contentColorBlue, text: 'New Users'),
        SizedBox(width: 16),
        _LegendItem(color: contentColorPink, text: 'Returning'),
        SizedBox(width: 16),
        _LegendItem(color: contentColorPurple, text: 'Inactive'),
      ],
    );
  }
}

// A dedicated helper widget for the legend items
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
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}