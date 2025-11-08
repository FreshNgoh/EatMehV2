import 'package:flutter/material.dart';
import 'admin_request.dart';

class AdminRequestDetailsScreen extends StatelessWidget {
  final Request request;

  const AdminRequestDetailsScreen({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1. App Bar (with just the back arrow)
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // 2. Body (wrapped in SingleChildScrollView to prevent overflow)
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Profile Header ---
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFE0E0E0), // Light grey background
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Color(0xFF757575), // Darker grey icon
                ),
              ),
              const SizedBox(height: 16),
              Text(
                request.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'ID: abcd...789', // Hardcoded from your wireframe
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // --- Personal Info Section ---
              _buildSectionHeader('Personal Info'),
              _buildInfoField(
                icon: Icons.person_outline,
                label: 'Name',
                value: request.name, // Data from the request object
              ),
              _buildInfoField(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: '28', // Dummy data as per wireframe
              ),
              _buildInfoField(
                icon: Icons.location_on_outlined,
                label: 'Data 3',
                value: 'Dummy Location Data', // Dummy data
              ),
              _buildInfoField(
                icon: Icons.bar_chart_outlined,
                label: 'Data 4',
                value: 'Dummy Metric Data', // Dummy data
              ),
              const SizedBox(height: 32),

              // --- Prove Section ---
              _buildSectionHeader('Prove'),
              // This widget mimics the "PDF" box in your wireframe
              InkWell(
                onTap: () {
                  // TODO: Add action to open PDF
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening PDF... (Not implemented)')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'PDF',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- Action Buttons ---
              Row(
                children: [
                  // APPROVE Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Add APPROVE logic
                        Navigator.of(context).pop(); // Go back after action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'APPROVE',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // REJECT Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Add REJECT logic
                        Navigator.of(context).pop(); // Go back after action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'REJECT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40), // Extra padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the section headers ("Personal Info", "Prove")
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // Helper widget to create the read-only info fields
  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      // Using TextField to exactly match your wireframe's boxed style
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}