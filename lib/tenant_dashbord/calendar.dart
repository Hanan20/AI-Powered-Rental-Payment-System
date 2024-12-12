import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? recentPaymentDate;
  DateTime? nextPaymentDate;
  int? daysRemaining;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  Future<void> _loadDates() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final recentPaymentString = data['recentPaymentDate'];
          final nextPaymentString = data['nextPaymentDate'];

          setState(() {
            if (recentPaymentString != null) {
              recentPaymentDate = DateTime.parse(recentPaymentString);
            }
            if (nextPaymentString != null) {
              nextPaymentDate = DateTime.parse(nextPaymentString);
              daysRemaining =
                  nextPaymentDate!.difference(DateTime.now()).inDays;
            }
          });
        }
      }
    }
  }

  Future<void> _saveDates() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'recentPaymentDate': recentPaymentDate?.toIso8601String(),
        'nextPaymentDate': nextPaymentDate?.toIso8601String(),
      });
    }
  }

  void _updateNextPaymentDate() {
    if (recentPaymentDate != null) {
      final nextPayment = recentPaymentDate!.add(Duration(days: 30));
      setState(() {
        nextPaymentDate = nextPayment;
        daysRemaining = nextPaymentDate!.difference(DateTime.now()).inDays;
      });
      _saveDates();
    }
  }

  void _selectDate(BuildContext context, bool isRecentPayment) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isRecentPayment) {
          recentPaymentDate = pickedDate;
        }
      });

      await _saveDates();
      _updateNextPaymentDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final circleSize = screenSize.height * 0.5;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Payment Tracker",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 7, 46, 51),
              ),
            ),
            const SizedBox(height: 20),
            // Circular progress indicator for days remaining
            if (daysRemaining != null)
              Center(
                child: CircularPercentIndicator(
                  radius: 120.0, // Circle radius
                  lineWidth: 13.0, // Width of the progress bar
                  percent: (daysRemaining! > 0 ? daysRemaining! / 30 : 0.0)
                      .clamp(
                          0.0, 1.0), // Clamping the value between 0.0 and 1.0
                  backgroundColor: Color.fromARGB(255, 109, 165, 192),
                  progressColor: daysRemaining! > 0 ? Colors.green : Colors.red,
                  center: Text(
                    daysRemaining! > 0 ? "$daysRemaining Days" : "Overdue!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: daysRemaining! > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _selectDate(context, true),
              icon: const Icon(Icons.calendar_today),
              label: const Text(
                "Select Recent Payment Date",
                style: TextStyle(color: Color.fromARGB(255, 109, 165, 192)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 7, 46, 51),
              ),
            ),
            if (recentPaymentDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Recent Payment Date: ${DateFormat.yMMMd().format(recentPaymentDate!)}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _selectDate(context, false),
              icon: const Icon(Icons.event),
              label: const Text(
                "Select Next Payment Date",
                style: TextStyle(color: Color.fromARGB(255, 109, 165, 192)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 7, 46, 51),
              ),
            ),
            if (nextPaymentDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Next Payment Date: ${DateFormat.yMMMd().format(nextPaymentDate!)}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
