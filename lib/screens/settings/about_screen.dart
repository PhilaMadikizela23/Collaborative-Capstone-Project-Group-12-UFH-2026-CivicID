import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About CivicID',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'About this academic prototype',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          40,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildInformationCard(),
                const SizedBox(height: 22),
                _buildPrototypeCard(),
                const SizedBox(height: 25),
                const Text(
                  '© 2026 CivicID Academic Project',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            darkGreen,
            civicGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.shield_outlined,
              size: 47,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'CivicID',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Secure Digital Citizen Profile & Application Assistant',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          SizedBox(height: 9),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          _infoRow(
            'Project Type',
            'Academic Prototype',
          ),
          _divider(),
          _infoRow(
            'Category',
            'Digital Citizen Services',
          ),
          _divider(),
          _infoRow(
            'Platform',
            'Flutter',
          ),
          _divider(),
          _infoRow(
            'Purpose',
            'Research & Demonstration',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      color: borderColor,
    );
  }

  Widget _buildPrototypeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFCFE5D7),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.school_outlined,
            color: civicGreen,
            size: 31,
          ),
          SizedBox(height: 10),
          Text(
            'Academic Prototype',
            style: TextStyle(
              color: darkGreen,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'CivicID is developed for academic research and demonstration purposes. It is not an official government website or service and is not connected to any government database.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textGrey,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}