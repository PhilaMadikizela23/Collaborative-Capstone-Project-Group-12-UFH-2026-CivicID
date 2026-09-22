import 'package:flutter/material.dart';

import '../models/government_service.dart';
import '../services/mock_data.dart';

import 'application/application_assistant_screen.dart';
import 'application/application_tracking_screen.dart';
import 'appointment_booking_screen.dart';
import 'settings/help_support_screen.dart';

import 'services/smart_id_overview_screen.dart';
import 'services/passport_overview_screen.dart';
import 'services/drivers_licence_overview_screen.dart';
import 'services/birth_certificate_overview_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);

  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF52635B);
  static const Color darkText = Color(0xFF14251C);

  static const Color passportPurple = Color(0xFF7B2CBF);
  static const Color passportLight = Color(0xFFF2E8FF);

  static const Color licenceBlue = Color(0xFF1976D2);
  static const Color licenceLight = Color(0xFFE7F3FF);

  static const Color birthOrange = Color(0xFFF57C00);
  static const Color birthLight = Color(0xFFFFF0DE);

  final List<GovernmentService> _allServices = MockData().services;

  List<GovernmentService> _filteredServices = [];

  final TextEditingController _searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    _filteredServices =
    List<GovernmentService>.from(_allServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterServices(String value) {
    final search = value.trim().toLowerCase();

    setState(() {
      if (search.isEmpty) {
        _filteredServices =
        List<GovernmentService>.from(_allServices);
        return;
      }

      _filteredServices = _allServices.where((service) {
        return service.name.toLowerCase().contains(search) ||
            service.description.toLowerCase().contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 850,
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      22,
                      20,
                      0,
                    ),
                    child: _buildHeader(),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      0,
                    ),
                    child: _buildSearchBar(),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      24,
                      20,
                      10,
                    ),
                    child: Text(
                      'Available Services',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                if (_filteredServices.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      15,
                    ),
                    sliver: SliverList.separated(
                      itemCount: _filteredServices.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (context, index) {
                        return _buildServiceCard(
                          _filteredServices[index],
                        );
                      },
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      11,
                    ),
                    child: Text(
                      'Other Services',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      25,
                    ),
                    child: _buildOtherServices(),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      35,
                    ),
                    child: _buildPrototypeNotice(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Government Services',
          style: TextStyle(
            color: darkText,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: 6),

        Text(
          'Choose a service to start preparing your application.',
          style: TextStyle(
            color: textGrey,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _filterServices,
      style: const TextStyle(
        fontSize: 14,
        color: darkText,
      ),
      decoration: InputDecoration(
        hintText: 'Search services...',
        hintStyle: const TextStyle(
          color: Color(0xFF8A9690),
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: textGrey,
          size: 21,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          onPressed: () {
            _searchController.clear();
            _filterServices('');
          },
          icon: const Icon(
            Icons.close_rounded,
            color: textGrey,
            size: 19,
          ),
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: civicGreen,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SERVICE CARD
  // ==========================================================

  Widget _buildServiceCard(
      GovernmentService service,
      ) {
    final style = _serviceStyle(service.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _openService(service);
        },
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: style.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: style.mainColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      style.icon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _shortDescription(service),
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8A9690),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // OTHER SERVICES
  // ==========================================================

  Widget _buildOtherServices() {
    return Column(
      children: [
        _otherServiceCard(
          icon: Icons.location_on_outlined,
          title: 'Find a Branch',
          subtitle: 'Locate a nearby service office',
          onTap: _showBranchFinder,
        ),

        const SizedBox(height: 10),

        _otherServiceCard(
          icon: Icons.calendar_month_outlined,
          title: 'Book Appointment',
          subtitle: 'Schedule a prototype appointment',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const AppointmentBookingScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 10),

        _otherServiceCard(
          icon: Icons.track_changes_outlined,
          title: 'Track Application',
          subtitle:
          'Check application progress and updates',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const ApplicationTrackingScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 10),

        _otherServiceCard(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'Get help using CivicID',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const HelpSupportScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _otherServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: civicGreen,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8A9690),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BRANCH FINDER
  // ==========================================================

  void _showBranchFinder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 22),

              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: civicGreen,
                  size: 34,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Find a Branch',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'The branch finder will allow users to search for nearby service offices. This feature is currently part of the CivicID academic prototype.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textGrey,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: civicGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // SERVICE STYLE
  // ==========================================================

  _ServiceStyle _serviceStyle(
      String id,
      ) {
    switch (id) {
      case 'SRV001':
        return const _ServiceStyle(
          icon: Icons.badge_outlined,
          mainColor: civicGreen,
          backgroundColor: lightGreen,
        );

      case 'SRV002':
        return const _ServiceStyle(
          icon: Icons.public_rounded,
          mainColor: passportPurple,
          backgroundColor: passportLight,
        );

      case 'SRV003':
        return const _ServiceStyle(
          icon: Icons.directions_car_outlined,
          mainColor: licenceBlue,
          backgroundColor: licenceLight,
        );

      case 'SRV004':
        return const _ServiceStyle(
          icon: Icons.child_care_outlined,
          mainColor: birthOrange,
          backgroundColor: birthLight,
        );

      default:
        return const _ServiceStyle(
          icon: Icons.description_outlined,
          mainColor: civicGreen,
          backgroundColor: lightGreen,
        );
    }
  }

  // ==========================================================
  // SHORT DESCRIPTION
  // ==========================================================

  String _shortDescription(
      GovernmentService service,
      ) {
    switch (service.id) {
      case 'SRV001':
        return 'Apply for or manage your Smart ID';

      case 'SRV002':
        return 'Apply for a passport service';

      case 'SRV003':
        return "Prepare your driver's licence service";

      case 'SRV004':
        return 'Prepare a birth certificate service';

      default:
        return service.description;
    }
  }

  // ==========================================================
  // OPEN SERVICE
  // ==========================================================

  void _openService(
      GovernmentService service,
      ) {
    Widget screen;

    switch (service.id) {
      case 'SRV001':
        screen = SmartIdOverviewScreen(
          service: service,
        );
        break;

      case 'SRV002':
        screen = PassportOverviewScreen(
          service: service,
        );
        break;

      case 'SRV003':
        screen = DriversLicenceOverviewScreen(
          service: service,
        );
        break;

      case 'SRV004':
        screen = BirthCertificateOverviewScreen(
          service: service,
        );
        break;

      default:
        screen = ApplicationAssistantScreen(
          service: service,
        );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(35),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: civicGreen,
              size: 34,
            ),
          ),

          const SizedBox(height: 17),

          const Text(
            'No services found',
            style: TextStyle(
              color: darkGreen,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Try a different search.',
            style: TextStyle(
              color: textGrey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PROTOTYPE NOTICE
  // ==========================================================

  Widget _buildPrototypeNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            color: textGrey,
            size: 17,
          ),

          SizedBox(width: 7),

          Flexible(
            child: Text(
              'Academic Prototype — CivicID is not an official government service.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textGrey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceStyle {
  final IconData icon;
  final Color mainColor;
  final Color backgroundColor;

  const _ServiceStyle({
    required this.icon,
    required this.mainColor,
    required this.backgroundColor,
  });
}