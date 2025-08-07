import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../BottomNavigationBar.dart';
import '../Home_Page/HomePage.dart';
import '../Admin_section/home_screen_admin.dart';
import '../Authentication_part/sign_up_screen.dart';
import 'Services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final box = GetStorage(); // 🔵 GetStorage instance
  final AuthService _authService = AuthService();

  bool isPasswordHidden = true;
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    setState(() => isLoading = true);

    String? result = await _authService.login(
      email: emailController.text,
      password: passwordController.text,
    );

    setState(() => isLoading = false);

    if (result == "Admin") {
      box.write('userType', 'Admin'); // 🔴 Save session
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreenAdmin()),
      );
    } else if (result == "User") {
      box.write('userType', 'User'); // 🔴 Save session
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavBarAssigment()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: $result")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Center(child: Text("Log in")),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Image.asset("assets/images/log_in.png", height: 300),
                SizedBox(height: 20),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: isPasswordHidden,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          isPasswordHidden ? Icons.visibility_off : Icons.visibility),
                      onPressed: () =>
                          setState(() => isPasswordHidden = !isPasswordHidden),
                    ),
                  ),
                ),
                SizedBox(height: 40),

                isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: login,
                    child: Text("Log In"),
                  ),
                ),
                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Don't have account?", style: TextStyle(fontSize: 18, color: Colors.blue)),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.red,
                          decorationThickness: 2,
                          height: 1.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
