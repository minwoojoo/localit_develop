import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:localit/screens/matching/home_screen.dart';
import 'package:localit/screens/chat/chat_screen.dart';
import 'package:localit/screens/auth/profile_screen.dart';
import 'package:localit/screens/common/menu_screen.dart';
import 'package:localit/screens/common/onboarding_screen.dart';
import 'package:localit/screens/auth/login_screen.dart';
import 'package:localit/screens/commerce/purchase_agency_screen.dart';
import 'package:localit/screens/community/community_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '로컬잇',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) =>
            const HomeScreen(), // MainScreen 대신 HomeScreen으로 직접 연결
      },
    );
  }
}
