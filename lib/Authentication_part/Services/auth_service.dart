import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // function to handle user sign_up
  Future <String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async{
    try{
      // Create user in firebase authentication with email and passWord
      UserCredential userCredential = await
      _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim()
      );
      // The trim() method removes any leading and trailing whitespace from a String.

      // save additional user data in firestore (name, role, email)
      print("UID: ${userCredential.user!.uid}");
      print("Firestore write starting...");
      await _firestore.collection("users").doc(userCredential.user!.uid).set({   // "users" eta firebase er database name
        'name':name.trim(),
        "email":email.trim(),
        "role": role, // role determines if user is admin or user
      });
      print("Firestore write completed!");
      return null;   // success : no error message
    } catch(e){
      return e.toString();   // error : return the exception message
    }
  }

  // function to handel user login
  Future <String?> login({
    required String email,
    required String password,
  }) async{
    try{
      // Sign in user using firebase authentication with email and passWord
      UserCredential userCredential = await
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      // The trim() method removes any leading and trailing whitespace from a String.

      // fetching the user's role from firestore to determine assess level
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(userCredential.user!.uid).get();
      return userDoc['role'];   // return the user's role (admin/user)
    } catch(e){
      print("Firestore Error: $e");
      return e.toString();   // error : return the exception message
    }
  }
}