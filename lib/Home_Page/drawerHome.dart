import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../Authentication_part/login_screen.dart';
import '../about_section.dart';
import '../leaderboardPage.dart';
import '../routineImagePage.dart';

class DrawerHome extends StatefulWidget {
  const DrawerHome({super.key});

  @override
  State<DrawerHome> createState() => _DrawerHomeState();
}

class _DrawerHomeState extends State<DrawerHome> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = doc['name'] ?? 'User';
        userEmail = doc['email'] ?? 'user@example.com';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Drawer(
      child: Container(
        width: double.infinity,
        color: const Color(0xFFFFFDD0).withOpacity(0.3), // Cream background with opacity
        child: Column(
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(
                  top: 40, left: 10, right: 10, bottom: 10),
              height: 200,
              width: size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0097A7), // Darker blue
                    Color(0xFF00ACC1), // Lighter accent
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome $userName",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // List Section
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.black),
                    title: const Text("Home",
                        style: TextStyle(color: Colors.black)),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.rocket, color: Colors.black),
                    title: Text("Routine",
                        style: TextStyle(color: Colors.black)),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RoutineImagePage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.black),
                    title: const Text("About",
                        style: TextStyle(color: Colors.black)),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AboutSection()),
                      );
                    },
                  ),
                  // ListTile(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (_) => LeaderboardPage()),
                  //     );
                  //   },
                  //   leading: Icon(Icons.leaderboard, color: Colors.blue),
                  //   title: Text(
                  //     "Leaderboard",
                  //     style: TextStyle(
                  //       color: Colors.blue,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  //   subtitle: Text(
                  //     "View top scorers and progress",
                  //     style: TextStyle(
                  //       color: Colors.blueAccent,
                  //       fontSize: 12,
                  //     ),
                  //   ),
                  //   trailing: Icon(
                  //     Icons.arrow_forward_ios,
                  //     size: 18,
                  //     color: Colors.blue,
                  //   ),
                  // ),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Log Out",
                        style: TextStyle(color: Colors.red)),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();

                        final box = GetStorage(); // Initialize GetStorage
                        box.erase(); // Clear all stored session data

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                              (route) => false,
                        );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
