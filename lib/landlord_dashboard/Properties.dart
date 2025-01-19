import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropertyPage extends StatefulWidget {
  const PropertyPage({Key? key}) : super(key: key);

  @override
  State<PropertyPage> createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
  final _auth = FirebaseAuth.instance;
  String? landlordEmail;

  @override
  void initState() {
    super.initState();
    // If landlord is logged in, get their email
    final user = _auth.currentUser;
    if (user != null) {
      landlordEmail = user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (landlordEmail == null) {
      return const Scaffold(
        body: Center(child: Text('No landlord is logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
        backgroundColor: const Color.fromARGB(255, 12, 112, 117),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePropertyDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('properties')
            .where('landlordEmail', isEqualTo: landlordEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No properties found.'));
          }

          final propertyDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: propertyDocs.length,
            itemBuilder: (context, index) {
              final doc = propertyDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              final propertyName = data['propertyName'] ?? 'Unnamed';
              final address = data['address'] ?? 'No address';
              final assignedTenant = data['tenantEmail'] ?? 'Unassigned';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(propertyName),
                  subtitle: Text('$address\nTenant: $assignedTenant'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.person_add),
                    tooltip: 'Assign Tenant',
                    onPressed: () => _showAssignTenantDialog(docId),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Show a dialog or bottom sheet to create a new property
  void _showCreatePropertyDialog() {
    final propertyNameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Property'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: propertyNameController,
                decoration: const InputDecoration(labelText: 'Property Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // cancel
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = propertyNameController.text.trim();
                final address = addressController.text.trim();

                if (name.isNotEmpty && address.isNotEmpty) {
                  await _createProperty(name, address);
                }
                Navigator.pop(context);
              },
              child: const Text('Create'),
            )
          ],
        );
      },
    );
  }

  /// Actually create the property doc in Firestore
  Future<void> _createProperty(String name, String address) async {
    if (landlordEmail == null) return;

    try {
      await FirebaseFirestore.instance.collection('properties').add({
        'landlordEmail': landlordEmail,
        'propertyName': name,
        'address': address,
        'tenantEmail': null, // no tenant assigned initially
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating property: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create property.')),
      );
    }
  }

  /// Show a dialog to assign a tenant to a property
  void _showAssignTenantDialog(String propertyDocId) {
    final tenantEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Tenant'),
          content: TextField(
            controller: tenantEmailController,
            decoration: const InputDecoration(labelText: 'Enter Tenant Email'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // cancel
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final tenantEmail = tenantEmailController.text.trim();
                if (tenantEmail.isNotEmpty) {
                  await _assignTenant(propertyDocId, tenantEmail);
                }
                Navigator.pop(context);
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
  }

  /// Assign tenant by updating the property doc with tenantEmail
  Future<void> _assignTenant(String propertyDocId, String tenantEmail) async {
    try {
      // 1. Update the property doc
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyDocId)
          .update({'tenantEmail': tenantEmail});

      // 2. Optionally, update the tenant's user doc to store the landlord
      final tenantSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: tenantEmail)
          .limit(1)
          .get();

      if (tenantSnapshot.docs.isNotEmpty) {
        final tenantDocId = tenantSnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(tenantDocId)
            .update({'landlordEmail': landlordEmail});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tenant assigned successfully!')),
      );
    } catch (e) {
      debugPrint('Error assigning tenant: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to assign tenant.')),
      );
    }
  }
}
