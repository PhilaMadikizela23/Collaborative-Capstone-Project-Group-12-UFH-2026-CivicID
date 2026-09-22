import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/appointment_slot.dart';
import '../../services/appointment_slot_service.dart';

class AdminAppointmentSlotsScreen
    extends StatefulWidget {
  const AdminAppointmentSlotsScreen({
    super.key,
  });

  @override
  State<AdminAppointmentSlotsScreen>
  createState() =>
      _AdminAppointmentSlotsScreenState();
}

class _AdminAppointmentSlotsScreenState
    extends State<AdminAppointmentSlotsScreen> {
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

  final AppointmentSlotService _slotService =
  AppointmentSlotService();

  String _selectedBranch =
      'Alice Service Centre';

  DateTime _selectedDate =
  DateTime.now().add(
    const Duration(days: 1),
  );

  List<AppointmentSlot> _slots = [];

  final List<String> _branches = [
    'Alice Service Centre',
    'East London Service Centre',
    'Mthatha Service Centre',
    'Johannesburg Service Centre',
    'Durban Service Centre',
    'Cape Town Service Centre',
  ];

  // Every 30 minutes from 08:00 until 17:00.
  final List<TimeOfDay> _times = [
    for (int hour = 8;
    hour <= 17;
    hour++)
      ...[
        TimeOfDay(
          hour: hour,
          minute: 0,
        ),
        if (hour < 17)
          TimeOfDay(
            hour: hour,
            minute: 30,
          ),
      ],
  ];

  @override
  void initState() {
    super.initState();

    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final slots =
    await _slotService.getAllSlots();

    if (!mounted) return;

    setState(() {
      _slots = slots;
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked =
    await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: now.add(
        const Duration(days: 180),
      ),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
    });
  }

  AppointmentSlot? _findSlot(
      TimeOfDay time,
      ) {
    for (final slot in _slots) {
      if (slot.branch ==
          _selectedBranch &&
          slot.dateTime.year ==
              _selectedDate.year &&
          slot.dateTime.month ==
              _selectedDate.month &&
          slot.dateTime.day ==
              _selectedDate.day &&
          slot.dateTime.hour ==
              time.hour &&
          slot.dateTime.minute ==
              time.minute) {
        return slot;
      }
    }

    return null;
  }

  Future<void> _toggleSlot(
      TimeOfDay time,
      ) async {
    final existing =
    _findSlot(time);

    if (existing != null) {
      if (existing.isBooked) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'This time is already booked and cannot be removed.',
            ),
          ),
        );
        return;
      }

      await _slotService.removeSlot(
        existing.id,
      );
    } else {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        time.hour,
        time.minute,
      );

      await _slotService
          .addAvailableSlot(
        branch: _selectedBranch,
        dateTime: dateTime,
      );
    }

    await _loadSlots();
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
        title: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Appointment Availability',
              style: TextStyle(
                color: darkGreen,
                fontWeight:
                FontWeight.w900,
              ),
            ),
            Text(
              'Open time slots for citizens',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints:
            const BoxConstraints(
              maxWidth: 800,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),
                  decoration:
                  BoxDecoration(
                    color: lightGreen,
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: const Text(
                    'Select the branch, date and times that citizens may book. Opening hours: 08:00–17:00.',
                    style: TextStyle(
                      color: darkGreen,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Branch',
                  style: TextStyle(
                    color: darkGreen,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<
                    String>(
                  value:
                  _selectedBranch,
                  isExpanded: true,
                  items:
                  _branches.map(
                        (branch) {
                      return DropdownMenuItem(
                        value: branch,
                        child:
                        Text(branch),
                      );
                    },
                  ).toList(),
                  onChanged:
                      (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedBranch =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Date',
                  style: TextStyle(
                    color: darkGreen,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    width:
                    double.infinity,
                    padding:
                    const EdgeInsets.all(
                      15,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                      border:
                      Border.all(
                        color:
                        borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .calendar_month_outlined,
                          color:
                          civicGreen,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Text(
                          DateFormat(
                            'EEEE, dd MMM yyyy',
                          ).format(
                            _selectedDate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Time Slots',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Tap a time to make it available. Green = available, grey = closed, red = already booked.',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 15),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _times.map(
                        (time) {
                      final slot =
                      _findSlot(
                        time,
                      );

                      final booked =
                          slot?.isBooked ??
                              false;

                      final available =
                          slot != null &&
                              !booked;

                      Color background =
                          Colors.white;

                      Color foreground =
                          textGrey;

                      if (booked) {
                        background =
                        const Color(
                          0xFFFFEAEA,
                        );

                        foreground =
                            Colors.red;
                      } else if (available) {
                        background =
                            lightGreen;

                        foreground =
                            civicGreen;
                      }

                      return InkWell(
                        borderRadius:
                        BorderRadius.circular(
                          13,
                        ),
                        onTap: () =>
                            _toggleSlot(
                              time,
                            ),
                        child: Container(
                          width: 95,
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            background,
                            borderRadius:
                            BorderRadius.circular(
                              13,
                            ),
                            border:
                            Border.all(
                              color: booked
                                  ? Colors.red
                                  .withValues(
                                alpha:
                                0.3,
                              )
                                  : available
                                  ? civicGreen
                                  : borderColor,
                            ),
                          ),
                          alignment:
                          Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                style:
                                TextStyle(
                                  color:
                                  foreground,
                                  fontWeight:
                                  FontWeight.w800,
                                ),
                              ),

                              const SizedBox(
                                height: 3,
                              ),

                              Text(
                                booked
                                    ? 'Booked'
                                    : available
                                    ? 'Available'
                                    : 'Closed',
                                style:
                                TextStyle(
                                  color:
                                  foreground,
                                  fontSize:
                                  8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
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
                      13,
                    ),
                  ),
                  child: const Text(
                    'Academic Prototype — Availability is stored in mock data for testing. Firebase can later store the slots for multiple real devices/users.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}