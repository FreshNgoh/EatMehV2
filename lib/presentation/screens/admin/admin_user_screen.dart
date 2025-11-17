import 'package:flutter/material.dart';
// 1. Make sure to import your User Model and Repository
// Adjust the paths as needed for your project structure
import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/presentation/screens/user/profile_screen.dart';
import 'package:eatmehv2/core/localization/app_localizations.dart'; 

// Assuming this color is available in scope or defined elsewhere, 
// using a fallback if necessary.
const Color kTextPrimaryLight = Colors.black87; 

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserRepository _userRepository = UserRepository();
  
  List<UserModel>? _users;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await _userRepository.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final loc = context.loc;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.adminUserErrorFetch(e.toString()))),
        );
      }
    }
  }

  Future<void> _handleFreeze(UserModel user) async {
    final bool newFreezeState = !user.isFrozen;

    try {
      await _userRepository.freezeAccount(user.uid, newFreezeState);

      if (mounted) {
        final loc = context.loc;
        final message = newFreezeState
            ? loc.adminUserFreezeSuccess(user.username)
            : loc.adminUserUnfreezeSuccess(user.username);
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

      _fetchUsers();
    } catch (e) {
      if (mounted) {
        final loc = context.loc;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.adminUserErrorUpdate(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<UserModel> displayUsers = _users
        ?.where((user) => user.role != 'admin')
        .toList() ??
        [];

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80.0),
              itemCount: displayUsers.length,
              itemBuilder: (context, index) {
                final user = displayUsers[index];
                return UserListItem(
                  user: user,
                  onFreeze: () => _handleFreeze(user),
                );
              },
            ),
    );
  }
}

// --- Custom List Item Widget (Updated) ---

class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onFreeze;

  const UserListItem({
    super.key,
    required this.user,
    required this.onFreeze,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    
    // 1. Check if bio exists and is not just empty whitespace
    final hasBio = user.bio != null && user.bio!.trim().isNotEmpty;
    
    // Determine the subtitle widget (null if no bio is present)
    final Widget? userSubtitle = hasBio
        ? Text(
            user.bio!, 
            style: TextStyle(color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userUid: user.uid ,),
            ),
          );
        },
        // 2. Updated CircleAvatar styling and logic
        child: CircleAvatar(
          radius: 25, // Updated radius
          backgroundColor: Colors.grey.shade300, // Updated background color
          backgroundImage: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
              ? NetworkImage(user.imageUrl!)
              : null,
          
          child: (user.imageUrl == null || user.imageUrl!.isEmpty)
              ? Text(
                  user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 18, // Updated font size
                    fontWeight: FontWeight.bold,
                  ), 
                )
              : null,
        ),
      ),
      
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          user.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      
      // Use the calculated subtitle (null if no bio)
      subtitle: userSubtitle, 

      trailing: SizedBox(
        width: 90,
        child: ElevatedButton(
          onPressed: onFreeze,
          style: ElevatedButton.styleFrom(
            backgroundColor: user.isFrozen ? Colors.red.shade600 : Colors.blue.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            elevation: 2,
          ),
          child: Text(
            user.isFrozen ? loc.adminUserButtonUnfreeze : loc.adminUserButtonFreeze,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}