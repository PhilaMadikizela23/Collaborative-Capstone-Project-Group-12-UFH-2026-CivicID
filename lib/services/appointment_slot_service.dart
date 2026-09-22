import '../models/appointment_slot.dart';

class AppointmentSlotService {
  static final List<AppointmentSlot> _slots = [];

  // ============================================================
  // GET ALL SLOTS
  // ============================================================

  Future<List<AppointmentSlot>> getAllSlots() async {
    await Future.delayed(
      const Duration(
        milliseconds: 150,
      ),
    );

    final List<AppointmentSlot> slots =
    List<AppointmentSlot>.from(
      _slots,
    );

    slots.sort(
          (a, b) =>
          a.dateTime.compareTo(
            b.dateTime,
          ),
    );

    return slots;
  }

  // ============================================================
  // AVAILABLE SLOTS
  // ============================================================

  Future<List<AppointmentSlot>> getAvailableSlots({
    required String branch,
    required DateTime date,
  }) async {
    await Future.delayed(
      const Duration(
        milliseconds: 150,
      ),
    );

    final DateTime now =
    DateTime.now();

    final List<AppointmentSlot> slots =
    _slots.where(
          (slot) {
        final bool sameBranch =
            slot.branch ==
                branch;

        final bool sameDate =
            slot.dateTime.year ==
                date.year &&
                slot.dateTime.month ==
                    date.month &&
                slot.dateTime.day ==
                    date.day;

        final bool future =
        slot.dateTime.isAfter(
          now,
        );

        return sameBranch &&
            sameDate &&
            future &&
            !slot.isBooked;
      },
    ).toList();

    slots.sort(
          (a, b) =>
          a.dateTime.compareTo(
            b.dateTime,
          ),
    );

    return slots;
  }

  // ============================================================
  // ADD AVAILABLE SLOT
  // ============================================================

  Future<bool> addAvailableSlot({
    required String branch,
    required DateTime dateTime,
  }) async {
    await Future.delayed(
      const Duration(
        milliseconds: 150,
      ),
    );

    final DateTime now =
    DateTime.now();

    if (!dateTime.isAfter(now)) {
      return false;
    }

    // Opening hours:
    // 08:00 - 17:00
    if (dateTime.hour < 8 ||
        dateTime.hour > 17 ||
        (dateTime.hour == 17 &&
            dateTime.minute > 0)) {
      return false;
    }

    // Only 00 or 30 minute slots.
    if (dateTime.minute != 0 &&
        dateTime.minute != 30) {
      return false;
    }

    final bool alreadyExists =
    _slots.any(
          (slot) =>
      slot.branch ==
          branch &&
          slot.dateTime.year ==
              dateTime.year &&
          slot.dateTime.month ==
              dateTime.month &&
          slot.dateTime.day ==
              dateTime.day &&
          slot.dateTime.hour ==
              dateTime.hour &&
          slot.dateTime.minute ==
              dateTime.minute,
    );

    if (alreadyExists) {
      return false;
    }

    final AppointmentSlot newSlot =
    AppointmentSlot(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),

      branch:
      branch,

      dateTime:
      dateTime,

      isBooked:
      false,
    );

    _slots.add(
      newSlot,
    );

    return true;
  }

  // ============================================================
  // BOOK SLOT
  // ============================================================

  Future<bool> bookSlot(
      String slotId,
      ) async {
    await Future.delayed(
      const Duration(
        milliseconds: 150,
      ),
    );

    final int index =
    _slots.indexWhere(
          (slot) =>
      slot.id ==
          slotId,
    );

    if (index == -1) {
      return false;
    }

    final AppointmentSlot slot =
    _slots[index];

    if (slot.isBooked) {
      return false;
    }

    if (!slot.dateTime.isAfter(
      DateTime.now(),
    )) {
      return false;
    }

    _slots[index] =
        slot.copyWith(
          isBooked:
          true,
        );

    return true;
  }

  // ============================================================
  // CANCEL BOOKING
  // ============================================================

  Future<bool> cancelBooking(
      String slotId,
      ) async {
    await Future.delayed(
      const Duration(
        milliseconds: 150,
      ),
    );

    final int index =
    _slots.indexWhere(
          (slot) =>
      slot.id ==
          slotId,
    );

    if (index == -1) {
      return false;
    }

    if (!_slots[index].isBooked) {
      return false;
    }

    _slots[index] =
        _slots[index].copyWith(
          isBooked:
          false,
        );

    return true;
  }

  // ============================================================
  // REMOVE SLOT
  // ============================================================

  Future<bool> removeSlot(
      String slotId,
      ) async {
    await Future.delayed(
      const Duration(
        milliseconds: 150,
      ),
    );

    final int index =
    _slots.indexWhere(
          (slot) =>
      slot.id ==
          slotId,
    );

    if (index == -1) {
      return false;
    }

    if (_slots[index].isBooked) {
      return false;
    }

    _slots.removeAt(
      index,
    );

    return true;
  }

  // ============================================================
  // GET BOOKED TODAY
  // ============================================================

  Future<List<AppointmentSlot>>
  getBookedToday() async {
    final List<AppointmentSlot> slots =
    await getAllSlots();

    final DateTime now =
    DateTime.now();

    return slots.where(
          (slot) =>
      slot.isBooked &&
          slot.dateTime.year ==
              now.year &&
          slot.dateTime.month ==
              now.month &&
          slot.dateTime.day ==
              now.day,
    ).toList();
  }

  // ============================================================
  // GET UPCOMING BOOKINGS
  // ============================================================

  Future<List<AppointmentSlot>>
  getUpcomingBookings() async {
    final List<AppointmentSlot> slots =
    await getAllSlots();

    final DateTime now =
    DateTime.now();

    return slots.where(
          (slot) =>
      slot.isBooked &&
          slot.dateTime.isAfter(
            now,
          ),
    ).toList();
  }

  // ============================================================
  // ACTIVE BRANCHES
  // ============================================================

  Future<List<String>>
  getActiveBranches() async {
    final List<AppointmentSlot> slots =
    await getAllSlots();

    final DateTime now =
    DateTime.now();

    final Set<String> branches =
    slots
        .where(
          (slot) =>
          slot.dateTime
              .isAfter(
            now,
          ),
    )
        .map(
          (slot) =>
      slot.branch,
    )
        .toSet();

    final List<String> result =
    branches.toList();

    result.sort();

    return result;
  }
}