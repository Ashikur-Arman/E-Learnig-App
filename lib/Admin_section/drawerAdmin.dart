import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../Authentication_part/login_screen.dart';
import '../routineImagePage.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  String adminName = '';
  String adminEmail = '';

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  void fetchAdminData() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        adminName = doc['name'] ?? 'Admin';
        adminEmail = doc['email'] ?? 'admin@example.com';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.cyan,
            ),
            accountName: Text(adminName),
            accountEmail: Text(adminEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.cyan),
            ),
          ),

          // Navigation Items
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text("Dashboard"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text("Manage Users"),
            onTap: () {},
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
            leading: Icon(Icons.help_outline),
            title: Text("Help & Support"),
            onTap: () {},
          ),

          Divider(),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              "Log Out",
              style: TextStyle(color: Colors.red),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.grey[400],
            ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();

                final box = GetStorage(); // GetStorage instance
                box.erase(); // Clear all session data

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                );
              },
          ),
        ],
      ),
    );
  }
}
