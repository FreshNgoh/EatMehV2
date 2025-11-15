import 'package:eatmehv2/presentation/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';

class FriendRequestButton extends StatefulWidget {
  final String targetUserId;
  final List<String> currentUserFriends;
  final List<String> targetUserFriendRequests;
  final List<String> currentUserFriendRequests;
  final VoidCallback? onStatusChanged; // Add this callback

  const FriendRequestButton({
    super.key,
    required this.targetUserId,
    required this.currentUserFriends,
    required this.targetUserFriendRequests,
    required this.currentUserFriendRequests,
    this.onStatusChanged, // Add this parameter
  });

  @override
  State<FriendRequestButton> createState() => _FriendRequestButtonState();
}

class _FriendRequestButtonState extends State<FriendRequestButton> {
  final UserRepository _userRepo = UserRepository();
  bool _isLoading = false;

  bool get _isFriend => widget.currentUserFriends.contains(widget.targetUserId);
  bool get _isPending =>
      widget.targetUserFriendRequests.contains(_getCurrentUserId());
  bool get isRequesting =>
      widget.currentUserFriendRequests.contains(widget.targetUserId);

  String _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.uid;
    }
    return '';
  }

  Future<void> _handleButtonPress() async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      if (_isFriend) {
        await _userRepo.removeFriend(currentUserId, widget.targetUserId);
        if (mounted) {
          final successMsg = 'Friend removed!';
          showCustomToast(context, successMsg, type: ToastType.success);
        }
      } else if (_isPending) {
        await _userRepo.rejectFriendRequest(widget.targetUserId, currentUserId);
        if (mounted) {
          final successMsg = 'Friend request cancelled!';
          showCustomToast(context, successMsg, type: ToastType.success);
        }
      } else {
        await _userRepo.sendFriendRequest(currentUserId, widget.targetUserId);
        if (mounted) {
          final successMsg = 'Friend request sent!';
          showCustomToast(context, successMsg, type: ToastType.success);
        }
      }

      // Trigger refresh after successful action
      if (mounted) {
        widget.onStatusChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = 'Error: $e';
        showCustomToast(context, errorMsg, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmRequest() async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _userRepo.acceptFriendRequest(currentUserId, widget.targetUserId);
      if (mounted) {
        final successMsg = 'Friend request accepted';
        showCustomToast(context, successMsg, type: ToastType.success);
        // Trigger refresh after successful action
        widget.onStatusChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = 'Error: $e';
        showCustomToast(context, errorMsg, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectRequest() async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _userRepo.rejectFriendRequest(currentUserId, widget.targetUserId);
      if (mounted) {
        final successMsg = 'Friend request deleted';
        showCustomToast(context, successMsg, type: ToastType.success);
        // Trigger refresh after successful action
        widget.onStatusChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = 'Error: $e';
        showCustomToast(context, errorMsg, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isRequesting) {
      // Show Confirm + Delete buttons
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 0,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _rejectRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.grey.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 0,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ),
        ],
      );
    }

    // Default single button (Request / Requesting / Friends)
    String buttonText;
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (_isFriend) {
      buttonText = 'Friends';
      backgroundColor = Colors.grey.shade100;
      textColor = Colors.grey.shade700;
      icon = Icons.check;
    } else if (_isPending) {
      buttonText = 'Requesting';
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade700;
      icon = Icons.schedule;
    } else {
      buttonText = 'Request';
      backgroundColor = const Color(0xFF191919);
      textColor = Colors.white;
      icon = Icons.person_add;
    }

    return SizedBox(
      width: double.infinity,
      height: 35,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleButtonPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5),
          elevation: 0,
        ),
        child:
            _isLoading
                ? SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
