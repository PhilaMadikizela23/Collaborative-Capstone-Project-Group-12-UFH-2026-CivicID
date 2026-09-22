class Appointment {
  final String id;
  final String serviceName;
  final DateTime dateTime;
  final String location;
  final String status;

  const Appointment({
    required this.id,
    required this.serviceName,
    required this.dateTime,
    required this.location,
    this.status = 'Confirmed',
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  Appointment copyWith({
    String? id,
    String? serviceName,
    DateTime? dateTime,
    String? location,
    String? status,
  }) {
    return Appointment(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory Appointment.fromMap(
      Map<String, dynamic> map,
      ) {
    return Appointment(
      id: map['id']?.toString() ?? '',
      serviceName:
      map['serviceName']?.toString() ?? '',
      dateTime: _parseDateTime(
        map['dateTime'],
      ),
      location:
      map['location']?.toString() ?? '',
      status:
      map['status']?.toString() ??
          'Confirmed',
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceName': serviceName,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'status': status,
    };
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  static DateTime _parseDateTime(
      dynamic value,
      ) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.now();
    }

    return DateTime.now();
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  bool get isConfirmed =>
      status.toLowerCase() == 'confirmed';

  bool get isCancelled =>
      status.toLowerCase() == 'cancelled';

  bool get isCompleted =>
      status.toLowerCase() == 'completed';

  bool get isUpcoming {
    return dateTime.isAfter(
      DateTime.now(),
    ) &&
        !isCancelled &&
        !isCompleted;
  }

  // ============================================================
  // DISPLAY
  // ============================================================

  @override
  String toString() {
    return 'Appointment('
        'id: $id, '
        'serviceName: $serviceName, '
        'dateTime: $dateTime, '
        'location: $location, '
        'status: $status'
        ')';
  }
}