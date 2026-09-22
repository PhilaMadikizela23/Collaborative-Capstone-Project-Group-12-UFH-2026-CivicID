import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(),

                // Logo box
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: civicGreen.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    size: 70,
                    color: civicGreen,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'CivicID',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Your Digital Citizen Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF607069),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Simpler Applications.\nA Brighter South Africa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 22,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD7E8DD),
                    ),
                  ),
                  child: const Text(
                    '🇿🇦 South Africa',
                    style: TextStyle(
                      color: civicGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const Spacer(),

                const CircularProgressIndicator(
                  color: civicGreen,
                  strokeWidth: 3,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Academic Prototype',
                  style: TextStyle(
                    color: civicGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Not an official government service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8A9690),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}