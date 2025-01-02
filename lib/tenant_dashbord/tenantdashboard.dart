import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payapp/chat_page.dart';
import 'package:payapp/components/my_drawer.dart';
import 'package:payapp/tenant_dashbord/Paymentpage.dart';
import 'package:payapp/tenant_dashbord/homecontent.dart';
import 'package:payapp/tenant_dashbord/notification.dart';

class Tenantdashboard extends StatefulWidget {
  final String tenantEmail; // Tenant's email passed to dashboard
  final String landlordEmail; // Landlord's email to chat with

  const Tenantdashboard({
    super.key,
    required this.tenantEmail,
    required this.landlordEmail,
  });

  @override
  State<Tenantdashboard> createState() => _HomepageState();
}

class _HomepageState extends State<Tenantdashboard> {
  int _currentIndex = 0;

  // List of pages
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeContent(),
      PaymentPage(),
      const NotificationPage(),
      const SizedBox(), // Placeholder for Chat navigation, as we will push it separately
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      body: _currentIndex == 3
          ? const SizedBox() // Placeholder, as ChatPage is navigated separately
          : _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            // Navigate to the ChatPage when the "Chat" tab is clicked
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  landlordEmail:
                      widget.landlordEmail, // Pass actual landlord email
                  tenantEmail: widget.tenantEmail, // Pass actual tenant email
                ),
              ),
            );
          } else {
            setState(() {
              _currentIndex = index; // Update the current index for other tabs
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
