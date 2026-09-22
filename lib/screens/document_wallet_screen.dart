import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../models/document.dart';
import '../services/document_service.dart';

class DocumentWalletScreen extends StatefulWidget {
  const DocumentWalletScreen({
    super.key,
  });

  @override
  State<DocumentWalletScreen> createState() =>
      _DocumentWalletScreenState();
}

class _DocumentWalletScreenState
    extends State<DocumentWalletScreen> {
  // ============================================================
  // CIVICID COLORS
  // ============================================================

  static const Color civicGreen =
  Color(0xFF08783E);

  static const Color darkGreen =
  Color(0xFF04542C);

  static const Color lightGreen =
  Color(0xFFEAF7EF);

  static const Color pageBackground =
  Color(0xFFF8FBF9);

  static const Color borderColor =
  Color(0xFFDDE7E1);

  static const Color textGrey =
  Color(0xFF66756E);

  final DocumentService _documentService =
  DocumentService();

  final ImagePicker _picker =
  ImagePicker();

  List<Document> _documents = [];

  bool _isLoading = true;

  String _filter = 'All';

  // ============================================================
  // DOCUMENT TYPES
  // ============================================================

  final List<String> _documentTypes = [
    'Identity Document',
    'Passport',
    'Passport Photo',
    'Proof of Residence',
    'Academic Certificate',
    'Eye Test Result',
    'Parents\' Details',
    'Other',
  ];

  // ============================================================
  // INITIAL LOAD
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final documents =
      await _documentService
          .getDocuments();

      if (!mounted) return;

      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load documents.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FILTERED DOCUMENTS
  // ============================================================

  List<Document> get _filteredDocuments {
    if (_filter == 'All') {
      return _documents;
    }

    if (_filter == 'Verified') {
      return _documents.where(
            (document) {
          return document.status
              .toLowerCase() ==
              'verified';
        },
      ).toList();
    }

    if (_filter == 'Pending') {
      return _documents.where(
            (document) {
          final status =
          document.status
              .toLowerCase();

          return status == 'pending' ||
              status ==
                  'pending verification';
        },
      ).toList();
    }

    if (_filter == 'Rejected') {
      return _documents.where(
            (document) {
          return document.status
              .toLowerCase() ==
              'rejected';
        },
      ).toList();
    }

    return _documents;
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  int get _verifiedCount {
    return _documents.where(
          (document) {
        return document.status
            .toLowerCase() ==
            'verified';
      },
    ).length;
  }

  int get _pendingCount {
    return _documents.where(
          (document) {
        final status =
        document.status
            .toLowerCase();

        return status == 'pending' ||
            status ==
                'pending verification';
      },
    ).length;
  }

  int get _rejectedCount {
    return _documents.where(
          (document) {
        return document.status
            .toLowerCase() ==
            'rejected';
      },
    ).length;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      pageBackground,

      appBar: AppBar(
        backgroundColor:
        Colors.white,
        surfaceTintColor:
        Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Document Wallet',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight:
                FontWeight.w900,
              ),
            ),

            Text(
              'Secure CivicID document storage',
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
            onPressed:
            _isLoading
                ? null
                : _loadDocuments,
            icon: const Icon(
              Icons.refresh_rounded,
              color: civicGreen,
            ),
          ),

          const SizedBox(
            width: 5,
          ),
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
        _loadDocuments,
        child:
        _buildContent(),
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed:
        _showAddDocumentDialog,
        backgroundColor:
        civicGreen,
        foregroundColor:
        Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'ADD DOCUMENT',
          style: TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        100,
      ),
      children: [
        Center(
          child: Container(
            constraints:
            const BoxConstraints(
              maxWidth: 1000,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),

                const SizedBox(
                  height: 22,
                ),

                _buildStatistics(),

                const SizedBox(
                  height: 22,
                ),

                _buildFilters(),

                const SizedBox(
                  height: 22,
                ),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'My Documents',
                        style:
                        TextStyle(
                          color: Color(
                            0xFF14251C,
                          ),
                          fontSize: 19,
                          fontWeight:
                          FontWeight
                              .w900,
                        ),
                      ),
                    ),

                    Text(
                      '${_filteredDocuments.length}',
                      style:
                      const TextStyle(
                        color:
                        civicGreen,
                        fontWeight:
                        FontWeight
                            .w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 5,
                ),

                const Text(
                  'Store supporting documents and track their verification status.',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                if (_filteredDocuments
                    .isEmpty)
                  _buildEmptyState()
                else
                  ..._filteredDocuments
                      .map(
                    _buildDocumentCard,
                  ),

                const SizedBox(
                  height: 20,
                ),

                _buildPrototypeNotice(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER CARD
  // ============================================================

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient:
        const LinearGradient(
          colors: [
            darkGreen,
            civicGreen,
          ],
        ),
        borderRadius:
        BorderRadius.circular(23),
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final small =
              constraints.maxWidth <
                  540;

          final information =
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Document Wallet',
                style:
                TextStyle(
                  color:
                  Colors.white,
                  fontSize: 22,
                  fontWeight:
                  FontWeight
                      .w900,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                'Keep your CivicID documents organised and ready when preparing applications.',
                style: TextStyle(
                  color: Colors.white
                      .withValues(
                    alpha: 0.86,
                  ),
                  fontSize: 10,
                  height: 1.5,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration:
                BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.13,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    20,
                  ),
                ),
                child: Text(
                  '${_documents.length} DOCUMENT${_documents.length == 1 ? '' : 'S'}',
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 9,
                    fontWeight:
                    FontWeight
                        .w800,
                  ),
                ),
              ),
            ],
          );

          if (small) {
            return information;
          }

          return Row(
            children: [
              Expanded(
                child:
                information,
              ),

              const SizedBox(
                width: 20,
              ),

              Container(
                width: 86,
                height: 86,
                decoration:
                BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.12,
                  ),
                  shape:
                  BoxShape.circle,
                ),
                child:
                const Icon(
                  Icons
                      .account_balance_wallet_outlined,
                  color:
                  Colors.white,
                  size: 40,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatistics() {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final narrow =
            constraints.maxWidth <
                600;

        if (narrow) {
          return Column(
            children: [
              _statCard(
                'Verified',
                _verifiedCount,
                Icons
                    .verified_outlined,
                civicGreen,
                lightGreen,
              ),

              const SizedBox(
                height: 9,
              ),

              _statCard(
                'Pending',
                _pendingCount,
                Icons
                    .hourglass_top_rounded,
                const Color(
                  0xFF8B6900,
                ),
                const Color(
                  0xFFFFF5D9,
                ),
              ),

              const SizedBox(
                height: 9,
              ),

              _statCard(
                'Rejected',
                _rejectedCount,
                Icons
                    .error_outline_rounded,
                const Color(
                  0xFFB3261E,
                ),
                const Color(
                  0xFFFFECEA,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _statCard(
                'Verified',
                _verifiedCount,
                Icons
                    .verified_outlined,
                civicGreen,
                lightGreen,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: _statCard(
                'Pending',
                _pendingCount,
                Icons
                    .hourglass_top_rounded,
                const Color(
                  0xFF8B6900,
                ),
                const Color(
                  0xFFFFF5D9,
                ),
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: _statCard(
                'Rejected',
                _rejectedCount,
                Icons
                    .error_outline_rounded,
                const Color(
                  0xFFB3261E,
                ),
                const Color(
                  0xFFFFECEA,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(
      String label,
      int value,
      IconData icon,
      Color foreground,
      Color background,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 41,
            height: 41,
            decoration:
            BoxDecoration(
              color: background,
              borderRadius:
              BorderRadius
                  .circular(12),
            ),
            child: Icon(
              icon,
              color: foreground,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  '$value',
                  style:
                  TextStyle(
                    color:
                    foreground,
                    fontSize: 18,
                    fontWeight:
                    FontWeight
                        .w900,
                  ),
                ),

                Text(
                  label,
                  style:
                  const TextStyle(
                    color:
                    textGrey,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    const filters = [
      'All',
      'Verified',
      'Pending',
      'Rejected',
    ];

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,
      child: Row(
        children:
        filters.map(
              (filter) {
            final selected =
                _filter ==
                    filter;

            return Padding(
              padding:
              const EdgeInsets
                  .only(
                right: 8,
              ),
              child: ChoiceChip(
                selected:
                selected,
                label:
                Text(filter),
                selectedColor:
                civicGreen,
                backgroundColor:
                Colors.white,
                side: BorderSide(
                  color: selected
                      ? civicGreen
                      : borderColor,
                ),
                labelStyle:
                TextStyle(
                  color: selected
                      ? Colors.white
                      : textGrey,
                  fontSize: 10,
                  fontWeight:
                  FontWeight
                      .w700,
                ),
                onSelected: (_) {
                  setState(() {
                    _filter =
                        filter;
                  });
                },
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  // ============================================================
  // DOCUMENT CARD
  // ============================================================

  Widget _buildDocumentCard(
      Document document,
      ) {
    final status =
    document.status
        .toLowerCase();

    final rejected =
        status ==
            'rejected';

    final linked =
        document.applicationId !=
            null;

    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: rejected
              ? const Color(
            0xFFFFC9C4,
          )
              : borderColor,
        ),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration:
                  BoxDecoration(
                    color:
                    lightGreen,
                    borderRadius:
                    BorderRadius
                        .circular(14),
                  ),
                  child: Icon(
                    _getIconForType(
                      document.type,
                    ),
                    color:
                    civicGreen,
                    size: 23,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        document.name,
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        const TextStyle(
                          color: Color(
                            0xFF14251C,
                          ),
                          fontSize: 13,
                          fontWeight:
                          FontWeight
                              .w900,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        document.type,
                        style:
                        const TextStyle(
                          color:
                          textGrey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                _buildStatusBadge(
                  document.status,
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            const Divider(
              height: 1,
              color: borderColor,
            ),

            const SizedBox(
              height: 12,
            ),

            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                if (document.expiryDate !=
                    null)
                  _infoChip(
                    Icons
                        .event_outlined,
                    'Expiry',
                    DateFormat(
                      'dd MMM yyyy',
                    ).format(
                      document
                          .expiryDate!,
                    ),
                  ),

                _infoChip(
                  document.isRequired
                      ? Icons
                      .priority_high_rounded
                      : Icons
                      .description_outlined,
                  'Required',
                  document.isRequired
                      ? 'Yes'
                      : 'No',
                ),

                if (linked)
                  _infoChip(
                    Icons
                        .link_rounded,
                    'Application',
                    'Linked',
                  ),
              ],
            ),

            if (rejected) ...[
              const SizedBox(
                height: 14,
              ),

              Container(
                width:
                double.infinity,
                padding:
                const EdgeInsets
                    .all(12),
                decoration:
                BoxDecoration(
                  color: const Color(
                    0xFFFFECEA,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(12),
                ),
                child:
                const Row(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Icon(
                      Icons
                          .info_outline_rounded,
                      color: Color(
                        0xFFB3261E,
                      ),
                      size: 17,
                    ),

                    SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child: Text(
                        'This document was not accepted. You can replace it with a new file.',
                        style:
                        TextStyle(
                          color: Color(
                            0xFF8B1E18,
                          ),
                          fontSize: 9,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(
              height: 13,
            ),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                if (rejected)
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showReplaceDocumentDialog(
                          document,
                        ),
                    icon:
                    const Icon(
                      Icons
                          .upload_file_rounded,
                      size: 17,
                    ),
                    label:
                    const Text(
                      'REPLACE',
                    ),
                    style:
                    OutlinedButton
                        .styleFrom(
                      foregroundColor:
                      civicGreen,
                      side:
                      const BorderSide(
                        color:
                        civicGreen,
                      ),
                    ),
                  ),

                if (rejected)
                  const SizedBox(
                    width: 8,
                  ),

                IconButton(
                  tooltip:
                  'Delete document',
                  onPressed: () =>
                      _deleteDocument(
                        document,
                      ),
                  icon:
                  const Icon(
                    Icons
                        .delete_outline_rounded,
                    color: Color(
                      0xFFB3261E,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(
      String status,
      ) {
    final lower =
    status.toLowerCase();

    Color foreground;
    Color background;
    String text;

    if (lower == 'verified') {
      foreground =
          civicGreen;

      background =
          lightGreen;

      text =
      'VERIFIED';
    } else if (lower ==
        'pending' ||
        lower ==
            'pending verification') {
      foreground =
      const Color(
        0xFF8B6900,
      );

      background =
      const Color(
        0xFFFFF5D9,
      );

      text =
      'PENDING';
    } else if (lower ==
        'rejected') {
      foreground =
      const Color(
        0xFFB3261E,
      );

      background =
      const Color(
        0xFFFFECEA,
      );

      text =
      'REJECTED';
    } else if (lower ==
        'expired') {
      foreground =
      const Color(
        0xFFB3261E,
      );

      background =
      const Color(
        0xFFFFECEA,
      );

      text =
      'EXPIRED';
    } else {
      foreground =
          textGrey;

      background =
      const Color(
        0xFFF1F5F2,
      );

      text =
          status.toUpperCase();
    }

    return Container(
      constraints:
      const BoxConstraints(
        maxWidth: 130,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
      BoxDecoration(
        color: background,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 8,
          fontWeight:
          FontWeight.w900,
        ),
      ),
    );
  }

  Widget _infoChip(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: civicGreen,
        ),

        const SizedBox(
          width: 5,
        ),

        Text(
          '$label: ',
          style:
          const TextStyle(
            color: textGrey,
            fontSize: 9,
          ),
        ),

        Text(
          value,
          style:
          const TextStyle(
            color:
            Color(
              0xFF263B31,
            ),
            fontSize: 9,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ADD DOCUMENT
  // ============================================================

  void _showAddDocumentDialog() {
    String selectedType =
        'Identity Document';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.white,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top:
          Radius.circular(26),
        ),
      ),
      builder: (
          bottomSheetContext,
          ) {
        return StatefulBuilder(
          builder: (
              context,
              setModalState,
              ) {
            return Padding(
              padding:
              EdgeInsets.fromLTRB(
                22,
                22,
                22,
                MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                    24,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    margin:
                    const EdgeInsets
                        .only(
                      bottom: 18,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      borderColor,
                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),
                    ),
                  ),

                  const Text(
                    'Add Document',
                    style:
                    TextStyle(
                      color:
                      darkGreen,
                      fontSize: 20,
                      fontWeight:
                      FontWeight
                          .w900,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  const Text(
                    'Select the type of document and choose where to upload it from.',
                    style:
                    TextStyle(
                      color:
                      textGrey,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  DropdownButtonFormField<
                      String>(
                    initialValue:
                    selectedType,
                    decoration:
                    InputDecoration(
                      labelText:
                      'Document Type',
                      prefixIcon:
                      const Icon(
                        Icons
                            .description_outlined,
                        color:
                        civicGreen,
                      ),
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                      ),
                    ),
                    items:
                    _documentTypes
                        .map(
                          (type) {
                        return DropdownMenuItem<
                            String>(
                          value:
                          type,
                          child:
                          Text(
                            type,
                          ),
                        );
                      },
                    ).toList(),
                    onChanged:
                        (value) {
                      if (value ==
                          null) {
                        return;
                      }

                      setModalState(
                            () {
                          selectedType =
                              value;
                        },
                      );
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                        _buildSourceButton(
                          icon:
                          Icons
                              .photo_library_outlined,
                          label:
                          'Gallery',
                          onTap:
                              () async {
                            Navigator.pop(
                              bottomSheetContext,
                            );

                            await _handlePickImage(
                              selectedType,
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                        _buildSourceButton(
                          icon:
                          Icons
                              .folder_open_outlined,
                          label:
                          'Files',
                          onTap:
                              () async {
                            Navigator.pop(
                              bottomSheetContext,
                            );

                            await _handlePickFile(
                              selectedType,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Container(
                    padding:
                    const EdgeInsets
                        .all(
                      12,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      lightGreen,
                      borderRadius:
                      BorderRadius
                          .circular(
                        12,
                      ),
                    ),
                    child:
                    const Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Icon(
                          Icons
                              .info_outline_rounded,
                          color:
                          civicGreen,
                          size: 17,
                        ),

                        SizedBox(
                          width: 8,
                        ),

                        Expanded(
                          child:
                          Text(
                            'New documents will be marked Pending Verification until reviewed by a CivicID administrator.',
                            style:
                            TextStyle(
                              color:
                              darkGreen,
                              fontSize:
                              9,
                              height:
                              1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _handlePickImage(
      String type,
      ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();

      if (bytes.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to read this image.',
            ),
          ),
        );
        return;
      }

      final fileName = image.name;

      final document = Document(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: type,
        name: fileName,
        originalFileName: fileName,
        filePath: image.path,
        mimeType: _getMimeType(fileName),
        fileBytes: bytes,
        status: 'Pending Verification',
        isRequired: false,
      );

      await _documentService.addDocument(document);
      await _loadDocuments();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: civicGreen,
          content: Text(
            'Document uploaded successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to upload document.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // PICK FILE
  // ============================================================

  Future<void> _handlePickFile(
      String type,
      ) async {
    try {
      final FilePickerResult? result =
      await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const [
          'jpg',
          'jpeg',
          'png',
          'pdf',
        ],
        withData: true,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to read this file.',
            ),
          ),
        );
        return;
      }

      final document = Document(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: type,
        name: file.name,
        originalFileName: file.name,
        filePath: file.path,
        mimeType: _getMimeType(file.name),
        fileBytes: bytes,
        status: 'Pending Verification',
        isRequired: false,
      );

      await _documentService.addDocument(document);
      await _loadDocuments();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: civicGreen,
          content: Text(
            'Document uploaded successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to upload document.',
          ),
        ),
      );
    }
  }

  String _getMimeType(String fileName) {
    final lower = fileName.toLowerCase();

    if (lower.endsWith('.png')) {
      return 'image/png';
    }

    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    if (lower.endsWith('.pdf')) {
      return 'application/pdf';
    }

    return 'application/octet-stream';
  }

  // ============================================================
  // REPLACE REJECTED DOCUMENT
  // ============================================================

  void _showReplaceDocumentDialog(
      Document oldDocument,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
      Colors.white,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top:
          Radius.circular(26),
        ),
      ),
      builder: (
          bottomSheetContext,
          ) {
        return Padding(
          padding:
          const EdgeInsets.all(22),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
            children: [
              const Text(
                'Replace Document',
                style:
                TextStyle(
                  color:
                  darkGreen,
                  fontSize: 20,
                  fontWeight:
                  FontWeight
                      .w900,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                oldDocument.type,
                style:
                const TextStyle(
                  color:
                  textGrey,
                  fontSize: 10,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                    _buildSourceButton(
                      icon:
                      Icons
                          .photo_library_outlined,
                      label:
                      'Gallery',
                      onTap:
                          () async {
                        Navigator.pop(
                          bottomSheetContext,
                        );

                        await _replaceWithImage(
                          oldDocument,
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                    _buildSourceButton(
                      icon:
                      Icons
                          .folder_open_outlined,
                      label:
                      'Files',
                      onTap:
                          () async {
                        Navigator.pop(
                          bottomSheetContext,
                        );

                        await _replaceWithFile(
                          oldDocument,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _replaceWithImage(
      Document oldDocument,
      ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();

      if (bytes.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to read this image.',
            ),
          ),
        );
        return;
      }

      final fileName = image.name;

      final updated = Document(
        id: oldDocument.id,
        applicationId: oldDocument.applicationId,
        type: oldDocument.type,
        name: fileName,
        originalFileName: fileName,
        filePath: image.path,
        mimeType: _getMimeType(fileName),
        fileBytes: bytes,
        status: 'Pending Verification',
        expiryDate: oldDocument.expiryDate,
        isRequired: oldDocument.isRequired,
      );

      await _documentService.updateDocument(updated);
      await _loadDocuments();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: civicGreen,
          content: Text(
            'Replacement document uploaded for verification.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to replace document.',
          ),
        ),
      );
    }
  }

  Future<void> _replaceWithFile(
      Document oldDocument,
      ) async {
    try {
      final FilePickerResult? result =
      await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const [
          'jpg',
          'jpeg',
          'png',
          'pdf',
        ],
        withData: true,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to read this file.',
            ),
          ),
        );
        return;
      }

      final updated = Document(
        id: oldDocument.id,
        applicationId: oldDocument.applicationId,
        type: oldDocument.type,
        name: file.name,
        originalFileName: file.name,
        filePath: file.path,
        mimeType: _getMimeType(file.name),
        fileBytes: bytes,
        status: 'Pending Verification',
        expiryDate: oldDocument.expiryDate,
        isRequired: oldDocument.isRequired,
      );

      await _documentService.updateDocument(updated);
      await _loadDocuments();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: civicGreen,
          content: Text(
            'Replacement document uploaded for verification.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to replace document.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteDocument(
      Document document,
      ) async {
    final bool? confirmed =
    await showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          backgroundColor:
          Colors.white,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              22,
            ),
          ),

          title: const Text(
            'Delete Document?',
            style: TextStyle(
              color:
              darkGreen,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          content: Text(
            'Are you sure you want to remove "${document.name}" from your CivicID wallet?',
            style:
            const TextStyle(
              color:
              textGrey,
              height: 1.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    false,
                  ),
              child:
              const Text(
                'CANCEL',
              ),
            ),

            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    true,
                  ),
              style:
              FilledButton
                  .styleFrom(
                backgroundColor:
                const Color(
                  0xFFB3261E,
                ),
              ),
              child:
              const Text(
                'DELETE',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _documentService
        .deleteDocument(
      document.id,
    );

    await _loadDocuments();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Document removed from wallet.',
        ),
      ),
    );
  }

  // ============================================================
  // SOURCE BUTTON
  // ============================================================

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(16),
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          vertical: 19,
          horizontal: 12,
        ),
        decoration:
        BoxDecoration(
          color:
          const Color(
            0xFFF8FBF9,
          ),
          border:
          Border.all(
            color:
            borderColor,
          ),
          borderRadius:
          BorderRadius
              .circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color:
              civicGreen,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              label,
              style:
              const TextStyle(
                color:
                darkGreen,
                fontSize: 11,
                fontWeight:
                FontWeight
                    .w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ICON
  // ============================================================

  IconData _getIconForType(
      String type,
      ) {
    switch (
    type.toLowerCase()) {
      case 'identity document':
        return Icons
            .badge_outlined;

      case 'passport':
        return Icons
            .public_outlined;

      case 'passport photo':
        return Icons
            .photo_camera_outlined;

      case 'proof of residence':
        return Icons
            .home_outlined;

      case 'academic certificate':
        return Icons
            .school_outlined;

      case 'eye test result':
        return Icons
            .visibility_outlined;

      case 'parents\' details':
        return Icons
            .family_restroom_outlined;

      default:
        return Icons
            .description_outlined;
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 55,
      ),
      decoration: BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        border:
        Border.all(
          color:
          borderColor,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration:
            const BoxDecoration(
              color:
              lightGreen,
              shape:
              BoxShape.circle,
            ),
            child:
            const Icon(
              Icons
                  .account_balance_wallet_outlined,
              color:
              civicGreen,
              size: 45,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            _filter == 'All'
                ? 'Your Wallet Is Empty'
                : 'No $_filter Documents',
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color:
              darkGreen,
              fontSize: 18,
              fontWeight:
              FontWeight
                  .w900,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            _filter == 'All'
                ? 'Upload your supporting documents so they can be used when preparing CivicID applications.'
                : 'There are currently no documents in this category.',
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color:
              textGrey,
              fontSize: 10,
              height: 1.5,
            ),
          ),

          if (_filter ==
              'All') ...[
            const SizedBox(
              height: 20,
            ),

            FilledButton.icon(
              onPressed:
              _showAddDocumentDialog,
              style:
              FilledButton
                  .styleFrom(
                backgroundColor:
                civicGreen,
              ),
              icon:
              const Icon(
                Icons
                    .add_rounded,
              ),
              label:
              const Text(
                'ADD FIRST DOCUMENT',
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PROTOTYPE NOTICE
  // ============================================================

  Widget _buildPrototypeNotice() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(13),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFF1F5F2,
        ),
        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),
      child:
      const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .school_outlined,
            color:
            textGrey,
            size: 18,
          ),

          SizedBox(
            width: 9,
          ),

          Expanded(
            child: Text(
              'Academic Prototype — Documents and verification statuses shown in CivicID are for demonstration purposes and do not represent official government document verification.',
              style:
              TextStyle(
                color:
                textGrey,
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
