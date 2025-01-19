import 'package:flutter/material.dart';
import 'package:payapp/chat_page.dart'; // Import the ChatPage
import 'package:payapp/landlord_dashboard/homecontentlandlord.dart';
import 'package:payapp/landlord_dashboard/landlord_drawer.dart';
import 'package:payapp/landlord_dashboard/messaging.dart';
import 'package:payapp/landlord_dashboard/notification.dart';
import 'package:payapp/landlord_dashboard/transaction.dart';

class Landlorddashboard extends StatefulWidget {
  final String landlordEmail; // Landlord's email passed to the dashboard
  final String tenantEmail; // Tenant's email to chat with

  const Landlorddashboard({
    super.key,
    required this.landlordEmail,
    required this.tenantEmail,
  });

  @override
  State<Landlorddashboard> createState() => _LandlorddashboardState();
}

class _LandlorddashboardState extends State<Landlorddashboard> {
  int _currentIndex = 0;

  // List of pages
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Homecontentlandlord(),
      const ReceiptsPage(),
      const Notificationpage(),
      const SizedBox(), // Placeholder for Chat navigation
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LandlordDrawer(),
      body: _currentIndex == 3
          ? const SizedBox() // Placeholder as ChatPage is navigated separately
          : _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            // Navigate to ChatPage when "Chat" is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  landlordEmail: widget.landlordEmail, // Pass landlord email
                  tenantEmail: widget.tenantEmail, // Pass tenant email
                ),
              ),
            );
          } else {
            setState(() {
              _currentIndex = index; // Update the selected index for other tabs
            });
          }
        },
        selectedItemColor: const Color.fromARGB(255, 12, 112, 117),
        unselectedItemColor: Colors.grey,
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
