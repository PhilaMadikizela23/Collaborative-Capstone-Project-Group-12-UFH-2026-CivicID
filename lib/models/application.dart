class Application {
  final String id;
  final String referenceNumber;
  final String serviceId;
  final String status;
  final DateTime submissionDate;
  final Map<String, dynamic> data;
  final List<StatusHistoryItem> statusHistory;
  final List<AdminComment> comments;

  const Application({
    required this.id,
    required this.referenceNumber,
    required this.serviceId,
    required this.status,
    required this.submissionDate,
    required this.data,
    required this.statusHistory,
    this.comments = const [],
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  Application copyWith({
    String? id,
    String? referenceNumber,
    String? serviceId,
    String? status,
    DateTime? submissionDate,
    Map<String, dynamic>? data,
    List<StatusHistoryItem>? statusHistory,
    List<AdminComment>? comments,
  }) {
    return Application(
      id: id ?? this.id,
      referenceNumber:
      referenceNumber ?? this.referenceNumber,
      serviceId:
      serviceId ?? this.serviceId,
      status:
      status ?? this.status,
      submissionDate:
      submissionDate ?? this.submissionDate,
      data:
      data ?? Map<String, dynamic>.from(this.data),
      statusHistory:
      statusHistory ?? List<StatusHistoryItem>.from(this.statusHistory),
      comments:
      comments ?? List<AdminComment>.from(this.comments),
    );
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory Application.fromMap(
      Map<String, dynamic> map,
      ) {
    return Application(
      id: map['id']?.toString() ?? '',
      referenceNumber:
      map['referenceNumber']?.toString() ?? '',
      serviceId:
      map['serviceId']?.toString() ?? '',
      status:
      map['status']?.toString() ?? 'Draft',
      submissionDate:
      _parseDateTime(map['submissionDate']),
      data:
      Map<String, dynamic>.from(
        map['data'] ?? const {},
      ),
      statusHistory:
      (map['statusHistory'] as List<dynamic>? ?? const [])
          .map(
            (item) => StatusHistoryItem.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
      comments:
      (map['comments'] as List<dynamic>? ?? const [])
          .map(
            (item) => AdminComment.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'referenceNumber': referenceNumber,
      'serviceId': serviceId,
      'status': status,
      'submissionDate':
      submissionDate.toIso8601String(),
      'data':
      Map<String, dynamic>.from(data),
      'statusHistory':
      statusHistory
          .map(
            (item) => item.toMap(),
      )
          .toList(),
      'comments':
      comments
          .map(
            (comment) => comment.toMap(),
      )
          .toList(),
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

  bool get isDraft =>
      status.toLowerCase() == 'draft';

  bool get isSubmitted =>
      status.toLowerCase() == 'submitted';

  bool get isApproved =>
      status.toLowerCase() == 'approved';

  bool get isRejected =>
      status.toLowerCase() == 'rejected';

  bool get requiresMoreInformation {
    final normalized =
    status.toLowerCase();

    return normalized ==
        'more information required' ||
        normalized ==
            'request info' ||
        normalized ==
            'additional information required';
  }

  bool get isPending {
    final normalized =
    status.toLowerCase();

    return normalized ==
        'submitted' ||
        normalized ==
            'pending' ||
        normalized ==
            'under review' ||
        normalized ==
            'pending review';
  }

  // ============================================================
  // LATEST STATUS
  // ============================================================

  StatusHistoryItem? get latestStatus {
    if (statusHistory.isEmpty) {
      return null;
    }

    final sorted =
    List<StatusHistoryItem>.from(
      statusHistory,
    );

    sorted.sort(
          (a, b) =>
          b.timestamp.compareTo(
            a.timestamp,
          ),
    );

    return sorted.first;
  }

  // ============================================================
  // DISPLAY
  // ============================================================

  @override
  String toString() {
    return 'Application('
        'id: $id, '
        'referenceNumber: $referenceNumber, '
        'serviceId: $serviceId, '
        'status: $status'
        ')';
  }
}

// ================================================================
// ADMIN COMMENT
// ================================================================

class AdminComment {
  final String text;
  final DateTime timestamp;

  // Example:
  // Admin
  // User
  final String authorType;

  final String authorName;

  const AdminComment({
    required this.text,
    required this.timestamp,
    required this.authorType,
    required this.authorName,
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  AdminComment copyWith({
    String? text,
    DateTime? timestamp,
    String? authorType,
    String? authorName,
  }) {
    return AdminComment(
      text:
      text ?? this.text,
      timestamp:
      timestamp ?? this.timestamp,
      authorType:
      authorType ?? this.authorType,
      authorName:
      authorName ?? this.authorName,
    );
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory AdminComment.fromMap(
      Map<String, dynamic> map,
      ) {
    return AdminComment(
      text:
      map['text']?.toString() ?? '',
      timestamp:
      _parseDateTime(map['timestamp']),
      authorType:
      map['authorType']?.toString() ?? 'Admin',
      authorName:
      map['authorName']?.toString() ?? 'Administrator',
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timestamp':
      timestamp.toIso8601String(),
      'authorType':
      authorType,
      'authorName':
      authorName,
    };
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool get isAdmin =>
      authorType.toLowerCase() ==
          'admin';

  bool get isUser =>
      authorType.toLowerCase() ==
          'user';

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
}

// ================================================================
// STATUS HISTORY
// ================================================================

class StatusHistoryItem {
  final String status;
  final DateTime timestamp;

  const StatusHistoryItem({
    required this.status,
    required this.timestamp,
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  StatusHistoryItem copyWith({
    String? status,
    DateTime? timestamp,
  }) {
    return StatusHistoryItem(
      status:
      status ?? this.status,
      timestamp:
      timestamp ?? this.timestamp,
    );
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory StatusHistoryItem.fromMap(
      Map<String, dynamic> map,
      ) {
    return StatusHistoryItem(
      status:
      map['status']?.toString() ?? '',
      timestamp:
      _parseDateTime(map['timestamp']),
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'timestamp':
      timestamp.toIso8601String(),
    };
  }

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
}