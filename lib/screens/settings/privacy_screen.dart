import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy & Data',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Prototype data information',
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
            constraints:
            const BoxConstraints(
              maxWidth: 850,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 24),
                _section(
                  Icons.person_outline_rounded,
                  'Data Entered in CivicID',
                  'The prototype may contain profile information, application details and document metadata entered while testing the system.',
                ),
                _section(
                  Icons.storage_outlined,
                  'Prototype Storage',
                  'This current academic version uses demonstration data structures. It is not connected to an official government database.',
                ),
                _section(
                  Icons.share_outlined,
                  'Third-Party Sharing',
                  'The academic prototype does not represent an official data-sharing arrangement with government agencies or commercial organisations.',
                ),
                _section(
                  Icons.admin_panel_settings_outlined,
                  'Your Control',
                  'Users should only enter test or demonstration information while CivicID is being developed and evaluated.',
                ),
                const SizedBox(height: 10),
                _prototypeNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            darkGreen,
            civicGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: Colors.white,
            size: 39,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy & Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Understand how information is treated in this academic prototype.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
      IconData icon,
      String title,
      String content,
      ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 11,
      ),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: civicGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _prototypeNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFCFE5D7),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.school_outlined,
            color: civicGreen,
            size: 18,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Academic Prototype — Do not enter sensitive real-world personal information while testing CivicID.',
              style: TextStyle(
                color: darkGreen,
                fontSize: 9,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}