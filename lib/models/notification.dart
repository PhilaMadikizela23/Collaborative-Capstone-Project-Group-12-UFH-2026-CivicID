class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  // User or Admin
  final String targetType;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.targetType = 'User',
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? targetType,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      targetType: targetType ?? this.targetType,
    );
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory AppNotification.fromMap(
      Map<String, dynamic> map,
      ) {
    return AppNotification(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      timestamp: _parseDateTime(
        map['timestamp'],
      ),
      isRead: map['isRead'] == true,
      targetType:
      map['targetType']?.toString() ?? 'User',
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'targetType': targetType,
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
  // HELPERS
  // ============================================================

  bool get isUnread => !isRead;

  bool get isUserNotification =>
      targetType.toLowerCase() == 'user';

  bool get isAdminNotification =>
      targetType.toLowerCase() == 'admin';

  // ============================================================
  // DISPLAY
  // ============================================================

  @override
  String toString() {
    return 'AppNotification('
        'id: $id, '
        'title: $title, '
        'targetType: $targetType, '
        'isRead: $isRead, '
        'timestamp: $timestamp'
        ')';
  }
}