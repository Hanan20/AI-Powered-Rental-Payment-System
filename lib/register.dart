import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payapp/helper/helper.dart';

import 'components/my_button.dart';
import 'components/my_textfield.dart';

class Register extends StatefulWidget {
  final VoidCallback? onTap;

  const Register({super.key, required this.onTap});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpwdController = TextEditingController();

  // Role selection
  String _role = 'tenant'; // Default role is tenant

  // Register method
  void registerUser() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Ensure passwords match
    if (passwordController.text != confirmpwdController.text) {
      Navigator.pop(context);
      displayMessageToUser("Passwords don't match", context);
    } else {
      try {
        // Create user with Firebase Auth
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        // Create the user document in Firestore with role info
        createUserDocument(userCredential);

        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        displayMessageToUser(e.code, context);
      }
    }
  }

  // Create a user document with role in Firestore
  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
        'role': _role, // Save the user's role (tenant or landlord)
        'createdAt': FieldValue.serverTimestamp(),
      });
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
              Icon(Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary),
              const SizedBox(height: 25),
              const Text("ViPAY", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 25),

              // Username field
              MyTextfield(
                hintText: "Name",
                obscureText: false,
                controller: usernameController,
              ),
              const SizedBox(height: 10),

              // Email field
              MyTextfield(
                hintText: "Email",
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 10),

              // Password field
              MyTextfield(
                hintText: "Password",
                obscureText: true,
                controller: passwordController,
              ),
              const SizedBox(height: 10),

              // Confirm Password field
              MyTextfield(
                hintText: "Confirm Password",
                obscureText: true,
                controller: confirmpwdController,
              ),
              const SizedBox(height: 20),

              // Role selection (Tenant or Landlord)
              Row(
                children: [
                  Text("i am a : "),
                  Text("tenant "),
                  Radio<String>(
                    value: 'tenant',
                    groupValue: _role,
                    onChanged: (String? value) {
                      setState(() {
                        _role = value!;
                      });
                    },
                  ),
                  Text("landlord"),
                  Radio<String>(
                    value: 'landlord',
                    groupValue: _role,
                    onChanged: (String? value) {
                      setState(() {
                        _role = value!;
                      });
                    },
                  ),
                ],
              ),

              // Forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Forgot Password?",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                ],
              ),
              const SizedBox(height: 25),

              // Register button
              MyButton(
                text: "Register",
                onTap: registerUser,
              ),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                ],
              ),
              GestureDetector(
                onTap: widget.onTap,
                child: const Text("Login Here",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
