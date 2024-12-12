import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payapp/components/my_drawer.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomepageState();
}

class _HomepageState extends State<HomeContent> {
  // Current logged-in user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
              child: Text(
            'Tenant Dashboard',
            style: TextStyle(color: Color.fromARGB(255, 235, 238, 238)),
          )),
          backgroundColor: Color.fromARGB(255, 12, 112, 117),
        ),
        drawer: const MyDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Welcome Section with User's Name
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: getUserDetails(),
                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Error
                  if (snapshot.hasError) {
                    return Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    );
                  }

                  // Data Retrieved
                  if (snapshot.hasData) {
                    Map<String, dynamic>? user = snapshot.data!.data();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          // Profile Icon
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Color.fromARGB(255, 15, 150, 156),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Color.fromARGB(255, 12, 112, 117),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Welcome Text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back,",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                user?['username'] ??
                                    'User', // Fallback to 'User'
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  // No Data
                  return const Text(
                    "Welcome, User",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  );
                },
              ),

              // Calendar Section
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/calendar');
                },
                child: Container(
                  child: Container(
                    width: 800,
                    height: 200,
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 12, 112, 117),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.calendar_month),
                          Text(
                            "Calendar",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 7, 46, 51)),
                          ),
                          SizedBox(height: 10),
                          Text("Your calendar will be displayed here."),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Transactions Section
              Container(
                width: 800,
                height: 200,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.receipt_long),
                    Text(
                      "Transactions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Your transaction history will be displayed here."),
                  ],
                ),
              ),

              // Invoices Section
              Container(
                width: 800,
                height: 200,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 109, 165, 192),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.description),
                    Text(
                      "Invoices",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 7, 46, 51)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Your invoices will be displayed here.",
                      style: TextStyle(color: Color.fromARGB(255, 7, 46, 51)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
