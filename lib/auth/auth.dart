import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payapp/landlord_dashboard/landlorddashboard.dart';
import 'package:payapp/login_page.dart';
import 'package:payapp/tenant_dashbord/tenantdashboard.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          // User is signed in; get their role and navigate
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("Users")
                .doc(snapshot.data!.email)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (userSnapshot.hasData && userSnapshot.data != null) {
                String role = userSnapshot.data!['role'];
                if (role == 'tenant') {
                  return Tenantdashboard();
                } else if (role == 'landlord') {
                  return Landlorddashboard();
                }
              }
              return LoginPage(onTap: null);
            },
          );
        } else {
          // User is not signed in
          return LoginPage(onTap: null);
        }
      },
    );
  }
}
