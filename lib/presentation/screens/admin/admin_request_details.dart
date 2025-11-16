import 'package:flutter/material.dart';
// Adjust these paths to match your project structure
import 'package:eatmehv2/data/models/trainer/trainer_application.dart';
import 'package:eatmehv2/data/repos/trainer_application_repo.dart';
import 'package:eatmehv2/data/services/trainer_application_service.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart';

class AdminRequestDetailsScreen extends StatefulWidget {
  final TrainerApplication application; // Use your model

  const AdminRequestDetailsScreen({
    super.key,
    required this.application,
  });

  @override
  State<AdminRequestDetailsScreen> createState() =>
      _AdminRequestDetailsScreenState();
}

class _AdminRequestDetailsScreenState extends State<AdminRequestDetailsScreen> {
  // Use your repository
  final TrainerApplicationRepository _repository =
      TrainerApplicationRepository(TrainerApplicationService());
  bool _isLoading = false;


  Future<void> _onApprove() async {
    final loc = context.loc;
    setState(() => _isLoading = true);
    try {
      await _repository.approveApplication(
        widget.application.uid, 
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(loc.adminRequestApproveSuccess),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(loc.adminRequestApproveError(e.toString())),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Reject Action ---
  Future<void> _onReject() async {
    final loc = context.loc;
    String reason = loc.adminRequestRejectReasonDefault;

    setState(() => _isLoading = true);
    try {
      await _repository.rejectApplication(widget.application.uid, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(loc.adminRequestRejectSuccess),
              backgroundColor: Colors.orange),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(loc.adminRequestRejectError(e.toString())),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- UPDATED ---
    final loc = context.loc; // Get localization object

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Profile Header ---
              // (This section is already commented out per your request)
              Text(
                widget.application.name, // Use data from your model
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const SizedBox(height: 32),

              // --- Personal Info Section (Using your model's data) ---
              // --- UPDATED ---
              _buildSectionHeader(loc.adminRequestHeaderInfo),
              _buildInfoField(
                  icon: Icons.person_outline,
                  // --- UPDATED (Re-using keys from trainerForm) ---
                  label: loc.trainerFormNameLabel,
                  value: widget.application.name),
              _buildInfoField(
                  icon: Icons.cake_outlined,
                  label: loc.trainerFormAgeLabel,
                  value: widget.application.age),
              _buildInfoField(
                  icon: Icons.school_outlined,
                  label: loc.trainerFormSpecLabel,
                  value: widget.application.specialization),
              _buildInfoField(
                  icon: Icons.work_outline,
                  label: loc.trainerFormExpLabel,
                  value: widget.application.experience),
              _buildInfoField(
                  icon: Icons.phone_outlined,
                  label: loc.trainerFormContactLabel,
                  value: widget.application.contactNumber),
              const SizedBox(height: 32),

              // --- Prove Section (Using your model's data) ---
              // --- UPDATED ---
              _buildSectionHeader(loc.adminRequestHeaderProve),
              if (widget.application.certificateUrls.isEmpty)
                // --- UPDATED ---
                Text(loc.adminRequestNoCerts)
              else
                Column(
                  children: widget.application.certificateUrls
                      .map((url) => _buildCertificateTile(url))
                      .toList(),
                ),
              const SizedBox(height: 40),

              // --- Action Buttons ---
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onApprove, // Connect action
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // --- UPDATED ---
                        child: Text(loc.adminRequestButtonApprove,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onReject, // Connect action
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // --- UPDATED ---
                        child: Text(loc.adminRequestButtonReject,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCertificateTile(String url) {
    // --- UPDATED ---
    final loc = context.loc; // Get localization object

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            // Show a loading spinner while the image downloads
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child; // Image is loaded
              return Container(
                height: 250, // Placeholder height
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            // Show an error icon if the image fails to load
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 250, // Placeholder height
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.grey[600], size: 40),
                    const SizedBox(height: 8),
                    Text(
                      // --- UPDATED ---
                      loc.adminRequestErrorLoadCert,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

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

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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