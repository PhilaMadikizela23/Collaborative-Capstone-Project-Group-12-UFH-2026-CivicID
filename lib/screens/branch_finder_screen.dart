import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BranchFinderScreen extends StatefulWidget {
  const BranchFinderScreen({super.key});

  @override
  State<BranchFinderScreen> createState() =>
      _BranchFinderScreenState();
}

class _BranchFinderScreenState extends State<BranchFinderScreen> {
  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);

  final TextEditingController _searchController =
  TextEditingController();

  String _selectedProvince = 'All';

  final List<String> _provinces = const [
    'All',
    'Eastern Cape',
    'Gauteng',
    'KwaZulu-Natal',
    'Western Cape',
  ];

  final List<BranchInfo> _branches = const [
    BranchInfo(
      name: 'Alice Service Centre',
      town: 'Alice',
      province: 'Eastern Cape',
      address: 'Alice, Eastern Cape',
      hours: 'Mon - Fri • 08:00 - 16:00',
      distance: 'Prototype location',
    ),
    BranchInfo(
      name: 'East London Service Centre',
      town: 'East London',
      province: 'Eastern Cape',
      address: 'East London, Eastern Cape',
      hours: 'Mon - Fri • 08:00 - 16:00',
      distance: 'Prototype location',
    ),
    BranchInfo(
      name: 'Mthatha Service Centre',
      town: 'Mthatha',
      province: 'Eastern Cape',
      address: 'Mthatha, Eastern Cape',
      hours: 'Mon - Fri • 08:00 - 16:00',
      distance: 'Prototype location',
    ),
    BranchInfo(
      name: 'Johannesburg Service Centre',
      town: 'Johannesburg',
      province: 'Gauteng',
      address: 'Johannesburg, Gauteng',
      hours: 'Mon - Fri • 08:00 - 16:00',
      distance: 'Prototype location',
    ),
    BranchInfo(
      name: 'Durban Service Centre',
      town: 'Durban',
      province: 'KwaZulu-Natal',
      address: 'Durban, KwaZulu-Natal',
      hours: 'Mon - Fri • 08:00 - 16:00',
      distance: 'Prototype location',
    ),
    BranchInfo(
      name: 'Cape Town Service Centre',
      town: 'Cape Town',
      province: 'Western Cape',
      address: 'Cape Town, Western Cape',
      hours: 'Mon - Fri • 08:00 - 16:00',
      distance: 'Prototype location',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BranchInfo> get _filteredBranches {
    final search =
    _searchController.text.trim().toLowerCase();

    return _branches.where((branch) {
      final matchesProvince =
          _selectedProvince == 'All' ||
              branch.province == _selectedProvince;

      final matchesSearch =
          search.isEmpty ||
              branch.name.toLowerCase().contains(search) ||
              branch.town.toLowerCase().contains(search) ||
              branch.province.toLowerCase().contains(search);

      return matchesProvince && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final branches = _filteredBranches;

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find a Branch',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Search prototype service locations',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 850,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                40,
              ),
              children: [
                _buildHeader(),

                const SizedBox(height: 20),

                _buildSearch(),

                const SizedBox(height: 15),

                _buildProvinceSelector(),

                const SizedBox(height: 24),

                Text(
                  '${branches.length} Branch${branches.length == 1 ? '' : 'es'}',
                  style: const TextStyle(
                    color: Color(0xFF14251C),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                if (branches.isEmpty)
                  _buildEmptyState()
                else
                  ...branches.map(
                        (branch) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 11,
                      ),
                      child: _buildBranchCard(branch),
                    ),
                  ),

                const SizedBox(height: 15),

                _buildPrototypeNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            darkGreen,
            civicGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Find a Service Branch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Search by town or province and choose a branch for your appointment.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: 'Search town or branch...',
        hintStyle: const TextStyle(
          color: textGrey,
          fontSize: 11,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: civicGreen,
        ),
        suffixIcon:
        _searchController.text.isNotEmpty
            ? IconButton(
          onPressed: () {
            _searchController.clear();

            setState(() {});
          },
          icon: const Icon(
            Icons.close_rounded,
          ),
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: civicGreen,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildProvinceSelector() {
    return SizedBox(
      height: 39,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _provinces.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final province = _provinces[index];

          final selected =
              province == _selectedProvince;

          return ChoiceChip(
            label: Text(province),
            selected: selected,
            showCheckmark: false,
            selectedColor: lightGreen,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? civicGreen
                  : borderColor,
            ),
            labelStyle: TextStyle(
              color: selected
                  ? civicGreen
                  : textGrey,
              fontSize: 10,
              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
            onSelected: (_) {
              setState(() {
                _selectedProvince =
                    province;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildBranchCard(
      BranchInfo branch,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  color: civicGreen,
                  size: 25,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: const TextStyle(
                        color: darkGreen,
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: textGrey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            branch.address,
                            style:
                            const TextStyle(
                              color: textGrey,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: textGrey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          branch.hours,
                          style:
                          const TextStyle(
                            color: textGrey,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 42,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BranchAppointmentScreen(
                          branch: branch,
                        ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: civicGreen,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 18,
              ),
              label: const Text(
                'SELECT BRANCH & BOOK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            color: civicGreen,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'No branches found',
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try another town or province.',
            style: TextStyle(
              color: textGrey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrototypeNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Academic Prototype — Branch names and locations shown here are demonstration data and must not be treated as an official branch directory.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textGrey,
          fontSize: 9,
          height: 1.5,
        ),
      ),
    );
  }
}

// ============================================================
// BRANCH MODEL
// ============================================================

class BranchInfo {
  final String name;
  final String town;
  final String province;
  final String address;
  final String hours;
  final String distance;

  const BranchInfo({
    required this.name,
    required this.town,
    required this.province,
    required this.address,
    required this.hours,
    required this.distance,
  });
}

// ============================================================
// APPOINTMENT SCREEN
// ============================================================

class BranchAppointmentScreen extends StatefulWidget {
  final BranchInfo branch;

  const BranchAppointmentScreen({
    super.key,
    required this.branch,
  });

  @override
  State<BranchAppointmentScreen> createState() =>
      _BranchAppointmentScreenState();
}

class _BranchAppointmentScreenState
    extends State<BranchAppointmentScreen> {
  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);

  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _times = const [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
  ];

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selected =
    await showDatePicker(
      context: context,
      initialDate:
      now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate:
      now.add(const Duration(days: 90)),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedDate = selected;
    });
  }

  void _confirmBooking() {
    if (_selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a date and time.',
          ),
        ),
      );

      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(22),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration:
                const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: civicGreen,
                  size: 45,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Appointment Confirmed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your prototype appointment has been booked.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textGrey,
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 20),

              _confirmationRow(
                'Branch',
                widget.branch.name,
              ),

              _confirmationRow(
                'Date',
                DateFormat(
                  'dd MMM yyyy',
                ).format(
                  _selectedDate!,
                ),
              ),

              _confirmationRow(
                'Time',
                _selectedTime!,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style:
                  FilledButton.styleFrom(
                    backgroundColor:
                    civicGreen,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );

                    Navigator.pop(
                      context,
                    );
                  },
                  child: const Text(
                    'DONE',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _confirmationRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 65,
            child: Text(
              label,
              style: const TextStyle(
                color: textGrey,
                fontSize: 9,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          40,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildBranchSummary(),

                const SizedBox(height: 25),

                const Text(
                  'Select Date',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                InkWell(
                  borderRadius:
                  BorderRadius.circular(15),
                  onTap: _selectDate,
                  child: Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(15),
                      border: Border.all(
                        color: borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .calendar_month_outlined,
                          color: civicGreen,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'Choose appointment date'
                                : DateFormat(
                              'EEEE, dd MMMM yyyy',
                            ).format(
                              _selectedDate!,
                            ),
                            style: TextStyle(
                              color:
                              _selectedDate ==
                                  null
                                  ? textGrey
                                  : darkGreen,
                              fontWeight:
                              FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons
                              .chevron_right_rounded,
                          color: textGrey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Select Time',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _times.map(
                        (time) {
                      final selected =
                          time == _selectedTime;

                      return ChoiceChip(
                        label: Text(time),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor:
                        civicGreen,
                        backgroundColor:
                        Colors.white,
                        side: BorderSide(
                          color: selected
                              ? civicGreen
                              : borderColor,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : darkGreen,
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w800,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedTime =
                                time;
                          });
                        },
                      );
                    },
                  ).toList(),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _confirmBooking,
                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      civicGreen,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          13,
                        ),
                      ),
                    ),
                    child: const Text(
                      'CONFIRM APPOINTMENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Academic Prototype — This appointment is a demonstration booking and is not sent to a government office.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 9,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFCFE5D7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: civicGreen,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Branch',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 9,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.branch.name,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.branch.address,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}