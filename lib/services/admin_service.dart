import 'mock_data.dart';
import 'notification_service.dart';

import '../models/application.dart';
import '../models/document.dart';
import '../models/audit_event.dart';

class AdminService {
  final MockData _mockData = MockData();
  final NotificationService _notificationService =
  NotificationService();

  // ============================================================
  // SYSTEM STATISTICS
  // ============================================================

  Future<Map<String, int>> getSystemStats() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final pendingDocuments = _mockData.documents.where(
          (document) {
        final status = document.status.toLowerCase();

        return status == 'pending' ||
            status == 'pending verification';
      },
    ).length;

    final completedApplications =
        _mockData.applications.where(
              (application) {
            final status =
            application.status.toLowerCase();

            return status == 'approved' ||
                status == 'completed';
          },
        ).length;

    return {
      'totalApplications':
      _mockData.applications.length,
      'pendingVerifications': pendingDocuments,
      'totalUsers': 1,
      'completedApps': completedApplications,
    };
  }

  // ============================================================
  // APPLICATIONS
  // ============================================================

  Future<List<Application>>
  getAllApplications() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    return _mockData.applications;
  }

  Future<void> updateApplicationStatus(
      String id,
      String status,
      ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final index = _mockData.applications.indexWhere(
          (application) => application.id == id,
    );

    if (index == -1) return;

    final application =
    _mockData.applications[index];

    // Prevent duplicate history entries if the status
    // has not actually changed.
    if (application.status == status) return;

    final history =
    List<StatusHistoryItem>.from(
      application.statusHistory,
    )..add(
      StatusHistoryItem(
        status: status,
        timestamp: DateTime.now(),
      ),
    );

    _mockData.applications[index] =
        application.copyWith(
          status: status,
          statusHistory: history,
        );

    // Notify citizen.
    await _notificationService.addNotification(
      _notificationTitle(status),
      _notificationMessage(
        application.referenceNumber,
        status,
      ),
    );

    // Add admin audit event.
    _mockData.auditEvents.insert(
      0,
      AuditEvent(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        eventType: 'Application $status',
        description:
        'Admin changed application '
            '${application.referenceNumber} '
            'to $status',
        timestamp: DateTime.now(),
      ),
    );
  }

  // ============================================================
  // DOCUMENTS
  // ============================================================

  Future<List<Document>>
  getAllPendingDocuments() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    return _mockData.documents.where(
          (document) {
        final status = document.status.toLowerCase();

        return status == 'pending' ||
            status == 'pending verification';
      },
    ).toList();
  }

  Future<List<Document>> getPendingDocumentsForApplication(String applicationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockData.documents.where((d) {
      final status = d.status.toLowerCase();
      return d.applicationId == applicationId && (status == 'pending' || status == 'pending verification');
    }).toList();
  }

  Future<List<Document>> getDocumentsForApplication(String applicationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData.documents.where((d) => d.applicationId == applicationId).toList();
  }

  Future<void> verifyDocument(
      String id,
      bool approved,
      ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final index = _mockData.documents.indexWhere(
          (document) => document.id == id,
    );

    if (index == -1) return;

    final oldDocument =
    _mockData.documents[index];

    final String status =
    approved ? 'Verified' : 'Rejected';

    final updatedDocument =
    oldDocument.copyWith(
      status: status,
    );

    _mockData.documents[index] =
        updatedDocument;

    // Notify citizen.
    await _notificationService.addNotification(
      approved
          ? 'Document Verified'
          : 'Document Requires Attention',
      approved
          ? "Your document '${updatedDocument.name}' "
          'has been verified.'
          : "Your document '${updatedDocument.name}' "
          'was not accepted. Please review the '
          'application information or upload a '
          'suitable document.',
    );

    // Audit event.
    _mockData.auditEvents.insert(
      0,
      AuditEvent(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        eventType: 'Document Verification',
        description:
        "Admin marked document "
            "'${updatedDocument.name}' as $status",
        timestamp: DateTime.now(),
      ),
    );
  }

  // ============================================================
  // COMMENTS / CORRESPONDENCE
  // ============================================================

  Future<void> addComment(
      String applicationId,
      String comment, {
        String authorType = 'Admin',
        String authorName = 'Admin',
      }) async {
    final cleanComment = comment.trim();

    if (cleanComment.isEmpty) return;

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final index = _mockData.applications.indexWhere(
          (application) =>
      application.id == applicationId,
    );

    if (index == -1) return;

    final application =
    _mockData.applications[index];

    final updatedComments =
    List<AdminComment>.from(
      application.comments,
    )..add(
      AdminComment(
        text: cleanComment,
        timestamp: DateTime.now(),
        authorType: authorType,
        authorName: authorName,
      ),
    );

    _mockData.applications[index] =
        application.copyWith(
          comments: updatedComments,
        );

    if (authorType == 'Admin') {
      await _notificationService.addNotification(
        'New Admin Comment',
        'An administrator added a comment to '
            'application ${application.referenceNumber}: '
            '"$cleanComment"',
      );

      _mockData.auditEvents.insert(
        0,
        AuditEvent(
          id: DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
          eventType: 'Admin Comment',
          description:
          'Admin added a comment to application '
              '${application.referenceNumber}',
          timestamp: DateTime.now(),
        ),
      );
    } else {
      _mockData.auditEvents.insert(
        0,
        AuditEvent(
          id: DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
          eventType: 'User Reply',
          description:
          'User replied to application '
              '${application.referenceNumber}',
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  // ============================================================
  // REQUEST MORE INFORMATION
  // ============================================================

  Future<void> requestMoreInformation(
      String applicationId,
      String message,
      ) async {
    final cleanMessage = message.trim();

    if (cleanMessage.isEmpty) return;

    // Add the administrator's explanation first.
    await addComment(
      applicationId,
      cleanMessage,
      authorType: 'Admin',
      authorName: 'CivicID Admin',
    );

    // Then change application status.
    await updateApplicationStatus(
      applicationId,
      'More Information Required',
    );
  }

  // ============================================================
  // NOTIFICATION TEXT
  // ============================================================

  String _notificationTitle(String status) {
    switch (status) {
      case 'Under Review':
        return 'Application Under Review';

      case 'Approved':
        return 'Application Approved';

      case 'Rejected':
        return 'Application Status Updated';

      case 'More Information Required':
        return 'More Information Required';

      default:
        return 'Application Status Updated';
    }
  }

  String _notificationMessage(
      String referenceNumber,
      String status,
      ) {
    switch (status) {
      case 'Under Review':
        return 'Your application $referenceNumber '
            'is now under administrative review.';

      case 'Approved':
        return 'Your CivicID prototype application '
            '$referenceNumber has been approved.';

      case 'Rejected':
        return 'Your CivicID prototype application '
            '$referenceNumber has been marked as '
            'rejected. Check the application for '
            'administrator comments.';

      case 'More Information Required':
        return 'More information is required for '
            'application $referenceNumber. Check the '
            'administrator comments for details.';

      default:
        return 'Application $referenceNumber status '
            'has changed to $status.';
    }
  }
}