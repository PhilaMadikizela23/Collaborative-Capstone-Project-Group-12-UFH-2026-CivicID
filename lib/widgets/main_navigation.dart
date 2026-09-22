import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/services_screen.dart';
import '../screens/document_wallet_screen.dart';
import '../screens/application/application_tracking_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/appointment_booking_screen.dart';
import '../screens/settings/help_support_screen.dart';
import '../screens/settings/settings_screen.dart';

import '../services/notification_service.dart';

import 'civic_header.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
  });

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {
  static const Color civicGreen =
  Color(0xFF08783E);

  static const Color darkGreen =
  Color(0xFF04542C);

  static const Color lightGreen =
  Color(0xFFEAF7EF);

  static const Color pageBackground =
  Color(0xFFF8FBF9);

  static const Color textGrey =
  Color(0xFF52635B);

  static const Color borderColor =
  Color(0xFFDDE7E1);

  static const Color darkText =
  Color(0xFF14251C);

  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();

  final NotificationService _notificationService =
  NotificationService();

  late Future<int> _unreadCountFuture;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  void _loadUnreadCount() {
    _unreadCountFuture =
        _notificationService.getUnreadCount(
          type: 'User',
        );
  }

  void _refreshUnreadCount() {
    setState(() {
      _loadUnreadCount();
    });
  }

  void _onTabChange(
      int index,
      ) {
    if (index < 0 || index > 4) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      _refreshUnreadCount();
    }
  }

  void _closeDrawerAndGoToTab(
      int index,
      ) {
    Navigator.pop(context);

    _onTabChange(index);
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const NotificationsScreen(),
      ),
    );

    if (mounted) {
      _refreshUnreadCount();
    }
  }

  Future<void> _openPage(
      Widget page,
      ) async {
    Navigator.pop(context);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );

    if (mounted) {
      _refreshUnreadCount();
    }
  }

  void _showLogoutDialog() {
    Navigator.pop(context);

    showDialog<void>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Log out?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Are you sure you want to leave your CivicID account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
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
                );

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/welcome',
                      (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: civicGreen,
              ),
              child: const Text(
                'LOG OUT',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final List<Widget> screens = [
      DashboardScreen(
        onTabChange: _onTabChange,
      ),
      const ServicesScreen(),
      const DocumentWalletScreen(),
      const ApplicationTrackingScreen(),
      const ProfileScreen(),
    ];

    return FutureBuilder<int>(
      future: _unreadCountFuture,
      builder: (
          context,
          snapshot,
          ) {
        final unreadCount =
            snapshot.data ?? 0;

        return Scaffold(
          key: _scaffoldKey,

          backgroundColor:
          pageBackground,

          endDrawer:
          _buildMenuDrawer(),

          body: Column(
            children: [
              CivicHeader(
                unreadCount:
                unreadCount,

                onHomeTap: () {
                  _onTabChange(0);
                },

                onNotificationsTap:
                _openNotifications,

                onMenuTap: () {
                  _scaffoldKey
                      .currentState
                      ?.openEndDrawer();
                },
              ),

              Expanded(
                child: IndexedStack(
                  index:
                  _currentIndex,
                  children:
                  screens,
                ),
              ),
            ],
          ),

          // =====================================================
          // BOTTOM NAVIGATION
          // =====================================================

          bottomNavigationBar:
          Container(
            decoration:
            BoxDecoration(
              color:
              Colors.white,

              border:
              const Border(
                top:
                BorderSide(
                  color:
                  borderColor,
                  width:
                  1,
                ),
              ),

              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black
                      .withValues(
                    alpha:
                    0.05,
                  ),
                  blurRadius:
                  18,
                  offset:
                  const Offset(
                    0,
                    -4,
                  ),
                ),
              ],
            ),

            child:
            SafeArea(
              top:
              false,

              child:
              NavigationBarTheme(
                data:
                NavigationBarThemeData(
                  backgroundColor:
                  Colors.white,

                  indicatorColor:
                  lightGreen,

                  elevation:
                  0,

                  height:
                  72,

                  surfaceTintColor:
                  Colors.white,

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
                          FontWeight.w700,
                        );
                      }

                      return const TextStyle(
                        color:
                        textGrey,
                        fontSize:
                        12,
                        fontWeight:
                        FontWeight.w500,
                      );
                    },
                  ),

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
                          civicGreen,
                          size:
                          25,
                        );
                      }

                      return const IconThemeData(
                        color:
                        textGrey,
                        size:
                        23,
                      );
                    },
                  ),
                ),

                // ===============================================
                // TOOLTIP POPUPS DISABLED HERE
                // ===============================================

                child:
                TooltipVisibility(
                  visible:
                  false,

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
                    _onTabChange,

                    destinations:
                    const [
                      NavigationDestination(
                        icon:
                        Icon(
                          Icons
                              .home_outlined,
                        ),
                        selectedIcon:
                        Icon(
                          Icons
                              .home_rounded,
                        ),
                        label:
                        'Home',
                      ),

                      NavigationDestination(
                        icon:
                        Icon(
                          Icons
                              .grid_view_outlined,
                        ),
                        selectedIcon:
                        Icon(
                          Icons
                              .grid_view_rounded,
                        ),
                        label:
                        'Services',
                      ),

                      NavigationDestination(
                        icon:
                        Icon(
                          Icons
                              .folder_outlined,
                        ),
                        selectedIcon:
                        Icon(
                          Icons
                              .folder_rounded,
                        ),
                        label:
                        'Documents',
                      ),

                      NavigationDestination(
                        icon:
                        Icon(
                          Icons
                              .assignment_outlined,
                        ),
                        selectedIcon:
                        Icon(
                          Icons
                              .assignment_rounded,
                        ),
                        label:
                        'Applications',
                      ),

                      NavigationDestination(
                        icon:
                        Icon(
                          Icons
                              .person_outline_rounded,
                        ),
                        selectedIcon:
                        Icon(
                          Icons
                              .person_rounded,
                        ),
                        label:
                        'Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DRAWER
  // ============================================================

  Widget _buildMenuDrawer() {
    return Drawer(
      width: 310,

      backgroundColor:
      Colors.white,

      child: SafeArea(
        child: Column(
          children: [
            Container(
              width:
              double.infinity,

              padding:
              const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                22,
              ),

              decoration:
              const BoxDecoration(
                gradient:
                LinearGradient(
                  colors: [
                    civicGreen,
                    darkGreen,
                  ],
                  begin:
                  Alignment.topLeft,
                  end:
                  Alignment.bottomRight,
                ),
              ),

              child:
              const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons
                            .account_balance_rounded,
                        color:
                        Colors.white,
                        size:
                        31,
                      ),

                      SizedBox(
                        width:
                        10,
                      ),

                      Text(
                        'CivicID',
                        style:
                        TextStyle(
                          color:
                          Colors.white,
                          fontSize:
                          23,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height:
                    7,
                  ),

                  Text(
                    'Your Digital Citizen Profile',
                    style:
                    TextStyle(
                      color:
                      Color(
                        0xFFEAF7EF,
                      ),
                      fontSize:
                      12,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child:
              ListView(
                padding:
                const EdgeInsets
                    .symmetric(
                  vertical:
                  10,
                ),
                children: [
                  _drawerItem(
                    icon:
                    Icons.home_rounded,
                    title:
                    'Home',
                    selected:
                    _currentIndex == 0,
                    onTap: () {
                      _closeDrawerAndGoToTab(
                        0,
                      );
                    },
                  ),

                  _drawerItem(
                    icon:
                    Icons.grid_view_rounded,
                    title:
                    'Services',
                    selected:
                    _currentIndex == 1,
                    onTap: () {
                      _closeDrawerAndGoToTab(
                        1,
                      );
                    },
                  ),

                  _drawerItem(
                    icon:
                    Icons.folder_rounded,
                    title:
                    'Documents',
                    selected:
                    _currentIndex == 2,
                    onTap: () {
                      _closeDrawerAndGoToTab(
                        2,
                      );
                    },
                  ),

                  _drawerItem(
                    icon:
                    Icons.assignment_rounded,
                    title:
                    'My Applications',
                    selected:
                    _currentIndex == 3,
                    onTap: () {
                      _closeDrawerAndGoToTab(
                        3,
                      );
                    },
                  ),

                  _drawerItem(
                    icon:
                    Icons.person_rounded,
                    title:
                    'Profile',
                    selected:
                    _currentIndex == 4,
                    onTap: () {
                      _closeDrawerAndGoToTab(
                        4,
                      );
                    },
                  ),

                  const Divider(
                    height:
                    24,
                  ),

                  _drawerItem(
                    icon:
                    Icons.calendar_month_rounded,
                    title:
                    'Appointments',
                    onTap: () {
                      _openPage(
                        const AppointmentBookingScreen(),
                      );
                    },
                  ),

                  _drawerItem(
                    icon:
                    Icons.notifications_rounded,
                    title:
                    'Notifications',
                    onTap: () {
                      _openPage(
                        const NotificationsScreen(),
                      );
                    },
                  ),

                  _drawerItem(
                    icon:
                    Icons.help_outline_rounded,
                    title:
                    'Help & Support',
                    onTap: () {
                      _openPage(
                        const HelpSupportScreen(),
                      );
                    },
                  ),

                  _drawerItem(
                    icon:
                    Icons.settings_rounded,
                    title:
                    'Settings',
                    onTap: () {
                      _openPage(
                        const SettingsScreen(),
                      );
                    },
                  ),

                  const Divider(
                    height:
                    24,
                  ),

                  _drawerItem(
                    icon:
                    Icons.logout_rounded,
                    title:
                    'Log Out',
                    isDanger:
                    true,
                    onTap:
                    _showLogoutDialog,
                  ),
                ],
              ),
            ),

            const Padding(
              padding:
              EdgeInsets.fromLTRB(
                16,
                8,
                16,
                18,
              ),
              child:
              Text(
                'Academic Prototype — CivicID is not an official government service.',
                textAlign:
                TextAlign.center,
                style:
                TextStyle(
                  color:
                  textGrey,
                  fontSize:
                  11,
                  height:
                  1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DRAWER ITEM
  // ============================================================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    bool isDanger = false,
  }) {
    final Color foreground =
    isDanger
        ? Colors.red.shade700
        : selected
        ? civicGreen
        : darkText;

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal:
        10,
        vertical:
        2,
      ),

      child:
      ListTile(
        onTap:
        onTap,

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            13,
          ),
        ),

        tileColor:
        selected
            ? lightGreen
            : Colors.transparent,

        leading:
        Icon(
          icon,
          color:
          foreground,
        ),

        title:
        Text(
          title,
          style:
          TextStyle(
            color:
            foreground,
            fontSize:
            14,
            fontWeight:
            selected ||
                isDanger
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),

        trailing:
        isDanger
            ? null
            : const Icon(
          Icons
              .chevron_right_rounded,
          color:
          Color(
            0xFF8A9690,
          ),
        ),
      ),
    );
  }
}