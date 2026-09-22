class AppointmentSlot {
  final String id;
  final String branch;
  final DateTime dateTime;
  final bool isBooked;

  const AppointmentSlot({
    required this.id,
    required this.branch,
    required this.dateTime,
    this.isBooked = false,
  });

  AppointmentSlot copyWith({
    String? id,
    String? branch,
    DateTime? dateTime,
    bool? isBooked,
  }) {
    return AppointmentSlot(
      id: id ?? this.id,
      branch: branch ?? this.branch,
      dateTime: dateTime ?? this.dateTime,
      isBooked: isBooked ?? this.isBooked,
    );
  }
}