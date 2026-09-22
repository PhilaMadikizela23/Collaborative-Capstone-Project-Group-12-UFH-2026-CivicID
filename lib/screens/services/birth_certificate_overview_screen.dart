import 'package:flutter/material.dart';

import '../../models/government_service.dart';
import 'birth_service_type_screen.dart';

class BirthCertificateOverviewScreen extends StatelessWidget {
  final GovernmentService service;

  const BirthCertificateOverviewScreen({
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
          'Birth Certificate Overview',
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
          18,
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
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _hero(),

                const SizedBox(height: 20),

                _sectionCard(
                  title: 'Before you apply',
                  child: Column(
                    children: [
                      _checkItem(
                        'Check the person’s names and birth details carefully.',
                      ),
                      _checkItem(
                        'Prepare the supporting documents requested in the application.',
                      ),
                      _checkItem(
                        'Confirm parent or guardian information where applicable.',
                      ),
                      _checkItem(
                        'Make sure names and dates match the supporting documents.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _stepsCard(
                  const [
                    'Choose certificate service type',
                    'Enter personal details',
                    'Enter birth or parent details',
                    'Upload supporting documents',
                    'Review the application',
                    'Submit the application',
                  ],
                ),

                const SizedBox(height: 18),

                _tipCard(
                  'Check spelling, names and dates carefully before submitting the application.',
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BirthServiceTypeScreen(
                                service: service,
                              ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                    ),
                    label: const Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: civicGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    'Academic Prototype — not an official government service.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/birth_certificate_overview_image.png',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }

  Widget _checkItem(
      String text,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: birthOrange,
            size: 21,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: textGrey,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepsCard(
      List<String> steps,
      ) {
    return _sectionCard(
      title: 'Application steps',
      child: Column(
        children: List.generate(
          steps.length,
              (index) => Padding(
            padding: const EdgeInsets.only(
              bottom: 13,
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration:
                  const BoxDecoration(
                    color: birthLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: birthOrange,
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 5,
                    ),
                    child: Text(
                      steps[index],
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tipCard(
      String text,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: birthLight,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: birthOrange,
            size: 24,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF8A4500),
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}