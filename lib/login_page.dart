import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payapp/helper/helper.dart';

import 'components/my_button.dart';
import 'components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controller
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  void login() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing accidentally
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Sign in with Firebase
      print("Attempting to log in...");
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("Login successful for: ${userCredential.user?.email}");

      // Fetch user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .get();

      print("User document fetched: ${userDoc.data()}");

      // Ensure the widget is still mounted
      if (!mounted) return;

      // Dismiss the loading dialog BEFORE navigating
      Navigator.pop(context);

      // Redirect based on role
      String role = userDoc['role'];
      print("User role: $role");
      if (role == 'tenant') {
        Navigator.pushReplacementNamed(context, '/tenantdashboard');
      } else if (role == 'landlord') {
        Navigator.pushReplacementNamed(context, '/landlorddashboard');
      }
    } on FirebaseAuthException catch (e) {
      // Ensure the widget is still mounted
      if (!mounted) return;

      Navigator.pop(context); // Remove loading indicator first
      print("FirebaseAuthException: ${e.message}");
      displayMessageToUser(e.message ?? "Login failed", context);
    } catch (e) {
      Navigator.pop(context);
      print("Unexpected error: $e");
      displayMessageToUser("Unexpected error occurred", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              const SizedBox(height: 25),

              //appname
              Text(
                "ViPAY",
                style: TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 25),
              //emailtextfield
              MyTextfield(
                hintText: "Email",
                obscureText: false,
                controller: emailController,
              ),

              const SizedBox(height: 10),

              //password textfield
              MyTextfield(
                hintText: "Password",
                obscureText: true,
                controller: passwordController,
              ),

              const SizedBox(height: 10),

              //forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              //signin button
              MyButton(
                text: "Login",
                onTap: login,
              ),
              //dont have an account? register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "Register Here",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
