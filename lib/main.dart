import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // এটা Add করতে ভুলবে না!
import 'package:flutter_with_noman_android_studio/firebase_options.dart';
import 'package:get_storage/get_storage.dart';
import 'Authentication_part/login_screen.dart';
import 'Authentication_part/sign_up_screen.dart';
import 'BottomNavigationBar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // ⬅️ এখানেই GetMaterialApp ব্যবহার করতে হবে
      debugShowCheckedModeBanner: false,
      title: 'Flutter Course App',
      //home: BottomNavBarAssigment(),
      home: LoginScreen(),
      // home: SignUpScreen(),
    );
  }
}
