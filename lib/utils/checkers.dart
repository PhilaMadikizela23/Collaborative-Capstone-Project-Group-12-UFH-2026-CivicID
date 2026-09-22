import '../models/application.dart';
import '../models/user_profile.dart';
import '../models/document.dart';
import '../models/government_service.dart';

class CompletenessResult {
  final double progress;
  final bool isComplete;
  final List<String> missingInformation;
  final List<String> missingDocuments;
  final List<String> unverifiedDocuments;
  final List<String> inconsistencies;

  const CompletenessResult({
    required this.progress,
    required this.isComplete,
    required this.missingInformation,
    required this.missingDocuments,
    required this.unverifiedDocuments,
    required this.inconsistencies,
  });

  int get percentage => (progress * 100).round();
}

class CompletenessChecker {
  // ============================================================
  // REQUIRED INFORMATION
  // ============================================================

  static const List<String> requiredInfoKeys = [
    'name',
    'idNumber',
    'dob',
  ];

  // ============================================================
  // FULL CHECK
  // ============================================================

  static CompletenessResult checkApplication({
    required Application application,
    required GovernmentService service,
    required List<Document> userDocuments,
    UserProfile? profile,
  }) {
    final missingInformation = <String>[];
    final missingDocuments = <String>[];
    final unverifiedDocuments = <String>[];
    final inconsistencies = <String>[];

    // ----------------------------------------------------------
    // CHECK REQUIRED INFORMATION
    // ----------------------------------------------------------

    for (final key in requiredInfoKeys) {
      final value = application.data[key];

      if (value == null || value.toString().trim().isEmpty) {
        missingInformation.add(
          _friendlyFieldName(key),
        );
      }
    }

    // ----------------------------------------------------------
    // CHECK REQUIRED DOCUMENTS
    // ----------------------------------------------------------

    for (final requiredType in service.requiredDocumentTypes) {
      final matchingDocuments = userDocuments.where(
            (doc) => _normalize(doc.type) == _normalize(requiredType),
      );

      if (matchingDocuments.isEmpty) {
        missingDocuments.add(requiredType);
        continue;
      }

      final hasVerifiedDocument = matchingDocuments.any(
            (doc) => _normalize(doc.status) == 'verified',
      );

      if (!hasVerifiedDocument) {
        unverifiedDocuments.add(requiredType);
      }
    }

    // ----------------------------------------------------------
    // CHECK CONSISTENCY
    // ----------------------------------------------------------

    if (profile != null) {
      inconsistencies.addAll(
        ConsistencyChecker.compareWithProfile(
          application: application,
          profile: profile,
        ),
      );
    }

    // ----------------------------------------------------------
    // CALCULATE PROGRESS
    // ----------------------------------------------------------

    final progress = calculateProgress(
      application: application,
      service: service,
      userDocuments: userDocuments,
    );

    // ----------------------------------------------------------
    // FINAL COMPLETENESS
    // ----------------------------------------------------------

    final isComplete =
        missingInformation.isEmpty &&
            missingDocuments.isEmpty &&
            unverifiedDocuments.isEmpty &&
            inconsistencies.isEmpty;

    return CompletenessResult(
      progress: progress,
      isComplete: isComplete,
      missingInformation: missingInformation,
      missingDocuments: missingDocuments,
      unverifiedDocuments: unverifiedDocuments,
      inconsistencies: inconsistencies,
    );
  }

  // ============================================================
  // SIMPLE TRUE/FALSE CHECK
  // ============================================================

  static bool isApplicationComplete({
    required Application application,
    required GovernmentService service,
    required List<Document> userDocuments,
    UserProfile? profile,
  }) {
    return checkApplication(
      application: application,
      service: service,
      userDocuments: userDocuments,
      profile: profile,
    ).isComplete;
  }

  // ============================================================
  // PROGRESS CALCULATION
  // ============================================================

  static double calculateProgress({
    required Application application,
    required GovernmentService service,
    required List<Document> userDocuments,
  }) {
    // 40% = basic/profile information
    // 60% = required verified documents

    double informationProgress = 0;
    double documentProgress = 0;

    // ----------------------------------------------------------
    // INFORMATION PROGRESS - 40%
    // ----------------------------------------------------------

    int completedInfo = 0;

    for (final key in requiredInfoKeys) {
      final value = application.data[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        completedInfo++;
      }
    }

    if (requiredInfoKeys.isNotEmpty) {
      informationProgress =
          completedInfo / requiredInfoKeys.length;
    }

    // ----------------------------------------------------------
    // DOCUMENT PROGRESS - 60%
    // ----------------------------------------------------------

    int completedDocuments = 0;

    for (final requiredType in service.requiredDocumentTypes) {
      final hasVerifiedDocument = userDocuments.any(
            (doc) =>
        _normalize(doc.type) == _normalize(requiredType) &&
            _normalize(doc.status) == 'verified',
      );

      if (hasVerifiedDocument) {
        completedDocuments++;
      }
    }

    if (service.requiredDocumentTypes.isEmpty) {
      documentProgress = 1;
    } else {
      documentProgress =
          completedDocuments /
              service.requiredDocumentTypes.length;
    }

    // ----------------------------------------------------------
    // FINAL WEIGHTED PROGRESS
    // ----------------------------------------------------------

    final result =
        (informationProgress * 0.40) +
            (documentProgress * 0.60);

    return result.clamp(0.0, 1.0);
  }

  // ============================================================
  // MISSING ITEMS HELPERS
  // ============================================================

  static List<String> getMissingInformation({
    required Application application,
  }) {
    final missing = <String>[];

    for (final key in requiredInfoKeys) {
      final value = application.data[key];

      if (value == null ||
          value.toString().trim().isEmpty) {
        missing.add(
          _friendlyFieldName(key),
        );
      }
    }

    return missing;
  }

  static List<String> getMissingDocuments({
    required GovernmentService service,
    required List<Document> userDocuments,
  }) {
    final missing = <String>[];

    for (final requiredType in service.requiredDocumentTypes) {
      final exists = userDocuments.any(
            (doc) =>
        _normalize(doc.type) ==
            _normalize(requiredType),
      );

      if (!exists) {
        missing.add(requiredType);
      }
    }

    return missing;
  }

  static List<String> getUnverifiedDocuments({
    required GovernmentService service,
    required List<Document> userDocuments,
  }) {
    final unverified = <String>[];

    for (final requiredType in service.requiredDocumentTypes) {
      final matchingDocuments = userDocuments.where(
            (doc) =>
        _normalize(doc.type) ==
            _normalize(requiredType),
      );

      if (matchingDocuments.isEmpty) {
        continue;
      }

      final verified = matchingDocuments.any(
            (doc) =>
        _normalize(doc.status) ==
            'verified',
      );

      if (!verified) {
        unverified.add(requiredType);
      }
    }

    return unverified;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  static String _friendlyFieldName(String key) {
    switch (key) {
      case 'name':
        return 'Full Name';

      case 'idNumber':
        return 'ID Number';

      case 'dob':
        return 'Date of Birth';

      default:
        return key;
    }
  }
}

class ConsistencyChecker {
  static List<String> compareWithProfile({
    required Application application,
    required UserProfile profile,
  }) {
    final inconsistencies = <String>[];

    // ----------------------------------------------------------
    // NAME
    // ----------------------------------------------------------

    final applicationName =
    application.data['name']?.toString().trim();

    final profileName =
    profile.name.trim();

    if (applicationName != null &&
        applicationName.isNotEmpty &&
        _normalize(applicationName) !=
            _normalize(profileName)) {
      inconsistencies.add(
        'Name does not match profile',
      );
    }

    // ----------------------------------------------------------
    // ID NUMBER
    // ----------------------------------------------------------

    final applicationId =
    application.data['idNumber']
        ?.toString()
        .trim();

    final profileId =
    profile.idNumber.trim();

    if (applicationId != null &&
        applicationId.isNotEmpty &&
        applicationId != profileId) {
      inconsistencies.add(
        'ID Number does not match profile',
      );
    }

    // ----------------------------------------------------------
    // DATE OF BIRTH
    // ----------------------------------------------------------

    final applicationDob =
    application.data['dob']
        ?.toString()
        .trim();

    final profileDob =
    profile.dob.toString().trim();

    if (applicationDob != null &&
        applicationDob.isNotEmpty &&
        applicationDob != profileDob) {
      inconsistencies.add(
        'Date of Birth does not match profile',
      );
    }

    return inconsistencies;
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}