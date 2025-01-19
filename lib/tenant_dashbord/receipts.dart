import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ReceiptsPage extends StatelessWidget {
  const ReceiptsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('receipts')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('All Receipts')),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No receipts found.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final receiptId = data['receiptId'] ?? '';
              final invoiceId = data['invoiceId'] ?? '';
              final propertyId = data['propertyId'] ?? '';
              final rentAmount = data['rentAmount'] ?? '';
              final flutterwaveTxRef = data['flutterwaveTxRef'] ?? 'N/A';
              final createdAt =
                  data['createdAt'] as Timestamp?; // Firestore Timestamp
              final date = createdAt != null
                  ? DateFormat('dd MMM yyyy, hh:mm a')
                      .format(createdAt.toDate())
                  : 'Date not available';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Receipt #$receiptId'),
                  subtitle: Text(
                      'Invoice ID: $invoiceId\nProperty: $propertyId\nAmount: UGX $rentAmount\nDate: $date'),
                  trailing: Text('TxRef: $flutterwaveTxRef'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
