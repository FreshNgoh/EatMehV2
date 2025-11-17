import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart';
import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/chat_room_repo.dart';
import 'package:eatmehv2/data/repos/trainer_profile_repo.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/data/services/chat_room_service.dart';
import 'package:eatmehv2/data/services/trainer_profile_service.dart';
import 'package:eatmehv2/presentation/widgets/custom_button.dart';
import 'package:eatmehv2/presentation/widgets/custom_card.dart';
import 'package:eatmehv2/presentation/widgets/custom_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserFeedbackScreen extends StatefulWidget {
  final String trainerUid;
  const UserFeedbackScreen({super.key, required this.trainerUid});

  @override
  State<UserFeedbackScreen> createState() => _UserFeedbackScreenState();
}

class _UserFeedbackScreenState extends State<UserFeedbackScreen> {
  final userRepo = UserRepository();
  final trainerRepo = TrainerProfileRepo(TrainerProfileService());

  UserModel? _trainer;
  double _rating = 0;
  int? _existingRating;
  bool isLoading = true;
  bool isSaving = false;
  int _trainingMonths = 0;

  Future<void> loadTrainerProfile() async {
    final trainer = await userRepo.getUser(widget.trainerUid);
    if (!mounted) return;
    setState(() {
      _trainer = trainer;
      isLoading = false;
    });
  }

  Future<void> _submitRating() async {
    if (!mounted) return;
    final loc = context.loc;
    if (_rating == 0.0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.feedbackErrorSelectRating)));
      return;
    }

    setState(() => isSaving = true);

    try {
      final double rating = _rating;

      await userRepo.submitTrainerRating(widget.trainerUid, rating);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _existingRating == null
                  ? loc.feedbackSuccessSubmitted
                  : loc.feedbackSuccessUpdated,
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
            SnackBar(content: Text(loc.feedbackErrorSubmit(e.toString()))));
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadTrainerProfile();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_trainer == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.trainerGoalErrorTitle)),
        body: Center(child: Text(loc.feedbackErrorTrainerNotFound)),
      );
    }

    final trainerName = _trainer!.username;
    final trainerId = '@${_trainer!.uid.substring(0, 10)}...';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.feedbackTitle,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, color: Colors.black),
            onPressed: () {
              // Share
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF191919),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _trainer!.imageUrl != null &&
                                  _trainer!.imageUrl!.isNotEmpty
                              ? NetworkImage(_trainer!.imageUrl!)
                              : null,
                          child: (_trainer!.imageUrl == null ||
                                  _trainer!.imageUrl!.isEmpty)
                              ? Text(
                                  _trainer!.username[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF191919),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Trainer Name
                  Text(
                    trainerName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Trainer ID
                  GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: _trainer!.uid));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.feedbackTrainerIDCopied),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trainerId,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.copy, size: 14, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Training Duration
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _trainingMonths > 0
                          ? loc.feedbackTrainingDuration(_trainingMonths)
                          : loc.feedbackTrainingDurationRecent,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Rating Section
            CustomCard(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber[600],
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _existingRating != null
                            ? loc.feedbackUpdateRatingTitle
                            : loc.feedbackRateExperienceTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.feedbackRatingPrompt(trainerName),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Star Rating
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              index < _rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 48,
                              color: index < _rating
                                  ? Colors.amber[600]
                                  : Colors.grey[300],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  if (_rating > 0) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _getRatingText(_rating, loc),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _getRatingColor(_rating),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submit Button
                  CustomButton(
                    text: isSaving
                        ? loc.cameraSaving
                        : loc.feedbackSubmitButton,
                    onPressed: isSaving ? null : _submitRating,
                    backgroundColor: const Color(0xFF191919),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  CustomList(
                    profile: Icon(
                      Icons.person_add,
                      size: 28,
                      color: Colors.blue[600],
                    ),
                    value: loc.feedbackSendFriendRequest,
                    actionIcons: [
                      ListActionIcon(icon: Icons.arrow_forward_ios),
                    ],
                    onFieldTap: () async {
                      final authState =
                          context.read<AuthBloc>().state as Authenticated;
                      final currentUserUid = authState.user.uid;
                      await userRepo.sendFriendRequest(
                        currentUserUid,
                        widget.trainerUid,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.friendButtonSuccessSent)),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomList(
                    profile: Icon(
                      Icons.swap_horiz,
                      size: 28,
                      color: Colors.orange[600],
                    ),
                    value: loc.feedbackChangeTrainer,
                    actionIcons: [
                      ListActionIcon(icon: Icons.arrow_forward_ios),
                    ],
                    onFieldTap: () {
                      _showChangeTrainerDialog(loc);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double rating, AppLocalizations loc) {
    switch (rating) {
      case 1:
        return loc.feedbackRatingPoor;
      case 2:
        return loc.feedbackRatingFair;
      case 3:
        return loc.feedbackRatingGood;
      case 4:
        return loc.feedbackRatingVeryGood;
      case 5:
        return loc.feedbackRatingExcellent;
      default:
        return '';
    }
  }

  Color _getRatingColor(double rating) {
    if (rating <= 2) return Colors.red;
    if (rating == 3) return Colors.orange;
    return Colors.green;
  }

  void _showChangeTrainerDialog(AppLocalizations loc) {
    final authState = context.read<AuthBloc>().state as Authenticated;
    final currentUserUid = authState.user.uid;
    final chatRepo = ChatRoomRepo(ChatRoomService());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: Text(loc.feedbackChangeTrainer),
        content: Text(loc.feedbackChangeTrainerConfirmMsg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.profileBioCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              if (!mounted) return;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                await userRepo.changeTrainer(
                  widget.trainerUid,
                  currentUserUid,
                );

                await chatRepo.deleteChatRoom(
                  currentUserUid,
                  widget.trainerUid,
                );

                await userRepo.deleteUserGoal(currentUserUid);

                if (!mounted) return;
                Navigator.pop(context); // Pop loading indicator
                Navigator.pop(context); // Pop feedback screen

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.feedbackChangeTrainerSuccessMsg),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                // Pop loading indicator
                Navigator.pop(context);

                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(loc.feedbackErrorChangeTrainer(e.toString())),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.friendButtonLabelConfirm),
          ),
        ],
      ),
    );
  }
}