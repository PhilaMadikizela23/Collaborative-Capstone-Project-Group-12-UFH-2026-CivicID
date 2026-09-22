import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
              'Help & Support',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'CivicID prototype assistance',
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
              maxWidth: 850,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 25),
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    color: Color(0xFF14251C),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _faq(
                  'How do I add a document?',
                  'Open Document Wallet and select Add Document. Choose a document type and upload a file or image.',
                ),
                _faq(
                  'How do I track an application?',
                  'Open My Applications and select an application to view its CivicID prototype status and history.',
                ),
                _faq(
                  'What does Pending Verification mean?',
                  'The document has been uploaded but has not yet been reviewed by the CivicID prototype administrator.',
                ),
                _faq(
                  'Is CivicID an official government service?',
                  'No. CivicID is an academic prototype created for demonstration purposes.',
                ),
                const SizedBox(height: 25),
                const Text(
                  'Contact Support',
                  style: TextStyle(
                    color: Color(0xFF14251C),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(18),
                    border: Border.all(
                      color: borderColor,
                    ),
                  ),
                  child: _contactItem(
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle:
                    'support@civicid.app',
                    onTap: () =>
                        _openEmail(context),
                  ),
                ),
                const SizedBox(height: 20),
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
            Icons.help_outline_rounded,
            color: Colors.white,
            size: 40,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'How Can We Help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Find answers about using the CivicID academic prototype.',
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

  Widget _faq(
      String question,
      String answer,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: ExpansionTile(
        iconColor: civicGreen,
        collapsedIconColor: civicGreen,
        title: Text(
          question,
          style: const TextStyle(
            color: darkGreen,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            child: Text(
              answer,
              style: const TextStyle(
                color: textGrey,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: lightGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: civicGreen,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: darkGreen,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: textGrey,
          fontSize: 9,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: textGrey,
      ),
      onTap: onTap,
    );
  }

  Future<void> _openEmail(
      BuildContext context,
      ) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@civicid.app',
      queryParameters: {
        'subject': 'CivicID Support Request',
      },
    );

    try {
      final launched =
      await launchUrl(uri);

      if (!launched &&
          context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open email application.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open email application.',
          ),
        ),
      );
    }
  }

  Widget _prototypeNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Academic Prototype — Support information on this page belongs to the CivicID demonstration project and is not government support.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textGrey,
          fontSize: 9,
          height: 1.5,
        ),
      ),
    );
  }
}