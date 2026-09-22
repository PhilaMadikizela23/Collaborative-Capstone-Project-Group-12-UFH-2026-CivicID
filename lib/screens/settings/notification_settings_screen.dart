import 'package:flutter/material.dart';

class NotificationSettingsScreen
    extends StatefulWidget {
  const NotificationSettingsScreen({
    super.key,
  });

  @override
  State<NotificationSettingsScreen>
  createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);

  bool _applicationUpdates = true;
  bool _securityAlerts = true;
  bool _documentUpdates = true;
  bool _generalUpdates = false;

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
              'Notification Settings',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Choose the updates you want to see',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          40,
        ),
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 850,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 24),
                  _sectionTitle(
                    'Application Notifications',
                  ),
                  const SizedBox(height: 10),
                  _toggle(
                    'Application Updates',
                    'Receive updates when your CivicID application status changes.',
                    _applicationUpdates,
                        (value) {
                      setState(() {
                        _applicationUpdates =
                            value;
                      });
                    },
                  ),
                  _toggle(
                    'Security Alerts',
                    'Receive prototype account security notifications.',
                    _securityAlerts,
                        (value) {
                      setState(() {
                        _securityAlerts = value;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  _sectionTitle(
                    'Document Notifications',
                  ),
                  const SizedBox(height: 10),
                  _toggle(
                    'Document Updates',
                    'Receive verification and rejection updates for uploaded documents.',
                    _documentUpdates,
                        (value) {
                      setState(() {
                        _documentUpdates = value;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  _sectionTitle(
                    'General',
                  ),
                  const SizedBox(height: 10),
                  _toggle(
                    'General CivicID Updates',
                    'Receive general prototype feature updates.',
                    _generalUpdates,
                        (value) {
                      setState(() {
                        _generalUpdates = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _prototypeNotice(),
                ],
              ),
            ),
          ),
        ],
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
            Icons.notifications_active_outlined,
            color: Colors.white,
            size: 38,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Preferences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Control the CivicID alerts displayed to you.',
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

  Widget _sectionTitle(
      String title,
      ) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: civicGreen,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _toggle(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: SwitchListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: darkGreen,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 3,
          ),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: textGrey,
              fontSize: 9,
              height: 1.4,
            ),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: civicGreen,
        activeTrackColor:
        civicGreen.withValues(
          alpha: 0.25,
        ),
      ),
    );
  }

  Widget _prototypeNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Text(
        'Academic Prototype — These preferences currently control demonstration settings only.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textGrey,
          fontSize: 9,
        ),
      ),
    );
  }
}