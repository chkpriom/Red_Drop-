import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Import all screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/find_donors_screen.dart';
import 'screens/donate_blood_screen.dart';
import 'screens/donation_history_screen.dart';
import 'screens/request_blood_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/EditProfileScreen.dart'; // ✅ Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RedDropApp());
}

class RedDropApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RedDrop',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      initialRoute: '/', // Splash screen initial
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/find_donors': (context) => FindDonorsScreen(),
        '/donate_blood': (context) => DonateBloodScreen(),
        '/donation_history': (context) => DonationHistoryScreen(),
        '/request_blood': (context) => RequestBloodScreen(),
        '/profile': (context) => ProfileScreen(),
        '/edit_profile': (context) => EditProfileScreen(), // ✅ New route
      },
    );
  }
}
