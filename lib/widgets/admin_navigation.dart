import 'package:flutter/material.dart';

import '../screens/admin/admin_dashboard_home.dart';
import '../screens/admin/admin_application_list.dart';
import '../screens/admin/admin_document_verification.dart';
import '../screens/admin/admin_identity_verification_screen.dart';
import '../screens/admin/admin_appointment_slots_screen.dart';
import '../screens/admin/admin_logs_screen.dart';

import '../screens/notifications_screen.dart';
import '../services/notification_service.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({
    super.key,
  });

  @override
  State<AdminNavigation> createState() =>
      _AdminNavigationState();
}

class _AdminNavigationState
    extends State<AdminNavigation> {
  static const Color primaryGreen =
  Color(0xFF08783E);

  static const Color darkGreen =
  Color(0xFF04542C);

  static const Color lightGreen =
  Color(0xFFEAF7EF);

  static const Color pageBackground =
  Color(0xFFF8FBF9);

  static const Color darkText =
  Color(0xFF1F2933);

  static const Color greyText =
  Color(0xFF52635B);

  static const Color borderColor =
  Color(0xFFE4E7E5);

  final NotificationService _notificationService =
  NotificationService();

  int _currentIndex = 0;

  late Future<int> _unreadCountFuture;

  @override
  void initState() {
    super.initState();

    _unreadCountFuture =
        _notificationService.getUnreadCount(
          type: 'Admin',
        );
  }

  void _refreshUnreadCount() {
    setState(() {
      _unreadCountFuture =
          _notificationService.getUnreadCount(
            type: 'Admin',
          );
    });
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final confirm =
    await showDialog<bool>(
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
              18,
            ),
          ),
          title:
          const Row(
            children: [
              CircleAvatar(
                backgroundColor:
                Color(
                  0xFFFFEEEE,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                ),
              ),

              SizedBox(width: 12),

              Text(
                'Admin Logout',
                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),
          content:
          const Text(
            'Are you sure you want to log out of the CivicID Admin Portal?',
            style: TextStyle(
              color: greyText,
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
              child:
              const Text(
                'Cancel',
              ),
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              icon:
              const Icon(
                Icons.logout_rounded,
                size: 18,
              ),
              label:
              const Text(
                'Logout',
              ),
              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                Colors.red,
                foregroundColor:
                Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true &&
        mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/',
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
    final List<Widget> screens = [
      const AdminDashboardHome(),
      const AdminApplicationList(),
      const AdminDocumentVerification(),
      const AdminIdentityVerificationScreen(),
      const AdminAppointmentSlotsScreen(),
      const AdminLogsScreen(),
    ];

    return Scaffold(
      backgroundColor:
      pageBackground,

      appBar:
      AppBar(
        backgroundColor:
        Colors.white,
        surfaceTintColor:
        Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,
        titleSpacing: 20,

        title:
        const Row(
          children: [
            Icon(
              Icons
                  .admin_panel_settings_rounded,
              color:
              primaryGreen,
              size: 28,
            ),

            SizedBox(width: 10),

            Text(
              'CivicID ADMIN',
              style: TextStyle(
                color:
                darkGreen,
                fontSize: 20,
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ],
        ),

        actions: [
          FutureBuilder<int>(
            future:
            _unreadCountFuture,
            builder: (
                context,
                snapshot,
                ) {
              final count =
                  snapshot.data ?? 0;

              return Padding(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: Badge(
                  isLabelVisible:
                  count > 0,
                  label: Text(
                    count.toString(),
                  ),
                  backgroundColor:
                  Colors.red,
                  child: Container(
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
                    IconButton(
                      icon:
                      const Icon(
                        Icons
                            .notifications_none_rounded,
                        color:
                        primaryGreen,
                      ),
                      onPressed:
                          () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                            const NotificationsScreen(
                              type:
                              'Admin',
                            ),
                          ),
                        );

                        _refreshUnreadCount();
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 10),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Material(
              color:
              const Color(
                0xFFFFEEEE,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
              child: InkWell(
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
                onTap:
                _logout,
                child:
                const Padding(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 13,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color:
                    Colors.red,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),
        ],

        bottom:
        const PreferredSize(
          preferredSize:
          Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color:
            borderColor,
          ),
        ),
      ),

      body:
      IndexedStack(
        index:
        _currentIndex,
        children:
        screens,
      ),

      bottomNavigationBar:
      NavigationBarTheme(
        data:
        NavigationBarThemeData(
          backgroundColor:
          Colors.white,

          indicatorColor:
          lightGreen,

          height:
          84,

          elevation:
          0,

          surfaceTintColor:
          Colors.white,

          iconTheme:
          WidgetStateProperty
              .resolveWith<
              IconThemeData>(
                (
                states,
                ) {
              if (states.contains(
                WidgetState.selected,
              )) {
                return const IconThemeData(
                  color:
                  primaryGreen,
                  size:
                  24,
                );
              }

              return const IconThemeData(
                color:
                greyText,
                size:
                23,
              );
            },
          ),

          labelTextStyle:
          WidgetStateProperty
              .resolveWith<
              TextStyle>(
                (
                states,
                ) {
              if (states.contains(
                WidgetState.selected,
              )) {
                return const TextStyle(
                  color:
                  darkGreen,
                  fontSize:
                  12,
                  fontWeight:
                  FontWeight.w800,
                );
              }

              return const TextStyle(
                color:
                greyText,
                fontSize:
                12,
                fontWeight:
                FontWeight.w600,
              );
            },
          ),
        ),

        child:
        NavigationBar(
          selectedIndex:
          _currentIndex,

          animationDuration:
          const Duration(
            milliseconds:
            350,
          ),

          labelBehavior:
          NavigationDestinationLabelBehavior
              .alwaysShow,

          onDestinationSelected:
              (
              index,
              ) {
            setState(() {
              _currentIndex =
                  index;
            });
          },

          destinations:
          const [
            NavigationDestination(
              tooltip: '',
              icon:
              Icon(
                Icons
                    .dashboard_outlined,
              ),
              selectedIcon:
              Icon(
                Icons
                    .dashboard_rounded,
              ),
              label:
              'Overview',
            ),

            NavigationDestination(
              tooltip: '',
              icon:
              Icon(
                Icons
                    .fact_check_outlined,
              ),
              selectedIcon:
              Icon(
                Icons
                    .fact_check_rounded,
              ),
              label:
              'Applications',
            ),

            NavigationDestination(
              tooltip: '',
              icon:
              Icon(
                Icons
                    .description_outlined,
              ),
              selectedIcon:
              Icon(
                Icons
                    .description_rounded,
              ),
              label:
              'Documents',
            ),

            NavigationDestination(
              tooltip: '',
              icon:
              Icon(
                Icons
                    .face_retouching_natural_outlined,
              ),
              selectedIcon:
              Icon(
                Icons
                    .face_retouching_natural_rounded,
              ),
              label:
              'Identity',
            ),

            NavigationDestination(
              tooltip: '',
              icon:
              Icon(
                Icons
                    .calendar_month_outlined,
              ),
              selectedIcon:
              Icon(
                Icons
                    .calendar_month_rounded,
              ),
              label:
              'Appointments',
            ),

            NavigationDestination(
              tooltip: '',
              icon:
              Icon(
                Icons
                    .history_outlined,
              ),
              selectedIcon:
              Icon(
                Icons
                    .history_rounded,
              ),
              label:
              'Logs',
            ),
          ],
        ),
      ),
    );
  }
}