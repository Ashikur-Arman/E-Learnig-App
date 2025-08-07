import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Authentication_part/login_screen.dart';
import 'BottomNavigationBar.dart';
import 'Admin_section/home_screen_admin.dart';
import 'firebase_options.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final box = GetStorage();
  final userType = box.read('userType'); // Check if logged in already

  runApp(MyApp(userType: userType));
}

class MyApp extends StatelessWidget {
  final String? userType;

  const MyApp({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart-Learn : Admin Panel',
      home: userType == "Admin"
          ? HomeScreenAdmin()
          : userType == "User"
          ? BottomNavBarAssigment()
          : LoginScreen(),
    );
  }
}
