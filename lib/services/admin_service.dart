import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/application.dart';
import '../models/document.dart';

class AdminService {
  static const String _baseUrl = String.fromEnvironment(
    'CIVICID_API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  final Map<String, String> _documentApplicationIds = {};

  Future<Map<String, int>> getSystemStats() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/dashboard'),
      headers: await _headers(),
    );

    _ensureSuccess(response);

    final data =
        Map<String, dynamic>.from(jsonDecode(response.body));

    return {
      'totalApplications': _asInt(data['totalApplications']),
      'pendingVerifications':
          _asInt(data['pendingApplications']),
      'totalUsers': _asInt(data['totalUsers']),
      'completedApps':
          _asInt(data['approvedApplications']),
    };
  }

  Future<List<Application>> getAllApplications() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/applications'),
      headers: await _headers(),
    );

    _ensureSuccess(response);

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      return [];
    }

    final List<Application> applications = [];

    for (final item in decoded) {
      final summary =
          Map<String, dynamic>.from(item as Map);

      final id =
          summary['applicationId']?.toString();

      if (id == null || id.isEmpty) {
        continue;
      }

      try {
        final detail = await _fetchApplicationDetail(id);

        applications.add(
          _applicationFromDetail(detail),
        );
      } catch (_) {
        applications.add(
          _applicationFromSummary(summary),
        );
      }
    }

    return applications;
  }

  Future<void> updateApplicationStatus(
    String id,
    String status,
  ) async {
    final normalized = status
        .trim()
        .toLowerCase();

    if (normalized == 'under review') {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/api/admin/applications/$id/start-review',
        ),
        headers: await _headers(),
      );

      _ensureSuccess(response);
      return;
    }

    if (normalized == 'approved') {
      await _decision(
        id,
        action: 'APPROVE',
        message: '',
      );
      return;
    }

    if (normalized == 'rejected') {
      await _decision(
        id,
        action: 'REJECT',
        message:
            'Application rejected by CivicID administrator.',
      );
      return;
    }

    throw Exception(
      'Unsupported admin status: $status',
    );
  }

  Future<List<Document>>
      getAllPendingDocuments() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/admin/applications'),
      headers: await _headers(),
    );

    _ensureSuccess(response);

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      return [];
    }

    final List<Document> documents = [];

    for (final item in decoded) {
      final summary =
          Map<String, dynamic>.from(item as Map);

      final applicationId =
          summary['applicationId']?.toString();

      if (applicationId == null ||
          applicationId.isEmpty) {
        continue;
      }

      try {
        final detail =
            await _fetchApplicationDetail(
          applicationId,
        );

        documents.addAll(
          await _documentsFromDetail(
            applicationId,
            detail,
            onlyPending: true,
          ),
        );
      } catch (_) {}
    }

    return documents;
  }

  Future<List<Document>>
      getPendingDocumentsForApplication(
    String applicationId,
  ) async {
    final detail =
        await _fetchApplicationDetail(
      applicationId,
    );

    return _documentsFromDetail(
      applicationId,
      detail,
      onlyPending: true,
    );
  }

  Future<List<Document>>
      getDocumentsForApplication(
    String applicationId,
  ) async {
    final detail =
        await _fetchApplicationDetail(
      applicationId,
    );

    return _documentsFromDetail(
      applicationId,
      detail,
      onlyPending: false,
    );
  }

  Future<void> reviewApplicationDocument({
    required String applicationId,
    required String applicationDocumentId,
    required bool approved,
    String notes = '',
  }) async {
    final response = await http.patch(
      Uri.parse(
        '$_baseUrl/api/admin/applications/'
        '$applicationId/documents/'
        '$applicationDocumentId',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'status':
            approved ? 'VERIFIED' : 'REJECTED',
        'notes':
            notes.trim().isEmpty ? null : notes.trim(),
      }),
    );

    _ensureSuccess(response);
  }

  Future<void> verifyDocument(
    String id,
    bool approved,
  ) async {
    final applicationId =
        _documentApplicationIds[id];

    if (applicationId == null) {
      throw Exception(
        'Application ID for this document is unavailable.',
      );
    }

    await reviewApplicationDocument(
      applicationId: applicationId,
      applicationDocumentId: id,
      approved: approved,
    );
  }

  Future<void> addComment(
    String applicationId,
    String comment, {
    String authorType = 'Admin',
    String authorName = 'Admin',
  }) async {
    final cleanComment = comment.trim();

    if (cleanComment.isEmpty) {
      return;
    }

    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/admin/applications/'
        '$applicationId/comments',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'message': cleanComment,
        'internal': false,
      }),
    );

    _ensureSuccess(response);
  }

  Future<void> requestMoreInformation(
    String applicationId,
    String message,
  ) async {
    final cleanMessage = message.trim();

    if (cleanMessage.isEmpty) {
      return;
    }

    await _decision(
      applicationId,
      action: 'REQUEST_INFORMATION',
      message: cleanMessage,
    );
  }

  Future<void> _decision(
    String applicationId, {
    required String action,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/admin/applications/'
        '$applicationId/decision',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'action': action,
        'message': message,
      }),
    );

    _ensureSuccess(response);
  }

  Future<Map<String, dynamic>>
      _fetchApplicationDetail(
    String applicationId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/api/admin/applications/'
        '$applicationId',
      ),
      headers: await _headers(),
    );

    _ensureSuccess(response);

    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  Application _applicationFromDetail(
    Map<String, dynamic> detail,
  ) {
    final rawApplication = detail['application'];

    final summary = rawApplication is Map
        ? Map<String, dynamic>.from(rawApplication)
        : <String, dynamic>{};

    final Map<String, dynamic> data = {};

    final rawFields = detail['fields'];

    if (rawFields is List) {
      for (final rawField in rawFields) {
        final field =
            Map<String, dynamic>.from(
          rawField as Map,
        );

        final key =
            field['fieldKey']?.toString();

        final value =
            field['fieldValue']?.toString() ?? '';

        if (key == null || key.isEmpty) {
          continue;
        }

        data[key] = value;

        switch (key) {
          case 'fullName':
            data['name'] = value;
            break;

          case 'dateOfBirth':
            data['dob'] = value;
            break;

          case 'phoneNumber':
            data['phone'] = value;
            break;

          case 'residentialAddress':
            data['address'] = value;
            break;
        }
      }
    }

    data['serviceName'] =
        summary['serviceName']?.toString() ?? '';

    data['serviceCode'] =
        summary['serviceCode']?.toString() ?? '';

    data['readinessStatus'] =
        summary['readinessStatus']?.toString() ?? '';

    data['citizenUserId'] =
        summary['citizenUserId'];

    final citizenUserId =
        summary['citizenUserId']?.toString();

    final List<StatusHistoryItem> history = [];

    final rawHistory = detail['statusHistory'];

    if (rawHistory is List) {
      for (final rawItem in rawHistory) {
        final item =
            Map<String, dynamic>.from(
          rawItem as Map,
        );

        history.add(
          StatusHistoryItem(
            status: _displayStatus(
              item['toStatus']?.toString(),
              null,
            ),
            timestamp: _parseDate(
              item['changedAt'],
            ),
          ),
        );
      }
    }

    final List<AdminComment> comments = [];

    final rawCorrespondence =
        detail['correspondence'];

    if (rawCorrespondence is List) {
      for (final rawItem
          in rawCorrespondence) {
        final item =
            Map<String, dynamic>.from(
          rawItem as Map,
        );

        final senderId =
            item['senderUserId']?.toString();

        comments.add(
          AdminComment(
            text:
                item['message']?.toString() ?? '',
            timestamp:
                _parseDate(item['createdAt']),
            authorType:
                senderId == citizenUserId
                    ? 'User'
                    : 'Admin',
            authorName:
                item['senderName']?.toString() ??
                    'CivicID',
          ),
        );
      }
    }

    return Application(
      id:
          summary['applicationId']?.toString() ??
              '',
      referenceNumber:
          summary['referenceNumber']?.toString() ??
              '',
      serviceId: _frontendServiceId(
        summary['serviceId'],
      ),
      status: _displayStatus(
        summary['statusCode']?.toString(),
        summary['statusName']?.toString(),
      ),
      submissionDate: _submissionDate(summary),
      data: data,
      statusHistory: history,
      comments: comments,
    );
  }

  Application _applicationFromSummary(
    Map<String, dynamic> summary,
  ) {
    return Application(
      id:
          summary['applicationId']?.toString() ??
              '',
      referenceNumber:
          summary['referenceNumber']?.toString() ??
              '',
      serviceId:
          _frontendServiceId(summary['serviceId']),
      status: _displayStatus(
        summary['statusCode']?.toString(),
        summary['statusName']?.toString(),
      ),
      submissionDate: _submissionDate(summary),
      data: {
        'serviceName':
            summary['serviceName']?.toString() ??
                '',
        'serviceCode':
            summary['serviceCode']?.toString() ??
                '',
        'citizenUserId':
            summary['citizenUserId'],
      },
      statusHistory: const [],
      comments: const [],
    );
  }

  Future<List<Document>> _documentsFromDetail(
    String applicationId,
    Map<String, dynamic> detail, {
    required bool onlyPending,
  }) async {
    final rawDocuments = detail['documents'];

    if (rawDocuments is! List) {
      return [];
    }

    final List<Document> documents = [];

    for (final rawDocument in rawDocuments) {
      final item =
          Map<String, dynamic>.from(
        rawDocument as Map,
      );

      final reviewStatus =
          item['reviewStatus']
                  ?.toString()
                  .toUpperCase() ??
              'PENDING';

      if (onlyPending &&
          reviewStatus != 'PENDING') {
        continue;
      }

      documents.add(
        await _documentFromAttached(
          applicationId,
          item,
        ),
      );
    }

    return documents;
  }

  Future<Document> _documentFromAttached(
    String applicationId,
    Map<String, dynamic> item,
  ) async {
    final applicationDocumentId =
        item['applicationDocumentId']
                ?.toString() ??
            '';

    final documentId =
        item['documentId']?.toString() ?? '';

    _documentApplicationIds[
        applicationDocumentId] = applicationId;

    List<int>? bytes;
    String? mimeType;
    String? originalFileName;

    if (documentId.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse(
            '$_baseUrl/api/admin/documents/'
            '$documentId/download',
          ),
          headers: await _headers(
            includeJsonContentType: false,
          ),
        );

        if (response.statusCode == 200) {
          bytes = response.bodyBytes;

          mimeType = response
              .headers['content-type']
              ?.split(';')
              .first
              .trim();

          originalFileName =
              _fileNameFromHeaders(
            response.headers,
          );
        }
      } catch (_) {}
    }

    final displayName =
        item['displayName']?.toString() ??
            item['typeName']?.toString() ??
            'Document';

    return Document(
      id: applicationDocumentId,
      applicationId: applicationId,
      type: _frontendDocumentType(
        item['typeCode']?.toString(),
        item['typeName']?.toString(),
      ),
      name: displayName,
      status: _documentStatus(
        item['reviewStatus']?.toString(),
      ),
      filePath: documentId.isEmpty
          ? null
          : '$_baseUrl/api/admin/documents/'
              '$documentId/download',
      mimeType: mimeType,
      originalFileName:
          originalFileName ?? displayName,
      fileBytes:
          bytes == null ? null : Uint8List.fromList(bytes),
      isRequired: false,
      adminComment:
          item['reviewNotes']?.toString(),
      reviewedBy:
          item['reviewedByUserId']?.toString(),
      reviewedAt: _parseNullableDate(
        item['reviewedAt'],
      ),
    );
  }

  Future<Map<String, String>> _headers({
    bool includeJsonContentType = true,
  }) async {
    final preferences =
        await SharedPreferences.getInstance();

    final token =
        preferences.getString(
      'civicid_access_token',
    );

    if (token == null || token.isEmpty) {
      throw Exception(
        'No CivicID access token is available.',
      );
    }

    return {
      'Authorization': 'Bearer $token',
      if (includeJsonContentType)
        'Content-Type': 'application/json',
    };
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message =
        'Request failed (${response.statusCode}).';

    try {
      final decoded =
          jsonDecode(response.body);

      if (decoded is Map) {
        message =
            decoded['message']?.toString() ??
                decoded['error']?.toString() ??
                message;
      }
    } catch (_) {}

    throw Exception(message);
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _frontendServiceId(dynamic value) {
    switch (_asInt(value)) {
      case 1:
        return 'SRV002';

      case 2:
        return 'SRV001';

      case 3:
        return 'SRV004';

      default:
        return value?.toString() ?? '';
    }
  }

  String _displayStatus(
    String? statusCode,
    String? statusName,
  ) {
    switch (statusCode?.toUpperCase()) {
      case 'DRAFT':
        return 'Draft';

      case 'READY':
        return 'Ready';

      case 'SUBMITTED':
        return 'Submitted';

      case 'UNDER_REVIEW':
        return 'Under Review';

      case 'APPROVED':
        return 'Approved';

      case 'REJECTED':
        return 'Rejected';

      case 'ADDITIONAL_INFORMATION_REQUIRED':
        return 'More Information Required';

      default:
        return statusName ??
            statusCode ??
            'Unknown';
    }
  }

  String _frontendDocumentType(
    String? typeCode,
    String? typeName,
  ) {
    switch (typeCode?.toUpperCase()) {
      case 'SA_ID':
        return 'Identity Document';

      case 'PROOF_OF_RESIDENCE':
        return 'Proof of Residence';

      case 'PASSPORT_PHOTO':
        return 'Passport Photo';

      default:
        return typeName ?? 'Document';
    }
  }

  String _documentStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'VERIFIED':
        return 'Verified';

      case 'REJECTED':
        return 'Rejected';

      default:
        return 'Pending Verification';
    }
  }

  DateTime _submissionDate(
    Map<String, dynamic> summary,
  ) {
    return _parseDate(
      summary['submittedAt'] ??
          summary['draftCreatedAt'] ??
          summary['updatedAt'],
    );
  }

  DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value != null) {
      final parsed =
          DateTime.tryParse(value.toString());

      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }

  DateTime? _parseNullableDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  String? _fileNameFromHeaders(
    Map<String, String> headers,
  ) {
    final disposition =
        headers['content-disposition'];

    if (disposition == null) {
      return null;
    }

    final lower =
        disposition.toLowerCase();

    final index =
        lower.indexOf('filename=');

    if (index == -1) {
      return null;
    }

    return disposition
        .substring(
          index + 'filename='.length,
        )
        .replaceAll('"', '')
        .trim();
  }
}