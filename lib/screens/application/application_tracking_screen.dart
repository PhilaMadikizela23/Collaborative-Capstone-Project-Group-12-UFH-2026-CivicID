import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/application.dart';
import '../../models/government_service.dart';
import '../../services/application_service.dart';
import '../../services/mock_data.dart';

class ApplicationTrackingScreen extends StatefulWidget {
  const ApplicationTrackingScreen({super.key});

  @override
  State<ApplicationTrackingScreen> createState() =>
      _ApplicationTrackingScreenState();
}

class _ApplicationTrackingScreenState
    extends State<ApplicationTrackingScreen> {
  // ============================================================
  // CIVICID COLORS
  // ============================================================

  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);

  final ApplicationService _applicationService =
  ApplicationService();

  final MockData _mockData = MockData();

  List<Application> _applications = [];

  bool _isLoading = true;

  String _filter = 'All';

  // ============================================================
  // INITIAL LOAD
  // ============================================================

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
      final applications =
      await _applicationService.getApplications();

      applications.sort(
            (a, b) => b.submissionDate.compareTo(
          a.submissionDate,
        ),
      );

      if (!mounted) return;

      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load your applications.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FILTERING
  // ============================================================

  List<Application> get _filteredApplications {
    if (_filter == 'All') {
      return _applications;
    }

    if (_filter == 'Active') {
      return _applications.where(
            (application) {
          return application.status != 'Approved' &&
              application.status != 'Rejected' &&
              application.status != 'Completed';
        },
      ).toList();
    }

    if (_filter == 'Completed') {
      return _applications.where(
            (application) {
          return application.status == 'Approved' ||
              application.status == 'Completed';
        },
      ).toList();
    }

    return _applications;
  }

  // ============================================================
  // SERVICE DETAILS
  // ============================================================

  GovernmentService? _getService(
      String serviceId,
      ) {
    try {
      return _mockData.services.firstWhere(
            (service) => service.id == serviceId,
      );
    } catch (_) {
      return null;
    }
  }

  String _getServiceName(
      Application application,
      ) {
    final service =
    _getService(application.serviceId);

    return service?.name ??
        application.data['applicationType']
            ?.toString() ??
        'CivicID Application';
  }

  // ============================================================
  // OPEN APPLICATION
  // ============================================================

  void _openApplication(
      Application application,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _ApplicationTrackingDetail(
          applicationId: application.id,
        );
      },
    ).then((_) {
      _loadApplications();
    });
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
          child: CircularProgressIndicator(
            color: civicGreen,
          ),
        )
            : RefreshIndicator(
          color: civicGreen,
          onRefresh: _loadApplications,
          child: _buildContent(),
        ),
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
                _buildHeader(),

                const SizedBox(height: 24),

                _buildFilters(),

                const SizedBox(height: 22),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'My Applications',
                        style: TextStyle(
                          color:
                          Color(0xFF14251C),
                          fontSize: 20,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${_filteredApplications.length}',
                      style:
                      const TextStyle(
                        color: civicGreen,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                const Text(
                  'Track the progress of your CivicID applications and view administrator updates.',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                if (_filteredApplications.isEmpty)
                  _buildEmptyState()
                else
                  ..._filteredApplications.map(
                    _buildApplicationCard,
                  ),

                const SizedBox(height: 22),

                _buildPrototypeNotice(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final active = _applications.where(
          (application) {
        return application.status !=
            'Approved' &&
            application.status !=
                'Completed' &&
            application.status !=
                'Rejected';
      },
    ).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            darkGreen,
            civicGreen,
          ],
        ),
        borderRadius:
        BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final small =
              constraints.maxWidth < 550;

          final information = Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Application Tracking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Follow every step from submission to the final CivicID prototype decision.',
                style: TextStyle(
                  color: Colors.white
                      .withValues(
                    alpha: 0.86,
                  ),
                  fontSize: 10,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _headerBadge(
                    '${_applications.length} TOTAL',
                  ),
                  _headerBadge(
                    '$active ACTIVE',
                  ),
                ],
              ),
            ],
          );

          if (small) {
            return information;
          }

          return Row(
            children: [
              Expanded(
                child: information,
              ),

              const SizedBox(width: 20),

              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .track_changes_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _headerBadge(
      String text,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.13,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight:
          FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    const filters = [
      'All',
      'Active',
      'Completed',
    ];

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,
      child: Row(
        children:
        filters.map((filter) {
          final selected =
              _filter == filter;

          return Padding(
            padding:
            const EdgeInsets.only(
              right: 8,
            ),
            child: ChoiceChip(
              selected: selected,
              label: Text(filter),
              selectedColor:
              civicGreen,
              backgroundColor:
              Colors.white,
              side: BorderSide(
                color: selected
                    ? civicGreen
                    : borderColor,
              ),
              labelStyle:
              TextStyle(
                color: selected
                    ? Colors.white
                    : textGrey,
                fontSize: 10,
                fontWeight:
                FontWeight.w700,
              ),
              onSelected: (_) {
                setState(() {
                  _filter = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // APPLICATION CARD
  // ============================================================

  Widget _buildApplicationCard(
      Application application,
      ) {
    final serviceName =
    _getServiceName(
      application,
    );

    final applicationType =
        application.data[
        'applicationType']
            ?.toString() ??
            serviceName;

    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(20),
        onTap: () =>
            _openApplication(
              application,
            ),
        child: Padding(
          padding:
          const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration:
                    BoxDecoration(
                      color: lightGreen,
                      borderRadius:
                      BorderRadius
                          .circular(13),
                    ),
                    child: Icon(
                      _serviceIcon(
                        application
                            .serviceId,
                      ),
                      color: civicGreen,
                      size: 22,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          application
                              .referenceNumber,
                          style:
                          const TextStyle(
                            color:
                            darkGreen,
                            fontSize: 13,
                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          applicationType,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            color:
                            textGrey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  _statusBadge(
                    application.status,
                  ),
                ],
              ),

              const SizedBox(
                height: 15,
              ),

              const Divider(
                height: 1,
                color: borderColor,
              ),

              const SizedBox(
                height: 13,
              ),

              Wrap(
                spacing: 25,
                runSpacing: 11,
                children: [
                  _smallInfo(
                    Icons
                        .calendar_today_outlined,
                    'Submitted',
                    DateFormat(
                      'dd MMM yyyy',
                    ).format(
                      application
                          .submissionDate,
                    ),
                  ),

                  _smallInfo(
                    Icons
                        .history_rounded,
                    'Updates',
                    '${application.statusHistory.length}',
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              Row(
                children: [
                  const Spacer(),

                  const Text(
                    'VIEW PROGRESS',
                    style:
                    TextStyle(
                      color:
                      civicGreen,
                      fontSize: 9,
                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  const Icon(
                    Icons
                        .arrow_forward_rounded,
                    color: civicGreen,
                    size: 17,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _serviceIcon(
      String serviceId,
      ) {
    switch (serviceId) {
      case 'SRV001':
        return Icons
            .badge_outlined;

      case 'SRV002':
        return Icons
            .public_rounded;

      case 'SRV003':
        return Icons
            .drive_eta_outlined;

      case 'SRV004':
        return Icons
            .child_care_outlined;

      default:
        return Icons
            .description_outlined;
    }
  }

  Widget _smallInfo(
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
          color: civicGreen,
          size: 15,
        ),

        const SizedBox(width: 6),

        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style:
              const TextStyle(
                color: textGrey,
                fontSize: 8,
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
                Color(0xFF14251C),
                fontSize: 10,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge(
      String status,
      ) {
    final colors =
    _statusColors(status);

    return Container(
      constraints:
      const BoxConstraints(
        maxWidth: 150,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.$1,
          fontSize: 8,
          fontWeight:
          FontWeight.w900,
        ),
      ),
    );
  }

  (Color, Color) _statusColors(
      String status,
      ) {
    switch (status) {
      case 'Approved':
      case 'Completed':
        return (
        civicGreen,
        lightGreen,
        );

      case 'Rejected':
        return (
        const Color(
          0xFFB3261E,
        ),
        const Color(
          0xFFFFECEA,
        ),
        );

      case 'More Information Required':
        return (
        const Color(
          0xFF8B6900,
        ),
        const Color(
          0xFFFFF5D9,
        ),
        );

      case 'Under Review':
        return (
        const Color(
          0xFF755600,
        ),
        const Color(
          0xFFFFF8E6,
        ),
        );

      case 'Submitted':
        return (
        const Color(
          0xFF176A45,
        ),
        const Color(
          0xFFEAF7EF,
        ),
        );

      default:
        return (
        textGrey,
        const Color(
          0xFFF1F5F2,
        ),
        );
    }
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 55,
      ),
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
            Icons
                .description_outlined,
            color: civicGreen,
            size: 52,
          ),

          SizedBox(height: 15),

          Text(
            'No Applications Yet',
            style: TextStyle(
              color: darkGreen,
              fontSize: 18,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Applications you submit through CivicID will appear here for tracking.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color: textGrey,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROTOTYPE NOTICE
  // ============================================================

  Widget _buildPrototypeNotice() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color:
        const Color(0xFFF1F5F2),
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
            size: 18,
          ),

          SizedBox(width: 9),

          Expanded(
            child: Text(
              'Academic Prototype — Application statuses displayed in CivicID are demonstration statuses and are not official government application results.',
              style: TextStyle(
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
}

class ApplicationDetailScreen extends StatelessWidget {
  final String applicationId;

  const ApplicationDetailScreen({
    super.key,
    required this.applicationId,
  });

  @override
  Widget build(BuildContext context) {
    return _ApplicationTrackingDetail(
      applicationId: applicationId,
    );
  }
}

// ================================================================
// APPLICATION TRACKING DETAIL
// ================================================================

class _ApplicationTrackingDetail
    extends StatefulWidget {
  final String applicationId;

  const _ApplicationTrackingDetail({
    required this.applicationId,
  });

  @override
  State<_ApplicationTrackingDetail>
  createState() =>
      _ApplicationTrackingDetailState();
}

class _ApplicationTrackingDetailState
    extends State<
        _ApplicationTrackingDetail> {
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

  final ApplicationService
  _applicationService =
  ApplicationService();

  Application? _application;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void>
  _loadApplication() async {
    try {
      final applications =
      await _applicationService
          .getApplications();

      Application? found;

      for (final application
      in applications) {
        if (application.id ==
            widget.applicationId) {
          found = application;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _application = found;
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
  Widget build(
      BuildContext context,
      ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.60,
      maxChildSize: 0.97,
      builder: (
          context,
          scrollController,
          ) {
        return Container(
          decoration:
          const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(
              top:
              Radius.circular(28),
            ),
          ),
          child: _isLoading
              ? const Center(
            child:
            CircularProgressIndicator(
              color:
              civicGreen,
            ),
          )
              : _application == null
              ? _buildMissing()
              : _buildDetail(
            scrollController,
            _application!,
          ),
        );
      },
    );
  }

  Widget _buildMissing() {
    return const Center(
      child: Text(
        'Application could not be found.',
        style: TextStyle(
          color: textGrey,
        ),
      ),
    );
  }

  Widget _buildDetail(
      ScrollController
      scrollController,
      Application application,
      ) {
    return Column(
      children: [
        const SizedBox(height: 10),

        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color:
            const Color(
              0xFFD9E1DC,
            ),
            borderRadius:
            BorderRadius.circular(20),
          ),
        ),

        Padding(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            14,
            12,
            10,
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration:
                BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                  BorderRadius
                      .circular(12),
                ),
                child: const Icon(
                  Icons
                      .track_changes_rounded,
                  color: civicGreen,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    const Text(
                      'Application Progress',
                      style:
                      TextStyle(
                        color:
                        darkGreen,
                        fontSize: 17,
                        fontWeight:
                        FontWeight
                            .w900,
                      ),
                    ),

                    Text(
                      application
                          .referenceNumber,
                      style:
                      const TextStyle(
                        color:
                        textGrey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () =>
                    Navigator.pop(
                      context,
                    ),
                icon: const Icon(
                  Icons.close_rounded,
                ),
              ),
            ],
          ),
        ),

        const Divider(
          height: 1,
          color: borderColor,
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
              child: Container(
                constraints:
                const BoxConstraints(
                  maxWidth: 800,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    _statusCard(
                      application,
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    _sectionTitle(
                      'Progress Timeline',
                    ),

                    const SizedBox(
                      height: 13,
                    ),

                    _buildTimeline(
                      application,
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    _sectionTitle(
                      'Application Information',
                    ),

                    const SizedBox(
                      height: 13,
                    ),

                    _applicationData(
                      application,
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    _sectionTitle(
                      'Messages & Updates',
                    ),

                    const SizedBox(
                      height: 13,
                    ),

                    _buildComments(
                      application,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _prototypeNotice(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusCard(
      Application application,
      ) {
    final message =
    _statusMessage(
      application.status,
    );

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius:
        BorderRadius.circular(19),
        border: Border.all(
          color: const Color(
            0xFFCFE5D7,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
            const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon(
                application.status,
              ),
              color: civicGreen,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  application.status,
                  style:
                  const TextStyle(
                    color: darkGreen,
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  message,
                  style:
                  const TextStyle(
                    color: textGrey,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(
      String status,
      ) {
    switch (status) {
      case 'Submitted':
        return Icons
            .upload_file_rounded;

      case 'Under Review':
        return Icons
            .manage_search_rounded;

      case 'More Information Required':
        return Icons
            .help_outline_rounded;

      case 'Approved':
      case 'Completed':
        return Icons
            .check_circle_outline_rounded;

      case 'Rejected':
        return Icons
            .cancel_outlined;

      default:
        return Icons
            .schedule_rounded;
    }
  }

  String _statusMessage(
      String status,
      ) {
    switch (status) {
      case 'Draft':
        return 'Your application is still being prepared.';

      case 'Submitted':
        return 'Your application has been submitted in the CivicID prototype and is waiting for administrative review.';

      case 'Under Review':
        return 'An administrator is currently reviewing your application and supporting information.';

      case 'More Information Required':
        return 'The administrator needs additional information. Check the messages below for details.';

      case 'Approved':
        return 'Your CivicID prototype application has been approved.';

      case 'Completed':
        return 'This CivicID prototype application has been completed.';

      case 'Rejected':
        return 'This CivicID prototype application has been marked as rejected. Check administrator messages for more information.';

      default:
        return 'Your CivicID application status has been updated.';
    }
  }

  Widget _sectionTitle(
      String title,
      ) {
    return Text(
      title,
      style:
      const TextStyle(
        color:
        Color(0xFF14251C),
        fontSize: 14,
        fontWeight:
        FontWeight.w900,
      ),
    );
  }

  // ============================================================
  // TIMELINE
  // ============================================================

  Widget _buildTimeline(
      Application application,
      ) {
    if (application
        .statusHistory.isEmpty) {
      return const Text(
        'No status updates yet.',
        style: TextStyle(
          color: textGrey,
          fontSize: 10,
        ),
      );
    }

    final history =
        application.statusHistory;

    return Column(
      children:
      List.generate(
        history.length,
            (index) {
          final item =
          history[index];

          final latest =
              index ==
                  history.length - 1;

          return _timelineItem(
            item,
            latest: latest,
            showLine:
            index !=
                history.length - 1,
          );
        },
      ),
    );
  }

  Widget _timelineItem(
      StatusHistoryItem item, {
        required bool latest,
        required bool showLine,
      }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              Container(
                width: latest
                    ? 16
                    : 13,
                height: latest
                    ? 16
                    : 13,
                decoration:
                BoxDecoration(
                  color: latest
                      ? civicGreen
                      : Colors.white,
                  shape:
                  BoxShape.circle,
                  border: Border.all(
                    color:
                    civicGreen,
                    width: 2,
                  ),
                ),
              ),

              if (showLine)
                Container(
                  width: 2,
                  height: 55,
                  color:
                  const Color(
                    0xFFCFE5D7,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: Container(
            margin:
            const EdgeInsets.only(
              bottom: 12,
            ),
            padding:
            const EdgeInsets.all(
              13,
            ),
            decoration:
            BoxDecoration(
              color: latest
                  ? lightGreen
                  : const Color(
                0xFFF8FBF9,
              ),
              borderRadius:
              BorderRadius
                  .circular(14),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.status,
                    style:
                    TextStyle(
                      color: latest
                          ? darkGreen
                          : const Color(
                        0xFF263B31,
                      ),
                      fontSize: 10,
                      fontWeight:
                      latest
                          ? FontWeight
                          .w900
                          : FontWeight
                          .w700,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Text(
                  DateFormat(
                    'dd MMM • HH:mm',
                  ).format(
                    item.timestamp,
                  ),
                  style:
                  const TextStyle(
                    color: textGrey,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // APPLICATION DATA
  // ============================================================

  Widget _applicationData(
      Application application,
      ) {
    if (application.data.isEmpty) {
      return const Text(
        'No application information available.',
        style: TextStyle(
          color: textGrey,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color:
        const Color(0xFFF8FBF9),
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children:
        application.data.entries
            .map(
              (entry) {
            return _dataRow(
              _formatKey(
                entry.key,
              ),
              _formatValue(
                entry.value,
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  String _formatKey(
      String key,
      ) {
    final spaced =
    key.replaceAllMapped(
      RegExp(r'([A-Z])'),
          (match) =>
      ' ${match.group(1)}',
    );

    if (spaced.isEmpty) {
      return key;
    }

    return '${spaced[0].toUpperCase()}'
        '${spaced.substring(1)}';
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
        bottom: 11,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style:
              const TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign:
              TextAlign.right,
              style:
              const TextStyle(
                color:
                Color(0xFF14251C),
                fontSize: 10,
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
  // ADMIN MESSAGES
  // ============================================================

  Widget _buildComments(
      Application application,
      ) {
    if (application
        .comments.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(
          17,
        ),
        decoration:
        BoxDecoration(
          color:
          const Color(
            0xFFF8FBF9,
          ),
          borderRadius:
          BorderRadius
              .circular(15),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons
                  .chat_bubble_outline_rounded,
              color: civicGreen,
              size: 20,
            ),

            SizedBox(width: 10),

            Expanded(
              child: Text(
                'No messages from the administrator yet.',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children:
      application.comments
          .map(
            (comment) {
          final admin =
              comment.authorType ==
                  'Admin';

          return Container(
            width: double.infinity,
            margin:
            const EdgeInsets.only(
              bottom: 9,
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
                  .circular(15),
              border: Border.all(
                color: admin
                    ? const Color(
                  0xFFCFE5D7,
                )
                    : borderColor,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Row(
                  children: [
                    Icon(
                      admin
                          ? Icons
                          .admin_panel_settings_outlined
                          : Icons
                          .person_outline,
                      color:
                      civicGreen,
                      size: 15,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Expanded(
                      child: Text(
                        comment
                            .authorName,
                        style:
                        const TextStyle(
                          color:
                          darkGreen,
                          fontSize: 9,
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
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  comment.text,
                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF263B31,
                    ),
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _prototypeNotice() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
        const Color(
          0xFFF1F5F2,
        ),
        borderRadius:
        BorderRadius
            .circular(13),
      ),
      child: const Text(
        'Academic Prototype — Tracking information shown here is generated inside CivicID for demonstration purposes and is not an official government tracking service.',
        textAlign:
        TextAlign.center,
        style: TextStyle(
          color: textGrey,
          fontSize: 9,
          height: 1.5,
        ),
      ),
    );
  }
}