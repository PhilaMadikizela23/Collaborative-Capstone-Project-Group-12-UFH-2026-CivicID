import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/appointment_slot.dart';
import '../../services/admin_service.dart';
import '../../services/appointment_slot_service.dart';
import '../../services/mock_data.dart';

import 'admin_application_list.dart';
import 'admin_document_verification.dart';
import 'admin_appointment_slots_screen.dart';
import 'admin_logs_screen.dart';

class AdminDashboardHome extends StatefulWidget {
  const AdminDashboardHome({
    super.key,
  });

  @override
  State<AdminDashboardHome> createState() =>
      _AdminDashboardHomeState();
}

class _AdminDashboardHomeState
    extends State<AdminDashboardHome> {
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
  Color(0xFF52635B);

  static const Color darkText =
  Color(0xFF14251C);

  static const Color warningColor =
  Color(0xFFA66E00);

  static const Color warningBackground =
  Color(0xFFFFF5D9);

  static const Color blueColor =
  Color(0xFF2866C7);

  static const Color blueBackground =
  Color(0xFFEAF2FF);

  static const Color redColor =
  Color(0xFFC62828);

  static const Color redBackground =
  Color(0xFFFFEAEA);

  // ============================================================
  // SERVICES
  // ============================================================

  final AdminService _adminService =
  AdminService();

  final AppointmentSlotService _slotService =
  AppointmentSlotService();

  final MockData _mockData =
  MockData();

  late Future<Map<String, int>> _statsFuture;

  late Future<List<AppointmentSlot>>
  _appointmentSlotsFuture;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  void _loadDashboard() {
    _statsFuture =
        _adminService.getSystemStats();

    _appointmentSlotsFuture =
        _slotService.getAllSlots();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshDashboard() async {
    setState(() {
      _loadDashboard();
    });

    await Future.wait([
      _statsFuture,
      _appointmentSlotsFuture,
    ]);
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openApplications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const AdminApplicationList(),
      ),
    );
  }

  void _openDocuments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const AdminDocumentVerification(),
      ),
    );
  }

  // ============================================================
  // IMPORTANT:
  // REFRESH APPOINTMENTS WHEN ADMIN COMES BACK
  // ============================================================

  Future<void> _openAppointments() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const AdminAppointmentSlotsScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _appointmentSlotsFuture =
          _slotService.getAllSlots();
    });
  }

  void _openLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const AdminLogsScreen(),
      ),
    );
  }

  // ============================================================
  // CITIZENS INFO
  // ============================================================

  void _showCitizensInfo(
      int totalUsers,
      ) {
    showDialog(
      context: context,
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
          const Row(
            children: [
              Icon(
                Icons.people_outline_rounded,
                color: civicGreen,
              ),

              SizedBox(
                width: 10,
              ),

              Text(
                'Citizen Accounts',
                style: TextStyle(
                  color: darkGreen,
                  fontWeight:
                  FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),

          content:
          Text(
            '$totalUsers citizen account'
                '${totalUsers == 1 ? '' : 's'} '
                'currently exist in this CivicID prototype.\n\n'
                'Citizen management can be expanded with account '
                'search, profile viewing and account status controls.',

            style:
            const TextStyle(
              color: textGrey,
              fontSize: 14,
              height: 1.55,
            ),
          ),

          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              style:
              FilledButton.styleFrom(
                backgroundColor:
                civicGreen,
                foregroundColor:
                Colors.white,
              ),

              child:
              const Text(
                'OK',
                style: TextStyle(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      pageBackground,

      body:
      SafeArea(
        child:
        RefreshIndicator(
          color:
          civicGreen,

          onRefresh:
          _refreshDashboard,

          child:
          SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            padding:
            const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              40,
            ),

            child:
            Center(
              child:
              Container(
                width:
                double.infinity,

                constraints:
                const BoxConstraints(
                  maxWidth: 1100,
                ),

                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    _buildHeader(),

                    const SizedBox(
                      height: 26,
                    ),

                    _buildAdminBanner(),

                    const SizedBox(
                      height: 32,
                    ),

                    _buildSectionHeader(
                      title:
                      'System Overview',

                      subtitle:
                      'Tap any card to open the related admin section.',
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _buildStatsGrid(),

                    const SizedBox(
                      height: 36,
                    ),

                    _buildSectionHeader(
                      title:
                      'Appointment Overview',

                      subtitle:
                      'Manage appointment availability and monitor citizen bookings.',
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _buildAppointmentStats(),

                    const SizedBox(
                      height: 34,
                    ),

                    _buildUpcomingBookings(),

                    const SizedBox(
                      height: 34,
                    ),

                    _buildQuickOverview(),

                    const SizedBox(
                      height: 34,
                    ),

                    _buildSectionHeader(
                      title:
                      'Recent Activity',

                      subtitle:
                      'Latest administrative and system actions.',
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _buildActivityList(),

                    const SizedBox(
                      height: 30,
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final bool small =
            constraints.maxWidth <
                520;

        final Widget title =
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
                civicGreen,

                borderRadius:
                BorderRadius.circular(
                  15,
                ),
              ),

              child:
              const Icon(
                Icons.admin_panel_settings_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            const Expanded(
              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    'CivicID Admin',

                    style:
                    TextStyle(
                      color:
                      darkGreen,

                      fontSize:
                      22,

                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  SizedBox(
                    height:
                    3,
                  ),

                  Text(
                    'Administration & Verification Portal',

                    style:
                    TextStyle(
                      color:
                      textGrey,

                      fontSize:
                      13,

                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final Widget online =
        Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal:
            13,

            vertical:
            9,
          ),

          decoration:
          BoxDecoration(
            color:
            lightGreen,

            borderRadius:
            BorderRadius.circular(
              30,
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
            mainAxisSize:
            MainAxisSize.min,

            children: [
              Icon(
                Icons.circle,
                color:
                civicGreen,
                size:
                9,
              ),

              SizedBox(
                width:
                7,
              ),

              Text(
                'System Online',

                style:
                TextStyle(
                  color:
                  darkGreen,

                  fontSize:
                  12,

                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),
        );

        if (small) {
          return Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              title,

              const SizedBox(
                height:
                13,
              ),

              online,
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child:
              title,
            ),

            online,
          ],
        );
      },
    );
  }

  // ============================================================
  // ADMIN BANNER
  // ============================================================

  Widget _buildAdminBanner() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        24,
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
          24,
        ),
      ),

      child:
      LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final bool small =
              constraints.maxWidth <
                  520;

          final Widget text =
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              const Text(
                'Admin Command Center',

                style:
                TextStyle(
                  color:
                  Colors.white,

                  fontSize:
                  26,

                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(
                height:
                8,
              ),

              Text(
                'Review applications, verify uploaded documents, '
                    'manage appointment slots and monitor CivicID '
                    'prototype activity.',

                style:
                TextStyle(
                  color:
                  Colors.white.withValues(
                    alpha:
                    0.90,
                  ),

                  fontSize:
                  14,

                  height:
                  1.55,
                ),
              ),

              const SizedBox(
                height:
                18,
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal:
                  12,

                  vertical:
                  8,
                ),

                decoration:
                BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha:
                    0.13,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child:
                const Text(
                  'ADMINISTRATOR',

                  style:
                  TextStyle(
                    color:
                    Colors.white,

                    fontSize:
                    11,

                    fontWeight:
                    FontWeight.w900,

                    letterSpacing:
                    0.8,
                  ),
                ),
              ),
            ],
          );

          if (small) {
            return text;
          }

          return Row(
            children: [
              Expanded(
                child:
                text,
              ),

              const SizedBox(
                width:
                25,
              ),

              Container(
                width:
                105,

                height:
                105,

                decoration:
                BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha:
                    0.12,
                  ),

                  shape:
                  BoxShape.circle,
                ),

                child:
                const Icon(
                  Icons.security_rounded,
                  color:
                  Colors.white,
                  size:
                  52,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // SYSTEM STATISTICS
  // ============================================================

  Widget _buildStatsGrid() {
    return FutureBuilder<
        Map<String, int>>(
      future:
      _statsFuture,

      builder: (
          context,
          snapshot,
          ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding:
            EdgeInsets.all(
              40,
            ),

            child:
            Center(
              child:
              CircularProgressIndicator(
                color:
                civicGreen,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _errorCard(
            'Unable to load system statistics.',
          );
        }

        final Map<String, int> stats =
            snapshot.data ??
                {};

        return LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            int columns =
            2;

            if (constraints.maxWidth >=
                900) {
              columns =
              4;
            }

            return GridView.count(
              shrinkWrap:
              true,

              physics:
              const NeverScrollableScrollPhysics(),

              crossAxisCount:
              columns,

              crossAxisSpacing:
              14,

              mainAxisSpacing:
              14,

              childAspectRatio:
              constraints.maxWidth <
                  450
                  ? 1.08
                  : 1.45,

              children: [
                _buildStatCard(
                  label:
                  'Total Applications',

                  value:
                  '${stats['totalApplications'] ?? 0}',

                  description:
                  'Open all submitted applications',

                  icon:
                  Icons.description_outlined,

                  onTap:
                  _openApplications,
                ),

                _buildStatCard(
                  label:
                  'Pending Review',

                  value:
                  '${stats['pendingVerifications'] ?? 0}',

                  description:
                  'Review documents waiting for verification',

                  icon:
                  Icons.pending_actions_rounded,

                  attention:
                  true,

                  onTap:
                  _openDocuments,
                ),

                _buildStatCard(
                  label:
                  'Citizens',

                  value:
                  '${stats['totalUsers'] ?? 0}',

                  description:
                  'View citizen account information',

                  icon:
                  Icons.people_outline_rounded,

                  onTap:
                      () {
                    _showCitizensInfo(
                      stats['totalUsers'] ??
                          0,
                    );
                  },
                ),

                _buildStatCard(
                  label:
                  'Completed',

                  value:
                  '${stats['completedApps'] ?? 0}',

                  description:
                  'Open applications and review outcomes',

                  icon:
                  Icons.verified_outlined,

                  onTap:
                  _openApplications,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool attention = false,
  }) {
    final Color iconColor =
    attention
        ? warningColor
        : civicGreen;

    final Color iconBackground =
    attention
        ? warningBackground
        : lightGreen;

    return Material(
      color:
      Colors.transparent,

      child:
      InkWell(
        onTap:
        onTap,

        borderRadius:
        BorderRadius.circular(
          19,
        ),

        child:
        Container(
          padding:
          const EdgeInsets.all(
            18,
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
              attention
                  ? const Color(
                0xFFF0D9A1,
              )
                  : borderColor,
            ),

            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withValues(
                  alpha:
                  0.025,
                ),

                blurRadius:
                10,

                offset:
                const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),

          child:
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

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
                      iconBackground,

                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),

                    child:
                    Icon(
                      icon,
                      color:
                      iconColor,
                      size:
                      22,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.arrow_forward_rounded,
                    color:
                    civicGreen,
                  ),
                ],
              ),

              const Spacer(),

              Text(
                value,

                style:
                const TextStyle(
                  color:
                  darkText,

                  fontSize:
                  28,

                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(
                height:
                4,
              ),

              Text(
                label,

                maxLines:
                1,

                overflow:
                TextOverflow.ellipsis,

                style:
                const TextStyle(
                  color:
                  darkGreen,

                  fontSize:
                  14,

                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(
                height:
                5,
              ),

              Text(
                description,

                maxLines:
                2,

                overflow:
                TextOverflow.ellipsis,

                style:
                const TextStyle(
                  color:
                  textGrey,

                  fontSize:
                  11,

                  height:
                  1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // APPOINTMENT STATISTICS
  // ============================================================

  Widget _buildAppointmentStats() {
    return FutureBuilder<
        List<AppointmentSlot>>(
      future:
      _appointmentSlotsFuture,

      builder: (
          context,
          snapshot,
          ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding:
            EdgeInsets.all(
              30,
            ),

            child:
            Center(
              child:
              CircularProgressIndicator(
                color:
                civicGreen,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _errorCard(
            'Unable to load appointment information.',
          );
        }

        final List<AppointmentSlot> slots =
            snapshot.data ??
                [];

        final DateTime now =
        DateTime.now();

        // AVAILABLE FUTURE SLOTS
        final List<AppointmentSlot>
        available =
        slots
            .where(
              (slot) =>
          !slot.isBooked &&
              slot.dateTime.isAfter(
                now,
              ),
        )
            .toList();

        // BOOKED TODAY
        final List<AppointmentSlot>
        bookedToday =
        slots.where(
              (slot) {
            return slot.isBooked &&
                slot.dateTime.year ==
                    now.year &&
                slot.dateTime.month ==
                    now.month &&
                slot.dateTime.day ==
                    now.day;
          },
        ).toList();

        // FUTURE BOOKED APPOINTMENTS
        final List<AppointmentSlot>
        upcoming =
        slots
            .where(
              (slot) =>
          slot.isBooked &&
              slot.dateTime.isAfter(
                now,
              ),
        )
            .toList();

        // ACTIVE BRANCHES
        //
        // Only branches that still have future appointment
        // availability/bookings are counted.
        final int branches =
            slots
                .where(
                  (slot) =>
                  slot.dateTime.isAfter(
                    now,
                  ),
            )
                .map(
                  (slot) =>
              slot.branch,
            )
                .toSet()
                .length;

        return LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            int columns =
            2;

            if (constraints.maxWidth >=
                900) {
              columns =
              4;
            }

            return GridView.count(
              shrinkWrap:
              true,

              physics:
              const NeverScrollableScrollPhysics(),

              crossAxisCount:
              columns,

              crossAxisSpacing:
              14,

              mainAxisSpacing:
              14,

              childAspectRatio:
              constraints.maxWidth <
                  450
                  ? 1.08
                  : 1.45,

              children: [
                _buildAppointmentStatCard(
                  label:
                  'Available Slots',

                  value:
                  '${available.length}',

                  description:
                  'Manage slots citizens can book',

                  icon:
                  Icons.event_available_outlined,

                  background:
                  lightGreen,

                  iconColor:
                  civicGreen,

                  onTap:
                      () {
                    _openAppointments();
                  },
                ),

                _buildAppointmentStatCard(
                  label:
                  'Booked Today',

                  value:
                  '${bookedToday.length}',

                  description:
                  'View today\'s booked appointments',

                  icon:
                  Icons.calendar_today_rounded,

                  background:
                  redBackground,

                  iconColor:
                  redColor,

                  onTap:
                      () {
                    _openAppointments();
                  },
                ),

                _buildAppointmentStatCard(
                  label:
                  'Upcoming',

                  value:
                  '${upcoming.length}',

                  description:
                  'View future citizen bookings',

                  icon:
                  Icons.schedule_rounded,

                  background:
                  warningBackground,

                  iconColor:
                  warningColor,

                  onTap:
                      () {
                    _openAppointments();
                  },
                ),

                _buildAppointmentStatCard(
                  label:
                  'Active Branches',

                  value:
                  '$branches',

                  description:
                  'Branches with future appointment slots',

                  icon:
                  Icons.location_on_outlined,

                  background:
                  blueBackground,

                  iconColor:
                  blueColor,

                  onTap:
                      () {
                    _openAppointments();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentStatCard({
    required String label,
    required String value,
    required String description,
    required IconData icon,
    required Color background,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
      Colors.transparent,

      child:
      InkWell(
        onTap:
        onTap,

        borderRadius:
        BorderRadius.circular(
          19,
        ),

        child:
        Container(
          padding:
          const EdgeInsets.all(
            18,
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

            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withValues(
                  alpha:
                  0.025,
                ),

                blurRadius:
                10,

                offset:
                const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),

          child:
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

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
                      background,

                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),

                    child:
                    Icon(
                      icon,
                      color:
                      iconColor,
                      size:
                      22,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.arrow_forward_rounded,
                    color:
                    civicGreen,
                    size:
                    20,
                  ),
                ],
              ),

              const Spacer(),

              Text(
                value,

                style:
                const TextStyle(
                  color:
                  darkText,

                  fontSize:
                  28,

                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(
                height:
                4,
              ),

              Text(
                label,

                maxLines:
                1,

                overflow:
                TextOverflow.ellipsis,

                style:
                const TextStyle(
                  color:
                  darkGreen,

                  fontSize:
                  14,

                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(
                height:
                5,
              ),

              Text(
                description,

                maxLines:
                2,

                overflow:
                TextOverflow.ellipsis,

                style:
                const TextStyle(
                  color:
                  textGrey,

                  fontSize:
                  11,

                  height:
                  1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UPCOMING BOOKINGS
  // ============================================================

  Widget _buildUpcomingBookings() {
    return FutureBuilder<
        List<AppointmentSlot>>(
      future:
      _appointmentSlotsFuture,

      builder: (
          context,
          snapshot,
          ) {
        final List<AppointmentSlot> allSlots =
            snapshot.data ??
                [];

        final DateTime now =
        DateTime.now();

        final List<AppointmentSlot> upcoming =
        allSlots
            .where(
              (slot) =>
          slot.isBooked &&
              !slot.dateTime.isBefore(
                now,
              ),
        )
            .toList();

        upcoming.sort(
              (
              a,
              b,
              ) =>
              a.dateTime.compareTo(
                b.dateTime,
              ),
        );

        final List<AppointmentSlot>
        displayBookings =
        upcoming
            .take(
          5,
        )
            .toList();

        return Container(
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
              21,
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
              Row(
                children: [
                  Container(
                    width:
                    46,

                    height:
                    46,

                    decoration:
                    BoxDecoration(
                      color:
                      lightGreen,

                      borderRadius:
                      BorderRadius.circular(
                        13,
                      ),
                    ),

                    child:
                    const Icon(
                      Icons.event_note_rounded,
                      color:
                      civicGreen,
                      size:
                      24,
                    ),
                  ),

                  const SizedBox(
                    width:
                    13,
                  ),

                  const Expanded(
                    child:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Upcoming Bookings',

                          style:
                          TextStyle(
                            color:
                            darkGreen,

                            fontSize:
                            18,

                            fontWeight:
                            FontWeight.w900,
                          ),
                        ),

                        SizedBox(
                          height:
                          3,
                        ),

                        Text(
                          'Next citizen appointment bookings.',

                          style:
                          TextStyle(
                            color:
                            textGrey,

                            fontSize:
                            12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  TextButton.icon(
                    onPressed:
                        () {
                      _openAppointments();
                    },

                    icon:
                    const Icon(
                      Icons.open_in_new_rounded,
                      size:
                      18,
                    ),

                    label:
                    const Text(
                      'OPEN',
                      style:
                      TextStyle(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    style:
                    TextButton.styleFrom(
                      foregroundColor:
                      civicGreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                18,
              ),

              if (snapshot.connectionState ==
                  ConnectionState.waiting)
                const Center(
                  child:
                  Padding(
                    padding:
                    EdgeInsets.all(
                      20,
                    ),

                    child:
                    CircularProgressIndicator(
                      color:
                      civicGreen,
                    ),
                  ),
                )
              else if (displayBookings.isEmpty)
                _emptyAppointments()
              else
                ...displayBookings.map(
                  _bookingRow,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _bookingRow(
      AppointmentSlot slot,
      ) {
    return Material(
      color:
      Colors.transparent,

      child:
      InkWell(
        onTap:
            () {
          _openAppointments();
        },

        borderRadius:
        BorderRadius.circular(
          15,
        ),

        child:
        Container(
          margin:
          const EdgeInsets.only(
            bottom:
            10,
          ),

          padding:
          const EdgeInsets.all(
            16,
          ),

          decoration:
          BoxDecoration(
            color:
            pageBackground,

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
          Row(
            children: [
              Container(
                width:
                48,

                height:
                48,

                decoration:
                BoxDecoration(
                  color:
                  redBackground,

                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),

                child:
                const Icon(
                  Icons.calendar_month_rounded,
                  color:
                  redColor,
                  size:
                  22,
                ),
              ),

              const SizedBox(
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
                      slot.branch,

                      style:
                      const TextStyle(
                        color:
                        darkText,

                        fontSize:
                        14,

                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height:
                      6,
                    ),

                    Wrap(
                      spacing:
                      14,

                      runSpacing:
                      7,

                      children: [
                        _smallInfo(
                          Icons.calendar_today_outlined,

                          DateFormat(
                            'dd MMM yyyy',
                          ).format(
                            slot.dateTime,
                          ),
                        ),

                        _smallInfo(
                          Icons.schedule_outlined,

                          DateFormat(
                            'HH:mm',
                          ).format(
                            slot.dateTime,
                          ),
                        ),
                      ],
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
                  11,

                  vertical:
                  7,
                ),

                decoration:
                BoxDecoration(
                  color:
                  redBackground,

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child:
                const Text(
                  'BOOKED',

                  style:
                  TextStyle(
                    color:
                    redColor,

                    fontSize:
                    10,

                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallInfo(
      IconData icon,
      String value,
      ) {
    return Row(
      mainAxisSize:
      MainAxisSize.min,

      children: [
        Icon(
          icon,
          size:
          15,
          color:
          textGrey,
        ),

        const SizedBox(
          width:
          5,
        ),

        Text(
          value,

          style:
          const TextStyle(
            color:
            textGrey,

            fontSize:
            12,
          ),
        ),
      ],
    );
  }

  Widget _emptyAppointments() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        32,
      ),

      decoration:
      BoxDecoration(
        color:
        pageBackground,

        borderRadius:
        BorderRadius.circular(
          15,
        ),
      ),

      child:
      Column(
        children: [
          const Icon(
            Icons.event_available_outlined,
            color:
            civicGreen,
            size:
            38,
          ),

          const SizedBox(
            height:
            10,
          ),

          const Text(
            'No upcoming bookings',

            style:
            TextStyle(
              color:
              darkGreen,

              fontSize:
              15,

              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height:
            5,
          ),

          const Text(
            'Booked citizen appointments will appear here automatically.',

            textAlign:
            TextAlign.center,

            style:
            TextStyle(
              color:
              textGrey,

              fontSize:
              12,
            ),
          ),

          const SizedBox(
            height:
            14,
          ),

          OutlinedButton.icon(
            onPressed:
                () {
              _openAppointments();
            },

            icon:
            const Icon(
              Icons.settings_outlined,
            ),

            label:
            const Text(
              'MANAGE APPOINTMENTS',

              style:
              TextStyle(
                fontWeight:
                FontWeight.w800,
              ),
            ),

            style:
            OutlinedButton.styleFrom(
              foregroundColor:
              civicGreen,

              side:
              const BorderSide(
                color:
                civicGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADMIN WORKFLOW
  // ============================================================

  Widget _buildQuickOverview() {
    return Container(
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
          21,
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
                Icons.fact_check_outlined,
                color:
                civicGreen,
                size:
                26,
              ),

              SizedBox(
                width:
                11,
              ),

              Text(
                'Admin Workflow',

                style:
                TextStyle(
                  color:
                  darkGreen,

                  fontSize:
                  18,

                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
            6,
          ),

          const Text(
            'Open the relevant section to continue the administrative process.',

            style:
            TextStyle(
              color:
              textGrey,

              fontSize:
              12,

              height:
              1.45,
            ),
          ),

          const SizedBox(
            height:
            20,
          ),

          LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final bool horizontal =
                  constraints.maxWidth >=
                      760;

              final List<Widget> items = [
                _buildWorkflowItem(
                  number:
                  '1',

                  title:
                  'Submitted',

                  subtitle:
                  'Open submitted applications',

                  icon:
                  Icons.send_outlined,

                  onTap:
                  _openApplications,
                ),

                _buildWorkflowItem(
                  number:
                  '2',

                  title:
                  'Review',

                  subtitle:
                  'Review application details',

                  icon:
                  Icons.manage_search_rounded,

                  onTap:
                  _openApplications,
                ),

                _buildWorkflowItem(
                  number:
                  '3',

                  title:
                  'Verify',

                  subtitle:
                  'Inspect citizen documents',

                  icon:
                  Icons.verified_user_outlined,

                  onTap:
                  _openDocuments,
                ),

                _buildWorkflowItem(
                  number:
                  '4',

                  title:
                  'Decision',

                  subtitle:
                  'Review final application status',

                  icon:
                  Icons.task_alt_rounded,

                  onTap:
                  _openApplications,
                ),
              ];

              if (!horizontal) {
                return Column(
                  children:
                  items.map(
                        (item) {
                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom:
                          11,
                        ),
                        child:
                        item,
                      );
                    },
                  ).toList(),
                );
              }

              return Row(
                children:
                items.map(
                      (item) {
                    return Expanded(
                      child:
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                          5,
                        ),

                        child:
                        item,
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),

          const SizedBox(
            height:
            15,
          ),

          SizedBox(
            width:
            double.infinity,

            child:
            OutlinedButton.icon(
              onPressed:
              _openLogs,

              icon:
              const Icon(
                Icons.history_rounded,
              ),

              label:
              const Text(
                'OPEN SYSTEM AUDIT LOGS',

                style:
                TextStyle(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                civicGreen,

                side:
                const BorderSide(
                  color:
                  civicGreen,
                ),

                padding:
                const EdgeInsets.symmetric(
                  vertical:
                  15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowItem({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
      Colors.transparent,

      child:
      InkWell(
        onTap:
        onTap,

        borderRadius:
        BorderRadius.circular(
          16,
        ),

        child:
        Container(
          constraints:
          const BoxConstraints(
            minHeight:
            105,
          ),

          padding:
          const EdgeInsets.all(
            15,
          ),

          decoration:
          BoxDecoration(
            color:
            pageBackground,

            borderRadius:
            BorderRadius.circular(
              16,
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
              Container(
                width:
                38,

                height:
                38,

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

                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(
                width:
                10,
              ),

              Icon(
                icon,
                color:
                civicGreen,
                size:
                22,
              ),

              const SizedBox(
                width:
                10,
              ),

              Expanded(
                child:
                Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

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
                        14,

                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height:
                      4,
                    ),

                    Text(
                      subtitle,

                      style:
                      const TextStyle(
                        color:
                        textGrey,

                        fontSize:
                        11,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color:
                civicGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style:
          const TextStyle(
            color:
            darkText,

            fontSize:
            22,

            fontWeight:
            FontWeight.w900,
          ),
        ),

        const SizedBox(
          height:
          5,
        ),

        Text(
          subtitle,

          style:
          const TextStyle(
            color:
            textGrey,

            fontSize:
            13,

            height:
            1.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTIVITY
  // ============================================================

  Widget _buildActivityList() {
    final events =
    _mockData.auditEvents
        .take(
      5,
    )
        .toList();

    if (events.isEmpty) {
      return Container(
        width:
        double.infinity,

        padding:
        const EdgeInsets.all(
          30,
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
        Column(
          children: [
            const Icon(
              Icons.history_rounded,
              color:
              textGrey,
              size:
              38,
            ),

            const SizedBox(
              height:
              10,
            ),

            const Text(
              'No recent activity',

              style:
              TextStyle(
                color:
                darkGreen,

                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height:
              12,
            ),

            OutlinedButton.icon(
              onPressed:
              _openLogs,

              icon:
              const Icon(
                Icons.history_rounded,
              ),

              label:
              const Text(
                'OPEN AUDIT LOGS',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...events.map(
              (event) {
            return Material(
              color:
              Colors.transparent,

              child:
              InkWell(
                onTap:
                _openLogs,

                borderRadius:
                BorderRadius.circular(
                  17,
                ),

                child:
                Container(
                  width:
                  double.infinity,

                  margin:
                  const EdgeInsets.only(
                    bottom:
                    11,
                  ),

                  padding:
                  const EdgeInsets.all(
                    16,
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

                  child:
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Container(
                        width:
                        46,

                        height:
                        46,

                        decoration:
                        BoxDecoration(
                          color:
                          lightGreen,

                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),

                        child:
                        const Icon(
                          Icons.history_rounded,
                          color:
                          civicGreen,
                        ),
                      ),

                      const SizedBox(
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
                              event.description,

                              style:
                              const TextStyle(
                                color:
                                darkText,

                                fontSize:
                                14,

                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),

                            const SizedBox(
                              height:
                              6,
                            ),

                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size:
                                  15,
                                  color:
                                  textGrey,
                                ),

                                const SizedBox(
                                  width:
                                  5,
                                ),

                                Flexible(
                                  child:
                                  Text(
                                    DateFormat(
                                      'dd MMM yyyy • HH:mm',
                                    ).format(
                                      event.timestamp,
                                    ),

                                    style:
                                    const TextStyle(
                                      color:
                                      textGrey,

                                      fontSize:
                                      12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right_rounded,
                        color:
                        civicGreen,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(
          height:
          5,
        ),

        SizedBox(
          width:
          double.infinity,

          child:
          OutlinedButton.icon(
            onPressed:
            _openLogs,

            icon:
            const Icon(
              Icons.history_rounded,
            ),

            label:
            const Text(
              'VIEW ALL ACTIVITY',

              style:
              TextStyle(
                fontWeight:
                FontWeight.w800,
              ),
            ),

            style:
            OutlinedButton.styleFrom(
              foregroundColor:
              civicGreen,

              side:
              const BorderSide(
                color:
                civicGreen,
              ),

              padding:
              const EdgeInsets.symmetric(
                vertical:
                15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorCard(
      String message,
      ) {
    return Container(
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
          18,
        ),

        border:
        Border.all(
          color:
          borderColor,
        ),
      ),

      child:
      Text(
        message,

        textAlign:
        TextAlign.center,

        style:
        const TextStyle(
          color:
          textGrey,

          fontSize:
          14,

          height:
          1.4,
        ),
      ),
    );
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  Widget _buildPrototypeNotice() {
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
            20,
          ),

          SizedBox(
            width:
            10,
          ),

          Expanded(
            child:
            Text(
              'Academic Prototype — This administration portal '
                  'and its appointment availability are demonstration '
                  'features and are not connected to an official '
                  'government system.',

              style:
              TextStyle(
                color:
                textGrey,

                fontSize:
                12,

                height:
                1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}