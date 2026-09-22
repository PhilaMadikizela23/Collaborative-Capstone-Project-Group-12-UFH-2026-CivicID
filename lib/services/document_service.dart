import 'mock_data.dart';
import '../models/document.dart';

class DocumentService {
  final MockData _mockData = MockData();

  // ============================================================
  // ALL DOCUMENTS
  // ============================================================

  Future<List<Document>> getDocuments() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    return List<Document>.from(
      _mockData.documents,
    );
  }

  // ============================================================
  // GET ONE DOCUMENT
  // ============================================================

  Future<Document?> getDocumentById(
      String documentId,
      ) async {
    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    try {
      return _mockData.documents.firstWhere(
            (document) =>
        document.id == documentId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // DOCUMENTS FOR ONE APPLICATION
  // ============================================================

  Future<List<Document>> getApplicationDocuments(
      String applicationId,
      ) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    return _mockData.documents.where(
          (document) {
        return document.applicationId ==
            applicationId;
      },
    ).toList();
  }

  // ============================================================
  // PENDING DOCUMENTS
  // ============================================================

  Future<List<Document>>
  getPendingDocuments() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    return _mockData.documents.where(
          (document) {
        return document.status ==
            'Pending Verification' ||
            document.status == 'Pending';
      },
    ).toList();
  }

  // ============================================================
  // VERIFIED DOCUMENTS
  // ============================================================

  Future<List<Document>>
  getVerifiedDocuments() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    return _mockData.documents.where(
          (document) =>
      document.status == 'Verified',
    ).toList();
  }

  // ============================================================
  // REJECTED DOCUMENTS
  // ============================================================

  Future<List<Document>>
  getRejectedDocuments() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    return _mockData.documents.where(
          (document) =>
      document.status == 'Rejected',
    ).toList();
  }

  // ============================================================
  // MORE INFORMATION REQUIRED
  // ============================================================

  Future<List<Document>>
  getDocumentsRequiringInformation() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    return _mockData.documents.where(
          (document) =>
      document.status ==
          'More Information Required',
    ).toList();
  }

  // ============================================================
  // ADD DOCUMENT
  // ============================================================

  Future<void> addDocument(
      Document document,
      ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final existingIndex =
    _mockData.documents.indexWhere(
          (d) => d.id == document.id,
    );

    if (existingIndex != -1) {
      _mockData.documents[existingIndex] =
          document;
      return;
    }

    _mockData.documents.add(document);
  }

  // ============================================================
  // UPDATE DOCUMENT
  // ============================================================

  Future<void> updateDocument(
      Document document,
      ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final index =
    _mockData.documents.indexWhere(
          (d) => d.id == document.id,
    );

    if (index == -1) {
      throw Exception(
        'Document not found.',
      );
    }

    _mockData.documents[index] =
        document;
  }

  // ============================================================
  // LINK DOCUMENT TO APPLICATION
  // ============================================================

  Future<void> linkDocumentToApplication(
      String documentId,
      String applicationId,
      ) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    final index =
    _mockData.documents.indexWhere(
          (document) =>
      document.id == documentId,
    );

    if (index == -1) {
      throw Exception(
        'Document not found.',
      );
    }

    final document =
    _mockData.documents[index];

    _mockData.documents[index] =
        document.copyWith(
          applicationId: applicationId,
        );
  }

  // ============================================================
  // MARK DOCUMENT AS PENDING
  // ============================================================

  Future<void> markAsPending(
      String documentId,
      ) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    final index =
    _mockData.documents.indexWhere(
          (document) =>
      document.id == documentId,
    );

    if (index == -1) {
      throw Exception(
        'Document not found.',
      );
    }

    final document =
    _mockData.documents[index];

    _mockData.documents[index] =
        document.copyWith(
          status: 'Pending Verification',
        );
  }

  // ============================================================
  // ADMIN ACCEPT / VERIFY DOCUMENT
  // ============================================================

  Future<void> verifyDocument({
    required String documentId,
    String? comment,
    String reviewedBy = 'CivicID Admin',
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 450),
    );

    final index =
    _mockData.documents.indexWhere(
          (document) =>
      document.id == documentId,
    );

    if (index == -1) {
      throw Exception(
        'Document not found.',
      );
    }

    final document =
    _mockData.documents[index];

    _mockData.documents[index] =
        document.copyWith(
          status: 'Verified',
          adminComment:
          _cleanComment(comment),
          reviewedBy: reviewedBy,
          reviewedAt: DateTime.now(),
        );
  }

  // ============================================================
  // ADMIN REJECT DOCUMENT
  // ============================================================

  Future<void> rejectDocument({
    required String documentId,
    required String comment,
    String reviewedBy = 'CivicID Admin',
  }) async {
    final cleanComment =
    comment.trim();

    if (cleanComment.isEmpty) {
      throw Exception(
        'A rejection reason is required.',
      );
    }

    await Future.delayed(
      const Duration(milliseconds: 450),
    );

    final index =
    _mockData.documents.indexWhere(
          (document) =>
      document.id == documentId,
    );

    if (index == -1) {
      throw Exception(
        'Document not found.',
      );
    }

    final document =
    _mockData.documents[index];

    _mockData.documents[index] =
        document.copyWith(
          status: 'Rejected',
          adminComment: cleanComment,
          reviewedBy: reviewedBy,
          reviewedAt: DateTime.now(),
        );
  }

  // ============================================================
  // ADMIN REQUEST MORE INFORMATION
  // ============================================================

  Future<void> requestMoreInformation({
    required String documentId,
    required String comment,
    String reviewedBy = 'CivicID Admin',
  }) async {
    final cleanComment =
    comment.trim();

    if (cleanComment.isEmpty) {
      throw Exception(
        'A comment is required when requesting more information.',
      );
    }

    await Future.delayed(
      const Duration(milliseconds: 450),
    );

    final index =
    _mockData.documents.indexWhere(
          (document) =>
      document.id == documentId,
    );

    if (index == -1) {
      throw Exception(
        'Document not found.',
      );
    }

    final document =
    _mockData.documents[index];

    _mockData.documents[index] =
        document.copyWith(
          status:
          'More Information Required',
          adminComment: cleanComment,
          reviewedBy: reviewedBy,
          reviewedAt: DateTime.now(),
        );
  }

  // ============================================================
  // RESET DOCUMENT AFTER USER RE-UPLOADS IT
  // ============================================================

  Future<void> resubmitDocument({
    required String documentId,
    required String filePath,
    String? mimeType,
    String? originalFileName,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 450),
    );

    final index =
    _mockData.documents.indexWhere(
          (document) =>
      document.id == documentId,
    );

    if (index == -1) {
      throw Exception(
        'Document not found.',
      );
    }

    final document =
    _mockData.documents[index];

    _mockData.documents[index] =
        document.copyWith(
          filePath: filePath,
          mimeType: mimeType,
          originalFileName:
          originalFileName,
          status: 'Pending Verification',
          adminComment: '',
          reviewedBy: '',
        );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteDocument(
      String id,
      ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    _mockData.documents.removeWhere(
          (document) =>
      document.id == id,
    );
  }

  // ============================================================
  // HELPER
  // ============================================================

  String? _cleanComment(
      String? comment,
      ) {
    if (comment == null) {
      return null;
    }

    final value =
    comment.trim();

    if (value.isEmpty) {
      return null;
    }

    return value;
  }
}