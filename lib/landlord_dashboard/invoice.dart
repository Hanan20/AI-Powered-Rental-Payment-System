import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({Key? key}) : super(key: key);

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  final _tenantEmailController = TextEditingController();
  final _propertyIdController = TextEditingController();
  final _rentAmountController = TextEditingController();
  DateTime? _dueDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Invoice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tenant Email
            TextField(
              controller: _tenantEmailController,
              decoration: InputDecoration(
                labelText: 'Tenant Email',
              ),
            ),

            // Property ID
            TextField(
              controller: _propertyIdController,
              decoration: InputDecoration(
                labelText: 'Property ID',
              ),
            ),

            // Rent Amount
            TextField(
              controller: _rentAmountController,
              decoration: InputDecoration(
                labelText: 'Rent Amount',
              ),
              keyboardType: TextInputType.number,
            ),

            // Due Date Picker (example)
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _dueDate = date;
                  });
                }
              },
              child: Text(_dueDate == null
                  ? 'Pick Due Date'
                  : 'Due Date: ${_dueDate!.toLocal()}'),
            ),

            // Submit Button
            ElevatedButton(
              onPressed: _createInvoice,
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createInvoice() async {
    // Get the currently logged-in landlord’s email
    final user = FirebaseAuth.instance.currentUser;
    final landlordEmail = user?.email ?? '';

    final tenantEmail = _tenantEmailController.text.trim();
    final propertyId = _propertyIdController.text.trim();
    final rentAmount = _rentAmountController.text.trim();
    final dueDate = _dueDate ?? DateTime.now();

    // Validate inputs...
    if (tenantEmail.isEmpty || propertyId.isEmpty || rentAmount.isEmpty) {
      // Show an error or validation message
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('invoices').add({
        'landlordEmail': landlordEmail,
        'tenantEmail': tenantEmail,
        'propertyID': propertyId,
        'rentAmount': rentAmount,
        'dueDate': Timestamp.fromDate(dueDate),
        'paid': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Pop back or show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice created successfully!')),
      );
      Navigator.pop(context); // or similar
    } catch (e) {
      print('Error creating invoice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create invoice.')),
      );
    }
  }
}
