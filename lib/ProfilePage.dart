import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Information"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/Arman.jpg', // Path to your local image
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16), // Add spacing between widgets
            Text(
              "About the user",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "This app was developed by Md Ashikur Arman, a passionate Flutter developer dedicated to creating interactive and efficient mobile applications.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Contact:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("Email: ashikurarman92157@gmail.com"),
            Text("GitHub: https://github.com/Ashikur-Arman"),
          ],
        ),
      ),
    );
  }
}
