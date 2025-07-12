import 'package:flutter/material.dart';
import 'package:flutter_with_noman_android_studio/Admin_section/drawerAdmin.dart';
import 'package:flutter_with_noman_android_studio/Admin_section/launch_course_page.dart';
import 'manage_courses_page.dart';
import 'view_enrolled_students_page.dart';

class HomeScreenAdmin extends StatefulWidget {
  const HomeScreenAdmin({super.key});

  @override
  State<HomeScreenAdmin> createState() => _HomeScreenAdminState();
}

class _HomeScreenAdminState extends State<HomeScreenAdmin> {
  Widget buildAdminCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withOpacity(0.1),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color,
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        backgroundColor: Colors.cyan,
      ),
      drawer: AdminDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),

            buildAdminCard(
              title: "Launch New Course",
              icon: Icons.add_circle_outline,
              color: Colors.cyan,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LaunchCoursePage()),
                );
              },
            ),

            buildAdminCard(
              title: "Manage Courses",
              icon: Icons.edit_note,
              color: Colors.deepOrange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageCoursesPage()),
                );
              },
            ),

            buildAdminCard(
              title: "View Enrolled Students",
              icon: Icons.people,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EnrolledStudentsPage()),
                );
              },
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
