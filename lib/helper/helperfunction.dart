import 'package:cloud_firestore/cloud_firestore.dart';

/// Fetches the role of the user (tenant or landlord) based on their email.
Future<String> getUserRole(String email) async {
  try {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("Users").doc(email).get();
    if (userDoc.exists) {
      return userDoc['role'] ?? 'unknown';
    } else {
      throw Exception("User not found");
    }
  } catch (e) {
    // Log error or handle it gracefully
    return 'unknown';
  }
}
