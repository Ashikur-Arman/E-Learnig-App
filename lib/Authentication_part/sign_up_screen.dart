import 'package:flutter/material.dart';
import 'package:flutter_with_noman_android_studio/Authentication_part/login_screen.dart';

import 'Services/auth_service.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  String selectedRole = "User"; // default selected role from dropdown

  bool isLoading = false;    // show loading snipper during signup waiting time
  bool isPasswordHidden = true;

  @override
  void dispose() {  // eta dite hobe, eta na dile controller coltei thakbe ja app performance komay dibe
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // instance for AuthService for authentication logic
  final AuthService _authService = AuthService();
  // signup function to handle user registration
  void _signup() async{

    setState(() {
      isLoading = true;
    });

    // call signup method from services/auth_service.dart with user inputs
    String? result = await _authService.signup(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: selectedRole,
    );
    setState(() {
      isLoading = false;
    });
    if(result == null){
      // signup successful : Navigate to login screen with success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup SuccessFull!!! Now turn to Login",),),);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> LoginScreen(),),);
    } else{
      // signup failed : show the error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup Failed!!! $result",),),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Center(child: Text("Sign Up")),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset("assets/images/sign_up.png",
                height: 200, fit: BoxFit.cover,
              ),
              SizedBox(height: 20,),

              // Input Email,
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20,),

              // for input password
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20,),

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
              SizedBox(height: 20,),

              // Dropdown for selecting the admin or user
              DropdownButtonFormField(
                value: selectedRole,
                decoration: InputDecoration( labelText: "Role", border: OutlineInputBorder()
                ),
                items: ["Admin","User"].map((role){
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
                onChanged: (String? newValue){
                  setState(() {
                    selectedRole = newValue!; // update role selection in the text field
                  });
                },
              ),
              SizedBox(height: 20,),

              // Sign_Up button
              isLoading ? const Center(child: CircularProgressIndicator(),):
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(
                    onPressed: _signup,
                    child: Text("Sign Up")),
              ),
              SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Already have an account?", style: TextStyle(fontSize: 18, color: Colors.blue),),
                  SizedBox(width: 10,),

                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
                    },
                    child: Text("Log in",
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
    );
  }
}
