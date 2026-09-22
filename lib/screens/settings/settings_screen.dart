import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/auth_service.dart';
import '../../services/sound_service.dart';

import 'audit_trail_screen.dart';
import 'account_details_screen.dart';
import 'security_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ============================================================
  // CIVICID COLORS
  // ============================================================

  static const Color civicGreen =
  Color(0xFF1F7A3D);

  static const Color darkGreen =
  Color(0xFF145A2A);

  static const Color lightGreen =
  Color(0xFFEAF6EC);

  static const Color pageBackground =
  Color(0xFFF5F7F6);

  static const Color borderColor =
  Color(0xFFDCE5DF);

  static const Color textGrey =
  Color(0xFF667085);

  // ============================================================
  // SOUND SETTINGS
  // ============================================================

  bool _soundEnabled = true;
  bool _loadingSound = true;

  @override
  void initState() {
    super.initState();
    _loadSoundSetting();
  }

  Future<void> _loadSoundSetting() async {
    final enabled =
    await SoundService.isSoundEnabled();

    if (!mounted) return;

    setState(() {
      _soundEnabled = enabled;
      _loadingSound = false;
    });
  }

  Future<void> _changeSoundSetting(
      bool value,
      ) async {
    setState(() {
      _soundEnabled = value;
    });

    await SoundService.setSoundEnabled(
      value,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,

          content: Row(
            children: [
              Icon(
                value
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: Colors.white,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  value
                      ? 'Notification sounds turned on'
                      : 'Notification sounds turned off',
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final authService =
    AuthService();

    return Scaffold(
      backgroundColor:
      pageBackground,

      appBar: AppBar(
        backgroundColor:
        Colors.white,

        surfaceTintColor:
        Colors.white,

        elevation: 0,

        title: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Text(
              'Settings',

              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight:
                FontWeight.w900,
              ),
            ),

            Text(
              'Manage your CivicID preferences',

              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          40,
        ),

        children: [
          Center(
            child: Container(
              constraints:
              const BoxConstraints(
                maxWidth: 850,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  _buildHeaderCard(),

                  const SizedBox(
                    height: 24,
                  ),

                  // ====================================================
                  // ACCOUNT
                  // ====================================================

                  _sectionTitle(
                    'Account',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _settingsCard(
                    children: [
                      _settingsTile(
                        context,

                        icon: Icons
                            .person_outline_rounded,

                        title:
                        'Account Details',

                        subtitle:
                        'Review your CivicID account information.',

                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                              const AccountDetailsScreen(),
                            ),
                          );
                        },
                      ),

                      _divider(),

                      _settingsTile(
                        context,

                        icon: Icons
                            .security_rounded,

                        title:
                        'Security & Biometrics',

                        subtitle:
                        'Manage prototype security options.',

                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                              const SecurityScreen(),
                            ),
                          );
                        },
                      ),

                      _divider(),

                      _settingsTile(
                        context,

                        icon: Icons
                            .history_rounded,

                        title:
                        'Audit Trail',

                        subtitle:
                        'Review activity recorded in CivicID.',

                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                              const AuditTrailScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ====================================================
                  // PREFERENCES
                  // ====================================================

                  _sectionTitle(
                    'Preferences',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _settingsCard(
                    children: [
                      // ------------------------------------------------
                      // NOTIFICATION SOUND SWITCH
                      // ------------------------------------------------

                      _soundSettingTile(),

                      _divider(),

                      // ------------------------------------------------
                      // NOTIFICATION SETTINGS
                      // ------------------------------------------------

                      _settingsTile(
                        context,

                        icon: Icons
                            .notifications_none_rounded,

                        title:
                        'Notifications',

                        subtitle:
                        'Manage notification preferences.',

                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                              const NotificationSettingsScreen(),
                            ),
                          );
                        },
                      ),

                      _divider(),

                      // ------------------------------------------------
                      // PRIVACY
                      // ------------------------------------------------

                      _settingsTile(
                        context,

                        icon: Icons
                            .privacy_tip_outlined,

                        title:
                        'Privacy & Data',

                        subtitle:
                        'View privacy and data controls.',

                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                              const PrivacyScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ====================================================
                  // SUPPORT
                  // ====================================================

                  _sectionTitle(
                    'Support',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _settingsCard(
                    children: [
                      _settingsTile(
                        context,

                        icon:
                        Icons.email_outlined,

                        title:
                        'Email Support',

                        subtitle:
                        'Open your email app to contact support.',

                        onTap: () =>
                            _openSupportEmail(
                              context,
                            ),
                      ),

                      _divider(),

                      _settingsTile(
                        context,

                        icon: Icons
                            .help_outline_rounded,

                        title:
                        'Help & Support',

                        subtitle:
                        'View common help information.',

                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                              const HelpSupportScreen(),
                            ),
                          );
                        },
                      ),

                      _divider(),

                      _settingsTile(
                        context,

                        icon: Icons
                            .info_outline_rounded,

                        title:
                        'About CivicID',

                        subtitle:
                        'Learn more about this academic prototype.',

                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                              const AboutScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  _buildLogoutCard(
                    context,
                    authService,
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  _buildPrototypeNotice(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SOUND TILE
  // ============================================================

  Widget _soundSettingTile() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: lightGreen,

              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              _soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,

              color: civicGreen,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  'Notification Sounds',

                  style: TextStyle(
                    color:
                    Color(0xFF14251C),

                    fontSize: 12,

                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Play a sound when important notifications arrive.',

                  style: TextStyle(
                    color: textGrey,
                    fontSize: 9,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          if (_loadingSound)
            const SizedBox(
              width: 24,
              height: 24,

              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: civicGreen,
              ),
            )
          else
            Switch(
              value:
              _soundEnabled,

              activeTrackColor:
              civicGreen,

              activeThumbColor:
              Colors.white,

              inactiveTrackColor:
              const Color(
                0xFFD6DCD8,
              ),

              inactiveThumbColor:
              Colors.white,

              onChanged:
              _changeSoundSetting,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER CARD
  // ============================================================

  Widget _buildHeaderCard() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        21,
      ),

      decoration:
      BoxDecoration(
        gradient:
        const LinearGradient(
          colors: [
            darkGreen,
            civicGreen,
          ],
        ),

        borderRadius:
        BorderRadius.circular(
          22,
        ),
      ),

      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final narrow =
              constraints.maxWidth <
                  520;

          final info =
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              const Text(
                'CivicID Settings',

                style: TextStyle(
                  color:
                  Colors.white,

                  fontSize: 21,

                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                'Manage your account, security, privacy and support options.',

                style: TextStyle(
                  color:
                  Colors.white
                      .withValues(
                    alpha: 0.86,
                  ),

                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ],
          );

          if (narrow) {
            return info;
          }

          return Row(
            children: [
              Expanded(
                child: info,
              ),

              const SizedBox(
                width: 20,
              ),

              Container(
                width: 76,
                height: 76,

                decoration:
                BoxDecoration(
                  color:
                  Colors.white
                      .withValues(
                    alpha: 0.12,
                  ),

                  shape:
                  BoxShape.circle,
                ),

                child:
                const Icon(
                  Icons
                      .settings_outlined,

                  color:
                  Colors.white,

                  size: 36,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      String title,
      ) {
    return Text(
      title.toUpperCase(),

      style:
      const TextStyle(
        color:
        civicGreen,

        fontSize: 10,

        fontWeight:
        FontWeight.w900,

        letterSpacing:
        1.1,
      ),
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _settingsCard({
    required List<Widget>
    children,
  }) {
    return Container(
      width:
      double.infinity,

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          19,
        ),

        border:
        Border.all(
          color:
          borderColor,
        ),
      ),

      child: Column(
        children:
        children,
      ),
    );
  }

  // ============================================================
  // SETTINGS TILE
  // ============================================================

  Widget _settingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 7,
      ),

      leading:
      Container(
        width: 42,
        height: 42,

        decoration:
        BoxDecoration(
          color:
          lightGreen,

          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),

        child: Icon(
          icon,

          color:
          civicGreen,

          size: 20,
        ),
      ),

      title: Text(
        title,

        style:
        const TextStyle(
          color:
          Color(
            0xFF14251C,
          ),

          fontSize: 12,

          fontWeight:
          FontWeight.w800,
        ),
      ),

      subtitle:
      Padding(
        padding:
        const EdgeInsets.only(
          top: 3,
        ),

        child: Text(
          subtitle,

          style:
          const TextStyle(
            color:
            textGrey,

            fontSize: 9,

            height: 1.35,
          ),
        ),
      ),

      trailing:
      const Icon(
        Icons
            .arrow_forward_ios_rounded,

        size: 14,

        color:
        textGrey,
      ),

      onTap:
      onTap,
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      indent: 69,
      endIndent: 15,
      color:
      borderColor,
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Widget _buildLogoutCard(
      BuildContext context,
      AuthService authService,
      ) {
    return Container(
      width:
      double.infinity,

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          19,
        ),

        border:
        Border.all(
          color:
          const Color(
            0xFFFFD4D0,
          ),
        ),
      ),

      child:
      ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ),

        leading:
        Container(
          width: 42,
          height: 42,

          decoration:
          BoxDecoration(
            color:
            const Color(
              0xFFFFECEA,
            ),

            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),

          child:
          const Icon(
            Icons.logout_rounded,

            color:
            Color(
              0xFFB3261E,
            ),

            size: 20,
          ),
        ),

        title:
        const Text(
          'Logout',

          style:
          TextStyle(
            color:
            Color(
              0xFFB3261E,
            ),

            fontSize: 12,

            fontWeight:
            FontWeight.w900,
          ),
        ),

        subtitle:
        const Text(
          'Sign out of the current CivicID session.',

          style:
          TextStyle(
            color:
            textGrey,

            fontSize: 9,
          ),
        ),

        onTap: () =>
            _confirmLogout(
              context,
              authService,
            ),
      ),
    );
  }

  Future<void> _confirmLogout(
      BuildContext context,
      AuthService authService,
      ) async {
    final confirm =
    await showDialog<bool>(
      context:
      context,

      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          backgroundColor:
          Colors.white,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              22,
            ),
          ),

          title:
          const Text(
            'Logout',

            style:
            TextStyle(
              color:
              darkGreen,

              fontWeight:
              FontWeight.w900,
            ),
          ),

          content:
          const Text(
            'Are you sure you want to log out of CivicID?',

            style:
            TextStyle(
              color:
              textGrey,

              height: 1.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    false,
                  ),

              child:
              const Text(
                'CANCEL',
              ),
            ),

            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    true,
                  ),

              style:
              FilledButton.styleFrom(
                backgroundColor:
                const Color(
                  0xFFB3261E,
                ),
              ),

              child:
              const Text(
                'LOGOUT',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await authService.logout();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil(
      '/',
          (route) => false,
    );
  }

  // ============================================================
  // EMAIL SUPPORT
  // ============================================================

  Future<void> _openSupportEmail(
      BuildContext context,
      ) async {
    final emailLaunchUri =
    Uri(
      scheme:
      'mailto',

      path:
      'support@civicid.app',

      queryParameters: {
        'subject':
        'Support Request from CivicID',
      },
    );

    try {
      final launched =
      await launchUrl(
        emailLaunchUri,

        mode:
        LaunchMode.externalApplication,
      );

      if (!launched &&
          context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open your email application.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open your email application.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // PROTOTYPE NOTICE
  // ============================================================

  Widget _buildPrototypeNotice() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        13,
      ),

      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFF1F5F2,
        ),

        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),

      child:
      const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Icon(
            Icons.school_outlined,

            color:
            textGrey,

            size: 18,
          ),

          SizedBox(
            width: 9,
          ),

          Expanded(
            child: Text(
              'Academic Prototype — CivicID is not an official South African government service. Settings and support features are part of the demonstration system.',

              style:
              TextStyle(
                color:
                textGrey,

                fontSize: 10,

                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}