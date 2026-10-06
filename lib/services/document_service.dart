import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'mock_data.dart';
import '../models/document.dart';

class DocumentService {
  final MockData _mockData = MockData();
    static const String _baseUrl = String.fromEnvironment(
    'CIVICID_API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // ============================================================
  // ALL DOCUMENTS
  // ============================================================

  Future<List<Document>> getDocuments() async {
  final token = await _accessToken();

  final response = await http.get(
    Uri.parse('$_baseUrl/api/documents'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Unable to load documents: ${response.body}',
    );
  }

  final dynamic decoded = jsonDecode(response.body);

  if (decoded is! List) {
    throw Exception(
      'Invalid documents response.',
    );
  }

  return decoded.map((item) {
    final data =
        Map<String, dynamic>.from(item);

    return Document(
      id: data['documentId'].toString(),

      type: _frontendDocumentType(
        data['typeCode']?.toString() ?? '',
        data['typeName']?.toString() ?? '',
      ),

      name:
          data['displayName']?.toString() ??
              '',

      status: _frontendStatus(
        data['verificationStatus'],
      ),

      originalFileName:
          data['originalFileName']
              ?.toString(),

      mimeType:
          data['mimeType']?.toString(),

      filePath:
          data['storageReference']
              ?.toString(),

      expiryDate:
          data['expiryDate'] == null
              ? null
              : DateTime.tryParse(
                  data['expiryDate'].toString(),
                ),

      isRequired: false,
    );
  }).toList();
 
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
  if (document.fileBytes == null ||
      document.fileBytes!.isEmpty) {
    throw Exception('The selected document has no file data.');
  }

  final token = await _accessToken();

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$_baseUrl/api/documents'),
  );

  request.headers['Authorization'] =
      'Bearer $token';

  request.fields['documentTypeId'] =
      _backendDocumentTypeId(document.type)
          .toString();

  request.fields['displayName'] =
      document.name;

  if (document.expiryDate != null) {
    request.fields['expiryDate'] =
        document.expiryDate!
            .toIso8601String()
            .substring(0, 10);
  }

  request.files.add(
    http.MultipartFile.fromBytes(
      'file',
      document.fileBytes!,
      filename:
          document.originalFileName ??
              document.name,
      contentType:
          _mediaTypeFor(document),
    ),
  );

  final streamedResponse =
      await request.send();

  final response =
      await http.Response.fromStream(
    streamedResponse,
  );

  if (response.statusCode != 201) {
    throw Exception(
      'Document upload failed: ${response.body}',
    );
  }

  final Map<String, dynamic> data =
      jsonDecode(response.body)
          as Map<String, dynamic>;

  final uploadedDocument =
      document.copyWith(
    id: data['documentId'].toString(),
    name:
        data['displayName']?.toString() ??
            document.name,
    originalFileName:
        data['originalFileName']
                ?.toString() ??
            document.originalFileName,
    mimeType:
        data['mimeType']?.toString() ??
            document.mimeType,
    status:
        _frontendStatus(
      data['verificationStatus'],
    ),
  );

  final existingIndex =
      _mockData.documents.indexWhere(
    (item) =>
        item.id == uploadedDocument.id,
  );

  if (existingIndex == -1) {
    _mockData.documents.add(
      uploadedDocument,
    );
  } else {
    _mockData.documents[existingIndex] =
        uploadedDocument;
  }
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
  final backendDocumentId =
      int.tryParse(documentId);

  final backendApplicationId =
      int.tryParse(applicationId);

  if (backendDocumentId == null) {
    throw Exception(
      'This document has not been uploaded to the backend.',
    );
  }

  if (backendApplicationId == null) {
    throw Exception(
      'This application does not have a valid backend ID.',
    );
  }

  final token = await _accessToken();

  final response = await http.post(
    Uri.parse(
      '$_baseUrl/api/applications/'
      '$backendApplicationId/documents/'
      '$backendDocumentId',
    ),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Unable to attach document: ${response.body}',
    );
  }

  final index =
      _mockData.documents.indexWhere(
    (document) =>
        document.id == documentId,
  );

  if (index != -1) {
    _mockData.documents[index] =
        _mockData.documents[index].copyWith(
      applicationId: applicationId,
    );
  }
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
  Future<String> _accessToken() async {
  final prefs =
      await SharedPreferences.getInstance();

  final token =
      prefs.getString(
    'civicid_access_token',
  );

  if (token == null ||
      token.trim().isEmpty) {
    throw Exception(
      'You are not logged in.',
    );
  }

  return token;
}

int _backendDocumentTypeId(
  String type,
) {
  switch (type.trim()) {
    case 'Identity Document':
    case 'South African Identity Document':
      return 1;

    case 'Proof of Residence':
      return 2;

    case 'Passport Photo':
    case 'Passport Photograph':
      return 3;

    default:
      throw Exception(
        'This document type is not connected to the backend yet: $type',
      );
  }
}

MediaType _mediaTypeFor(
  Document document,
) {
  final mime =
      document.mimeType
          ?.trim()
          .toLowerCase();

  switch (mime) {
    case 'application/pdf':
      return MediaType.parse(
        'application/pdf',
      );

    case 'image/jpeg':
      return MediaType.parse(
        'image/jpeg',
      );

    case 'image/png':
      return MediaType.parse(
        'image/png',
      );

    default:
      throw Exception(
        'Only PDF, JPEG and PNG documents are supported.',
      );
  }
}

String _frontendStatus(
  dynamic backendStatus,
) {
  switch (
      backendStatus
          ?.toString()
          .toUpperCase()) {
    case 'VERIFIED':
      return 'Verified';

    case 'REJECTED':
      return 'Rejected';

    default:
      return 'Pending Verification';
  }
}
String _frontendDocumentType(
  String typeCode,
  String typeName,
) {
  switch (typeCode) {
    case 'SA_ID':
      return 'Identity Document';

    case 'PROOF_OF_RESIDENCE':
      return 'Proof of Residence';

    case 'PASSPORT_PHOTO':
      return 'Passport Photo';

    default:
      return typeName;
  }
}
}