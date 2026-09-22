import 'package:flutter/material.dart';
import '../../services/mock_data.dart';
import 'package:intl/intl.dart';

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  // CivicID colours
  static const Color primaryGreen = Color(0xFF1F7A3D);
  static const Color darkGreen = Color(0xFF145A2A);
  static const Color lightGreen = Color(0xFFEAF6EC);
  static const Color pageBackground = Color(0xFFF5F7F6);
  static const Color darkText = Color(0xFF1F2933);

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _newestFirst = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getEventIcon(String eventType) {
    final type = eventType.toLowerCase();

    if (type.contains('login')) {
      return Icons.login_rounded;
    }

    if (type.contains('document')) {
      return Icons.description_outlined;
    }

    if (type.contains('profile')) {
      return Icons.person_outline_rounded;
    }

    if (type.contains('application')) {
      return Icons.assignment_outlined;
    }

    if (type.contains('approve')) {
      return Icons.check_circle_outline_rounded;
    }

    if (type.contains('reject')) {
      return Icons.cancel_outlined;
    }

    if (type.contains('verify')) {
      return Icons.verified_outlined;
    }

    return Icons.history_rounded;
  }

  Color _getEventColor(String eventType) {
    final type = eventType.toLowerCase();

    if (type.contains('reject') || type.contains('failed')) {
      return const Color(0xFFC62828);
    }

    if (type.contains('approve') ||
        type.contains('verify') ||
        type.contains('successful')) {
      return primaryGreen;
    }

    if (type.contains('review') || type.contains('pending')) {
      return const Color(0xFFE68A00);
    }

    if (type.contains('document')) {
      return const Color(0xFF6A1B9A);
    }

    if (type.contains('profile')) {
      return const Color(0xFF0277BD);
    }

    return primaryGreen;
  }

  String _getCategory(String eventType) {
    final type = eventType.toLowerCase();

    if (type.contains('login')) {
      return 'Login';
    }

    if (type.contains('document')) {
      return 'Documents';
    }

    if (type.contains('profile')) {
      return 'Profile';
    }

    if (type.contains('application') ||
        type.contains('approve') ||
        type.contains('reject') ||
        type.contains('review')) {
      return 'Applications';
    }

    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    final mockData = MockData();

    final allLogs = [...mockData.auditEvents];

    // Find categories currently available in the mock data.
    final categories = allLogs
        .map((log) => _getCategory(log.eventType))
        .toSet()
        .toList();

    categories.sort();

    final filterOptions = ['All', ...categories];

    // Filter logs.
    var filteredLogs = allLogs.where((log) {
      final searchText =
      '${log.eventType} ${log.description}'.toLowerCase();

      final matchesSearch =
      searchText.contains(_searchQuery.toLowerCase());

      final matchesFilter =
          _selectedFilter == 'All' ||
              _getCategory(log.eventType) == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    // Sort logs.
    filteredLogs.sort((a, b) {
      if (_newestFirst) {
        return b.timestamp.compareTo(a.timestamp);
      } else {
        return a.timestamp.compareTo(b.timestamp);
      }
    });

    return Scaffold(
      backgroundColor: pageBackground,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        titleSpacing: 24,

        title: const Text(
          'System Audit Logs',
          style: TextStyle(
            color: darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        iconTheme: const IconThemeData(
          color: primaryGreen,
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),

          const SizedBox(width: 8),
        ],

        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1200,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 32 : 16,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --------------------------------------------------
                      // PAGE HEADER
                      // --------------------------------------------------
                      _buildHeader(filteredLogs.length),

                      const SizedBox(height: 24),

                      // --------------------------------------------------
                      // SEARCH + FILTERS
                      // --------------------------------------------------
                      _buildControls(
                        filterOptions,
                        isWide,
                      ),

                      const SizedBox(height: 24),

                      // --------------------------------------------------
                      // LOG CARD
                      // --------------------------------------------------
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE4E7E5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.04,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: filteredLogs.isEmpty
                            ? _buildEmptyState()
                            : Column(
                          children: [
                            // Card heading
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: lightGreen,
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.history_rounded,
                                      color: primaryGreen,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Activity History',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight:
                                            FontWeight.w700,
                                            color: darkText,
                                          ),
                                        ),

                                        SizedBox(height: 3),

                                        Text(
                                          'Review recorded system and user activities.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(
                                              0xFF6B7280,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: lightGreen,
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${filteredLogs.length} logs',
                                      style: const TextStyle(
                                        color: darkGreen,
                                        fontWeight:
                                        FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Divider(
                              height: 1,
                              color: Color(0xFFE5E7EB),
                            ),

                            // Actual logs
                            ListView.separated(
                              shrinkWrap: true,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              itemCount: filteredLogs.length,

                              separatorBuilder:
                                  (context, index) =>
                              const Divider(
                                height: 1,
                                indent: 20,
                                endIndent: 20,
                                color: Color(
                                  0xFFEEEEEE,
                                ),
                              ),

                              itemBuilder: (context, index) {
                                final log =
                                filteredLogs[index];

                                return _buildLogItem(
                                  log.timestamp,
                                  log.eventType,
                                  log.description,
                                  isWide,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(int resultCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primaryGreen,
            darkGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              SizedBox(width: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Audit Logs',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Monitor important system activities.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white24,
              ),
            ),
            child: Text(
              '$resultCount records',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH + FILTERS
  // ============================================================

  Widget _buildControls(
      List<String> filterOptions,
      bool isWide,
      ) {
    final search = TextField(
      controller: _searchController,

      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim();
        });
      },

      decoration: InputDecoration(
        hintText: 'Search audit logs...',

        prefixIcon: const Icon(
          Icons.search_rounded,
          color: primaryGreen,
        ),

        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
          onPressed: () {
            _searchController.clear();

            setState(() {
              _searchQuery = '';
            });
          },
          icon: const Icon(
            Icons.close_rounded,
          ),
        )
            : null,

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFDCE1DD),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFDCE1DD),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: primaryGreen,
            width: 1.5,
          ),
        ),
      ),
    );

    final filter = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFDCE1DD),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filterOptions.contains(_selectedFilter)
              ? _selectedFilter
              : 'All',

          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: primaryGreen,
          ),

          items: filterOptions.map((filter) {
            return DropdownMenuItem(
              value: filter,
              child: Text(filter),
            );
          }).toList(),

          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedFilter = value;
            });
          },
        ),
      ),
    );

    final sortButton = OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _newestFirst = !_newestFirst;
        });
      },

      icon: Icon(
        _newestFirst
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded,
        size: 18,
      ),

      label: Text(
        _newestFirst
            ? 'Newest first'
            : 'Oldest first',
      ),

      style: OutlinedButton.styleFrom(
        foregroundColor: darkGreen,

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        side: const BorderSide(
          color: Color(0xFFDCE1DD),
        ),

        backgroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(
            child: search,
          ),

          const SizedBox(width: 12),

          filter,

          const SizedBox(width: 12),

          sortButton,
        ],
      );
    }

    return Column(
      children: [
        search,

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: filter,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: sortButton,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // LOG ITEM
  // ============================================================

  Widget _buildLogItem(
      DateTime timestamp,
      String eventType,
      String description,
      bool isWide,
      ) {
    final eventColor =
    _getEventColor(eventType);

    final eventIcon =
    _getEventIcon(eventType);

    final date =
    DateFormat('dd MMM yyyy').format(timestamp);

    final time =
    DateFormat('HH:mm').format(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      child: isWide
          ? Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildDateSection(
            date,
            time,
          ),

          const SizedBox(width: 20),

          _buildIcon(
            eventIcon,
            eventColor,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: _buildLogDetails(
              eventType,
              description,
              eventColor,
            ),
          ),
        ],
      )
          : Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildIcon(
            eventIcon,
            eventColor,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildLogDetails(
                  eventType,
                  description,
                  eventColor,
                ),

                const SizedBox(height: 10),

                Text(
                  '$date • $time',
                  style: const TextStyle(
                    color: Color(
                      0xFF8A9299,
                    ),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(
      String date,
      String time,
      ) {
    return SizedBox(
      width: 105,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: darkText,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF8A9299),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(
      IconData icon,
      Color color,
      ) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 21,
      ),
    );
  }

  Widget _buildLogDetails(
      String eventType,
      String description,
      Color color,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment:
          WrapCrossAlignment.center,
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Text(
                eventType.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            Text(
              _getCategory(eventType),
              style: const TextStyle(
                color: Color(0xFF8A9299),
                fontSize: 11,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          description,
          style: const TextStyle(
            color: darkText,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 70,
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: primaryGreen,
                size: 34,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No audit logs found',
              style: TextStyle(
                color: darkText,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Try changing your search or filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7C848C),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}