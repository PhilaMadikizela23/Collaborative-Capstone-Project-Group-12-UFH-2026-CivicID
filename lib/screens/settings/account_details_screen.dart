import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../services/profile_service.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() =>
      _AccountDetailsScreenState();
}

class _AccountDetailsScreenState
    extends State<AccountDetailsScreen> {
  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);

  final ProfileService _profileService =
  ProfileService();

  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile =
      await _profileService.getProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

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
              'Account Details',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Your CivicID account information',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: civicGreen,
        ),
      )
          : RefreshIndicator(
        color: civicGreen,
        onRefresh: _loadProfile,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
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
                  maxWidth: 800,
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 22),
                    _infoCard(
                      icon:
                      Icons.email_outlined,
                      title: 'Email Address',
                      value:
                      _profile?.email ??
                          'Not provided',
                    ),
                    _infoCard(
                      icon:
                      Icons.verified_user_outlined,
                      title: 'Profile Status',
                      value:
                      _profile?.isVerified ==
                          true
                          ? 'Verified'
                          : 'Pending Verification',
                    ),
                    _infoCard(
                      icon:
                      Icons.badge_outlined,
                      title: 'Identity Number',
                      value: _maskedId(),
                    ),
                    _infoCard(
                      icon:
                      Icons.phone_outlined,
                      title: 'Phone Number',
                      value:
                      _profile?.phone ??
                          'Not provided',
                    ),
                    const SizedBox(height: 12),
                    _prototypeNotice(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _maskedId() {
    final id =
        _profile?.idNumber ?? '';

    if (id.isEmpty) {
      return 'Not provided';
    }

    if (id.length <= 4) {
      return id;
    }

    return '••••••••${id.substring(id.length - 4)}';
  }

  Widget _buildHeader() {
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
          CircleAvatar(
            radius: 31,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Review the information connected to your CivicID profile.',
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

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 11,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
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
                    color: textGrey,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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
        color: const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Academic Prototype — Account information shown here is demonstration data used within CivicID.',
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