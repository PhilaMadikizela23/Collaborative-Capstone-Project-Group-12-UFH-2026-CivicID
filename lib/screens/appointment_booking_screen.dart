import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/appointment_slot.dart';
import '../services/appointment_service.dart';
import '../services/appointment_slot_service.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String? initialLocation;
  final String? initialService;

  const AppointmentBookingScreen({
    super.key,
    this.initialLocation,
    this.initialService,
  });

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState
    extends State<AppointmentBookingScreen> {
  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color darkText = Color(0xFF1F2933);
  static const Color textGrey = Color(0xFF66756E);

  final AppointmentService _appointmentService =
  AppointmentService();

  final AppointmentSlotService _slotService =
  AppointmentSlotService();

  DateTime _selectedDate =
  DateTime.now().add(
    const Duration(days: 1),
  );

  String _selectedService =
      'Smart ID Application';

  String _selectedLocation =
      'Alice Service Centre';

  AppointmentSlot? _selectedSlot;

  List<AppointmentSlot> _availableSlots = [];

  bool _loadingSlots = false;
  bool _isBooking = false;

  final List<String> _services = [
    'Smart ID Application',
    'Passport',
    'Driver\'s Licence',
    'Birth Certificate',
  ];

  final List<String> _locations = [
    'Alice Service Centre',
    'East London Service Centre',
    'Mthatha Service Centre',
    'Johannesburg Service Centre',
    'Durban Service Centre',
    'Cape Town Service Centre',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialService != null &&
        widget.initialService!
            .trim()
            .isNotEmpty) {
      final service =
      widget.initialService!.trim();

      if (!_services.contains(service)) {
        _services.add(service);
      }

      _selectedService = service;
    }

    if (widget.initialLocation != null &&
        widget.initialLocation!
            .trim()
            .isNotEmpty) {
      final location =
      widget.initialLocation!.trim();

      if (!_locations.contains(location)) {
        _locations.add(location);
      }

      _selectedLocation = location;
    }

    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    setState(() {
      _loadingSlots = true;
      _selectedSlot = null;
    });

    final slots =
    await _slotService
        .getAvailableSlots(
      branch: _selectedLocation,
      date: _selectedDate,
    );

    if (!mounted) return;

    setState(() {
      _availableSlots = slots;
      _loadingSlots = false;
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
        const Duration(days: 90),
      ),
      helpText:
      'SELECT APPOINTMENT DATE',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
      builder: (
          context,
          child,
          ) {
        return Theme(
          data:
          Theme.of(context).copyWith(
            colorScheme:
            const ColorScheme.light(
              primary: civicGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
    });

    await _loadAvailableSlots();
  }

  Future<void> _book() async {
    if (_isBooking) {
      return;
    }

    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Please select an available appointment time.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isBooking = true;
    });

    final AppointmentSlot selectedSlot =
    _selectedSlot!;

    bool slotReserved = false;

    try {
      final bool booked =
      await _slotService.bookSlot(
        selectedSlot.id,
      );

      if (!booked) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
            content: Text(
              'That time is no longer available. Please choose another slot.',
            ),
          ),
        );

        await _loadAvailableSlots();
        return;
      }

      slotReserved = true;

      await _appointmentService.bookAppointment(
        _selectedService,
        selectedSlot.dateTime,
        _selectedLocation,
      );

      if (!mounted) return;

      await _showConfirmation();

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (_) {
      if (slotReserved) {
        await _slotService.cancelBooking(
          selectedSlot.id,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Unable to book appointment. Please try again.',
          ),
        ),
      );

      await _loadAvailableSlots();
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  Future<void> _showConfirmation() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(22),
          ),
          content: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration:
                const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .event_available_rounded,
                  color: civicGreen,
                  size: 40,
                ),
              ),

              const SizedBox(height: 17),

              const Text(
                'Appointment Confirmed!',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(height: 18),

              _confirmationRow(
                'Service',
                _selectedService,
              ),

              _confirmationRow(
                'Branch',
                _selectedLocation,
              ),

              _confirmationRow(
                'Date',
                DateFormat(
                  'dd MMM yyyy',
                ).format(
                  _selectedSlot!.dateTime,
                ),
              ),

              _confirmationRow(
                'Time',
                DateFormat(
                  'HH:mm',
                ).format(
                  _selectedSlot!.dateTime,
                ),
              ),

              const SizedBox(height: 18),

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
              'Book Appointment',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight:
                FontWeight.w900,
              ),
            ),
            Text(
              'Select an available time slot',
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
        const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          40,
        ),
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
                _buildHeader(),

                const SizedBox(height: 22),

                _buildBookingForm(),

                const SizedBox(height: 22),

                SizedBox(
                  width:
                  double.infinity,
                  height: 50,
                  child:
                  FilledButton.icon(
                    onPressed:
                    _isBooking ||
                        _selectedSlot ==
                            null
                        ? null
                        : _book,
                    style:
                    FilledButton
                        .styleFrom(
                      backgroundColor:
                      civicGreen,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                      ),
                    ),
                    icon: _isBooking
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                        Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons
                          .event_available_rounded,
                    ),
                    label: Text(
                      _isBooking
                          ? 'BOOKING...'
                          : 'CONFIRM APPOINTMENT',
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                _prototypeNotice(),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
        const LinearGradient(
          colors: [
            darkGreen,
            civicGreen,
          ],
        ),
        borderRadius:
        BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(
            Icons
                .calendar_month_rounded,
            color: Colors.white,
            size: 38,
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Available Time',
                  style: TextStyle(
                    color:
                    Colors.white,
                    fontSize: 19,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Only times opened by an administrator are shown. Office hours are 08:00 to 17:00.',
                  style: TextStyle(
                    color:
                    Colors.white70,
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

  Widget _buildBookingForm() {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _fieldLabel(
            'Service',
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<
              String>(
            value: _selectedService,
            isExpanded: true,
            items: _services.map(
                  (service) {
                return DropdownMenuItem(
                  value: service,
                  child: Text(service),
                );
              },
            ).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedService =
                    value;
              });
            },
          ),

          const SizedBox(height: 20),

          _fieldLabel(
            'Branch',
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<
              String>(
            value:
            _selectedLocation,
            isExpanded: true,
            items: _locations.map(
                  (location) {
                return DropdownMenuItem(
                  value: location,
                  child:
                  Text(location),
                );
              },
            ).toList(),
            onChanged: (value) async {
              if (value == null) return;

              setState(() {
                _selectedLocation =
                    value;
              });

              await _loadAvailableSlots();
            },
          ),

          const SizedBox(height: 20),

          _fieldLabel(
            'Date',
          ),

          const SizedBox(height: 8),

          InkWell(
            borderRadius:
            BorderRadius.circular(14),
            onTap: _selectDate,
            child: Container(
              padding:
              const EdgeInsets.all(
                15,
              ),
              decoration:
              BoxDecoration(
                color: pageBackground,
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .calendar_today_outlined,
                    color: civicGreen,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      DateFormat(
                        'EEEE, dd MMM yyyy',
                      ).format(
                        _selectedDate,
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

          const SizedBox(height: 24),

          const Text(
            'Available Times',
            style: TextStyle(
              color: darkGreen,
              fontSize: 15,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Booked times are automatically removed.',
            style: TextStyle(
              color: textGrey,
              fontSize: 9,
            ),
          ),

          const SizedBox(height: 13),

          if (_loadingSlots)
            const Center(
              child:
              CircularProgressIndicator(
                color: civicGreen,
              ),
            )
          else if (_availableSlots.isEmpty)
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(
                18,
              ),
              decoration:
              BoxDecoration(
                color: const Color(
                  0xFFFFF8E7,
                ),
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
              child: const Text(
                'No available appointment times for this branch and date. Choose another date or wait for an administrator to open slots.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color:
                  Color(0xFF725500),
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            )
          else
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children:
              _availableSlots.map(
                    (slot) {
                  final selected =
                      _selectedSlot?.id ==
                          slot.id;

                  return ChoiceChip(
                    label: Text(
                      DateFormat(
                        'HH:mm',
                      ).format(
                        slot.dateTime,
                      ),
                    ),
                    selected:
                    selected,
                    showCheckmark:
                    false,
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
                          : darkGreen,
                      fontWeight:
                      FontWeight.w800,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedSlot =
                            slot;
                      });
                    },
                  );
                },
              ).toList(),
            ),
        ],
      ),
    );
  }

  Widget _fieldLabel(
      String value,
      ) {
    return Text(
      value,
      style: const TextStyle(
        color: darkText,
        fontSize: 11,
        fontWeight:
        FontWeight.w700,
      ),
    );
  }

  Widget _prototypeNotice() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
        const Color(0xFFF1F5F2),
        borderRadius:
        BorderRadius.circular(13),
      ),
      child: const Text(
        'Academic Prototype — Appointment slots are demonstration data. No booking is sent to an official government office.',
        textAlign:
        TextAlign.center,
        style: TextStyle(
          color: textGrey,
          fontSize: 9,
        ),
      ),
    );
  }

  static Widget _confirmationRow(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style:
              const TextStyle(
                color: textGrey,
                fontSize: 9,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign:
              TextAlign.right,
              style:
              const TextStyle(
                color: darkGreen,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
