import 'package:flutter/material.dart';
import 'package:payapp/components/my_drawer.dart';
import 'package:payapp/tenant_dashbord/Paymentpage.dart';
import 'package:payapp/tenant_dashbord/homecontent.dart';
import 'package:payapp/tenant_dashbord/messaging.dart';
import 'package:payapp/tenant_dashbord/notification.dart';

class Tenantdashboard extends StatefulWidget {
  const Tenantdashboard({super.key});

  @override
  State<Tenantdashboard> createState() => _HomepageState();
}

class _HomepageState extends State<Tenantdashboard> {
  int _currentIndex = 0; // Track the currently selected page

  // List of pages
  final List<Widget> _pages = [
    const HomeContent(), // Replace with your actual page classes
    const Paymentpage(),
    const NotificationPage(),
    Messaging(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
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
            label: 'Payment',
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
