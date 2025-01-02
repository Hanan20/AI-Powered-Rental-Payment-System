import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:payapp/api/firebase_api.dart';
import 'package:payapp/auth/auth.dart';
import 'package:payapp/auth/login_or_register.dart';
import 'package:payapp/landlord_dashboard/Properties.dart';
import 'package:payapp/landlord_dashboard/landlorddashboard.dart';
import 'package:payapp/landlord_dashboard/paymentanalysis.dart';
import 'package:payapp/landlord_dashboard/invoice.dart';
import 'package:payapp/login_page.dart';
import 'package:payapp/register.dart';
import 'package:payapp/tenant_dashbord/calendar.dart';
import 'package:payapp/tenant_dashbord/invoices.dart';
import 'package:payapp/tenant_dashbord/notification.dart';
import 'package:payapp/tenant_dashbord/profile.dart';
import 'package:payapp/tenant_dashbord/tenantdashboard.dart';
import 'package:payapp/themes/dark_mode.dart';
import 'package:payapp/themes/light_mode.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), // AuthWrapper determines the dashboard to show
      darkTheme: DarkMode,
      theme: LightMode,
      themeMode: ThemeMode.light,
      navigatorKey: navigatorKey,
      routes: {
        '/register': (context) => Register(onTap: () => Navigator.pop(context)),

        // Tenant Dashboard
        '/tenantdashboard': (context) => Tenantdashboard(
              tenantEmail: 'yasin@gmail.com', // Replace dynamically
              landlordEmail: 'saimas@gmail.com', // Replace dynamically
            ),

        // Landlord Dashboard
        '/landlorddashboard': (context) => Landlorddashboard(
              landlordEmail: 'saimas@gmail.com', // Replace dynamically
              tenantEmail: 'yasin@gmail.com', // Replace dynamically
            ),

        '/notificationPage': (context) => const NotificationPage(),
        '/calendar': (context) => const CalendarPage(),
        '/profile_page': (context) => ProfilePage(),
        '/paymentanalysis': (context) => Paymentanalysis(),
        '/Properties': (context) => const Properties(),
        '/CreateInvoicePage': (context) => const CreateInvoicePage(),
        '/paymentanalysis': (context) => const Paymentanalysis(),
        '/invoices': (context) {
          return const InvoicePage();
        },
      },
    );
  }
}
