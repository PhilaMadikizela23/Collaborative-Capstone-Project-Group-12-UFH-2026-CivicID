import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../models/document.dart';
import '../../services/admin_service.dart';
import '../../services/document_service.dart';

class AdminDocumentVerification extends StatefulWidget {
  final String? applicationId;
  final String? referenceNumber;

  const AdminDocumentVerification({
    super.key,
    this.applicationId,
    this.referenceNumber,
  });

  @override
  State<AdminDocumentVerification> createState() =>
      _AdminDocumentVerificationState();
}

class _AdminDocumentVerificationState
    extends State<AdminDocumentVerification> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);
  static const Color darkText = Color(0xFF14251C);

  static const Color rejectRed = Color(0xFFB3261E);
  static const Color warningOrange = Color(0xFFE88B00);
  static const Color warningBackground = Color(0xFFFFF8E7);

  // ============================================================
  // SERVICES
  // ============================================================

  final AdminService _adminService = AdminService();
  final DocumentService _documentService = DocumentService();

  // ============================================================
  // STATE
  // ============================================================

  List<Document> _pendingDocuments = [];

  bool _isLoading = true;

  String? _processingDocumentId;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadPendingDocuments();
  }

  // ============================================================
  // LOAD DOCUMENTS
  // ============================================================

  Future<void> _loadPendingDocuments() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final List<Document> documents;

      if (widget.applicationId != null) {
        documents =
        await _adminService.getPendingDocumentsForApplication(
          widget.applicationId!,
        );
      } else {
        documents =
        await _adminService.getAllPendingDocuments();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _pendingDocuments = documents;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load pending documents.',
        backgroundColor: rejectRed,
      );
    }
  }

  // ============================================================
  // FILE HELPERS
  // ============================================================

  bool _isImageDocument(Document document) {
    final mime = document.mimeType?.toLowerCase();

    if (mime != null && mime.startsWith('image/')) {
      return true;
    }

    final name =
    (document.originalFileName ?? document.name).toLowerCase();

    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png');
  }

  bool _isPdfDocument(Document document) {
    final mime = document.mimeType?.toLowerCase();

    if (mime == 'application/pdf') {
      return true;
    }

    final name =
    (document.originalFileName ?? document.name).toLowerCase();

    return name.endsWith('.pdf');
  }

  String _fileName(Document document) {
    return document.originalFileName ?? document.name;
  }

  String _fileType(Document document) {
    if (_isPdfDocument(document)) {
      return 'PDF';
    }

    if (_isImageDocument(document)) {
      return 'IMAGE';
    }

    return 'FILE';
  }

  String _fileSize(Document document) {
    final bytes = document.fileBytes;

    if (bytes == null || bytes.isEmpty) {
      return 'Unknown';
    }

    final size = bytes.length;

    if (size < 1024) {
      return '$size B';
    }

    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    }

    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  IconData _fileIcon(Document document) {
    if (_isPdfDocument(document)) {
      return Icons.picture_as_pdf_outlined;
    }

    if (_isImageDocument(document)) {
      return Icons.image_outlined;
    }

    return Icons.insert_drive_file_outlined;
  }

  // ============================================================
  // OPEN REVIEW
  // ============================================================

  Future<void> _openDocumentReview(
      Document document,
      ) async {
    final commentController = TextEditingController(
      text: document.adminComment ?? '',
    );

    await showDialog(
      context: context,
      barrierDismissible: _processingDocumentId == null,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            final processing =
                _processingDocumentId == document.id;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                width: 900,
                constraints: BoxConstraints(
                  maxHeight:
                  MediaQuery.of(context).size.height * 0.94,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================

                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        17,
                        12,
                        17,
                      ),
                      decoration: const BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.fact_check_outlined,
                              color: civicGreen,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Document Review',
                                  style: TextStyle(
                                    color: darkGreen,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  document.type,
                                  style: const TextStyle(
                                    color: textGrey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            tooltip: 'Close',
                            onPressed: processing
                                ? null
                                : () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      height: 1,
                      color: borderColor,
                    ),

                    // ==================================================
                    // BODY
                    // ==================================================

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Uploaded Document',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              'Inspect the actual image or PDF uploaded by the citizen before making a decision.',
                              style: TextStyle(
                                color: textGrey,
                                fontSize: 10,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 15),

                            _buildDocumentPreview(
                              document,
                            ),

                            const SizedBox(height: 15),

                            if (document.fileBytes != null &&
                                document.fileBytes!.isNotEmpty)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () {
                                    if (_isPdfDocument(document)) {
                                      _openPdf(document);
                                    } else if (_isImageDocument(
                                      document,
                                    )) {
                                      _openImage(document);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.open_in_full_rounded,
                                  ),
                                  label: Text(
                                    _isPdfDocument(document)
                                        ? 'OPEN FULL PDF'
                                        : 'OPEN FULL IMAGE',
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: civicGreen,
                                    foregroundColor: Colors.white,
                                    padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 26),

                            // ==================================================
                            // DETAILS
                            // ==================================================

                            const Text(
                              'Document Details',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: pageBackground,
                                borderRadius:
                                BorderRadius.circular(16),
                                border: Border.all(
                                  color: borderColor,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    'Document',
                                    document.name,
                                  ),

                                  const Divider(),

                                  _buildInfoRow(
                                    'Type',
                                    document.type,
                                  ),

                                  const Divider(),

                                  _buildInfoRow(
                                    'File Name',
                                    _fileName(document),
                                  ),

                                  const Divider(),

                                  _buildInfoRow(
                                    'Format',
                                    document.mimeType ??
                                        _fileType(document),
                                  ),

                                  const Divider(),

                                  _buildInfoRow(
                                    'File Size',
                                    _fileSize(document),
                                  ),

                                  const Divider(),

                                  _buildInfoRow(
                                    'Status',
                                    document.status,
                                  ),

                                  const Divider(),

                                  _buildInfoRow(
                                    'Required',
                                    document.isRequired
                                        ? 'Yes'
                                        : 'No',
                                  ),

                                  const Divider(),

                                  _buildInfoRow(
                                    'Document ID',
                                    document.id,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ==================================================
                            // ADMIN COMMENT
                            // ==================================================

                            const Text(
                              'Admin Comment',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              'Add a note if something is wrong. A comment is required when rejecting or requesting more information.',
                              style: TextStyle(
                                color: textGrey,
                                fontSize: 10,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 12),

                            TextField(
                              controller: commentController,
                              enabled: !processing,
                              minLines: 3,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText:
                                'Example: Please upload a clearer image showing the full document.',
                                filled: true,
                                fillColor: pageBackground,
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: borderColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: borderColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: civicGreen,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: warningBackground,
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                              child: const Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.visibility_outlined,
                                    color: warningOrange,
                                  ),
                                  SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      'Check that the document is readable, complete and matches the selected document type.',
                                      style: TextStyle(
                                        color: Color(
                                          0xFF725500,
                                        ),
                                        fontSize: 10,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // ==================================================
                            // ACTIONS
                            // ==================================================

                            LayoutBuilder(
                              builder: (
                                  context,
                                  constraints,
                                  ) {
                                if (constraints.maxWidth < 620) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child:
                                        OutlinedButton.icon(
                                          onPressed: processing
                                              ? null
                                              : () async {
                                            await _requestMoreInfo(
                                              dialogContext:
                                              dialogContext,
                                              document:
                                              document,
                                              comment:
                                              commentController
                                                  .text,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons
                                                .help_outline_rounded,
                                          ),
                                          label: const Text(
                                            'REQUEST MORE INFO',
                                          ),
                                          style: OutlinedButton
                                              .styleFrom(
                                            foregroundColor:
                                            warningOrange,
                                            side:
                                            const BorderSide(
                                              color:
                                              warningOrange,
                                            ),
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                              vertical: 15,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      SizedBox(
                                        width: double.infinity,
                                        child:
                                        OutlinedButton.icon(
                                          onPressed: processing
                                              ? null
                                              : () async {
                                            await _rejectDocument(
                                              dialogContext:
                                              dialogContext,
                                              document:
                                              document,
                                              comment:
                                              commentController
                                                  .text,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.cancel_outlined,
                                          ),
                                          label: const Text(
                                            'REJECT DOCUMENT',
                                          ),
                                          style: OutlinedButton
                                              .styleFrom(
                                            foregroundColor:
                                            rejectRed,
                                            side:
                                            const BorderSide(
                                              color: rejectRed,
                                            ),
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                              vertical: 15,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      SizedBox(
                                        width: double.infinity,
                                        child:
                                        FilledButton.icon(
                                          onPressed: processing
                                              ? null
                                              : () async {
                                            await _verifyDocument(
                                              dialogContext:
                                              dialogContext,
                                              document:
                                              document,
                                              comment:
                                              commentController
                                                  .text,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons
                                                .verified_rounded,
                                          ),
                                          label: const Text(
                                            'ACCEPT / VERIFY',
                                          ),
                                          style: FilledButton
                                              .styleFrom(
                                            backgroundColor:
                                            civicGreen,
                                            foregroundColor:
                                            Colors.white,
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                              vertical: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child:
                                      OutlinedButton.icon(
                                        onPressed: processing
                                            ? null
                                            : () async {
                                          await _requestMoreInfo(
                                            dialogContext:
                                            dialogContext,
                                            document:
                                            document,
                                            comment:
                                            commentController
                                                .text,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons
                                              .help_outline_rounded,
                                        ),
                                        label: const Text(
                                          'REQUEST INFO',
                                        ),
                                        style:
                                        OutlinedButton.styleFrom(
                                          foregroundColor:
                                          warningOrange,
                                          side:
                                          const BorderSide(
                                            color:
                                            warningOrange,
                                          ),
                                          padding:
                                          const EdgeInsets
                                              .symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child:
                                      OutlinedButton.icon(
                                        onPressed: processing
                                            ? null
                                            : () async {
                                          await _rejectDocument(
                                            dialogContext:
                                            dialogContext,
                                            document:
                                            document,
                                            comment:
                                            commentController
                                                .text,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.cancel_outlined,
                                        ),
                                        label: const Text(
                                          'REJECT',
                                        ),
                                        style:
                                        OutlinedButton.styleFrom(
                                          foregroundColor:
                                          rejectRed,
                                          side:
                                          const BorderSide(
                                            color: rejectRed,
                                          ),
                                          padding:
                                          const EdgeInsets
                                              .symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child:
                                      FilledButton.icon(
                                        onPressed: processing
                                            ? null
                                            : () async {
                                          await _verifyDocument(
                                            dialogContext:
                                            dialogContext,
                                            document:
                                            document,
                                            comment:
                                            commentController
                                                .text,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons
                                              .verified_rounded,
                                        ),
                                        label: const Text(
                                          'ACCEPT',
                                        ),
                                        style:
                                        FilledButton.styleFrom(
                                          backgroundColor:
                                          civicGreen,
                                          foregroundColor:
                                          Colors.white,
                                          padding:
                                          const EdgeInsets
                                              .symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    commentController.dispose();
  }

  // ============================================================
  // DOCUMENT PREVIEW
  // ============================================================

  Widget _buildDocumentPreview(
      Document document,
      ) {
    final bytes = document.fileBytes;

    if (bytes == null || bytes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 50,
        ),
        decoration: BoxDecoration(
          color: pageBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              size: 50,
              color: textGrey,
            ),
            SizedBox(height: 12),
            Text(
              'Document preview unavailable',
              style: TextStyle(
                color: darkText,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'The file data is not available. This may be an older document uploaded before file preview support was added.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // REAL IMAGE PREVIEW
    // ==========================================================

    if (_isImageDocument(document)) {
      return Container(
        width: double.infinity,
        height: 420,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3F1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 8,
            child: Image.memory(
              bytes,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return const Center(
                  child: Text(
                    'Unable to display this image.',
                    style: TextStyle(
                      color: textGrey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    // ==========================================================
    // REAL PDF PREVIEW
    // ==========================================================

    if (_isPdfDocument(document)) {
      return Container(
        width: double.infinity,
        height: 420,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: PdfViewer.data(
          bytes,
          sourceName: _fileName(document),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 55,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: pageBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _fileIcon(document),
            size: 55,
            color: civicGreen,
          ),
          const SizedBox(height: 12),
          Text(
            _fileName(document),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPEN FULL IMAGE
  // ============================================================

  void _openImage(
      Document document,
      ) {
    final bytes = document.fileBytes;

    if (bytes == null || bytes.isEmpty) {
      _showMessage(
        'This image is not available.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(
              document.type,
            ),
          ),
          body: InteractiveViewer(
            minScale: 0.3,
            maxScale: 10,
            child: Center(
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OPEN FULL PDF
  // ============================================================

  Future<void> _openPdf(
      Document document,
      ) async {
    final bytes = document.fileBytes;

    if (bytes == null || bytes.isEmpty) {
      _showMessage(
        'This PDF is not available.',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AdminPdfPreviewScreen(
          document: document,
        ),
      ),
    );
  }

  // ============================================================
  // VERIFY
  // ============================================================

  Future<void> _verifyDocument({
    required BuildContext dialogContext,
    required Document document,
    required String comment,
  }) async {
    final confirmed =
    await _confirmAction(
      title: 'Accept Document?',
      message:
      'Confirm that "${document.name}" has been inspected and should be marked as verified.',
      confirmText: 'ACCEPT',
      color: civicGreen,
    );

    if (!confirmed) {
      return;
    }

    if (mounted) {
      setState(() {
        _processingDocumentId =
            document.id;
      });
    }

    try {
      await _documentService.verifyDocument(
        documentId: document.id,
        comment: comment.trim(),
        reviewedBy: 'CivicID Admin',
      );

      if (!mounted ||
          !dialogContext.mounted) {
        return;
      }

      Navigator.pop(
        dialogContext,
      );

      _showMessage(
        '${document.name} verified successfully.',
        backgroundColor: civicGreen,
      );

      await _loadPendingDocuments();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to verify the document.',
        backgroundColor: rejectRed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingDocumentId = null;
        });
      }
    }
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<void> _rejectDocument({
    required BuildContext dialogContext,
    required Document document,
    required String comment,
  }) async {
    final cleanComment =
    comment.trim();

    if (cleanComment.isEmpty) {
      _showMessage(
        'Please enter a reason before rejecting the document.',
        backgroundColor: rejectRed,
      );
      return;
    }

    final confirmed =
    await _confirmAction(
      title: 'Reject Document?',
      message:
      'The citizen will be informed why this document was rejected.',
      confirmText: 'REJECT',
      color: rejectRed,
    );

    if (!confirmed) {
      return;
    }

    if (mounted) {
      setState(() {
        _processingDocumentId =
            document.id;
      });
    }

    try {
      await _documentService.rejectDocument(
        documentId: document.id,
        comment: cleanComment,
        reviewedBy: 'CivicID Admin',
      );

      if (!mounted ||
          !dialogContext.mounted) {
        return;
      }

      Navigator.pop(
        dialogContext,
      );

      _showMessage(
        '${document.name} was rejected.',
        backgroundColor: rejectRed,
      );

      await _loadPendingDocuments();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to reject the document.',
        backgroundColor: rejectRed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingDocumentId = null;
        });
      }
    }
  }

  // ============================================================
  // REQUEST MORE INFO
  // ============================================================

  Future<void> _requestMoreInfo({
    required BuildContext dialogContext,
    required Document document,
    required String comment,
  }) async {
    final cleanComment =
    comment.trim();

    if (cleanComment.isEmpty) {
      _showMessage(
        'Please explain what information or replacement document is required.',
        backgroundColor: warningOrange,
      );
      return;
    }

    final confirmed =
    await _confirmAction(
      title: 'Request More Information?',
      message:
      'The citizen will see your comment and can provide a corrected document.',
      confirmText: 'REQUEST INFO',
      color: warningOrange,
    );

    if (!confirmed) {
      return;
    }

    if (mounted) {
      setState(() {
        _processingDocumentId =
            document.id;
      });
    }

    try {
      await _documentService.requestMoreInformation(
        documentId: document.id,
        comment: cleanComment,
        reviewedBy: 'CivicID Admin',
      );

      if (!mounted ||
          !dialogContext.mounted) {
        return;
      }

      Navigator.pop(
        dialogContext,
      );

      _showMessage(
        'More information requested for ${document.name}.',
        backgroundColor: warningOrange,
      );

      await _loadPendingDocuments();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to request more information.',
        backgroundColor: warningOrange,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingDocumentId = null;
        });
      }
    }
  }

  // ============================================================
  // CONFIRM ACTION
  // ============================================================

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmText,
    required Color color,
  }) async {
    final result =
    await showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(22),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: textGrey,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'CANCEL',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: Text(
                confirmText,
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: textGrey,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        Color? backgroundColor,
      }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          message,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              widget.referenceNumber != null
                  ? 'Documents — ${widget.referenceNumber}'
                  : 'Document Verification',
              style: const TextStyle(
                color: darkGreen,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'CivicID Admin Portal',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading
                ? null
                : _loadPendingDocuments,
            icon: const Icon(
              Icons.refresh_rounded,
              color: civicGreen,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(
          color: civicGreen,
        ),
      )
          : RefreshIndicator(
        color: civicGreen,
        onRefresh:
        _loadPendingDocuments,
        child:
        _pendingDocuments.isEmpty
            ? _buildEmptyState()
            : _buildDocumentList(),
      ),
    );
  }

  // ============================================================
  // DOCUMENT LIST
  // ============================================================

  Widget _buildDocumentList() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        40,
      ),
      children: [
        Center(
          child: Container(
            constraints:
            const BoxConstraints(
              maxWidth: 950,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),

                const SizedBox(height: 25),

                const Text(
                  'Documents to Review',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Open each document to see the real uploaded image or PDF and verify its details.',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 16),

                ..._pendingDocuments.map(
                  _buildDocumentTile,
                ),

                const SizedBox(height: 18),

                _buildPrototypeNotice(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: const Color(
            0xFFCFE5D7,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.document_scanner_outlined,
              color: civicGreen,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  widget.referenceNumber != null
                      ? 'Application Documents'
                      : 'Pending Verification',
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.referenceNumber != null
                      ? 'Review documents linked to ${widget.referenceNumber}.'
                      : '${_pendingDocuments.length} document${_pendingDocuments.length == 1 ? '' : 's'} waiting for review.',
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(30),
            ),
            child: Text(
              '${_pendingDocuments.length}',
              style: const TextStyle(
                color: civicGreen,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DOCUMENT TILE
  // ============================================================

  Widget _buildDocumentTile(
      Document document,
      ) {
    final processing =
        _processingDocumentId ==
            document.id;

    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(18),
        onTap: processing
            ? null
            : () {
          _openDocumentReview(
            document,
          );
        },
        child: Padding(
          padding:
          const EdgeInsets.all(15),
          child: Row(
            children: [
              _buildThumbnail(
                document,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.type,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkGreen,
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _fileName(document),
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 9,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _badge(
                          _fileType(document),
                        ),
                        _badge(
                          _fileSize(document),
                        ),
                        _badge(
                          document.status,
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Tap to review uploaded file',
                      style: TextStyle(
                        color: civicGreen,
                        fontSize: 9,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              if (processing)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: civicGreen,
                  ),
                )
              else
                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  color: civicGreen,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // THUMBNAIL
  // ============================================================

  Widget _buildThumbnail(
      Document document,
      ) {
    final bytes =
        document.fileBytes;

    if (_isImageDocument(document) &&
        bytes != null &&
        bytes.isNotEmpty) {
      return ClipRRect(
        borderRadius:
        BorderRadius.circular(13),
        child: Image.memory(
          bytes,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return _fallbackThumbnail(
              document,
            );
          },
        ),
      );
    }

    return _fallbackThumbnail(
      document,
    );
  }

  Widget _fallbackThumbnail(
      Document document,
      ) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius:
        BorderRadius.circular(13),
      ),
      child: Icon(
        _fileIcon(document),
        color: civicGreen,
        size: 31,
      ),
    );
  }

  Widget _badge(
      String text,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: darkGreen,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
          MediaQuery.of(context)
              .size
              .height *
              0.65,
          child: const Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor:
                  lightGreen,
                  child: Icon(
                    Icons.verified_rounded,
                    color: civicGreen,
                    size: 48,
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  'No Pending Documents',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'All uploaded documents have been processed.',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROTOTYPE NOTICE
  // ============================================================

  Widget _buildPrototypeNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF1F5F2,
        ),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.school_outlined,
            color: textGrey,
            size: 18,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Academic Prototype — Document verification decisions made here are for the CivicID demonstration only and are not official government decisions.',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// FULL SCREEN PDF VIEWER
// ================================================================

class _AdminPdfPreviewScreen
    extends StatelessWidget {
  final Document document;

  const _AdminPdfPreviewScreen({
    required this.document,
  });

  static const Color darkGreen =
  Color(0xFF04542C);

  static const Color textGrey =
  Color(0xFF66756E);

  @override
  Widget build(
      BuildContext context,
      ) {
    final bytes =
        document.fileBytes;

    return Scaffold(
      backgroundColor:
      const Color(
        0xFFF4F7F5,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'PDF Document',
              style: TextStyle(
                color: darkGreen,
                fontSize: 16,
                fontWeight:
                FontWeight.w900,
              ),
            ),
            Text(
              document.originalFileName ??
                  document.name,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                color: textGrey,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
      body: bytes == null ||
          bytes.isEmpty
          ? const Center(
        child: Text(
          'This PDF is not available.',
          style: TextStyle(
            color: textGrey,
          ),
        ),
      )
          : PdfViewer.data(
        bytes,
        sourceName:
        document.originalFileName ??
            document.name,
      ),
    );
  }
}