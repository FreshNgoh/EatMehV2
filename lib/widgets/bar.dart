import 'package:eatmehv2/screens/camera_page.dart';
import 'package:eatmehv2/screens/consult_page.dart';
import 'package:eatmehv2/screens/friend_page.dart';
import 'package:eatmehv2/screens/friend_request_page.dart';
import 'package:eatmehv2/screens/profile_page.dart';
import 'package:eatmehv2/screens/record_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Bar extends StatelessWidget {
  const Bar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the currently signed-in user
    User? user = FirebaseAuth.instance.currentUser;

    String? username = "Guest"; // Default if no user is signed in
    if (user != null && user.email != null) {
      username = user.displayName; // Extract username from email
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text("Hi, $username"),
          ),

          // Future implementation of Avatar
          // child: Row(
          //     children: [
          //       CircleAvatar(
          //         radius: 25,
          //         backgroundColor: Colors.grey[100],
          //         backgroundImage:
          //             user?.photoURL != null
          //                 ? CachedNetworkImageProvider(user!.photoURL!)
          //                 : const AssetImage('assets/img/default_avatar.png')
          //                     as ImageProvider,
          //       ),
          //       Text(" $username"),
          //     ],
          //   ), //replace
          // ),
          // backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(Icons.people, size: 25),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendRequestPage()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                icon: Icon(Icons.notifications_active, size: 25),
                onPressed: () {
                  // Add notification action
                },
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 112, 110, 110),
                    width: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 100,
          padding: EdgeInsets.only(left: 10, right: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey, width: 0.25)),
          ),
          child: TabBar(
            padding: EdgeInsets.only(bottom: 20),
            // Uncomment it if you dont want the onClick effect.
            // splashFactory: NoSplash.splashFactory,
            // overlayColor: MaterialStateProperty.all(Colors.transparent),
            dividerHeight: 0,
            labelColor: Color(0xFF191919),
            labelStyle: const TextStyle(fontSize: 14),
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.transparent,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.group), text: "Friends"),
              Tab(icon: Icon(Icons.note_add_outlined), text: "Record"),
              Tab(icon: Icon(Icons.camera_alt), text: "Camera"),
              Tab(icon: Icon(Icons.person), text: "Consult"),
              Tab(icon: Icon(Icons.settings), text: "Profile"),
            ],
          ),
        ),
        // Change the view page
        body: TabBarView(
          children: <Widget>[
            FriendPage(),
            RecordPage(),
            CameraPage(),
            ConsultPage(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}
