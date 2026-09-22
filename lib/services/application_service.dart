import 'dart:math';

import 'mock_data.dart';
import 'notification_service.dart';

import '../models/application.dart';

class ApplicationService {
  final MockData _mockData = MockData();

  final NotificationService _notificationService =
  NotificationService();

  // ============================================================
  // GET ALL APPLICATIONS
  // ============================================================

  Future<List<Application>> getApplications() async {
    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );

    return _mockData.applications;
  }

  // ============================================================
  // CREATE APPLICATION
  // ============================================================

  Future<Application> createApplication(
      String serviceId,
      Map<String, dynamic> data,
      ) async {
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );

    final String refNumber =
    _generateReference();

    final Application newApplication =
    Application(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      referenceNumber:
      refNumber,

      serviceId:
      serviceId,

      status:
      'Draft',

      submissionDate:
      DateTime.now(),

      data:
      data,

      statusHistory: [
        StatusHistoryItem(
          status:
          'Draft',

          timestamp:
          DateTime.now(),
        ),
      ],
    );

    _mockData.applications.add(
      newApplication,
    );

    return newApplication;
  }

  // ============================================================
  // SUBMIT APPLICATION
  // ============================================================

  Future<Application> submitApplication(
      Application application,
      ) async {
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );

    final int index =
    _mockData.applications.indexWhere(
          (item) =>
      item.id ==
          application.id,
    );

    final Application updatedApplication =
    application.copyWith(
      status:
      'Submitted',

      statusHistory:
      List<StatusHistoryItem>.from(
        application.statusHistory,
      )..add(
        StatusHistoryItem(
          status:
          'Submitted',

          timestamp:
          DateTime.now(),
        ),
      ),
    );

    if (index != -1) {
      _mockData.applications[index] =
          updatedApplication;
    } else {
      _mockData.applications.add(
        updatedApplication,
      );
    }

    // Notify admin that a new application
    // has been submitted.
    await _notificationService.addNotification(
      'New Application Received',
      'A new application '
          '(${updatedApplication.referenceNumber}) '
          'has been submitted for review.',
      targetType: 'Admin',
    );

    return updatedApplication;
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> updateApplicationStatus(
      String applicationId,
      String newStatus,
      ) async {
    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );

    final int index =
    _mockData.applications.indexWhere(
          (item) =>
      item.id ==
          applicationId,
    );

    if (index == -1) {
      return;
    }

    final Application application =
    _mockData.applications[index];

    final List<StatusHistoryItem> updatedHistory =
    List<StatusHistoryItem>.from(
      application.statusHistory,
    )..add(
      StatusHistoryItem(
        status:
        newStatus,

        timestamp:
        DateTime.now(),
      ),
    );

    _mockData.applications[index] =
        application.copyWith(
          status:
          newStatus,

          statusHistory:
          updatedHistory,
        );
  }

  // ============================================================
  // REFERENCE NUMBER
  // ============================================================

  String _generateReference() {
    final Random random =
    Random();

    final int number =
        random.nextInt(
          90000,
        ) +
            10000;

    return 'CID-2026-$number';
  }
}