
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth/login_page.dart';
import 'main_navigation_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    Widget nextPage;

    if (user != null) {
      nextPage = const MainNavigationPage();
    } else {
      nextPage = const LoginPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => nextPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1976D2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.science_rounded,
              size: 90,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'LabInventory',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sistem Inventaris Alat Laboratorium',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 35),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
