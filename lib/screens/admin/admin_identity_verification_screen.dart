import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user_profile.dart';
import '../../services/profile_service.dart';

class AdminIdentityVerificationScreen extends StatefulWidget {
  const AdminIdentityVerificationScreen({
    super.key,
  });

  @override
  State<AdminIdentityVerificationScreen> createState() =>
      _AdminIdentityVerificationScreenState();
}

class _AdminIdentityVerificationScreenState
    extends State<AdminIdentityVerificationScreen> {
  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF52635B);
  static const Color darkText = Color(0xFF14251C);

  static const Color warningColor = Color(0xFFA66E00);
  static const Color warningBackground = Color(0xFFFFF5D9);
  static const Color rejectRed = Color(0xFFB3261E);
  static const Color rejectBackground = Color(0xFFFFECEA);

  final ProfileService _profileService = ProfileService();
  final TextEditingController _commentController =
  TextEditingController();

  UserProfile? _profile;

  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final profile = await _profileService.getProfile();

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = profile;
        _commentController.text =
            profile.identityVerificationComment ?? '';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load citizen identity information.',
      );
    }
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Uint8List? _getSelfieBytes() {
    final encoded =
        _profile?.registrationSelfieBase64;

    if (encoded == null ||
        encoded.trim().isEmpty) {
      return null;
    }

    try {
      return base64Decode(encoded);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // VERIFY
  // ============================================================

  Future<void> _verifyIdentity() async {
    final profile = _profile;

    if (profile == null ||
        _isProcessing) {
      return;
    }

    if (!profile.hasRegistrationSelfie) {
      _showMessage(
        'This citizen has not submitted a registration selfie.',
      );
      return;
    }

    final confirmed =
    await _confirmAction(
      title: 'Verify Identity?',
      message:
      'Confirm that you have reviewed the selfie and the citizen details and want to mark this identity as verified.',
      confirmText: 'VERIFY',
      color: civicGreen,
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final updated = profile.copyWith(
        isVerified: true,
        identityVerificationStatus:
        'Verified',
        identityVerificationComment:
        _commentController.text.trim(),
        identityVerifiedBy:
        'CivicID Admin',
        identityVerifiedAt:
        DateTime.now(),
      );

      await _profileService.updateProfile(
        updated,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = updated;
      });

      _showMessage(
        'Citizen identity verified successfully.',
        color: civicGreen,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to verify this identity.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<void> _rejectIdentity() async {
    final profile = _profile;

    if (profile == null ||
        _isProcessing) {
      return;
    }

    final comment =
    _commentController.text.trim();

    if (comment.isEmpty) {
      _showMessage(
        'Please enter a reason before rejecting the identity verification.',
        color: rejectRed,
      );
      return;
    }

    final confirmed =
    await _confirmAction(
      title: 'Reject Identity?',
      message:
      'The citizen will see your reason and can be asked to complete the identity verification again.',
      confirmText: 'REJECT',
      color: rejectRed,
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final updated = profile.copyWith(
        isVerified: false,
        identityVerificationStatus:
        'Rejected',
        identityVerificationComment:
        comment,
        identityVerifiedBy:
        'CivicID Admin',
        identityVerifiedAt:
        DateTime.now(),
      );

      await _profileService.updateProfile(
        updated,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = updated;
      });

      _showMessage(
        'Identity verification rejected.',
        color: rejectRed,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to reject this identity verification.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ============================================================
  // REQUEST MORE INFORMATION
  // ============================================================

  Future<void> _requestMoreInfo() async {
    final profile = _profile;

    if (profile == null ||
        _isProcessing) {
      return;
    }

    final comment =
    _commentController.text.trim();

    if (comment.isEmpty) {
      _showMessage(
        'Please explain what the citizen needs to correct or provide.',
        color: warningColor,
      );
      return;
    }

    final confirmed =
    await _confirmAction(
      title: 'Request More Information?',
      message:
      'The citizen identity status will be changed to More Information Required.',
      confirmText: 'REQUEST INFO',
      color: warningColor,
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final updated = profile.copyWith(
        isVerified: false,
        identityVerificationStatus:
        'More Information Required',
        identityVerificationComment:
        comment,
        identityVerifiedBy:
        'CivicID Admin',
        identityVerifiedAt:
        DateTime.now(),
      );

      await _profileService.updateProfile(
        updated,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = updated;
      });

      _showMessage(
        'More information requested from the citizen.',
        color: warningColor,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to update the identity verification.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // ============================================================
  // CONFIRM ACTION
  // ============================================================

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmText,
    required Color color,
  }) async {
    final result =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(22),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: textGrey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'CANCEL',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor:
                Colors.white,
              ),
              child: Text(
                confirmText,
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showMessage(
      String message, {
        Color? color,
      }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child:
          CircularProgressIndicator(
            color: civicGreen,
          ),
        )
            : RefreshIndicator(
          color: civicGreen,
          onRefresh: _loadProfile,
          child:
          SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.fromLTRB(
              20,
              22,
              20,
              40,
            ),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints:
                const BoxConstraints(
                  maxWidth: 1000,
                ),
                child: _profile == null
                    ? _buildErrorState()
                    : _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final profile = _profile!;
    final selfieBytes =
    _getSelfieBytes();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _buildHeader(profile),

        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final wide =
                constraints.maxWidth >=
                    760;

            final selfie =
            _buildSelfieCard(
              selfieBytes,
              profile,
            );

            final details =
            _buildCitizenDetails(
              profile,
            );

            if (!wide) {
              return Column(
                children: [
                  selfie,
                  const SizedBox(
                    height: 18,
                  ),
                  details,
                ],
              );
            }

            return Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: selfie,
                ),
                const SizedBox(width: 18),
                Expanded(
                  flex: 6,
                  child: details,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        _buildCommentSection(),

        const SizedBox(height: 20),

        _buildActions(),

        const SizedBox(height: 24),

        _buildSecurityNotice(),

        const SizedBox(height: 12),

        _buildPrototypeNotice(),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
      UserProfile profile,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final small =
              constraints.maxWidth < 520;

          final heading = Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons
                      .face_retouching_natural_rounded,
                  color: civicGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Identity Verification',
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 22,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.name.isEmpty
                          ? 'Citizen registration review'
                          : 'Reviewing ${profile.name}',
                      style:
                      const TextStyle(
                        color: textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final status =
          _statusBadge(
            profile
                .identityVerificationStatus,
          );

          if (small) {
            return Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                heading,
                const SizedBox(height: 14),
                status,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: heading),
              const SizedBox(width: 14),
              status,
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // SELFIE
  // ============================================================

  Widget _buildSelfieCard(
      Uint8List? bytes,
      UserProfile profile,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Registration Selfie',
            style: TextStyle(
              color: darkText,
              fontSize: 17,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use this image only for the authorized identity review process.',
            style: TextStyle(
              color: textGrey,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            constraints:
            const BoxConstraints(
              minHeight: 380,
              maxHeight: 520,
            ),
            decoration: BoxDecoration(
              color: pageBackground,
              borderRadius:
              BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: bytes == null
                ? const Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  Icons
                      .no_photography_outlined,
                  color: textGrey,
                  size: 60,
                ),
                SizedBox(height: 13),
                Text(
                  'No registration selfie',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Padding(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  child: Text(
                    'The citizen has not submitted a selfie yet.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            )
                : ClipRRect(
              borderRadius:
              BorderRadius.circular(
                17,
              ),
              child:
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Image.memory(
                  bytes,
                  width:
                  double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: civicGreen,
                size: 18,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  profile.hasRegistrationSelfie
                      ? 'Selfie received and available for admin review.'
                      : 'Waiting for the citizen to submit a selfie.',
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CITIZEN DETAILS
  // ============================================================

  Widget _buildCitizenDetails(
      UserProfile profile,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Citizen Details',
            style: TextStyle(
              color: darkText,
              fontSize: 17,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Compare these details with the information submitted by the citizen.',
            style: TextStyle(
              color: textGrey,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          _detailRow(
            'Full Name',
            profile.name,
            Icons.person_outline_rounded,
          ),

          _detailRow(
            'ID Number',
            profile.idNumber,
            Icons.badge_outlined,
          ),

          _detailRow(
            'Date of Birth',
            profile.dob,
            Icons
                .calendar_today_outlined,
          ),

          _detailRow(
            'Nationality',
            profile.nationality,
            Icons.public_outlined,
          ),

          _detailRow(
            'Gender',
            profile.gender,
            Icons.person_pin_outlined,
          ),

          _detailRow(
            'Phone',
            profile.phone,
            Icons.phone_outlined,
          ),

          _detailRow(
            'Email',
            profile.email,
            Icons.email_outlined,
          ),

          _detailRow(
            'Address',
            profile.address,
            Icons.home_outlined,
          ),

          if (profile.identityVerifiedAt !=
              null)
            _detailRow(
              'Last Reviewed',
              DateFormat(
                'dd MMM yyyy • HH:mm',
              ).format(
                profile.identityVerifiedAt!,
              ),
              Icons.history_rounded,
            ),

          if ((profile.identityVerifiedBy ??
              '')
              .trim()
              .isNotEmpty)
            _detailRow(
              'Reviewed By',
              profile.identityVerifiedBy!,
              Icons
                  .admin_panel_settings_outlined,
            ),
        ],
      ),
    );
  }

  Widget _detailRow(
      String label,
      String value,
      IconData icon,
      ) {
    final displayValue =
    value.trim().isEmpty
        ? 'Not provided'
        : value;

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 11,
      ),
      padding:
      const EdgeInsets.all(
        13,
      ),
      decoration: BoxDecoration(
        color: pageBackground,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              color: civicGreen,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  displayValue,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMENT
  // ============================================================

  Widget _buildCommentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Review Comment',
            style: TextStyle(
              color: darkText,
              fontSize: 17,
              fontWeight:
              FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'A comment is optional when verifying, but required when rejecting or requesting more information.',
            style: TextStyle(
              color: textGrey,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller:
            _commentController,
            enabled: !_isProcessing,
            minLines: 3,
            maxLines: 5,
            decoration:
            const InputDecoration(
              hintText:
              'Example: Please retake the selfie in better lighting and make sure your full face is visible.',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions() {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final wide =
            constraints.maxWidth >= 720;

        final verify =
        FilledButton.icon(
          onPressed:
          _isProcessing
              ? null
              : _verifyIdentity,
          icon: _isProcessing
              ? const SizedBox(
            width: 18,
            height: 18,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(
            Icons
                .verified_user_rounded,
          ),
          label: const Text(
            'VERIFY IDENTITY',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: civicGreen,
            foregroundColor:
            Colors.white,
            padding:
            const EdgeInsets.symmetric(
              vertical: 16,
            ),
          ),
        );

        final request =
        OutlinedButton.icon(
          onPressed:
          _isProcessing
              ? null
              : _requestMoreInfo,
          icon: const Icon(
            Icons
                .help_outline_rounded,
          ),
          label: const Text(
            'REQUEST MORE INFO',
          ),
          style:
          OutlinedButton.styleFrom(
            foregroundColor:
            warningColor,
            side: const BorderSide(
              color: warningColor,
            ),
            padding:
            const EdgeInsets.symmetric(
              vertical: 16,
            ),
          ),
        );

        final reject =
        OutlinedButton.icon(
          onPressed:
          _isProcessing
              ? null
              : _rejectIdentity,
          icon: const Icon(
            Icons.cancel_outlined,
          ),
          label: const Text(
            'REJECT',
          ),
          style:
          OutlinedButton.styleFrom(
            foregroundColor:
            rejectRed,
            side: const BorderSide(
              color: rejectRed,
            ),
            padding:
            const EdgeInsets.symmetric(
              vertical: 16,
            ),
          ),
        );

        if (!wide) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: verify,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: request,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: reject,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: verify),
            const SizedBox(width: 10),
            Expanded(child: request),
            const SizedBox(width: 10),
            Expanded(child: reject),
          ],
        );
      },
    );
  }

  // ============================================================
  // BADGE
  // ============================================================

  Widget _statusBadge(
      String status,
      ) {
    Color background;
    Color foreground;
    IconData icon;

    switch (status) {
      case 'Verified':
        background = lightGreen;
        foreground = civicGreen;
        icon = Icons.verified_rounded;
        break;

      case 'Rejected':
        background = rejectBackground;
        foreground = rejectRed;
        icon = Icons.cancel_rounded;
        break;

      case 'More Information Required':
        background = warningBackground;
        foreground = warningColor;
        icon =
            Icons.help_outline_rounded;
        break;

      case 'Pending Verification':
        background = warningBackground;
        foreground = warningColor;
        icon =
            Icons.pending_actions_rounded;
        break;

      default:
        background =
        const Color(0xFFF1F3F2);
        foreground = textGrey;
        icon =
            Icons.info_outline_rounded;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
        BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: foreground,
            size: 18,
          ),
          const SizedBox(width: 7),
          Text(
            status,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight:
              FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTICES
  // ============================================================

  Widget _buildSecurityNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius:
        BorderRadius.circular(15),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: warningColor,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'The registration selfie is sensitive personal information. Only authorized reviewers should access it, and it should be used only for the stated identity-verification purpose.',
              style: TextStyle(
                color: Color(0xFF725500),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrototypeNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F2),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.school_outlined,
            color: textGrey,
            size: 19,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Academic Prototype — This identity review is a demonstration feature and is not an official government identity-verification decision. No automated facial recognition is performed.',
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

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: textGrey,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'Unable to load citizen identity information.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkGreen,
              fontSize: 15,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
