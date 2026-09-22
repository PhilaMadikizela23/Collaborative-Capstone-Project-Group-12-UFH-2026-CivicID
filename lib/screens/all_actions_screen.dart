import 'package:flutter/material.dart';

import 'services_screen.dart';
import 'document_wallet_screen.dart';
import 'application/application_tracking_screen.dart';
import 'profile_screen.dart';
import 'appointment_booking_screen.dart';
import 'notifications_screen.dart';
import 'settings/audit_trail_screen.dart';
import 'settings/security_screen.dart';
import 'settings/help_support_screen.dart';

class AllActionsScreen extends StatelessWidget {
  const AllActionsScreen({super.key});

  static const Color civicGreen = Color(0xFF1F7A3D);
  static const Color darkGreen = Color(0xFF145A2A);
  static const Color lightGreen = Color(0xFFEAF6EC);
  static const Color pageBackground = Color(0xFFF5F7F6);
  static const Color borderColor = Color(0xFFDCE5DF);
  static const Color darkText = Color(0xFF1F2933);
  static const Color textGrey = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Applications',
        'subtitle': 'Start, manage and track CivicID applications.',
        'items': [
          {
            'name': 'New Application',
            'subtitle': 'Start a new government-service application.',
            'icon': Icons.add_task_rounded,
            'screen': const ServicesScreen(),
          },
          {
            'name': 'Book Appointment',
            'subtitle': 'Schedule an appointment for a selected service.',
            'icon': Icons.calendar_month_rounded,
            'screen': const AppointmentBookingScreen(),
          },
          {
            'name': 'Track Applications',
            'subtitle': 'Check the progress of submitted applications.',
            'icon': Icons.assignment_turned_in_rounded,
            'screen': const ApplicationTrackingScreen(),
          },
          {
            'name': 'Drafts',
            'subtitle': 'Continue applications that are not yet submitted.',
            'icon': Icons.edit_document,
            'screen': const ApplicationTrackingScreen(),
          },
        ],
      },
      {
        'title': 'Security & Identity',
        'subtitle': 'Manage your documents, identity and account security.',
        'items': [
          {
            'name': 'Document Wallet',
            'subtitle': 'View and manage your CivicID documents.',
            'icon': Icons.account_balance_wallet_rounded,
            'screen': const DocumentWalletScreen(),
          },
          {
            'name': 'Digital Profile',
            'subtitle': 'Review your personal CivicID profile.',
            'icon': Icons.person_rounded,
            'screen': const ProfileScreen(),
          },
          {
            'name': 'Security Centre',
            'subtitle': 'Manage security, biometrics and password options.',
            'icon': Icons.security_rounded,
            'screen': const SecurityScreen(),
          },
          {
            'name': 'Audit Trail',
            'subtitle': 'Review activity recorded on your account.',
            'icon': Icons.history_rounded,
            'screen': const AuditTrailScreen(),
          },
        ],
      },
      {
        'title': 'Communications',
        'subtitle': 'Stay updated and access support.',
        'items': [
          {
            'name': 'Notifications',
            'subtitle': 'View important CivicID updates and alerts.',
            'icon': Icons.notifications_rounded,
            'screen': const NotificationsScreen(),
          },
          {
            'name': 'Support Centre',
            'subtitle': 'Get help and view support information.',
            'icon': Icons.help_center_rounded,
            'screen': const HelpSupportScreen(),
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: pageBackground,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Services & Actions',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Quick access to CivicID features',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),

        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: borderColor,
          ),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          int crossAxisCount = 2;

          if (width >= 1000) {
            crossAxisCount = 4;
          } else if (width >= 700) {
            crossAxisCount = 3;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              24,
              20,
              40,
            ),
            children: [
              Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 1100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),

                      const SizedBox(height: 28),

                      ...categories.map(
                            (category) {
                          final items =
                          category['items']
                          as List<Map<String, dynamic>>;

                          return Padding(
                            padding:
                            const EdgeInsets.only(
                              bottom: 30,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  title:
                                  category['title']
                                  as String,
                                  subtitle:
                                  category['subtitle']
                                  as String,
                                ),

                                const SizedBox(height: 16),

                                GridView.builder(
                                  shrinkWrap: true,
                                  physics:
                                  const NeverScrollableScrollPhysics(),
                                  itemCount:
                                  items.length,

                                  gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                    crossAxisCount,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio:
                                    width < 500
                                        ? 1.35
                                        : 1.55,
                                  ),

                                  itemBuilder:
                                      (
                                      context,
                                      index,
                                      ) {
                                    final item =
                                    items[index];

                                    return _buildActionCard(
                                      context,
                                      name:
                                      item['name'],
                                      subtitle:
                                      item['subtitle'],
                                      icon:
                                      item['icon'],
                                      screen:
                                      item['screen'],
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER CARD
  // ============================================================

  Widget _buildHeaderCard() {
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

        borderRadius: BorderRadius.circular(
          22,
        ),
      ),

      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final isSmall =
              constraints.maxWidth < 550;

          final textContent = Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'CivicID Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Access applications, identity tools, security options and support from one place.',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.85,
                  ),
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          );

          if (isSmall) {
            return textContent;
          }

          return Row(
            children: [
              Expanded(
                child: textContent,
              ),

              const SizedBox(width: 20),

              Container(
                width: 82,
                height: 82,

                decoration: BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ],
          );
        },
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
          title.toUpperCase(),
          style: const TextStyle(
            color: civicGreen,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(
            color: textGrey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _buildActionCard(
      BuildContext context, {
        required String name,
        required String subtitle,
        required IconData icon,
        required Widget screen,
      }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        18,
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(
          18,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          );
        },

        child: Container(
          padding: const EdgeInsets.all(
            16,
          ),

          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              18,
            ),

            border: Border.all(
              color: borderColor,
            ),

            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withValues(
                  alpha: 0.03,
                ),
                blurRadius: 10,
                offset: const Offset(
                  0,
                  3,
                ),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),

                child: Icon(
                  icon,
                  color: civicGreen,
                  size: 23,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                name,

                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,

                style: const TextStyle(
                  color: darkText,
                  fontWeight:
                  FontWeight.w800,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,

                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,

                style: const TextStyle(
                  color: textGrey,
                  fontSize: 9,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}