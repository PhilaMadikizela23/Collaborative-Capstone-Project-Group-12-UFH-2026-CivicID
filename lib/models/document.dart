import 'dart:typed_data';

class Document {
  final String id;

  // null = document wallet document
  // value = linked to a specific application
  final String? applicationId;

  final String type;
  final String name;
  final String status;

  // ============================================================
  // FILE INFORMATION
  // ============================================================

  final String? filePath;

  final String? mimeType;

  final String? originalFileName;

  // Actual uploaded file data.
  // This allows the admin to preview files in Flutter Web.
  final Uint8List? fileBytes;

  // ============================================================
  // DOCUMENT INFORMATION
  // ============================================================

  final DateTime? expiryDate;

  final bool isRequired;

  // ============================================================
  // ADMIN REVIEW
  // ============================================================

  final String? adminComment;

  final String? reviewedBy;

  final DateTime? reviewedAt;

  Document({
    required this.id,
    this.applicationId,
    required this.type,
    required this.name,
    required this.status,
    this.filePath,
    this.mimeType,
    this.originalFileName,
    this.fileBytes,
    this.expiryDate,
    this.isRequired = false,
    this.adminComment,
    this.reviewedBy,
    this.reviewedAt,
  });

  Document copyWith({
    String? id,
    String? applicationId,
    String? type,
    String? name,
    String? status,
    String? filePath,
    String? mimeType,
    String? originalFileName,
    Uint8List? fileBytes,
    DateTime? expiryDate,
    bool? isRequired,
    String? adminComment,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) {
    return Document(
      id: id ?? this.id,
      applicationId:
      applicationId ?? this.applicationId,
      type: type ?? this.type,
      name: name ?? this.name,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      mimeType: mimeType ?? this.mimeType,
      originalFileName:
      originalFileName ?? this.originalFileName,
      fileBytes:
      fileBytes ?? this.fileBytes,
      expiryDate:
      expiryDate ?? this.expiryDate,
      isRequired:
      isRequired ?? this.isRequired,
      adminComment:
      adminComment ?? this.adminComment,
      reviewedBy:
      reviewedBy ?? this.reviewedBy,
      reviewedAt:
      reviewedAt ?? this.reviewedAt,
    );
  }
}