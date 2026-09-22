import 'package:flutter/material.dart';

import '../../models/government_service.dart';
import '../application/application_assistant_screen.dart';

class BirthServiceTypeScreen extends StatelessWidget {
  final GovernmentService service;

  const BirthServiceTypeScreen({
    super.key,
    required this.service,
  });

  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);

  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF52635B);
  static const Color darkText = Color(0xFF14251C);

  static const Color birthOrange = Color(0xFFF57C00);
  static const Color birthLight = Color(0xFFFFF0DE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Birth Certificate Service',
          style: TextStyle(
            color: darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          22,
          20,
          36,
        ),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 760,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What would you like to do?',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Choose the birth-related service you want to prepare.',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 22),

                _serviceOption(
                  context: context,
                  icon: Icons.child_care_rounded,
                  iconColor: birthOrange,
                  iconBackground: birthLight,
                  title: 'Register a Birth for the First Time',
                  subtitle:
                  'For a child whose birth has not yet been registered.',
                  badge: 'IN-PERSON PROCESS',
                  onTap: () {
                    _showFirstBirthInformation(context);
                  },
                ),

                const SizedBox(height: 14),

                _serviceOption(
                  context: context,
                  icon: Icons.content_copy_rounded,
                  iconColor: civicGreen,
                  iconBackground: lightGreen,
                  title: 'Request a Birth Certificate Copy',
                  subtitle:
                  'Continue with the CivicID application preparation flow.',
                  badge: 'CONTINUE IN CIVICID',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ApplicationAssistantScreen(
                              service: service,
                            ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                _serviceOption(
                  context: context,
                  icon: Icons.edit_note_rounded,
                  iconColor: civicGreen,
                  iconBackground: lightGreen,
                  title: 'Update / Correct Birth Details',
                  subtitle:
                  'Prepare information for a correction or amendment request.',
                  badge: 'PROTOTYPE FLOW',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ApplicationAssistantScreen(
                              service: service,
                            ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                _prototypeNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 11),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8A9690),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFirstBirthInformation(
      BuildContext context,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            28,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: birthLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.family_restroom_rounded,
                    color: birthOrange,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'First Birth Registration',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 9),

                const Text(
                  'This CivicID prototype does not allow a first birth registration to be completed as a normal online application.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: birthLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.person_rounded,
                        text:
                        'A parent or another qualifying person must handle the birth registration process.',
                      ),

                      SizedBox(height: 12),

                      _InfoRow(
                        icon: Icons.apartment_rounded,
                        text:
                        'The registration may involve Home Affairs or a connected health facility.',
                      ),

                      SizedBox(height: 12),

                      _InfoRow(
                        icon: Icons.info_outline_rounded,
                        text:
                        'CivicID can help explain what to prepare, but it will not submit the first registration.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: civicGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'I UNDERSTAND',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _prototypeNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.school_outlined,
            color: textGrey,
            size: 20,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Academic Prototype — CivicID helps users prepare information. It does not register births or issue official certificates.',
              style: TextStyle(
                color: textGrey,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: BirthServiceTypeScreen.birthOrange,
          size: 21,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: BirthServiceTypeScreen.darkText,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}