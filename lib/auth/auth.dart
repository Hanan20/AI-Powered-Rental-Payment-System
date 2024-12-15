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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is signed in; get their role and navigate
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("Users")
                .doc(snapshot.data!.email)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasData && userSnapshot.data != null) {
                final userRole = userSnapshot.data!['role'];
                final userEmail = snapshot.data!.email!;
                if (userRole == 'tenant') {
                  return Tenantdashboard(
                    tenantEmail: userEmail,
                    landlordEmail: userSnapshot
                        .data!['landlordEmail'], // Fetch landlord email
                  );
                } else if (userRole == 'landlord') {
                  return Landlorddashboard(
                    landlordEmail: userEmail,
                    tenantEmail:
                        userSnapshot.data!['tenantEmail'], // Fetch tenant email
                  );
                }
              }
              return const LoginPage(onTap: null);
            },
          );
        } else {
          // User is not signed in
          return const LoginPage(onTap: null);
        }
      },
    );
  }
}
