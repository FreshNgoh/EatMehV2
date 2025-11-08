import 'package:flutter/material.dart';

// --- Data Model ---

/// Represents a user profile in the list.
class User {
  final String name;
  final String description;
  final bool isFrozen;

  const User({
    required this.name,
    required this.description,
    this.isFrozen = false,
  });
}

// --- Sample Data ---

final List<User> sampleUsers = [
  const User(name: 'Alice Johnson', description: 'Admin Assistant'),
  const User(name: 'Bob Smith', description: 'Development Lead', isFrozen: true),
  const User(name: 'Charlie Brown', description: 'Sales Representative'),
  const User(name: 'Diana Prince', description: 'Marketing Specialist'),
  const User(name: 'Ethan Hunt', description: 'Financial Analyst'),
  const User(name: 'Fiona Glenanne', description: 'Operations Manager'),
  const User(name: 'George Kirk', description: 'Customer Support'),
  const User(name: 'Hannah Montana', description: 'Junior Designer'),
  const User(name: 'Ivan Drago', description: 'Data Scientist'),
  const User(name: 'Jana Miller', description: 'HR Partner'),
];

// --- Main Screen Widget ---

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. App Bar
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),

      // 2. Body: User List
      body: ListView.builder(
        // Add padding at the bottom so the list items aren't obscured by the bottom navigation bar
        padding: const EdgeInsets.only(bottom: 80.0),
        itemCount: sampleUsers.length,
        itemBuilder: (context, index) {
          final user = sampleUsers[index];
          return UserListItem(
            user: user,
            // Placeholder action for the button
            onFreeze: () {
              // In a real app, this would update the user state in Firestore or state management
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} FREEZE button tapped!')),
              );
            },
          );
        },
      ),

    );
  }
}

// --- Custom List Item Widget ---

class UserListItem extends StatelessWidget {
  final User user;
  final VoidCallback onFreeze;

  const UserListItem({
    super.key,
    required this.user,
    required this.onFreeze,
  });

  @override
  Widget build(BuildContext context) {
    // Using ListTile for standard list appearance
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      
      // Placeholder Profile Icon (Circle Avatar)
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[200],
        child: Icon(Icons.person, color: Colors.grey[600]),
      ),
      
      // Name and Description Text
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: Text(
        user.description,
        style: TextStyle(color: Colors.grey[600]),
      ),

      // FREEZE Button
      trailing: SizedBox(
        width: 90, // Fixed width for consistent button size
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
            user.isFrozen ? 'UNFREEZE' : 'FREEZE',
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