import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String? invoiceId;
  final String? propertyId;
  final String? rentAmount;

  const PaymentPage({
    Key? key,
    this.invoiceId,
    this.propertyId,
    this.rentAmount,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Payment',
            style: TextStyle(color: Color.fromARGB(255, 235, 238, 238)),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 112, 117),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isProcessing
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Property: ${widget.propertyId}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amount Due: UGX ${widget.rentAmount}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _dummyPayment,
                    child: const Text('Pay'),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _dummyPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate a payment process (e.g., 2-second delay)
    await Future.delayed(const Duration(seconds: 2));

    // After "successful" dummy payment, mark invoice as paid
    try {
      await FirebaseFirestore.instance
          .collection('invoices')
          .doc(widget.invoiceId)
          .update({'paid': true});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful!')),
      );

      // Go back to previous page (InvoicePage), possibly refresh
      Navigator.pop(context);
    } catch (e) {
      print('Error updating invoice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Please try again.')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
