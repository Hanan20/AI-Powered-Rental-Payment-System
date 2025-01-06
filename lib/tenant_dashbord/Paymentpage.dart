import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterwave_standard_smart/flutterwave.dart';

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
                    onPressed: () => handlePaymentInitialization(),
                    child: const Text('Pay'),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> handlePaymentInitialization() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Set up the customer details
      final Customer customer = Customer(
        name: "yasin", // Replace dynamically
        phoneNumber: "0760564547", // Replace dynamically
        email: "yasin@gmail.com", // Replace dynamically
      );

      // Initialize the Flutterwave payment
      final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey:
            "FLWPUBK_TEST-fb982e12991315330487facf1b7f1e9d-X", // Replace with your Flutterwave public key
        currency: "UGX",
        redirectUrl:
            "https://your-redirect-url.com", // Replace with your redirect URL
        txRef:
            "TX-${DateTime.now().millisecondsSinceEpoch}", // Unique transaction reference
        amount: widget.rentAmount ?? "30000", // Rent amount to pay
        customer: customer,
        paymentOptions: "card, mobilemoneyuganda, ussd",
        customization: Customization(
          title: "Rent Payment",
        ),
        isTestMode: true, // Set to false for live mode
      );

      // Handle payment response
      final response = await flutterwave.charge();

      if (response != null && response.status == "success") {
        // Payment successful, mark the invoice as paid
        await FirebaseFirestore.instance
            .collection('invoices')
            .doc(widget.invoiceId)
            .update({'paid': true});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful!')),
        );

        Navigator.pop(context);
      } else {
        // Payment failed or canceled
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response != null
                  ? 'Payment failed: ${response.status}'
                  : 'Payment failed: Unknown error',
            ),
          ),
        );
      }
    } catch (e) {
      // Handle errors
      print('Error initializing payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Payment initialization failed. Please try again.')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
