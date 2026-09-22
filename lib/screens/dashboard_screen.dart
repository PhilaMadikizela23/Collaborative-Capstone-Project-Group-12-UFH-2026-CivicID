import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/profile_service.dart';
import '../services/application_service.dart';
import '../services/mock_data.dart';

import '../models/user_profile.dart';
import '../models/application.dart';
import '../models/government_service.dart';

import 'application/application_tracking_screen.dart';
import 'application/application_assistant_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onTabChange;

  const DashboardScreen({
    super.key,
    this.onTabChange,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
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

  static const Color passportPurple =
  Color(0xFF7B2CBF);

  static const Color passportLight =
  Color(0xFFF2E8FF);

  static const Color licenceBlue =
  Color(0xFF1976D2);

  static const Color licenceLight =
  Color(0xFFE7F3FF);

  static const Color birthOrange =
  Color(0xFFF57C00);

  static const Color birthLight =
  Color(0xFFFFF0DE);

  final ProfileService _profileService =
  ProfileService();

  final ApplicationService _applicationService =
  ApplicationService();

  final MockData _mockData =
  MockData();

  late Future<UserProfile> _profileFuture;

  late Future<List<Application>>
  _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _profileFuture =
        _profileService.getProfile();

    _applicationsFuture =
        _applicationService.getApplications();
  }

  void _refreshData() {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      color: pageBackground,
      child: SafeArea(
        child: RefreshIndicator(
          color: civicGreen,
          onRefresh: () async {
            _refreshData();

            await Future.wait([
              _profileFuture,
              _applicationsFuture,
            ]);
          },
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints:
                const BoxConstraints(
                  maxWidth: 950,
                ),
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  22,
                  20,
                  38,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),

                    const SizedBox(
                      height: 24,
                    ),

                    _buildAccountCard(),

                    const SizedBox(
                      height: 30,
                    ),

                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 19,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    const Text(
                      'Choose a service to get started',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(
                      height: 17,
                    ),

                    _buildQuickActions(),

                    const SizedBox(
                      height: 30,
                    ),

                    _buildApplicationsHeader(),

                    const SizedBox(
                      height: 14,
                    ),

                    _buildRecentApplications(),

                    const SizedBox(
                      height: 26,
                    ),

                    _buildPrototypeNotice(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (
          context,
          snapshot,
          ) {
        final profile =
            snapshot.data;

        String firstName =
            'Citizen';

        if (profile != null &&
            profile.name.trim().isNotEmpty) {
          firstName =
              profile.name
                  .trim()
                  .split(' ')
                  .first;
        }

        final initial =
        firstName.isNotEmpty
            ? firstName
            .substring(
          0,
          1,
        )
            .toUpperCase()
            : 'C';

        return Row(
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment:
              Alignment.center,
              decoration:
              const BoxDecoration(
                color: civicGreen,
                shape:
                BoxShape.circle,
              ),
              child: Text(
                initial,
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize:
                  19,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $firstName 👋',
                    style:
                    const TextStyle(
                      color:
                      darkText,
                      fontSize:
                      18,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  const Text(
                    'Manage your CivicID services and applications.',
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountCard() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(
        20,
      ),
      decoration:
      BoxDecoration(
        color: lightGreen,
        borderRadius:
        BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color:
          const Color(
            0xFFCFE5D7,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          return Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration:
                BoxDecoration(
                  color:
                  civicGreen,
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .verified_user_outlined,
                  color:
                  Colors.white,
                  size:
                  23,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your CivicID account',
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
                      height: 4,
                    ),

                    Text(
                      'Access services, manage documents and track your applications in one place.',
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    final smartId =
    _findService(
      'SRV001',
    );

    final passport =
    _findService(
      'SRV002',
    );

    final licence =
    _findService(
      'SRV003',
    );

    final birthCertificate =
    _findService(
      'SRV004',
    );

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width =
            constraints.maxWidth;

        final cardWidth =
        width >= 700
            ? (width - 42) / 4
            : (width - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width:
              cardWidth,
              child:
              _quickActionCard(
                title:
                'Apply for ID',
                subtitle:
                'Smart ID',
                icon:
                Icons.badge_outlined,
                mainColor:
                civicGreen,
                backgroundColor:
                lightGreen,
                onTap:
                smartId == null
                    ? null
                    : () {
                  _openService(
                    smartId,
                  );
                },
              ),
            ),

            SizedBox(
              width:
              cardWidth,
              child:
              _quickActionCard(
                title:
                'Apply for Passport',
                subtitle:
                'Passport',
                icon:
                Icons.public_rounded,
                mainColor:
                passportPurple,
                backgroundColor:
                passportLight,
                onTap:
                passport == null
                    ? null
                    : () {
                  _openService(
                    passport,
                  );
                },
              ),
            ),

            SizedBox(
              width:
              cardWidth,
              child:
              _quickActionCard(
                title:
                "Driver's Licence",
                subtitle:
                'Licence Service',
                icon:
                Icons
                    .directions_car_outlined,
                mainColor:
                licenceBlue,
                backgroundColor:
                licenceLight,
                onTap:
                licence == null
                    ? null
                    : () {
                  _openService(
                    licence,
                  );
                },
              ),
            ),

            SizedBox(
              width:
              cardWidth,
              child:
              _quickActionCard(
                title:
                'Birth Certificate',
                subtitle:
                'Certificate Service',
                icon:
                Icons
                    .child_care_outlined,
                mainColor:
                birthOrange,
                backgroundColor:
                birthLight,
                onTap:
                birthCertificate ==
                    null
                    ? null
                    : () {
                  _openService(
                    birthCertificate,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _quickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color mainColor,
    required Color backgroundColor,
    required VoidCallback? onTap,
  }) {
    return Material(
      color:
      Colors.transparent,
      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          19,
        ),
        onTap:
        onTap,
        child: Ink(
          height: 145,
          padding:
          const EdgeInsets.all(
            15,
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
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration:
                BoxDecoration(
                  color:
                  backgroundColor,
                  borderRadius:
                  BorderRadius.circular(
                    17,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration:
                    BoxDecoration(
                      color:
                      mainColor,
                      borderRadius:
                      BorderRadius.circular(
                        11,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color:
                      Colors.white,
                      size:
                      21,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 11,
              ),

              Text(
                title,
                textAlign:
                TextAlign.center,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  color:
                  darkText,
                  fontSize:
                  11,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                subtitle,
                textAlign:
                TextAlign.center,
                style:
                TextStyle(
                  color:
                  mainColor,
                  fontSize:
                  8,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GovernmentService? _findService(
      String id,
      ) {
    for (final service
    in _mockData.services) {
      if (service.id == id) {
        return service;
      }
    }

    return null;
  }

  void _openService(
      GovernmentService service,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
            ApplicationAssistantScreen(
              service:
              service,
            ),
      ),
    ).then(
          (_) {
        _refreshData();
      },
    );
  }

  Widget _buildApplicationsHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Applications',
                style:
                TextStyle(
                  color:
                  darkText,
                  fontSize:
                  19,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              SizedBox(
                height:
                4,
              ),

              Text(
                'Track your latest applications',
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
        ),

        TextButton(
          onPressed:
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                const ApplicationTrackingScreen(),
              ),
            ).then(
                  (_) {
                _refreshData();
              },
            );
          },
          child:
          const Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Text(
                'See All',
                style:
                TextStyle(
                  color:
                  civicGreen,
                  fontSize:
                  10,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              SizedBox(
                width:
                3,
              ),

              Icon(
                Icons
                    .arrow_forward_rounded,
                color:
                civicGreen,
                size:
                14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentApplications() {
    return FutureBuilder<List<Application>>(
      future:
      _applicationsFuture,
      builder: (
          context,
          snapshot,
          ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding:
              EdgeInsets.all(
                22,
              ),
              child:
              CircularProgressIndicator(
                color:
                civicGreen,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
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
                18,
              ),
              border:
              Border.all(
                color:
                borderColor,
              ),
            ),
            child:
            const Text(
              'Unable to load applications.',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color:
                textGrey,
                fontSize:
                11,
              ),
            ),
          );
        }

        final applications =
            snapshot.data ?? [];

        final apps =
        applications
            .take(3)
            .toList();

        if (apps.isEmpty) {
          return _emptyApplications();
        }

        return Column(
          children:
          apps.map(
                (
                application,
                ) {
              final service =
              _serviceForApplication(
                application,
              );

              return _applicationCard(
                application:
                application,
                service:
                service,
              );
            },
          ).toList(),
        );
      },
    );
  }

  Widget _applicationCard({
    required Application application,
    required GovernmentService service,
  }) {
    final statusColor =
    _statusColor(
      application.status,
    );

    final statusBackground =
    statusColor.withValues(
      alpha:
      0.10,
    );

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom:
        11,
      ),
      child: Material(
        color:
        Colors.transparent,
        child: InkWell(
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          onTap:
              () {
            showModalBottomSheet(
              context:
              context,
              isScrollControlled:
              true,
              backgroundColor:
              Colors.transparent,
              builder:
                  (_) =>
                  ApplicationDetailScreen(
                    applicationId:
                    application.id,
                  ),
            );
          },
          child: Ink(
            padding:
            const EdgeInsets.all(
              15,
            ),
            decoration:
            BoxDecoration(
              color:
              Colors.white,
              borderRadius:
              BorderRadius.circular(
                18,
              ),
              border:
              Border.all(
                color:
                borderColor,
              ),
            ),
            child: Row(
              children: [
                _applicationIcon(
                  service.id,
                ),

                const SizedBox(
                  width:
                  12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        maxLines:
                        1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        const TextStyle(
                          color:
                          darkText,
                          fontSize:
                          12,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),

                      const SizedBox(
                        height:
                        4,
                      ),

                      Text(
                        application.referenceNumber,
                        style:
                        const TextStyle(
                          color:
                          textGrey,
                          fontSize:
                          9,
                        ),
                      ),

                      const SizedBox(
                        height:
                        5,
                      ),

                      Text(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(
                          application
                              .submissionDate,
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
                ),

                const SizedBox(
                  width:
                  10,
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
                    statusBackground,
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    application.status,
                    style:
                    TextStyle(
                      color:
                      statusColor,
                      fontSize:
                      8,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(
                  width:
                  5,
                ),

                const Icon(
                  Icons
                      .chevron_right_rounded,
                  color:
                  Color(
                    0xFF9BA8A1,
                  ),
                  size:
                  18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _applicationIcon(
      String serviceId,
      ) {
    Color mainColor;
    Color background;
    IconData icon;

    switch (serviceId) {
      case 'SRV002':
        mainColor =
            passportPurple;

        background =
            passportLight;

        icon =
            Icons.public_rounded;
        break;

      case 'SRV003':
        mainColor =
            licenceBlue;

        background =
            licenceLight;

        icon =
            Icons
                .directions_car_outlined;
        break;

      case 'SRV004':
        mainColor =
            birthOrange;

        background =
            birthLight;

        icon =
            Icons
                .child_care_outlined;
        break;

      default:
        mainColor =
            civicGreen;

        background =
            lightGreen;

        icon =
            Icons.badge_outlined;
    }

    return Container(
      width: 47,
      height: 47,
      decoration:
      BoxDecoration(
        color:
        background,
        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),
      child: Icon(
        icon,
        color:
        mainColor,
        size:
        23,
      ),
    );
  }

  GovernmentService _serviceForApplication(
      Application application,
      ) {
    return _mockData.services.firstWhere(
          (
          service,
          ) =>
      service.id ==
          application.serviceId,
      orElse:
          () =>
      _mockData.services.first,
    );
  }

  Widget _emptyApplications() {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        26,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
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
            Icons.assignment_outlined,
            color:
            civicGreen,
            size:
            36,
          ),

          SizedBox(
            height:
            10,
          ),

          Text(
            'No applications yet',
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

          SizedBox(
            height:
            5,
          ),

          Text(
            'Choose one of the services above to start an application.',
            textAlign:
            TextAlign.center,
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
    );
  }

  Color _statusColor(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return civicGreen;

      case 'submitted':
      case 'under review':
        return licenceBlue;

      case 'more information required':
        return birthOrange;

      case 'rejected':
        return Colors.red;

      case 'draft':
      case 'incomplete':
        return const Color(
          0xFF7A6D00,
        );

      default:
        return textGrey;
    }
  }

  Widget _buildPrototypeNotice() {
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
      const Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            color:
            textGrey,
            size:
            15,
          ),

          SizedBox(
            width:
            7,
          ),

          Flexible(
            child: Text(
              'Academic Prototype — CivicID is not an official government service.',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color:
                textGrey,
                fontSize:
                9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}