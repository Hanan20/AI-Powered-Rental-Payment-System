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
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  /// Check Firestore to see if invoice is already paid.
  Future<void> _checkPaymentStatus() async {
    if (widget.invoiceId != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('invoices')
            .doc(widget.invoiceId)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['paid'] == true) {
            setState(() => _isPaid = true);
          }
        }
      } catch (e) {
        print("Error checking payment status: $e");
      }
    }
  }

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
                  ElevatedButton.icon(
                    onPressed: _isPaid ? null : _handlePaymentInitialization,
                    icon: _isPaid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.payment),
                    label: Text(_isPaid ? 'Paid' : 'Pay Now'),
                  ),
                ],
              ),
      ),
    );
  }

  /// 1) Immediately mark invoice as paid (no matter what).
  /// 2) Create a separate 'receipts' doc.
  /// 3) Then proceed with Flutterwave payment. If success, update the receipt doc with the transaction ref.
  Future<void> _handlePaymentInitialization() async {
    // If there's no invoiceId, we can't do anything
    if (widget.invoiceId == null) return;

    setState(() => _isProcessing = true);

    try {
      // ---------------------------------------------------
      // STEP 1: Mark the invoice as paid RIGHT AWAY
      // ---------------------------------------------------
      await _markInvoicePaidImmediately();

      // ---------------------------------------------------
      // STEP 2: Create a receipt document in 'receipts'
      // ---------------------------------------------------
      final receiptId = await _createReceiptDoc();

      // Show invoice as paid locally:
      setState(() => _isPaid = true);

      // Optionally, show a quick notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice marked as paid.')),
      );

      // ---------------------------------------------------
      // STEP 3: Now attempt the real Flutterwave payment
      // ---------------------------------------------------
      final Customer customer = Customer(
        name: "yasin", // or actual tenant name
        phoneNumber: "0760564547",
        email: "yasin@gmail.com",
      );

      final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey: "FLWPUBK_TEST-fb982e12991315330487facf1b7f1e9d-X",
        currency: "UGX",
        redirectUrl: "https://your-redirect-url.com",
        txRef: "TX-${DateTime.now().millisecondsSinceEpoch}",
        amount: widget.rentAmount ?? "30000",
        customer: customer,
        paymentOptions: "card, mobilemoneyuganda, ussd",
        customization: Customization(
          title: "Rent Payment",
        ),
        isTestMode: true,
      );

      final response = await flutterwave.charge();

      if (response != null && response.status == "success") {
        // Payment successful on Flutterwave side
        // Optionally update the receipt doc with the transaction reference
        await _updateReceiptWithTxRef(receiptId, response.txRef);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful!')),
        );
      } else {
        // Payment failed or canceled on Flutterwave side
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

      // We do NOT revert the invoice to unpaid, as per your requirement.
      Navigator.pop(context);
    } catch (e) {
      print("Error initializing payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Payment initialization failed. Please try again.')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// Immediately sets 'paid = true' in the invoice doc.
  /// Also calls '_sendNotification()' to record a success notification.
  Future<void> _markInvoicePaidImmediately() async {
    try {
      await FirebaseFirestore.instance
          .collection('invoices')
          .doc(widget.invoiceId)
          .update({'paid': true});

      print("Invoice ${widget.invoiceId} marked as paid (immediately).");

      // Optionally, send a success notification
      await _sendNotification();
    } catch (e) {
      print("Error marking invoice as paid: $e");
    }
  }

  /// Create a separate receipt doc in 'receipts' collection with basic info.
  Future<String> _createReceiptDoc() async {
    final receiptRef = FirebaseFirestore.instance.collection('receipts').doc();
    final receiptNumber = "RCPT-${DateTime.now().millisecondsSinceEpoch}";

    await receiptRef.set({
      'receiptId': receiptRef.id,
      'invoiceId': widget.invoiceId,
      'propertyId': widget.propertyId,
      'rentAmount': widget.rentAmount,
      'receiptNumber': receiptNumber,
      'createdAt': FieldValue.serverTimestamp(),
    });

    print("Created new receipt doc in 'receipts': ${receiptRef.id}");
    return receiptRef.id;
  }

  /// Update the existing receipt doc to store the Flutterwave tx reference.
  Future<void> _updateReceiptWithTxRef(String receiptId, String? txRef) async {
    if (txRef == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('receipts')
          .doc(receiptId)
          .update({'flutterwaveTxRef': txRef});

      print("Updated receipt doc ($receiptId) with Flutterwave txRef: $txRef");
    } catch (e) {
      print("Error updating receipt with txRef: $e");
    }
  }

  /// Send a success notification for invoice payment.
  Future<void> _sendNotification() async {
    try {
      await FirebaseFirestore.instance.collection('Notifications').add({
        'title': 'Payment Successful',
        'body':
            'You have successfully paid UGX ${widget.rentAmount} for Property ID ${widget.propertyId}.',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false, // Default notification as unread
      });
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}
