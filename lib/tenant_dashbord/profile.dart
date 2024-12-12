import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  //current logged in user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  //future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Profile',
          style: TextStyle(color: Color.fromARGB(255, 235, 238, 238)),
        )),
        backgroundColor: Color.fromARGB(255, 12, 112, 117),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            //loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            //error
            else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            //data received
            else if (snapshot.hasData) {
              //extract date
              Map<String, dynamic>? user = snapshot.data!.data();

              return Center(
                child: Column(
                  children: [
                    //profile
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.all(25),
                      child: const Icon(
                        Icons.person,
                        size: 64,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),

                    //username
                    Text(
                      user!['username'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),

                    //email
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      user['email'],
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Text("No Data");
            }
          },
        ),
      ),
    );
  }
}
