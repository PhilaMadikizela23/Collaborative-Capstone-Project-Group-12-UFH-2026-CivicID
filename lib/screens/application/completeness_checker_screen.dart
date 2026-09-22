import 'package:flutter/material.dart';

import '../../models/application.dart';
import '../../models/government_service.dart';
import '../../models/document.dart';
import '../../models/user_profile.dart';

import '../../services/document_service.dart';
import '../../services/profile_service.dart';

import '../../utils/checkers.dart';

import 'submission_confirmation_screen.dart';

class CompletenessCheckerScreen extends StatefulWidget {
  final Application application;
  final GovernmentService service;

  const CompletenessCheckerScreen({
    super.key,
    required this.application,
    required this.service,
  });

  @override
  State<CompletenessCheckerScreen> createState() =>
      _CompletenessCheckerScreenState();
}

class _CompletenessCheckerScreenState
    extends State<CompletenessCheckerScreen> {
  // ============================================================
  // CIVICID COLORS
  // ============================================================

  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);

  final DocumentService _documentService = DocumentService();
  final ProfileService _profileService = ProfileService();

  List<Document> _userDocuments = [];

  UserProfile? _profile;

  bool _isLoading = true;

  // ============================================================
  // LOAD DATA
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final docs = await _documentService.getDocuments();
    final profile = await _profileService.getProfile();

    if (!mounted) return;

    setState(() {
      _userDocuments = docs;
      _profile = profile;
      _isLoading = false;
    });
  }

  // ============================================================
  // DOCUMENT CHECKING
  // ============================================================

  bool _documentCountsAsProvided(Document document) {
    final status = document.status.toLowerCase();

    return status != 'rejected';
  }

  List<String> _getMissingDocuments() {
    final List<String> missing = [];

    for (final requiredType
    in widget.service.requiredDocumentTypes) {
      final hasDocument = _userDocuments.any(
            (document) =>
        document.type == requiredType &&
            _documentCountsAsProvided(document),
      );

      if (!hasDocument) {
        missing.add(requiredType);
      }
    }

    return missing;
  }

  int _getPendingDocumentCount() {
    return _userDocuments.where((document) {
      final required =
      widget.service.requiredDocumentTypes.contains(
        document.type,
      );

      return required &&
          document.status.toLowerCase() ==
              'pending verification';
    }).length;
  }

  int _getVerifiedDocumentCount() {
    return _userDocuments.where((document) {
      final required =
      widget.service.requiredDocumentTypes.contains(
        document.type,
      );

      return required &&
          document.status.toLowerCase() == 'verified';
    }).length;
  }

  // ============================================================
  // APPLICATION DATA CHECK
  // ============================================================

  bool _isApplicationDataComplete() {
    final requiredKeys = [
      'name',
      'idNumber',
      'dob',
      'applicationType',
      'deliveryMethod',
    ];

    for (final key in requiredKeys) {
      final value = widget.application.data[key];

      if (value == null ||
          value.toString().trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  double _calculateProgress({
    required bool personalComplete,
    required bool documentsComplete,
    required bool consistent,
    required bool paymentComplete,
  }) {
    int completed = 0;

    if (personalComplete) completed++;
    if (documentsComplete) completed++;
    if (consistent) completed++;
    if (paymentComplete) completed++;

    return completed / 4;
  }

  bool _paymentRequirementComplete() {
    final dynamic feeValue =
    widget.application.data['fee'];

    final dynamic paymentConfirmed =
    widget.application.data['paymentConfirmed'];

    // Unknown authority fee:
    // do not block the prototype submission.
    if (feeValue == null) {
      return true;
    }

    final double fee =
        double.tryParse(feeValue.toString()) ?? 0;

    // Free application
    if (fee <= 0) {
      return true;
    }

    // Paid application
    return paymentConfirmed == true;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(
        backgroundColor: pageBackground,
        body: Center(
          child: CircularProgressIndicator(
            color: civicGreen,
          ),
        ),
      );
    }

    final bool personalComplete =
    _isApplicationDataComplete();

    final List<String> missingDocs =
    _getMissingDocuments();

    final bool documentsComplete =
        missingDocs.isEmpty;

    final inconsistencies =
    ConsistencyChecker.compareWithProfile(
      application: widget.application,
      profile: _profile!,
    );

    final bool consistencyComplete =
        inconsistencies.isEmpty;

    final bool paymentComplete =
    _paymentRequirementComplete();

    final double progressValue =
    _calculateProgress(
      personalComplete: personalComplete,
      documentsComplete: documentsComplete,
      consistent: consistencyComplete,
      paymentComplete: paymentComplete,
    );

    final bool isReady =
        personalComplete &&
            documentsComplete &&
            consistencyComplete &&
            paymentComplete;

    final int pendingDocuments =
    _getPendingDocumentCount();

    final int verifiedDocuments =
    _getVerifiedDocumentCount();

    return Scaffold(
      backgroundColor: pageBackground,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: darkGreen,
          ),
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completeness Check',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'CivicID Application Assistant',
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
          22,
          20,
          40,
        ),

        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 760,
            ),

            child: Column(
              children: [
                // ==================================================
                // HEADING
                // ==================================================

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Application Check',
                    style: TextStyle(
                      color: Color(0xFF14251C),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'We are checking whether your application has everything needed before submission.',
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // PROGRESS
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: borderColor,
                    ),
                  ),

                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        width: 180,

                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 160,
                              height: 160,

                              child:
                              CircularProgressIndicator(
                                value: progressValue,
                                strokeWidth: 11,

                                backgroundColor:
                                const Color(
                                  0xFFE7EFEA,
                                ),

                                color: isReady
                                    ? civicGreen
                                    : const Color(
                                  0xFFCAA122,
                                ),
                              ),
                            ),

                            Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [
                                Text(
                                  '${(progressValue * 100).round()}%',
                                  style: TextStyle(
                                    color: isReady
                                        ? civicGreen
                                        : darkGreen,
                                    fontSize: 34,
                                    fontWeight:
                                    FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                const Text(
                                  'Complete',
                                  style: TextStyle(
                                    color: textGrey,
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        isReady
                            ? 'Ready for Submission'
                            : 'Application Needs Attention',
                        style: TextStyle(
                          color: isReady
                              ? civicGreen
                              : const Color(
                            0xFF8B6900,
                          ),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        isReady
                            ? 'The required information and documents have been provided.'
                            : 'Complete the items marked below before submitting.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // CHECKLIST
                // ==================================================

                _buildCheckItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  done: personalComplete,
                  subtitle: personalComplete
                      ? 'Required personal information is available.'
                      : 'Some required personal information is missing.',
                ),

                _buildCheckItem(
                  icon: Icons.folder_outlined,
                  title: 'Required Documents',
                  done: documentsComplete,
                  subtitle: documentsComplete
                      ? 'All required documents have been provided.'
                      : 'Missing: ${missingDocs.join(', ')}',
                ),

                _buildCheckItem(
                  icon: Icons.compare_arrows_rounded,
                  title: 'Consistency Check',
                  done: consistencyComplete,
                  subtitle: consistencyComplete
                      ? 'Application information matches your CivicID profile.'
                      : 'A possible information mismatch was detected.',
                ),

                _buildCheckItem(
                  icon: Icons.payments_outlined,
                  title: 'Fee / Payment',
                  done: paymentComplete,
                  subtitle: paymentComplete
                      ? 'Payment requirement completed or no in-app payment is required.'
                      : 'Payment still needs to be confirmed.',
                ),

                const SizedBox(height: 10),

                // ==================================================
                // DOCUMENT VERIFICATION SUMMARY
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(
                        0xFFCFE5D7,
                      ),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons
                                .admin_panel_settings_outlined,
                            color: civicGreen,
                          ),

                          SizedBox(width: 10),

                          Text(
                            'Document Verification',
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 13,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _smallStatusRow(
                        'Verified documents',
                        '$verifiedDocuments',
                      ),

                      const SizedBox(height: 7),

                      _smallStatusRow(
                        'Pending admin verification',
                        '$pendingDocuments',
                      ),

                      if (pendingDocuments > 0) ...[
                        const SizedBox(height: 12),

                        const Text(
                          'Pending documents can be submitted with the application. An administrator will review them after submission.',
                          style: TextStyle(
                            color: textGrey,
                            fontSize: 10,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // READY
                // ==================================================

                if (isReady) ...[
                  Container(
                    width: 70,
                    height: 70,

                    decoration: const BoxDecoration(
                      color: lightGreen,
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.verified_rounded,
                      color: civicGreen,
                      size: 38,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Application Ready',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Your application can now be submitted for administrative review.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SubmissionConfirmationScreen(
                                  application:
                                  widget.application,
                                  service: widget.service,
                                ),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.send_rounded,
                      ),

                      label: const Text(
                        'SUBMIT APPLICATION',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      style: FilledButton.styleFrom(
                        backgroundColor: civicGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ]

                // ==================================================
                // NOT READY
                // ==================================================

                else ...[
                  Container(
                    width: 70,
                    height: 70,

                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF5DC),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFB48200),
                      size: 38,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Action Required',
                    style: TextStyle(
                      color: Color(0xFF8B6900),
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Please fix the missing or inconsistent information before submitting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.edit_outlined,
                      ),

                      label: const Text(
                        'FIX APPLICATION',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: civicGreen,
                        side: const BorderSide(
                          color: civicGreen,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 25),

                // ==================================================
                // DISCLAIMER
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6F4),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Icon(
                        Icons.school_outlined,
                        color: textGrey,
                        size: 18,
                      ),

                      SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          'Academic Prototype — Not an official government service.',
                          style: TextStyle(
                            color: textGrey,
                            fontSize: 10,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHECK ITEM
  // ============================================================

  Widget _buildCheckItem({
    required IconData icon,
    required String title,
    required bool done,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: done
              ? const Color(0xFFCDE5D6)
              : const Color(0xFFF0D9A1),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,

            decoration: BoxDecoration(
              color: done
                  ? lightGreen
                  : const Color(0xFFFFF6DD),

              borderRadius: BorderRadius.circular(13),
            ),

            child: Icon(
              done
                  ? Icons.check_rounded
                  : icon,

              color: done
                  ? civicGreen
                  : const Color(0xFFB48200),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF14251C),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: done
                        ? textGrey
                        : const Color(0xFF8B6900),
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,

            color: done
                ? civicGreen
                : const Color(0xFFB48200),
          ),
        ],
      ),
    );
  }

  Widget _smallStatusRow(
      String label,
      String value,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: textGrey,
              fontSize: 11,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Text(
            value,
            style: const TextStyle(
              color: darkGreen,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}