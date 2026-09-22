import 'package:flutter/material.dart';

import '../../models/application.dart';
import '../../models/government_service.dart';

import '../../services/application_service.dart';
import '../../services/notification_service.dart';

class SubmissionConfirmationScreen
    extends StatefulWidget {
  final Application application;
  final GovernmentService service;

  const SubmissionConfirmationScreen({
    super.key,
    required this.application,
    required this.service,
  });

  @override
  State<SubmissionConfirmationScreen>
  createState() =>
      _SubmissionConfirmationScreenState();
}

class _SubmissionConfirmationScreenState
    extends State<
        SubmissionConfirmationScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color civicGreen =
  Color(0xFF08783E);

  static const Color darkGreen =
  Color(0xFF04542C);

  static const Color lightGreen =
  Color(0xFFEAF7EF);

  static const Color pageBackground =
  Color(0xFFF8FBF9);

  static const Color borderColor =
  Color(0xFFDDE7E1);

  static const Color textGrey =
  Color(0xFF66756E);

  static const Color darkText =
  Color(0xFF14251C);

  // ============================================================
  // SERVICES
  // ============================================================

  final ApplicationService _applicationService =
  ApplicationService();

  final NotificationService _notificationService =
  NotificationService();

  // ============================================================
  // STATE
  // ============================================================

  bool _isSubmitting =
  false;

  Application? _submittedApplication;

  // ============================================================
  // CONFIRM SUBMISSION
  // ============================================================

  Future<void> _confirmAndSubmit() async {
    if (_isSubmitting ||
        _submittedApplication != null) {
      return;
    }

    final bool? confirmed =
    await showDialog<bool>(
      context:
      context,

      builder:
          (dialogContext) {
        return AlertDialog(
          backgroundColor:
          Colors.white,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              20,
            ),
          ),

          title:
          const Row(
            children: [
              CircleAvatar(
                backgroundColor:
                lightGreen,

                child:
                Icon(
                  Icons.send_rounded,
                  color:
                  civicGreen,
                ),
              ),

              SizedBox(
                width:
                12,
              ),

              Expanded(
                child:
                Text(
                  'Submit Application?',

                  style:
                  TextStyle(
                    color:
                    darkGreen,

                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          content:
          Text(
            'You are about to submit your '
                '${widget.service.name} application '
                'for administrative review.\n\n'
                'Please make sure your information '
                'and documents are correct.',

            style:
            const TextStyle(
              color:
              textGrey,

              height:
              1.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed:
                  () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },

              child:
              const Text(
                'CANCEL',
              ),
            ),

            FilledButton.icon(
              onPressed:
                  () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              icon:
              const Icon(
                Icons.send_rounded,
                size:
                18,
              ),

              label:
              const Text(
                'SUBMIT',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed ==
        true) {
      await _submit();
    }
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (_isSubmitting ||
        _submittedApplication != null) {
      return;
    }

    setState(() {
      _isSubmitting =
      true;
    });

    try {
      final Application result =
      await _applicationService
          .submitApplication(
        widget.application,
      );

      await _notificationService
          .addNotification(
        'Application Submitted',
        'Your ${widget.service.name} '
            'application was submitted successfully. '
            'Reference: ${result.referenceNumber}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _submittedApplication =
            result;

        _isSubmitting =
        false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting =
        false;
      });

      ScaffoldMessenger.of(
        context,
      )
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior:
            SnackBarBehavior.floating,

            backgroundColor:
            Colors.red.shade700,

            content:
            const Text(
              'Application could not be submitted. '
                  'Please try again.',
            ),
          ),
        );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    if (_submittedApplication !=
        null) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor:
      pageBackground,

      appBar:
      AppBar(
        backgroundColor:
        Colors.white,

        surfaceTintColor:
        Colors.white,

        elevation:
        0,

        scrolledUnderElevation:
        0,

        leading:
        IconButton(
          onPressed:
          _isSubmitting
              ? null
              : () {
            Navigator.pop(
              context,
            );
          },

          icon:
          const Icon(
            Icons.arrow_back_rounded,
            color:
            darkGreen,
          ),
        ),

        title:
        const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Text(
              'Review & Submit',

              style:
              TextStyle(
                color:
                darkGreen,

                fontSize:
                17,

                fontWeight:
                FontWeight.w900,
              ),
            ),

            Text(
              'Final application review',

              style:
              TextStyle(
                color:
                textGrey,

                fontSize:
                10,
              ),
            ),
          ],
        ),

        bottom:
        const PreferredSize(
          preferredSize:
          Size.fromHeight(
            1,
          ),

          child:
          Divider(
            height:
            1,

            color:
            borderColor,
          ),
        ),
      ),

      body:
      SingleChildScrollView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          24,
          20,
          40,
        ),

        child:
        Center(
          child:
          ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth:
              780,
            ),

            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                _buildHeader(),

                const SizedBox(
                  height:
                  22,
                ),

                _buildServiceCard(),

                const SizedBox(
                  height:
                  20,
                ),

                _buildApplicationSummary(),

                const SizedBox(
                  height:
                  20,
                ),

                _buildNextSteps(),

                const SizedBox(
                  height:
                  20,
                ),

                _buildConfirmationNotice(),

                const SizedBox(
                  height:
                  26,
                ),

                SizedBox(
                  width:
                  double.infinity,

                  height:
                  55,

                  child:
                  FilledButton.icon(
                    onPressed:
                    _isSubmitting
                        ? null
                        : _confirmAndSubmit,

                    icon:
                    _isSubmitting
                        ? const SizedBox(
                      width:
                      19,

                      height:
                      19,

                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,

                        color:
                        Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.send_rounded,
                    ),

                    label:
                    Text(
                      _isSubmitting
                          ? 'SUBMITTING...'
                          : 'SUBMIT APPLICATION',

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      civicGreen,

                      foregroundColor:
                      Colors.white,

                      disabledBackgroundColor:
                      civicGreen.withValues(
                        alpha:
                        0.60,
                      ),

                      disabledForegroundColor:
                      Colors.white,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height:
                  12,
                ),

                Center(
                  child:
                  TextButton.icon(
                    onPressed:
                    _isSubmitting
                        ? null
                        : () {
                      Navigator.pop(
                        context,
                      );
                    },

                    icon:
                    const Icon(
                      Icons.arrow_back_rounded,
                      size:
                      17,
                    ),

                    label:
                    const Text(
                      'Go back and make changes',
                    ),

                    style:
                    TextButton.styleFrom(
                      foregroundColor:
                      civicGreen,
                    ),
                  ),
                ),

                const SizedBox(
                  height:
                  22,
                ),

                _buildPrototypeNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        22,
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

      child:
      const Row(
        children: [
          CircleAvatar(
            radius:
            27,

            backgroundColor:
            Colors.white24,

            child:
            Icon(
              Icons.fact_check_outlined,
              color:
              Colors.white,
              size:
              28,
            ),
          ),

          SizedBox(
            width:
            15,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  'Almost Done',

                  style:
                  TextStyle(
                    color:
                    Colors.white,

                    fontSize:
                    21,

                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                SizedBox(
                  height:
                  4,
                ),

                Text(
                  'Review everything carefully '
                      'before submitting your application.',

                  style:
                  TextStyle(
                    color:
                    Colors.white70,

                    fontSize:
                    10,

                    height:
                    1.4,
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
  // SERVICE CARD
  // ============================================================

  Widget _buildServiceCard() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        18,
      ),

      decoration:
      BoxDecoration(
        color:
        lightGreen,

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border:
        Border.all(
          color:
          const Color(
            0xFFCFE5D7,
          ),
        ),
      ),

      child:
      Row(
        children: [
          Container(
            width:
            52,

            height:
            52,

            decoration:
            BoxDecoration(
              color:
              Colors.white,

              borderRadius:
              BorderRadius.circular(
                15,
              ),
            ),

            child:
            const Icon(
              Icons.account_balance_outlined,
              color:
              civicGreen,
              size:
              26,
            ),
          ),

          const SizedBox(
            width:
            14,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                const Text(
                  'Government Service',

                  style:
                  TextStyle(
                    color:
                    textGrey,

                    fontSize:
                    10,
                  ),
                ),

                const SizedBox(
                  height:
                  3,
                ),

                Text(
                  widget.service.name,

                  style:
                  const TextStyle(
                    color:
                    darkGreen,

                    fontSize:
                    16,

                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal:
              10,

              vertical:
              6,
            ),

            decoration:
            BoxDecoration(
              color:
              Colors.white,

              borderRadius:
              BorderRadius.circular(
                20,
              ),
            ),

            child:
            const Row(
              mainAxisSize:
              MainAxisSize.min,

              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color:
                  civicGreen,
                  size:
                  14,
                ),

                SizedBox(
                  width:
                  4,
                ),

                Text(
                  'READY',

                  style:
                  TextStyle(
                    color:
                    civicGreen,

                    fontSize:
                    9,

                    fontWeight:
                    FontWeight.w900,
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
  // APPLICATION SUMMARY
  // ============================================================

  Widget _buildApplicationSummary() {
    final entries =
    widget.application.data.entries
        .where(
          (entry) =>
      !_shouldHideField(
        entry.key,
      ),
    )
        .toList();

    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        20,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          20,
        ),

        border:
        Border.all(
          color:
          borderColor,
        ),
      ),

      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          const Row(
            children: [
              Icon(
                Icons.description_outlined,
                color:
                civicGreen,
              ),

              SizedBox(
                width:
                10,
              ),

              Text(
                'Application Summary',

                style:
                TextStyle(
                  color:
                  darkGreen,

                  fontSize:
                  15,

                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
            7,
          ),

          const Text(
            'Check that the information below is correct.',

            style:
            TextStyle(
              color:
              textGrey,

              fontSize:
              10,
            ),
          ),

          const SizedBox(
            height:
            17,
          ),

          if (entries.isEmpty)
            const Text(
              'No application information is available.',

              style:
              TextStyle(
                color:
                textGrey,
              ),
            )
          else
            ...entries.map(
                  (entry) {
                return _buildSummaryRow(
                  _formatLabel(
                    entry.key,
                  ),
                  _formatValue(
                    entry.key,
                    entry.value,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _buildSummaryRow(
      String label,
      String value,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical:
        11,
      ),

      decoration:
      const BoxDecoration(
        border:
        Border(
          bottom:
          BorderSide(
            color:
            Color(
              0xFFEEF2EF,
            ),
          ),
        ),
      ),

      child:
      Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Expanded(
            flex:
            2,

            child:
            Text(
              label,

              style:
              const TextStyle(
                color:
                textGrey,

                fontSize:
                11,
              ),
            ),
          ),

          const SizedBox(
            width:
            15,
          ),

          Expanded(
            flex:
            3,

            child:
            Text(
              value,

              textAlign:
              TextAlign.right,

              style:
              const TextStyle(
                color:
                darkText,

                fontSize:
                11,

                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NEXT STEPS
  // ============================================================

  Widget _buildNextSteps() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        20,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          20,
        ),

        border:
        Border.all(
          color:
          borderColor,
        ),
      ),

      child:
      const Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            'What happens next?',

            style:
            TextStyle(
              color:
              darkGreen,

              fontSize:
              15,

              fontWeight:
              FontWeight.w900,
            ),
          ),

          SizedBox(
            height:
            18,
          ),

          _NextStep(
            number:
            '1',

            title:
            'Application Submitted',

            description:
            'Your application is recorded with a CivicID reference number.',
          ),

          _NextStep(
            number:
            '2',

            title:
            'Admin Review',

            description:
            'The prototype administrator reviews your application.',
          ),

          _NextStep(
            number:
            '3',

            title:
            'Document Verification',

            description:
            'Supporting documents are reviewed.',
          ),

          _NextStep(
            number:
            '4',

            title:
            'Status Update',

            description:
            'Follow future status updates from your CivicID account.',

            showLine:
            false,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTICE
  // ============================================================

  Widget _buildConfirmationNotice() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFFFFBEB,
        ),

        borderRadius:
        BorderRadius.circular(
          16,
        ),

        border:
        Border.all(
          color:
          const Color(
            0xFFF0E2A8,
          ),
        ),
      ),

      child:
      const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Icon(
            Icons.info_outline_rounded,
            color:
            Color(
              0xFF9A7200,
            ),
          ),

          SizedBox(
            width:
            12,
          ),

          Expanded(
            child:
            Text(
              'By submitting, you confirm that the information '
                  'you provided is accurate to the best of your knowledge.',

              style:
              TextStyle(
                color:
                Color(
                  0xFF725A12,
                ),

                fontSize:
                11,

                height:
                1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUCCESS
  // ============================================================

  Widget _buildSuccessScreen() {
    final Application application =
    _submittedApplication!;

    return Scaffold(
      backgroundColor:
      pageBackground,

      body:
      SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            35,
            20,
            35,
          ),

          child:
          Center(
            child:
            ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth:
                650,
              ),

              child:
              Column(
                children: [
                  const SizedBox(
                    height:
                    20,
                  ),

                  Container(
                    width:
                    105,

                    height:
                    105,

                    decoration:
                    BoxDecoration(
                      color:
                      lightGreen,

                      shape:
                      BoxShape.circle,

                      border:
                      Border.all(
                        color:
                        const Color(
                          0xFFCFE5D7,
                        ),

                        width:
                        2,
                      ),
                    ),

                    child:
                    const Icon(
                      Icons.check_circle_rounded,
                      color:
                      civicGreen,
                      size:
                      66,
                    ),
                  ),

                  const SizedBox(
                    height:
                    24,
                  ),

                  const Text(
                    'Application Submitted!',

                    textAlign:
                    TextAlign.center,

                    style:
                    TextStyle(
                      color:
                      darkGreen,

                      fontSize:
                      27,

                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(
                    height:
                    8,
                  ),

                  Text(
                    'Your ${widget.service.name} application '
                        'has been submitted for review.',

                    textAlign:
                    TextAlign.center,

                    style:
                    const TextStyle(
                      color:
                      textGrey,

                      fontSize:
                      13,

                      height:
                      1.5,
                    ),
                  ),

                  const SizedBox(
                    height:
                    28,
                  ),

                  Container(
                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets.all(
                      22,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        22,
                      ),

                      border:
                      Border.all(
                        color:
                        borderColor,
                      ),
                    ),

                    child:
                    Column(
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          color:
                          civicGreen,
                          size:
                          28,
                        ),

                        const SizedBox(
                          height:
                          10,
                        ),

                        const Text(
                          'CivicID Reference Number',

                          style:
                          TextStyle(
                            color:
                            textGrey,

                            fontSize:
                            10,

                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height:
                          8,
                        ),

                        SelectableText(
                          application.referenceNumber,

                          textAlign:
                          TextAlign.center,

                          style:
                          const TextStyle(
                            color:
                            darkGreen,

                            fontSize:
                            24,

                            fontWeight:
                            FontWeight.w900,

                            letterSpacing:
                            1,
                          ),
                        ),

                        const SizedBox(
                          height:
                          12,
                        ),

                        const Text(
                          'Keep this reference number for tracking '
                              'inside the CivicID prototype.',

                          textAlign:
                          TextAlign.center,

                          style:
                          TextStyle(
                            color:
                            textGrey,

                            fontSize:
                            10,

                            height:
                            1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height:
                    18,
                  ),

                  Container(
                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets.all(
                      18,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      lightGreen,

                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),

                    child:
                    const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                          Colors.white,

                          child:
                          Icon(
                            Icons.schedule_rounded,
                            color:
                            civicGreen,
                          ),
                        ),

                        SizedBox(
                          width:
                          13,
                        ),

                        Expanded(
                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Current Status',

                                style:
                                TextStyle(
                                  color:
                                  textGrey,

                                  fontSize:
                                  10,
                                ),
                              ),

                              SizedBox(
                                height:
                                3,
                              ),

                              Text(
                                'Submitted — Awaiting Admin Review',

                                style:
                                TextStyle(
                                  color:
                                  darkGreen,

                                  fontSize:
                                  13,

                                  fontWeight:
                                  FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height:
                    30,
                  ),

                  SizedBox(
                    width:
                    double.infinity,

                    height:
                    54,

                    child:
                    FilledButton.icon(
                      onPressed:
                          () {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(
                          '/home',
                              (route) =>
                          false,
                        );
                      },

                      icon:
                      const Icon(
                        Icons.dashboard_outlined,
                      ),

                      label:
                      const Text(
                        'BACK TO DASHBOARD',

                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),

                      style:
                      FilledButton.styleFrom(
                        backgroundColor:
                        civicGreen,

                        foregroundColor:
                        Colors.white,

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                    28,
                  ),

                  _buildPrototypeNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT LABEL
  // ============================================================

  String _formatLabel(
      String key,
      ) {
    const Map<String, String> labels = {
      'name':
      'Full Name',

      'idNumber':
      'ID Number',

      'dob':
      'Date of Birth',

      'applicationType':
      'Application Type',

      'deliveryMethod':
      'Collection / Delivery',

      'address':
      'Address',

      'paymentMethod':
      'Payment Method',

      'paymentConfirmed':
      'Payment',

      'fee':
      'Service Fee',

      'feeDisplay':
      'Fee',

      'motherFirstName':
      'Mother First Name',

      'motherSurname':
      'Mother Surname',

      'motherIdNumber':
      'Mother ID Number',

      'motherDateOfBirth':
      'Mother Date of Birth',

      'motherPhoneNumber':
      'Mother Phone Number',

      'fatherFirstName':
      'Father First Name',

      'fatherSurname':
      'Father Surname',

      'fatherIdNumber':
      'Father ID Number',

      'fatherDateOfBirth':
      'Father Date of Birth',

      'fatherPhoneNumber':
      'Father Phone Number',

      'previousPassportNumber':
      'Previous Passport Number',

      'placeOfBirth':
      'Place of Birth',
    };

    if (labels.containsKey(
      key,
    )) {
      return labels[key]!;
    }

    final String words =
    key.replaceAllMapped(
      RegExp(
        r'([A-Z])',
      ),
          (match) =>
      ' ${match.group(1)}',
    ).trim();

    if (words.isEmpty) {
      return key;
    }

    return '${words[0].toUpperCase()}'
        '${words.substring(1)}';
  }

  // ============================================================
  // FORMAT VALUE
  // ============================================================

  String _formatValue(
      String key,
      dynamic value,
      ) {
    if (value ==
        null) {
      return 'Not applicable';
    }

    if (key ==
        'paymentConfirmed') {
      return value ==
          true
          ? 'Confirmed'
          : 'Not required / pending';
    }

    if (key ==
        'fee') {
      final double? fee =
      double.tryParse(
        value.toString(),
      );

      if (fee ==
          null) {
        return 'Confirm applicable fee';
      }

      if (fee ==
          0) {
        return 'FREE';
      }

      return 'R ${fee.toStringAsFixed(2)}';
    }

    if (value is bool) {
      return value
          ? 'Yes'
          : 'No';
    }

    if (value is List) {
      if (value.isEmpty) {
        return 'None';
      }

      return value.join(
        ', ',
      );
    }

    final String text =
    value.toString().trim();

    if (text.isEmpty) {
      return 'Not provided';
    }

    return text;
  }

  // ============================================================
  // HIDDEN FIELDS
  // ============================================================

  bool _shouldHideField(
      String key,
      ) {
    const Set<String> hiddenFields = {
      'internalId',
      'userId',
    };

    return hiddenFields.contains(
      key,
    );
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
            size:
            18,
          ),

          SizedBox(
            width:
            9,
          ),

          Expanded(
            child:
            Text(
              'Academic Prototype — CivicID is not an official '
                  'government service. Submitting here does not submit '
                  'an application to a government department.',

              style:
              TextStyle(
                color:
                textGrey,

                fontSize:
                10,

                height:
                1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// NEXT STEP
// ================================================================

class _NextStep
    extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final bool showLine;

  const _NextStep({
    required this.number,
    required this.title,
    required this.description,
    this.showLine = true,
  });

  static const Color civicGreen =
  Color(0xFF08783E);

  static const Color darkGreen =
  Color(0xFF04542C);

  static const Color lightGreen =
  Color(0xFFEAF7EF);

  static const Color borderColor =
  Color(0xFFDDE7E1);

  static const Color textGrey =
  Color(0xFF66756E);

  @override
  Widget build(
      BuildContext context,
      ) {
    return IntrinsicHeight(
      child:
      Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Column(
            children: [
              Container(
                width:
                31,

                height:
                31,

                alignment:
                Alignment.center,

                decoration:
                const BoxDecoration(
                  color:
                  lightGreen,

                  shape:
                  BoxShape.circle,
                ),

                child:
                Text(
                  number,

                  style:
                  const TextStyle(
                    color:
                    civicGreen,

                    fontSize:
                    11,

                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),

              if (showLine)
                Expanded(
                  child:
                  Container(
                    width:
                    2,

                    margin:
                    const EdgeInsets.symmetric(
                      vertical:
                      4,
                    ),

                    color:
                    borderColor,
                  ),
                ),
            ],
          ),

          const SizedBox(
            width:
            13,
          ),

          Expanded(
            child:
            Padding(
              padding:
              EdgeInsets.only(
                bottom:
                showLine
                    ? 20
                    : 0,
              ),

              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style:
                    const TextStyle(
                      color:
                      darkGreen,

                      fontSize:
                      12,

                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height:
                    3,
                  ),

                  Text(
                    description,

                    style:
                    const TextStyle(
                      color:
                      textGrey,

                      fontSize:
                      10,

                      height:
                      1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}