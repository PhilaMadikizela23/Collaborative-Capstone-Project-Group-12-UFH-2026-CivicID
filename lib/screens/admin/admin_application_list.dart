import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/application.dart';
import '../../services/admin_service.dart';
import 'admin_document_verification.dart';

class AdminApplicationList extends StatefulWidget {
  const AdminApplicationList({
    super.key,
  });

  @override
  State<AdminApplicationList> createState() =>
      _AdminApplicationListState();
}

class _AdminApplicationListState
    extends State<AdminApplicationList> {
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

  final AdminService _adminService =
  AdminService();

  List<Application> _applications = [];

  bool _isLoading = true;

  String _filter = 'All';

  @override
  void initState() {
    super.initState();

    _loadApplications();
  }

  Future<void> _loadApplications() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final apps =
      await _adminService
          .getAllApplications();

      if (!mounted) {
        return;
      }

      apps.sort(
            (a, b) =>
            b.submissionDate
                .compareTo(
              a.submissionDate,
            ),
      );

      setState(() {
        _applications = apps;

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load applications.',
          ),
        ),
      );
    }
  }

  List<Application>
  get _filteredApplications {
    if (_filter == 'All') {
      return _applications;
    }

    return _applications
        .where(
          (app) =>
      app.status ==
          _filter,
    )
        .toList();
  }

  void _viewApplicationDetail(
      Application app,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      builder: (
          context,
          ) {
        return _ApplicationDetailSheet(
          application: app,
          onUpdate:
          _loadApplications,
        );
      },
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      pageBackground,

      appBar: AppBar(
        backgroundColor:
        Colors.white,
        surfaceTintColor:
        Colors.white,
        elevation: 0,

        title:
        const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Applications Manager',
              style: TextStyle(
                color:
                darkGreen,
                fontSize:
                17,
                fontWeight:
                FontWeight.w900,
              ),
            ),
            Text(
              'CivicID Admin Portal',
              style: TextStyle(
                color:
                textGrey,
                fontSize:
                10,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip:
            'Refresh',
            onPressed:
            _isLoading
                ? null
                : _loadApplications,
            icon:
            const Icon(
              Icons.refresh_rounded,
              color:
              civicGreen,
            ),
          ),

          const SizedBox(
            width: 8,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(
          color:
          civicGreen,
        ),
      )
          : RefreshIndicator(
        color:
        civicGreen,
        onRefresh:
        _loadApplications,
        child:
        _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),

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
              maxWidth: 1000,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                _buildHeaderCard(),

                const SizedBox(
                  height: 24,
                ),

                _buildFilters(),

                const SizedBox(
                  height: 20,
                ),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Citizen Applications',
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF14251C,
                          ),
                          fontSize:
                          19,
                          fontWeight:
                          FontWeight
                              .w900,
                        ),
                      ),
                    ),

                    Text(
                      '${_filteredApplications.length}',
                      style:
                      const TextStyle(
                        color:
                        civicGreen,
                        fontWeight:
                        FontWeight
                            .w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 5,
                ),

                const Text(
                  'Select an application to review its details and make an administrative decision.',
                  style:
                  TextStyle(
                    color:
                    textGrey,
                    fontSize:
                    10,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                if (_filteredApplications
                    .isEmpty)
                  _buildEmptyState()
                else
                  ..._filteredApplications
                      .map(
                    _buildApplicationCard,
                  ),

                const SizedBox(
                  height: 20,
                ),

                _buildPrototypeNotice(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    final pending =
        _applications.where(
              (app) {
            return app.status ==
                'Submitted' ||
                app.status ==
                    'Under Review' ||
                app.status ==
                    'More Information Required';
          },
        ).length;

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
          final small =
              constraints.maxWidth <
                  520;

          final information =
          Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              const Text(
                'Application Review',
                style:
                TextStyle(
                  color:
                  Colors.white,
                  fontSize:
                  21,
                  fontWeight:
                  FontWeight
                      .w900,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                'Review citizen submissions and manage their prototype application status.',
                style:
                TextStyle(
                  color:
                  Colors.white
                      .withValues(
                    alpha:
                    0.85,
                  ),
                  fontSize:
                  10,
                  height:
                  1.5,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal:
                  11,
                  vertical:
                  7,
                ),
                decoration:
                BoxDecoration(
                  color:
                  Colors.white
                      .withValues(
                    alpha:
                    0.13,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    20,
                  ),
                ),
                child: Text(
                  '$pending NEED REVIEW',
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize:
                    9,
                    fontWeight:
                    FontWeight
                        .w800,
                  ),
                ),
              ),
            ],
          );

          if (small) {
            return information;
          }

          return Row(
            children: [
              Expanded(
                child:
                information,
              ),

              const SizedBox(
                width: 20,
              ),

              Container(
                width:
                80,
                height:
                80,
                decoration:
                BoxDecoration(
                  color:
                  Colors.white
                      .withValues(
                    alpha:
                    0.12,
                  ),
                  shape:
                  BoxShape.circle,
                ),
                child:
                const Icon(
                  Icons
                      .fact_check_outlined,
                  color:
                  Colors.white,
                  size:
                  38,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    const filters = [
      'All',
      'Submitted',
      'Under Review',
      'More Information Required',
      'Approved',
      'Rejected',
    ];

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,

      child: Row(
        children:
        filters.map(
              (
              filter,
              ) {
            final selected =
                _filter ==
                    filter;

            return Padding(
              padding:
              const EdgeInsets
                  .only(
                right:
                8,
              ),
              child:
              ChoiceChip(
                selected:
                selected,

                label:
                Text(
                  filter,
                ),

                selectedColor:
                civicGreen,

                backgroundColor:
                Colors.white,

                side:
                BorderSide(
                  color: selected
                      ? civicGreen
                      : borderColor,
                ),

                labelStyle:
                TextStyle(
                  color: selected
                      ? Colors.white
                      : textGrey,
                  fontSize:
                  10,
                  fontWeight:
                  FontWeight
                      .w700,
                ),

                onSelected:
                    (_) {
                  setState(() {
                    _filter =
                        filter;
                  });
                },
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildApplicationCard(
      Application app,
      ) {
    final applicant =
        app.data['name']
            ?.toString() ??
            'Unknown Applicant';

    final applicationType =
        app.data[
        'applicationType']
            ?.toString() ??
            'Application';

    return Container(
      width:
      double.infinity,

      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

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

      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          19,
        ),

        onTap: () =>
            _viewApplicationDetail(
              app,
            ),

        child: Padding(
          padding:
          const EdgeInsets.all(
            17,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [
              Row(
                children: [
                  Container(
                    width:
                    43,
                    height:
                    43,
                    decoration:
                    BoxDecoration(
                      color:
                      lightGreen,
                      borderRadius:
                      BorderRadius
                          .circular(
                        12,
                      ),
                    ),
                    child:
                    const Icon(
                      Icons
                          .description_outlined,
                      color:
                      civicGreen,
                      size:
                      21,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          app.referenceNumber,
                          style:
                          const TextStyle(
                            color:
                            darkGreen,
                            fontSize:
                            13,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),

                        const SizedBox(
                          height:
                          3,
                        ),

                        Text(
                          applicationType,
                          maxLines:
                          1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            color:
                            textGrey,
                            fontSize:
                            10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildStatusBadge(
                    app.status,
                  ),
                ],
              ),

              const SizedBox(
                height: 15,
              ),

              const Divider(
                color:
                borderColor,
                height:
                1,
              ),

              const SizedBox(
                height: 14,
              ),

              Wrap(
                spacing:
                25,
                runSpacing:
                12,
                children: [
                  _informationItem(
                    Icons
                        .person_outline_rounded,
                    'Applicant',
                    applicant,
                  ),

                  _informationItem(
                    Icons
                        .calendar_today_outlined,
                    'Submitted',
                    DateFormat(
                      'dd MMM yyyy',
                    ).format(
                      app.submissionDate,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              const Row(
                children: [
                  Spacer(),

                  Text(
                    'REVIEW APPLICATION',
                    style:
                    TextStyle(
                      color:
                      civicGreen,
                      fontSize:
                      9,
                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),

                  SizedBox(
                    width: 6,
                  ),

                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    color:
                    civicGreen,
                    size:
                    17,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _informationItem(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Icon(
          icon,
          color:
          civicGreen,
          size:
          16,
        ),

        const SizedBox(
          width: 7,
        ),

        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style:
              const TextStyle(
                color:
                textGrey,
                fontSize:
                8,
              ),
            ),

            const SizedBox(
              height: 1,
            ),

            Text(
              value,
              style:
              const TextStyle(
                color:
                Color(
                  0xFF14251C,
                ),
                fontSize:
                10,
                fontWeight:
                FontWeight
                    .w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(
      String status,
      ) {
    Color foreground;

    Color background;

    switch (status) {
      case 'Approved':
      case 'Completed':
        foreground =
            civicGreen;

        background =
            lightGreen;

        break;

      case 'Rejected':
        foreground =
        const Color(
          0xFFB3261E,
        );

        background =
        const Color(
          0xFFFFECEA,
        );

        break;

      case 'More Information Required':
        foreground =
        const Color(
          0xFF9A6700,
        );

        background =
        const Color(
          0xFFFFF5D9,
        );

        break;

      case 'Under Review':
        foreground =
        const Color(
          0xFF755600,
        );

        background =
        const Color(
          0xFFFFF8E6,
        );

        break;

      default:
        foreground =
            civicGreen;

        background =
            lightGreen;
    }

    return Container(
      constraints:
      const BoxConstraints(
        maxWidth:
        145,
      ),

      padding:
      const EdgeInsets.symmetric(
        horizontal:
        9,
        vertical:
        5,
      ),

      decoration:
      BoxDecoration(
        color:
        background,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: Text(
        status.toUpperCase(),

        maxLines:
        1,

        overflow:
        TextOverflow.ellipsis,

        style:
        TextStyle(
          color:
          foreground,
          fontSize:
          8,
          fontWeight:
          FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.symmetric(
        horizontal:
        20,
        vertical:
        50,
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
        children: [
          Icon(
            Icons
                .inbox_outlined,
            size:
            48,
            color:
            civicGreen,
          ),

          SizedBox(
            height: 14,
          ),

          Text(
            'No Applications',
            style:
            TextStyle(
              color:
              darkGreen,
              fontSize:
              17,
              fontWeight:
              FontWeight
                  .w900,
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Text(
            'No applications match this status.',
            textAlign:
            TextAlign.center,
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
    );
  }

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
            Icons
                .school_outlined,
            color:
            textGrey,
            size:
            18,
          ),

          SizedBox(
            width: 9,
          ),

          Expanded(
            child: Text(
              'Academic Prototype — Administrative decisions made here are part of the CivicID demonstration and are not official government decisions.',
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
// APPLICATION DETAIL / REVIEW SHEET
// ================================================================

class _ApplicationDetailSheet
    extends StatefulWidget {
  final Application application;

  final VoidCallback onUpdate;

  const _ApplicationDetailSheet({
    required this.application,
    required this.onUpdate,
  });

  @override
  State<_ApplicationDetailSheet>
  createState() =>
      _ApplicationDetailSheetState();
}

class _ApplicationDetailSheetState
    extends State<_ApplicationDetailSheet> {
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

  final AdminService _adminService =
  AdminService();

  final TextEditingController
  _commentController =
  TextEditingController();

  bool _isUpdating = false;

  late Application _currentApp;

  @override
  void initState() {
    super.initState();

    _currentApp =
        widget.application;
  }

  @override
  void dispose() {
    _commentController
        .dispose();

    super.dispose();
  }

  Future<void>
  _reloadCurrentApplication() async {
    final apps =
    await _adminService
        .getAllApplications();

    final updated =
    apps.firstWhere(
          (
          app,
          ) =>
      app.id ==
          _currentApp.id,

      orElse: () =>
      _currentApp,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _currentApp =
          updated;
    });
  }

  Future<void> _updateStatus(
      String status,
      ) async {
    if (_isUpdating) {
      return;
    }

    setState(() {
      _isUpdating =
      true;
    });

    try {
      await _adminService
          .updateApplicationStatus(
        _currentApp.id,
        status,
      );

      await _reloadCurrentApplication();

      widget.onUpdate();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          backgroundColor:
          civicGreen,
          content: Text(
            'Application status updated to $status.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update application.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating =
          false;
        });
      }
    }
  }

  Future<void> _addComment() async {
    final comment =
    _commentController
        .text
        .trim();

    if (comment.isEmpty ||
        _isUpdating) {
      return;
    }

    setState(() {
      _isUpdating =
      true;
    });

    try {
      await _adminService
          .addComment(
        _currentApp.id,
        comment,
        authorType:
        'Admin',
        authorName:
        'CivicID Admin',
      );

      _commentController
          .clear();

      await _reloadCurrentApplication();

      widget.onUpdate();
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating =
          false;
        });
      }
    }
  }

  Future<void>
  _requestMoreInformation() async {
    final controller =
    TextEditingController();

    final message =
    await showDialog<String>(
      context:
      context,

      builder:
          (
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
            'Request More Information',
            style:
            TextStyle(
              color:
              darkGreen,
              fontWeight:
              FontWeight
                  .w900,
            ),
          ),

          content:
          TextField(
            controller:
            controller,
            maxLines:
            4,
            decoration:
            InputDecoration(
              hintText:
              'Explain what the citizen needs to provide...',
              filled:
              true,
              fillColor:
              const Color(
                0xFFF8FBF9,
              ),
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(
                  14,
                ),
                borderSide:
                const BorderSide(
                  color:
                  borderColor,
                ),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed:
                  () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
              const Text(
                'CANCEL',
              ),
            ),

            FilledButton(
              style:
              FilledButton
                  .styleFrom(
                backgroundColor:
                civicGreen,
              ),
              onPressed:
                  () {
                final text =
                controller
                    .text
                    .trim();

                if (text
                    .isNotEmpty) {
                  Navigator.pop(
                    dialogContext,
                    text,
                  );
                }
              },
              child:
              const Text(
                'SEND REQUEST',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (message == null ||
        message.trim().isEmpty) {
      return;
    }

    setState(() {
      _isUpdating =
      true;
    });

    try {
      await _adminService
          .requestMoreInformation(
        _currentApp.id,
        message,
      );

      await _reloadCurrentApplication();

      widget.onUpdate();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          backgroundColor:
          civicGreen,
          content: Text(
            'Information request sent to citizen.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating =
          false;
        });
      }
    }
  }

  Future<void> _confirmDecision(
      String status,
      ) async {
    final approved =
        status ==
            'Approved';

    final confirmed =
    await showDialog<bool>(
      context:
      context,

      builder:
          (
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
          Text(
            approved
                ? 'Approve Application?'
                : 'Reject Application?',
            style:
            TextStyle(
              color: approved
                  ? darkGreen
                  : const Color(
                0xFFB3261E,
              ),
              fontWeight:
              FontWeight.w900,
            ),
          ),

          content:
          Text(
            approved
                ? 'Confirm that this CivicID prototype application should be marked as approved.'
                : 'Confirm that this CivicID prototype application should be marked as rejected.',
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

            FilledButton(
              style:
              FilledButton
                  .styleFrom(
                backgroundColor:
                approved
                    ? civicGreen
                    : const Color(
                  0xFFB3261E,
                ),
              ),
              onPressed:
                  () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
              Text(
                approved
                    ? 'APPROVE'
                    : 'REJECT',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed ==
        true) {
      await _updateStatus(
        status,
      );
    }
  }

  void _openDocumentVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
            AdminDocumentVerification(
              applicationId:
              _currentApp.id,
              referenceNumber:
              _currentApp
                  .referenceNumber,
            ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return DraggableScrollableSheet(
      initialChildSize:
      0.92,
      minChildSize:
      0.55,
      maxChildSize:
      0.96,

      builder: (
          context,
          scrollController,
          ) {
        return Container(
          decoration:
          const BoxDecoration(
            color:
            Colors.white,
            borderRadius:
            BorderRadius
                .vertical(
              top:
              Radius.circular(
                28,
              ),
            ),
          ),

          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),

              Container(
                width:
                42,
                height:
                4,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFD9E1DC,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    20,
                  ),
                ),
              ),

              Padding(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  20,
                  14,
                  12,
                  10,
                ),

                child: Row(
                  children: [
                    Container(
                      width:
                      43,
                      height:
                      43,
                      decoration:
                      BoxDecoration(
                        color:
                        lightGreen,
                        borderRadius:
                        BorderRadius
                            .circular(
                          12,
                        ),
                      ),
                      child:
                      const Icon(
                        Icons
                            .fact_check_outlined,
                        color:
                        civicGreen,
                      ),
                    ),

                    const SizedBox(
                      width:
                      11,
                    ),

                    Expanded(
                      child:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          const Text(
                            'Application Review',
                            style:
                            TextStyle(
                              color:
                              darkGreen,
                              fontSize:
                              17,
                              fontWeight:
                              FontWeight
                                  .w900,
                            ),
                          ),

                          Text(
                            _currentApp
                                .referenceNumber,
                            style:
                            const TextStyle(
                              color:
                              textGrey,
                              fontSize:
                              10,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed:
                          () {
                        Navigator.pop(
                          context,
                        );
                      },
                      icon:
                      const Icon(
                        Icons
                            .close_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                height:
                1,
                color:
                borderColor,
              ),

              Expanded(
                child:
                SingleChildScrollView(
                  controller:
                  scrollController,

                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    20,
                    20,
                    20,
                    35,
                  ),

                  child: Center(
                    child:
                    Container(
                      constraints:
                      const BoxConstraints(
                        maxWidth:
                        800,
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          _buildStatusSection(),

                          const SizedBox(
                            height:
                            24,
                          ),

                          _sectionTitle(
                            'Application Information',
                          ),

                          const SizedBox(
                            height:
                            12,
                          ),

                          _buildFormData(),

                          const SizedBox(
                            height:
                            14,
                          ),

                          _buildParentVerificationNotice(),

                          const SizedBox(
                            height:
                            25,
                          ),

                          _sectionTitle(
                            'Status History',
                          ),

                          const SizedBox(
                            height:
                            12,
                          ),

                          _buildStatusHistory(),

                          const SizedBox(
                            height:
                            25,
                          ),

                          _sectionTitle(
                            'Document Verification',
                          ),

                          const SizedBox(
                            height:
                            12,
                          ),

                          _buildDocumentAction(),

                          const SizedBox(
                            height:
                            25,
                          ),

                          _sectionTitle(
                            'Correspondence',
                          ),

                          const SizedBox(
                            height:
                            12,
                          ),

                          _buildComments(),

                          const SizedBox(
                            height:
                            12,
                          ),

                          _buildCommentField(),

                          const SizedBox(
                            height:
                            30,
                          ),

                          _buildDecisionActions(),

                          const SizedBox(
                            height:
                            18,
                          ),

                          _prototypeNotice(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // STATUS SUMMARY
  // ============================================================

  Widget _buildStatusSection() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        17,
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

      child: Wrap(
        spacing:
        30,
        runSpacing:
        15,
        children: [
          _summaryItem(
            'Reference',
            _currentApp
                .referenceNumber,
          ),

          _summaryItem(
            'Current Status',
            _currentApp
                .status,
          ),

          _summaryItem(
            'Submitted',
            DateFormat(
              'dd MMM yyyy • HH:mm',
            ).format(
              _currentApp
                  .submissionDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
      String label,
      String value,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
          const TextStyle(
            color:
            textGrey,
            fontSize:
            8,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          value,
          style:
          const TextStyle(
            color:
            darkGreen,
            fontSize:
            11,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(
      String title,
      ) {
    return Text(
      title,
      style:
      const TextStyle(
        color:
        Color(
          0xFF14251C,
        ),
        fontSize:
        14,
        fontWeight:
        FontWeight.w900,
      ),
    );
  }

  // ============================================================
  // APPLICATION DATA SECTIONS
  // ============================================================

  Widget _buildFormData() {
    final applicantEntries =
    <MapEntry<String, dynamic>>[];

    final parentEntries =
    <MapEntry<String, dynamic>>[];

    final serviceEntries =
    <MapEntry<String, dynamic>>[];

    final paymentEntries =
    <MapEntry<String, dynamic>>[];

    for (final entry
    in _currentApp.data.entries) {
      final key =
          entry.key;

      if (_isApplicantField(
        key,
      )) {
        applicantEntries.add(
          entry,
        );
      } else if (_isParentField(
        key,
      )) {
        parentEntries.add(
          entry,
        );
      } else if (_isPaymentField(
        key,
      )) {
        paymentEntries.add(
          entry,
        );
      } else {
        serviceEntries.add(
          entry,
        );
      }
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _adminDataSection(
          title:
          'Applicant Details',
          icon:
          Icons
              .person_outline_rounded,
          entries:
          applicantEntries,
          emptyText:
          'No applicant details available.',
        ),

        if (parentEntries
            .isNotEmpty) ...[
          const SizedBox(
            height:
            14,
          ),

          _adminDataSection(
            title:
            'Parent / Guardian Details',
            icon:
            Icons
                .family_restroom_rounded,
            entries:
            parentEntries,
            emptyText:
            'No parent or guardian details were required for this application.',
            highlight:
            true,
          ),
        ],

        const SizedBox(
          height: 14,
        ),

        _adminDataSection(
          title:
          'Application Details',
          icon:
          Icons
              .description_outlined,
          entries:
          serviceEntries,
          emptyText:
          'No additional application details available.',
        ),

        if (paymentEntries
            .isNotEmpty) ...[
          const SizedBox(
            height:
            14,
          ),

          _adminDataSection(
            title:
            'Payment / Collection',
            icon:
            Icons
                .payments_outlined,
            entries:
            paymentEntries,
            emptyText:
            'No payment or collection details available.',
          ),
        ],
      ],
    );
  }

  bool _isApplicantField(
      String key,
      ) {
    return const {
      'name',
      'idNumber',
      'dob',
      'applicantAgeGroup',
      'placeOfBirth',
    }.contains(
      key,
    );
  }

  bool _isParentField(
      String key,
      ) {
    return key.startsWith(
      'motherOrParent1',
    ) ||
        key.startsWith(
          'fatherOrParent2',
        ) ||
        key ==
            'parent2Status' ||
        key ==
            'parent2SpecialCircumstance';
  }

  bool _isPaymentField(
      String key,
      ) {
    return const {
      'deliveryMethod',
      'address',
      'paymentMethod',
      'paymentConfirmed',
      'fee',
      'feeDisplay',
    }.contains(
      key,
    );
  }

  Widget _adminDataSection({
    required String title,
    required IconData icon,
    required List<
        MapEntry<
            String,
            dynamic
        >>
    entries,
    required String emptyText,
    bool highlight = false,
  }) {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        17,
      ),

      decoration:
      BoxDecoration(
        color: highlight
            ? const Color(
          0xFFFFFBEB,
        )
            : const Color(
          0xFFF8FBF9,
        ),

        borderRadius:
        BorderRadius.circular(
          17,
        ),

        border:
        Border.all(
          color: highlight
              ? const Color(
            0xFFF0E2A8,
          )
              : borderColor,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width:
                38,
                height:
                38,

                decoration:
                BoxDecoration(
                  color: highlight
                      ? const Color(
                    0xFFFFF3C7,
                  )
                      : lightGreen,

                  borderRadius:
                  BorderRadius
                      .circular(
                    11,
                  ),
                ),

                child: Icon(
                  icon,
                  color: highlight
                      ? const Color(
                    0xFF8B6900,
                  )
                      : civicGreen,
                  size:
                  20,
                ),
              ),

              const SizedBox(
                width:
                10,
              ),

              Expanded(
                child:
                Text(
                  title,
                  style:
                  TextStyle(
                    color: highlight
                        ? const Color(
                      0xFF725500,
                    )
                        : darkGreen,
                    fontSize:
                    13,
                    fontWeight:
                    FontWeight
                        .w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
            14,
          ),

          if (entries
              .isEmpty)
            Text(
              emptyText,
              style:
              const TextStyle(
                color:
                textGrey,
                fontSize:
                10,
              ),
            )
          else
            ...entries.map(
                  (
                  entry,
                  ) =>
                  _dataRow(
                    _formatKey(
                      entry.key,
                    ),
                    _formatValue(
                      entry.value,
                    ),
                  ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // FRIENDLY FIELD NAMES
  // ============================================================

  String _formatKey(
      String key,
      ) {
    const labels =
    <String, String>{
      'name':
      'Full Name',

      'idNumber':
      'ID Number',

      'dob':
      'Date of Birth',

      'applicantAgeGroup':
      'Applicant Age Group',

      'placeOfBirth':
      'Place of Birth',

      'motherOrParent1FullName':
      'Mother / Parent 1 Full Name',

      'motherOrParent1IdPassport':
      'Mother / Parent 1 ID / Passport',

      'motherOrParent1Cellphone':
      'Mother / Parent 1 Cellphone',

      'motherOrParent1Nationality':
      'Mother / Parent 1 Nationality',

      'fatherOrParent2FullName':
      'Father / Parent 2 Full Name',

      'fatherOrParent2IdPassport':
      'Father / Parent 2 ID / Passport',

      'fatherOrParent2Cellphone':
      'Father / Parent 2 Cellphone',

      'fatherOrParent2Nationality':
      'Father / Parent 2 Nationality',

      'parent2Status':
      'Parent / Guardian 2 Status',

      'parent2SpecialCircumstance':
      'Parent / Guardian 2 Circumstance',

      'applicationType':
      'Application Type',

      'reason':
      'Application Reason',

      'previousPassportNumber':
      'Previous Passport Number',

      'additionalNotes':
      'Additional Notes',

      'deliveryMethod':
      'Collection / Delivery Method',

      'address':
      'Delivery Address',

      'paymentMethod':
      'Payment Method',

      'paymentConfirmed':
      'Payment Confirmed',

      'fee':
      'Application Fee',

      'feeDisplay':
      'Fee Display',
    };

    if (labels.containsKey(
      key,
    )) {
      return labels[key]!;
    }

    final spaced =
    key.replaceAllMapped(
      RegExp(
        r'([A-Z])',
      ),
          (
          match,
          ) =>
      ' ${match.group(1)}',
    );

    if (spaced.isEmpty) {
      return key;
    }

    return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }

  String _formatValue(
      dynamic value,
      ) {
    if (value == null) {
      return 'Not provided';
    }

    if (value is double) {
      return 'R${value.toStringAsFixed(2)}';
    }

    if (value is bool) {
      return value
          ? 'Yes'
          : 'No';
    }

    final text =
    value.toString();

    return text.isEmpty
        ? 'Not provided'
        : text;
  }

  Widget _dataRow(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom:
        11,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Expanded(
            flex:
            2,

            child: Text(
              label,
              style:
              const TextStyle(
                color:
                textGrey,
                fontSize:
                10,
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

            child: Text(
              value,

              textAlign:
              TextAlign.right,

              style:
              const TextStyle(
                color:
                Color(
                  0xFF14251C,
                ),
                fontSize:
                10,
                fontWeight:
                FontWeight
                    .w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PARENT VERIFICATION NOTICE
  // ============================================================

  Widget
  _buildParentVerificationNotice() {
    final hasParentData =
    _currentApp.data.keys.any(
      _isParentField,
    );

    if (!hasParentData) {
      return const SizedBox
          .shrink();
    }

    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        15,
      ),

      decoration:
      BoxDecoration(
        color:
        lightGreen,

        borderRadius:
        BorderRadius.circular(
          15,
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
      const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Icon(
            Icons
                .verified_user_outlined,
            color:
            civicGreen,
            size:
            20,
          ),

          SizedBox(
            width:
            10,
          ),

          Expanded(
            child: Text(
              'Parent / guardian details must be checked together with the uploaded parent identification documents. Use Document Verification below to verify, reject, or request more information.',
              style:
              TextStyle(
                color:
                darkGreen,
                fontSize:
                10,
                height:
                1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS HISTORY
  // ============================================================

  Widget _buildStatusHistory() {
    if (_currentApp
        .statusHistory
        .isEmpty) {
      return const Text(
        'No status history available.',
        style:
        TextStyle(
          color:
          textGrey,
          fontSize:
          10,
        ),
      );
    }

    return Column(
      children:
      _currentApp.statusHistory.map(
            (
            history,
            ) {
          return Container(
            margin:
            const EdgeInsets.only(
              bottom:
              9,
            ),

            padding:
            const EdgeInsets.all(
              13,
            ),

            decoration:
            BoxDecoration(
              color:
              const Color(
                0xFFF8FBF9,
              ),

              borderRadius:
              BorderRadius
                  .circular(
                14,
              ),

              border:
              Border.all(
                color:
                borderColor,
              ),
            ),

            child:
            Row(
              children: [
                const Icon(
                  Icons.circle,
                  color:
                  civicGreen,
                  size:
                  9,
                ),

                const SizedBox(
                  width:
                  10,
                ),

                Expanded(
                  child:
                  Text(
                    history.status,
                    style:
                    const TextStyle(
                      color:
                      darkGreen,
                      fontSize:
                      10,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),
                ),

                Text(
                  DateFormat(
                    'dd MMM • HH:mm',
                  ).format(
                    history.timestamp,
                  ),
                  style:
                  const TextStyle(
                    color:
                    textGrey,
                    fontSize:
                    8,
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // DOCUMENT VERIFICATION
  // ============================================================

  Widget _buildDocumentAction() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        17,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          17,
        ),

        border:
        Border.all(
          color:
          borderColor,
        ),
      ),

      child: Row(
        children: [
          Container(
            width:
            43,
            height:
            43,

            decoration:
            BoxDecoration(
              color:
              lightGreen,

              borderRadius:
              BorderRadius
                  .circular(
                12,
              ),
            ),

            child:
            const Icon(
              Icons
                  .document_scanner_outlined,
              color:
              civicGreen,
            ),
          ),

          const SizedBox(
            width:
            12,
          ),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  'Review Uploaded Documents',
                  style:
                  TextStyle(
                    color:
                    darkGreen,
                    fontSize:
                    11,
                    fontWeight:
                    FontWeight
                        .w800,
                  ),
                ),

                SizedBox(
                  height:
                  3,
                ),

                Text(
                  'Open the document verification queue, including applicant and parent / guardian ID documents.',
                  style:
                  TextStyle(
                    color:
                    textGrey,
                    fontSize:
                    9,
                  ),
                ),
              ],
            ),
          ),

          FilledButton(
            onPressed:
            _openDocumentVerification,

            style:
            FilledButton.styleFrom(
              backgroundColor:
              civicGreen,
            ),

            child:
            const Text(
              'OPEN',
              style:
              TextStyle(
                fontSize:
                9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMENTS / CORRESPONDENCE
  // ============================================================

  Widget _buildComments() {
    if (_currentApp
        .comments
        .isEmpty) {
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
            0xFFF8FBF9,
          ),
          borderRadius:
          BorderRadius.circular(
            15,
          ),
        ),

        child:
        const Text(
          'No correspondence yet.',
          style:
          TextStyle(
            color:
            textGrey,
            fontSize:
            10,
          ),
        ),
      );
    }

    return Column(
      children:
      _currentApp.comments.map(
            (
            comment,
            ) {
          final admin =
              comment.authorType ==
                  'Admin';

          return Container(
            width:
            double.infinity,

            margin:
            const EdgeInsets.only(
              bottom:
              9,
            ),

            padding:
            const EdgeInsets.all(
              14,
            ),

            decoration:
            BoxDecoration(
              color: admin
                  ? lightGreen
                  : const Color(
                0xFFF8FBF9,
              ),

              borderRadius:
              BorderRadius
                  .circular(
                15,
              ),
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Icon(
                      admin
                          ? Icons
                          .admin_panel_settings_outlined
                          : Icons
                          .person_outline,
                      size:
                      15,
                      color:
                      civicGreen,
                    ),

                    const SizedBox(
                      width:
                      6,
                    ),

                    Expanded(
                      child:
                      Text(
                        comment
                            .authorName,
                        style:
                        const TextStyle(
                          color:
                          darkGreen,
                          fontSize:
                          9,
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),
                    ),

                    Text(
                      DateFormat(
                        'dd MMM • HH:mm',
                      ).format(
                        comment
                            .timestamp,
                      ),
                      style:
                      const TextStyle(
                        color:
                        textGrey,
                        fontSize:
                        8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height:
                  8,
                ),

                Text(
                  comment.text,
                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF263B31,
                    ),
                    fontSize:
                    10,
                    height:
                    1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildCommentField() {
    return Row(
      children: [
        Expanded(
          child:
          TextField(
            controller:
            _commentController,

            enabled:
            !_isUpdating,

            decoration:
            InputDecoration(
              hintText:
              'Add admin comment...',

              hintStyle:
              const TextStyle(
                fontSize:
                10,
              ),

              filled:
              true,

              fillColor:
              const Color(
                0xFFF8FBF9,
              ),

              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(
                  14,
                ),
                borderSide:
                const BorderSide(
                  color:
                  borderColor,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(
          width:
          8,
        ),

        IconButton.filled(
          style:
          IconButton.styleFrom(
            backgroundColor:
            civicGreen,
          ),

          onPressed:
          _isUpdating
              ? null
              : _addComment,

          icon:
          const Icon(
            Icons.send_rounded,
            color:
            Colors.white,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ADMIN DECISIONS
  // ============================================================

  Widget _buildDecisionActions() {
    if (_isUpdating) {
      return const Center(
        child:
        CircularProgressIndicator(
          color:
          civicGreen,
        ),
      );
    }

    final status =
        _currentApp.status;

    if (status ==
        'Approved' ||
        status ==
            'Completed' ||
        status ==
            'Rejected') {
      return Container(
        width:
        double.infinity,

        padding:
        const EdgeInsets.all(
          15,
        ),

        decoration:
        BoxDecoration(
          color:
          const Color(
            0xFFF8FBF9,
          ),

          borderRadius:
          BorderRadius.circular(
            15,
          ),

          border:
          Border.all(
            color:
            borderColor,
          ),
        ),

        child:
        Text(
          'Final decision: $status',

          textAlign:
          TextAlign.center,

          style:
          const TextStyle(
            color:
            darkGreen,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      );
    }

    if (status ==
        'Submitted') {
      return SizedBox(
        width:
        double.infinity,

        child:
        FilledButton.icon(
          onPressed:
              () {
            _updateStatus(
              'Under Review',
            );
          },

          style:
          FilledButton.styleFrom(
            backgroundColor:
            civicGreen,

            padding:
            const EdgeInsets
                .symmetric(
              vertical:
              15,
            ),
          ),

          icon:
          const Icon(
            Icons
                .manage_search_rounded,
          ),

          label:
          const Text(
            'START REVIEW',
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width:
          double.infinity,

          child:
          OutlinedButton.icon(
            onPressed:
            _requestMoreInformation,

            style:
            OutlinedButton.styleFrom(
              foregroundColor:
              const Color(
                0xFF8B6900,
              ),

              side:
              const BorderSide(
                color:
                Color(
                  0xFFD7B95C,
                ),
              ),

              padding:
              const EdgeInsets
                  .symmetric(
                vertical:
                14,
              ),
            ),

            icon:
            const Icon(
              Icons
                  .help_outline_rounded,
            ),

            label:
            const Text(
              'REQUEST MORE INFORMATION',
            ),
          ),
        ),

        const SizedBox(
          height:
          10,
        ),

        Row(
          children: [
            Expanded(
              child:
              OutlinedButton.icon(
                onPressed:
                    () {
                  _confirmDecision(
                    'Rejected',
                  );
                },

                style:
                OutlinedButton
                    .styleFrom(
                  foregroundColor:
                  const Color(
                    0xFFB3261E,
                  ),

                  side:
                  const BorderSide(
                    color:
                    Color(
                      0xFFB3261E,
                    ),
                  ),

                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical:
                    14,
                  ),
                ),

                icon:
                const Icon(
                  Icons
                      .close_rounded,
                ),

                label:
                const Text(
                  'REJECT',
                ),
              ),
            ),

            const SizedBox(
              width:
              10,
            ),

            Expanded(
              child:
              FilledButton.icon(
                onPressed:
                    () {
                  _confirmDecision(
                    'Approved',
                  );
                },

                style:
                FilledButton
                    .styleFrom(
                  backgroundColor:
                  civicGreen,

                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical:
                    14,
                  ),
                ),

                icon:
                const Icon(
                  Icons
                      .check_rounded,
                ),

                label:
                const Text(
                  'APPROVE',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // PROTOTYPE NOTICE
  // ============================================================

  Widget _prototypeNotice() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        12,
      ),

      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFF1F5F2,
        ),

        borderRadius:
        BorderRadius.circular(
          13,
        ),
      ),

      child:
      const Text(
        'Academic Prototype — Application review and approval in CivicID are demonstration functions and are not official government decisions.',

        textAlign:
        TextAlign.center,

        style:
        TextStyle(
          color:
          textGrey,
          fontSize:
          9,
          height:
          1.5,
        ),
      ),
    );
  }
}