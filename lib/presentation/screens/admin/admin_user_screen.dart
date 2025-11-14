import 'package:flutter/material.dart';
// 1. Make sure to import your User Model and Repository
// Adjust the paths as needed for your project structure
import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';
import 'package:eatmehv2/presentation/screens/user/profile_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  // 2. Initialize your repository
  final UserRepository _userRepository = UserRepository();
  
  // 3. State variables to hold the list of users and loading state
  List<UserModel>? _users;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 4. Fetch users when the screen loads
    _fetchUsers();
  }

  /// Fetches all users from the repository and updates the state.
  Future<void> _fetchUsers() async {
    try {
      final users = await _userRepository.getAllUsers();
      // 5. Update the state with the fetched users
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching users: $e')),
        );
      }
    }
  }

  /// Handles the freeze/unfreeze action
  Future<void> _handleFreeze(UserModel user) async {
    // Determine the new state (toggle the current state)
    final bool newFreezeState = !user.isFrozen;

    try {
      // 6. Call the repository method
      await _userRepository.freezeAccount(user.uid, newFreezeState);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user.username} has been ${newFreezeState ? 'FROZEN' : 'UNFROZEN'}.',
            ),
          ),
        );
      }

      // 7. Refresh the user list to show the change
      _fetchUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 8. Filter the list to exclude 'admin' roles
    // We do this here so the list updates automatically when state changes.
    final List<UserModel> displayUsers = _users
            ?.where((user) => user.role != 'admin')
            .toList() ??
        [];

    return Scaffold(
      // 9. Body: User List (Updated)
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80.0),
              itemCount: displayUsers.length,
              itemBuilder: (context, index) {
                final user = displayUsers[index];
                return UserListItem(
                  user: user,
                  onFreeze: () => _handleFreeze(user), // 10. Connect the action
                );
              },
            ),
    );
  }
}

// --- Custom List Item Widget (Updated) ---

class UserListItem extends StatelessWidget {
  // 11. Use the UserModel from your file
  final UserModel user;
  final VoidCallback onFreeze;

  const UserListItem({
    super.key,
    required this.user,
    required this.onFreeze,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      
      // 12. Use user.imageUrl for the avatar
     // Wrap your CircleAvatar with a GestureDetector
leading: GestureDetector(
  onTap: () {
    // --- Add your navigation logic here ---
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userUid: user.uid ,), // Replace with your page
      ),
    );
    // -------------------------------------
  },
  child: CircleAvatar(
    radius: 28,
    backgroundColor: Colors.grey[200],
    // Use NetworkImage if imageUrl is present, otherwise show default icon
    backgroundImage: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
        ? NetworkImage(user.imageUrl!)
        : null,
    child: (user.imageUrl == null || user.imageUrl!.isEmpty)
        ? Icon(Icons.person, color: Colors.grey[600])
        : null,
  ),
),
      // 13. Use user.username and user.bio
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          user.username, // From UserModel
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: Text(
        user.bio ?? 'No bio available', // From UserModel (handles null)
        style: TextStyle(color: Colors.grey[600]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      // 14. Use user.isFrozen to set button text and color
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
            user.isFrozen ? 'UNFREEZE' : 'FREEZE', // Dynamic text
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