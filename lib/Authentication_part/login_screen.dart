import 'package:flutter/material.dart';
import 'package:flutter_with_noman_android_studio/Authentication_part/sign_up_screen.dart';

import '../BottomNavigationBar.dart';
import '../Home_Page/HomePage.dart';

import '../Admin_section/home_screen_admin.dart';
import 'Services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _obscureText = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;
  bool isLoading = false;    // show loading snipper during signup waiting time

  @override
  void dispose() {  // eta dite hobe, eta na dile controller coltei thakbe ja app performance komay dibe
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // instance for AuthService for authentication logic
  final AuthService _authService = AuthService();

  void login() async{
    setState(() {
      isLoading = true;
    });
    // call login method from auth_service.dar
    String? result = await _authService.login(email: emailController.text, password: passwordController.text);
    setState(() {
      isLoading = false;
    });
    // Navigate based on the role or show error message
    if(result == "Admin"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeScreenAdmin()),);
    } else if(result == "User"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> BottomNavBarAssigment()),);
    } else{
      // if login failed
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup Failed!!! $result",),),);
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
            child: Padding(padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Image.asset("assets/images/log_in.png",
                    height: 300, fit: BoxFit.cover,
                  ),
                  SizedBox(height: 20,),

                  // Input Email,
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                   ),
                  ),
                  SizedBox(height: 20,),

                 // for input password
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(onPressed: (){
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                        icon: Icon(isPasswordHidden ?Icons.visibility_off:Icons.visibility),),
                    ),
                    obscureText: isPasswordHidden,      // eta input password ke hide korbe
                  ),
                  SizedBox(height: 40,),

                  // Login button
                  isLoading ? Center(child: CircularProgressIndicator(),):
                  SizedBox(width: double.infinity, height: 50,
                    child: ElevatedButton(
                        onPressed: login,
                        child: Text("Log In")),
                  ),

                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Don't have account?", style: TextStyle(fontSize: 18, color: Colors.blue),),
                      SizedBox(width: 10,),

                      InkWell(
                        onTap: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>SignUpScreen()));
                        },
                        child: Text("Sign Up",
                          style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.red,         // underline color
                            decorationThickness: 2,            // underline thickness (adjust as needed)\
                            height: 1.8,
                        ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
        ),
      ),
    );
  }
}
