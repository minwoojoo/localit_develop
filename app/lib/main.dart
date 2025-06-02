import 'package:flutter/material.dart';
import 'package:localit/screens/home_screen.dart';
import 'package:localit/screens/explore_screen.dart';
import 'package:localit/screens/chat_screen.dart';
import 'package:localit/screens/profile_screen.dart';
import 'package:localit/screens/menu_screen.dart';
import 'package:localit/screens/onboarding_screen.dart';
import 'package:localit/screens/login_screen.dart';
import 'package:localit/screens/purchase_screen.dart';

void main() {
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
        '/main': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PurchaseScreen(),
    const ChatScreen(),
    const ProfileScreen(),
    const MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: '구매대행',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send_outlined),
            label: '메시지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inclusive),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '메뉴',
          ),
        ],
      ),
    );
  }
}
