import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payapp/tenant_dashbord/Paymentpage.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({Key? key}) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  late Future<List<QueryDocumentSnapshot>> _invoiceFuture;
  String? _tenantEmail;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  // Fetch invoices for the logged-in user
  void _fetchInvoices() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _tenantEmail = user.email;
      _invoiceFuture = FirebaseFirestore.instance
          .collection('invoices')
          .where('tenantEmail', isEqualTo: _tenantEmail)
          .get()
          .then((snapshot) => snapshot.docs)
          .catchError((error) {
        print("Error fetching invoices: $error");
        return <QueryDocumentSnapshot>[]; // Return empty list on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invoices',
          style: TextStyle(color: Color.fromARGB(255, 235, 238, 238)),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 112, 117),
      ),
      body: _tenantEmail == null
          ? const Center(child: Text('No user is logged in.'))
          : FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _invoiceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print("Firestore error: ${snapshot.error}");
                  return Center(
                      child:
                          Text('Error fetching invoices: ${snapshot.error}'));
                }
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  print("No invoices found for user: $_tenantEmail");
                  return const Center(child: Text('No invoices found.'));
                }

                final invoices = snapshot.data!;

                return ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    final propertyId = invoice['propertyID'];
                    final rentAmount = invoice['rentAmount'];
                    final landlordEmail = invoice['landlordEmail'];
                    final dueDate = (invoice['dueDate'] as Timestamp).toDate();
                    final paid = invoice['paid'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Property ID: $propertyId'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rent Amount: UGX $rentAmount'),
                            Text('Landlord: $landlordEmail'),
                            Text(
                                'Due Date: ${dueDate.toLocal().toString().split(' ')[0]}'),
                            Text('Paid: ${paid ? "Yes" : "No"}'),
                          ],
                        ),
                        trailing: paid
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : ElevatedButton(
                                onPressed: () {
                                  // Navigate to Payment Page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentPage(
                                        invoiceId:
                                            invoice.id, // Firestore doc ID
                                        propertyId: propertyId,
                                        rentAmount: rentAmount.toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Pay Now'),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
