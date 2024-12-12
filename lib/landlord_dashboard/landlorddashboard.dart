import 'package:flutter/material.dart';
import 'package:payapp/landlord_dashboard/homecontentlandlord.dart';
import 'package:payapp/landlord_dashboard/landlord_drawer.dart';
import 'package:payapp/landlord_dashboard/messaging.dart';
import 'package:payapp/landlord_dashboard/notification.dart';
import 'package:payapp/landlord_dashboard/transaction.dart';

class Landlorddashboard extends StatefulWidget {
  const Landlorddashboard({super.key});

  @override
  State<Landlorddashboard> createState() => _Landlorddashboard();
}

class _Landlorddashboard extends State<Landlorddashboard> {
  int _currentIndex = 0; // Track the currently selected page

  // List of pages
  final List<Widget> _pages = [
    const Homecontentlandlord(),
    const Transaction(), // Replace with your actual page classes
    const Notificationpage(),
    const Messaging(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LandlordDrawer(),
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        currentIndex: _currentIndex, // Set the current index
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the selected index
          });
        },
        selectedItemColor:
            Color.fromARGB(255, 12, 112, 117), // Color for selected icons
        unselectedItemColor: Colors.grey, // Color for unselected icons
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'Transaction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
