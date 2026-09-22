class AuditEvent {
  final String id;
  final String eventType;
  final String description;
  final DateTime timestamp;

  const AuditEvent({
    required this.id,
    required this.eventType,
    required this.description,
    required this.timestamp,
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  AuditEvent copyWith({
    String? id,
    String? eventType,
    String? description,
    DateTime? timestamp,
  }) {
    return AuditEvent(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory AuditEvent.fromMap(
      Map<String, dynamic> map,
      ) {
    return AuditEvent(
      id: map['id']?.toString() ?? '',
      eventType:
      map['eventType']?.toString() ?? 'Activity',
      description:
      map['description']?.toString() ?? '',
      timestamp:
      _parseDateTime(map['timestamp']),
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventType': eventType,
      'description': description,
      'timestamp':
      timestamp.toIso8601String(),
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
  // EVENT HELPERS
  // ============================================================

  bool get isLogin {
    return eventType.toLowerCase().contains(
      'login',
    );
  }

  bool get isLogout {
    return eventType.toLowerCase().contains(
      'logout',
    );
  }

  bool get isApplicationEvent {
    return eventType.toLowerCase().contains(
      'application',
    );
  }

  bool get isDocumentEvent {
    return eventType.toLowerCase().contains(
      'document',
    );
  }

  bool get isSecurityEvent {
    final type =
    eventType.toLowerCase();

    return type.contains('security') ||
        type.contains('password') ||
        type.contains('authentication');
  }

  // ============================================================
  // DISPLAY
  // ============================================================

  @override
  String toString() {
    return 'AuditEvent('
        'id: $id, '
        'eventType: $eventType, '
        'description: $description, '
        'timestamp: $timestamp'
        ')';
  }
}