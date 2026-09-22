import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/government_service.dart';
import '../../models/document.dart';

import '../../services/profile_service.dart';
import '../../services/application_service.dart';
import '../../services/document_service.dart';
import '../../services/notification_service.dart';

import 'completeness_checker_screen.dart';

class ApplicationAssistantScreen extends StatefulWidget {
  final GovernmentService service;

  const ApplicationAssistantScreen({
    super.key,
    required this.service,
  });

  @override
  State<ApplicationAssistantScreen> createState() =>
      _ApplicationAssistantScreenState();
}

class _ApplicationAssistantScreenState
    extends State<ApplicationAssistantScreen> {
  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);
  static const Color darkText = Color(0xFF14251C);

  final ProfileService _profileService = ProfileService();
  final ApplicationService _applicationService = ApplicationService();
  final DocumentService _documentService = DocumentService();
  final NotificationService _notificationService = NotificationService();

  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;

  bool _isLoading = true;
  bool _isCreatingApplication = false;

  List<Document> _userDocuments = [];

  String? _applicationType;

  // ============================================================
  // USER DETAILS
  // ============================================================

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _idController =
  TextEditingController();

  final TextEditingController _dobController =
  TextEditingController();

  // ============================================================
  // OTHER DETAILS
  // ============================================================

  final TextEditingController _extraController =
  TextEditingController();

  // ============================================================
  // MOTHER / GUARDIAN
  // ============================================================

  final TextEditingController _motherNameController =
  TextEditingController();

  final TextEditingController _motherSurnameController =
  TextEditingController();

  final TextEditingController _motherIdController =
  TextEditingController();

  final TextEditingController _motherDobController =
  TextEditingController();

  final TextEditingController _motherPhoneController =
  TextEditingController();

  // ============================================================
  // FATHER - OPTIONAL
  // ============================================================

  final TextEditingController _fatherNameController =
  TextEditingController();

  final TextEditingController _fatherSurnameController =
  TextEditingController();

  final TextEditingController _fatherIdController =
  TextEditingController();

  final TextEditingController _fatherDobController =
  TextEditingController();

  final TextEditingController _fatherPhoneController =
  TextEditingController();

  // ============================================================
  // PASSPORT
  // ============================================================

  final TextEditingController _prevPassportController =
  TextEditingController();

  final TextEditingController _birthPlaceController =
  TextEditingController();

  // ============================================================
  // COLLECTION
  // ============================================================

  String _deliveryMethod = 'Collection';

  final TextEditingController _addressController =
  TextEditingController();

  // ============================================================
  // PAYMENT
  // ============================================================

  bool _isPaid = false;

  String _paymentMethod = 'Visa / Mastercard';

  String _selectedBank = 'Capitec';

  final TextEditingController _cardholderController =
  TextEditingController();

  final TextEditingController _cardNumberController =
  TextEditingController();

  final TextEditingController _cardExpiryController =
  TextEditingController();

  final TextEditingController _cardSecurityCodeController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _dobController.dispose();

    _extraController.dispose();

    _motherNameController.dispose();
    _motherSurnameController.dispose();
    _motherIdController.dispose();
    _motherDobController.dispose();
    _motherPhoneController.dispose();

    _fatherNameController.dispose();
    _fatherSurnameController.dispose();
    _fatherIdController.dispose();
    _fatherDobController.dispose();
    _fatherPhoneController.dispose();

    _prevPassportController.dispose();
    _birthPlaceController.dispose();

    _addressController.dispose();

    _cardholderController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardSecurityCodeController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadInitialData() async {
    final profile =
    await _profileService.getProfile();

    final documents =
    await _documentService.getDocuments();

    if (!mounted) return;

    setState(() {
      _userDocuments = documents;

      _nameController.text =
          profile.name;

      _idController.text =
          profile.idNumber;

      _dobController.text =
          profile.dob;

      _isLoading = false;
    });
  }

  // ============================================================
  // APPLICATION TYPES
  // ============================================================

  List<String> _getApplicationTypes() {
    switch (widget.service.id) {
      case 'SRV001':
        return [
          'First-time ID',
          'Replacement / Re-issue ID',
        ];

      case 'SRV002':
        return [
          'Regular Passport - 32 Pages',
          'Maxi Passport - 48 Pages',
          'Replacement Passport',
        ];

      case 'SRV003':
        return [
          'Licence Renewal',
          'Replacement Licence',
        ];

      case 'SRV004':
        return [
          'First Birth Certificate',
          'Additional / Replacement Certificate',
        ];

      default:
        return [
          'New Application',
          'Replacement',
        ];
    }
  }

  IconData _getTypeIcon(String type) {
    final value = type.toLowerCase();

    if (value.contains('replacement') ||
        value.contains('re-issue')) {
      return Icons.find_replace_rounded;
    }

    if (value.contains('maxi')) {
      return Icons.menu_book_rounded;
    }

    if (value.contains('renewal')) {
      return Icons.autorenew_rounded;
    }

    return Icons.add_card_rounded;
  }

  // ============================================================
  // REQUIREMENTS
  // ============================================================

  List<String> _getRequirements() {
    final List<String> requirements = [
      'Your CivicID profile must contain your basic personal information.',
    ];

    for (final document
    in widget.service.requiredDocumentTypes) {
      requirements.add(document);
    }

    switch (widget.service.id) {
      case 'SRV001':
        if (_applicationType ==
            'First-time ID') {
          requirements.add(
            'Mother or guardian information is required. Father information is optional.',
          );
        } else {
          requirements.add(
            'Information relating to the previous or replaced ID may be required.',
          );
        }

        break;

      case 'SRV002':
        requirements.add(
          'Place of birth information is required in this prototype.',
        );

        if (_applicationType ==
            'Replacement Passport') {
          requirements.add(
            'Previous passport information should be provided when available.',
          );
        }

        break;

      case 'SRV003':
        requirements.add(
          'Licence information required for the selected application type should be available.',
        );

        break;

      case 'SRV004':
        requirements.add(
          'Birth registration information may be required for this application.',
        );

        break;
    }

    return requirements;
  }

  // ============================================================
  // FEES
  // ============================================================

  double? _getServiceFee() {
    switch (widget.service.id) {
      case 'SRV001':
        if (_applicationType ==
            'First-time ID') {
          return 0.00;
        }

        if (_applicationType ==
            'Replacement / Re-issue ID') {
          return 140.00;
        }

        return null;

      case 'SRV002':
        if (_applicationType ==
            'Regular Passport - 32 Pages') {
          return 600.00;
        }

        if (_applicationType ==
            'Maxi Passport - 48 Pages') {
          return 1200.00;
        }

        if (_applicationType ==
            'Replacement Passport') {
          return 600.00;
        }

        return null;

      case 'SRV003':
        return null;

      case 'SRV004':
        if (_applicationType ==
            'First Birth Certificate') {
          return 0.00;
        }

        return null;

      default:
        return null;
    }
  }

  String _getFeeDisplay() {
    final fee = _getServiceFee();

    if (fee != null) {
      if (fee == 0) {
        return 'FREE';
      }

      return 'R ${fee.toStringAsFixed(2)}';
    }

    return 'Fee to be confirmed';
  }

  String _feeForTypePreview(
      String type,
      ) {
    if (widget.service.id ==
        'SRV001') {
      if (type ==
          'First-time ID') {
        return 'Prototype fee: FREE';
      }

      return 'Prototype fee: R 140.00';
    }

    if (widget.service.id ==
        'SRV002') {
      if (type ==
          'Maxi Passport - 48 Pages') {
        return 'Prototype fee: R 1,200.00';
      }

      return 'Prototype fee: R 600.00';
    }

    if (widget.service.id ==
        'SRV003') {
      return 'Fee: To be confirmed';
    }

    if (widget.service.id ==
        'SRV004') {
      if (type ==
          'First Birth Certificate') {
        return 'Prototype fee: FREE';
      }

      return 'Fee: To be confirmed';
    }

    return 'Fee shown later';
  }

  bool _requiresInAppPayment() {
    final fee = _getServiceFee();

    return fee != null &&
        fee > 0;
  }

  bool _feeIsFree() {
    final fee = _getServiceFee();

    return fee != null &&
        fee == 0;
  }

  // ============================================================
  // DOCUMENTS
  // ============================================================

  Future<void> _refreshDocuments() async {
    final documents =
    await _documentService.getDocuments();

    if (!mounted) return;

    setState(() {
      _userDocuments =
          documents;
    });
  }

  bool _documentCanBeUsed(
      Document document,
      ) {
    final status =
    document.status.toLowerCase();

    return status == 'verified' ||
        status ==
            'pending verification' ||
        status == 'pending';
  }

  Document? _findProvidedDocument(
      String type,
      ) {
    try {
      return _userDocuments.firstWhere(
            (document) =>
        document.type ==
            type &&
            _documentCanBeUsed(
              document,
            ),
      );
    } catch (_) {
      return null;
    }
  }

  bool _hasRequiredDocuments() {
    for (final type
    in widget.service.requiredDocumentTypes) {
      final exists =
      _userDocuments.any(
            (document) =>
        document.type ==
            type &&
            _documentCanBeUsed(
              document,
            ),
      );

      if (!exists) {
        return false;
      }
    }

    return true;
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor:
        pageBackground,
        body: Center(
          child:
          CircularProgressIndicator(
            color:
            civicGreen,
          ),
        ),
      );
    }

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

        leading: IconButton(
          onPressed:
          _isCreatingApplication
              ? null
              : () {
            Navigator.pop(
              context,
            );
          },

          icon:
          const Icon(
            Icons.arrow_back_rounded,
            color:
            darkGreen,
          ),
        ),

        title:
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const Text(
              'Application Assistant',
              style:
              TextStyle(
                color:
                darkGreen,
                fontSize:
                17,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            Text(
              widget.service.name,
              style:
              const TextStyle(
                color:
                textGrey,
                fontSize:
                10,
              ),
            ),
          ],
        ),
      ),

      body:
      Column(
        children: [
          _buildProgress(),

          Expanded(
            child:
            SingleChildScrollView(
              padding:
              const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),

              child:
              Center(
                child:
                Container(
                  constraints:
                  const BoxConstraints(
                    maxWidth:
                    760,
                  ),

                  child:
                  _buildCurrentStep(),
                ),
              ),
            ),
          ),

          _buildNavigation(),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgress() {
    const labels = [
      'Type',
      'Requirements',
      'Profile',
      'Details',
      'Documents',
      'Collection',
      'Payment',
      'Review',
    ];

    return Container(
      width:
      double.infinity,

      color:
      Colors.white,

      padding:
      const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        15,
      ),

      child:
      SingleChildScrollView(
        scrollDirection:
        Axis.horizontal,

        child:
        Row(
          children:
          List.generate(
            labels.length,
                (index) {
              final active =
                  index <=
                      _currentStep;

              return Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width:
                        28,
                        height:
                        28,

                        alignment:
                        Alignment.center,

                        decoration:
                        BoxDecoration(
                          color: active
                              ? civicGreen
                              : const Color(
                            0xFFF0F3F1,
                          ),

                          shape:
                          BoxShape.circle,
                        ),

                        child: index <
                            _currentStep
                            ? const Icon(
                          Icons.check_rounded,
                          size:
                          15,
                          color:
                          Colors.white,
                        )
                            : Text(
                          '${index + 1}',
                          style:
                          TextStyle(
                            color: active
                                ? Colors.white
                                : textGrey,

                            fontSize:
                            10,

                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height:
                        5,
                      ),

                      Text(
                        labels[index],

                        style:
                        TextStyle(
                          color: active
                              ? darkGreen
                              : textGrey,

                          fontSize:
                          9,

                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  if (index <
                      labels.length - 1)
                    Container(
                      width:
                      28,

                      height:
                      2,

                      margin:
                      const EdgeInsets.only(
                        left:
                        5,
                        right:
                        5,
                        bottom:
                        17,
                      ),

                      color: index <
                          _currentStep
                          ? civicGreen
                          : borderColor,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildApplicationType();

      case 1:
        return _buildRequirements();

      case 2:
        return _buildPersonalInfo();

      case 3:
        return _buildApplicationDetails();

      case 4:
        return _buildDocuments();

      case 5:
        return _buildCollection();

      case 6:
        return _buildPayment();

      default:
        return _buildReview();
    }
  }

  // ============================================================
  // TYPE
  // ============================================================

  Widget _buildApplicationType() {
    final types =
    _getApplicationTypes();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _buildStepHeading(
          icon:
          Icons.description_outlined,

          title:
          'Choose Application Type',

          description:
          'Choose the ${widget.service.name} service you need.',
        ),

        const SizedBox(
          height:
          25,
        ),

        ...types.map(
              (type) {
            final selected =
                _applicationType ==
                    type;

            return Padding(
              padding:
              const EdgeInsets.only(
                bottom:
                12,
              ),

              child:
              InkWell(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),

                onTap:
                    () {
                  setState(() {
                    _applicationType =
                        type;

                    _isPaid =
                    false;
                  });
                },

                child:
                Container(
                  padding:
                  const EdgeInsets.all(
                    17,
                  ),

                  decoration:
                  BoxDecoration(
                    color: selected
                        ? lightGreen
                        : Colors.white,

                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),

                    border:
                    Border.all(
                      color: selected
                          ? civicGreen
                          : borderColor,

                      width: selected
                          ? 1.5
                          : 1,
                    ),
                  ),

                  child:
                  Row(
                    children: [
                      Container(
                        width:
                        45,
                        height:
                        45,

                        decoration:
                        BoxDecoration(
                          color: selected
                              ? Colors.white
                              : lightGreen,

                          borderRadius:
                          BorderRadius.circular(
                            13,
                          ),
                        ),

                        child:
                        Icon(
                          _getTypeIcon(
                            type,
                          ),

                          color:
                          civicGreen,
                        ),
                      ),

                      const SizedBox(
                        width:
                        15,
                      ),

                      Expanded(
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            Text(
                              type,

                              style:
                              const TextStyle(
                                color:
                                darkText,

                                fontSize:
                                14,

                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),

                            const SizedBox(
                              height:
                              4,
                            ),

                            Text(
                              _feeForTypePreview(
                                type,
                              ),

                              style:
                              const TextStyle(
                                color:
                                civicGreen,

                                fontSize:
                                11,

                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,

                        color: selected
                            ? civicGreen
                            : textGrey,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(
          height:
          10,
        ),

        _prototypeNotice(),
      ],
    );
  }

  // ============================================================
  // REQUIREMENTS
  // ============================================================

  Widget _buildRequirements() {
    final requirements =
    _getRequirements();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _buildStepHeading(
          icon:
          Icons.checklist_rounded,

          title:
          'Application Requirements',

          description:
          'Review what you need before continuing with this application.',
        ),

        const SizedBox(
          height:
          22,
        ),

        Container(
          width:
          double.infinity,

          padding:
          const EdgeInsets.all(
            17,
          ),

          decoration:
          BoxDecoration(
            color:
            lightGreen,

            borderRadius:
            BorderRadius.circular(
              18,
            ),
          ),

          child:
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color:
                civicGreen,
              ),

              const SizedBox(
                width:
                13,
              ),

              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'SELECTED APPLICATION',
                      style:
                      TextStyle(
                        color:
                        textGrey,

                        fontSize:
                        9,

                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height:
                      4,
                    ),

                    Text(
                      _applicationType ??
                          '',

                      style:
                      const TextStyle(
                        color:
                        darkGreen,

                        fontSize:
                        14,

                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height:
          24,
        ),

        ...requirements.map(
              (requirement) {
            return Container(
              width:
              double.infinity,

              margin:
              const EdgeInsets.only(
                bottom:
                11,
              ),

              padding:
              const EdgeInsets.all(
                15,
              ),

              decoration:
              BoxDecoration(
                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(
                  16,
                ),

                border:
                Border.all(
                  color:
                  borderColor,
                ),
              ),

              child:
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color:
                    civicGreen,
                  ),

                  const SizedBox(
                    width:
                    12,
                  ),

                  Expanded(
                    child:
                    Text(
                      requirement,

                      style:
                      const TextStyle(
                        color:
                        darkText,

                        fontSize:
                        12,

                        height:
                        1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(
          height:
          10,
        ),

        _prototypeNotice(),
      ],
    );
  }

  // ============================================================
  // PERSONAL INFO
  // ============================================================

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _buildStepHeading(
          icon:
          Icons.person_outline_rounded,

          title:
          'Personal Information',

          description:
          'Check the information that will be used for this application.',
        ),

        const SizedBox(
          height:
          25,
        ),

        _buildInfoField(
          'Full Name',
          _nameController.text,
          Icons.person_outline_rounded,
        ),

        const SizedBox(
          height:
          12,
        ),

        _buildInfoField(
          'ID Number',
          _idController.text,
          Icons.badge_outlined,
        ),

        const SizedBox(
          height:
          12,
        ),

        _buildInfoField(
          'Date of Birth',
          _dobController.text,
          Icons.calendar_month_outlined,
        ),
      ],
    );
  }

  Widget _buildInfoField(
      String label,
      String value,
      IconData icon,
      ) {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          17,
        ),

        border:
        Border.all(
          color:
          borderColor,
        ),
      ),

      child:
      Row(
        children: [
          Container(
            width:
            43,

            height:
            43,

            decoration:
            BoxDecoration(
              color:
              lightGreen,

              borderRadius:
              BorderRadius.circular(
                13,
              ),
            ),

            child:
            Icon(
              icon,
              color:
              civicGreen,
            ),
          ),

          const SizedBox(
            width:
            14,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  label,

                  style:
                  const TextStyle(
                    color:
                    textGrey,

                    fontSize:
                    10,
                  ),
                ),

                const SizedBox(
                  height:
                  3,
                ),

                Text(
                  value.isEmpty
                      ? 'Not provided'
                      : value,

                  style:
                  const TextStyle(
                    color:
                    darkText,

                    fontWeight:
                    FontWeight.w700,
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
  // APPLICATION DETAILS
  // ============================================================

  Widget _buildApplicationDetails() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _buildStepHeading(
          icon:
          Icons.edit_document,

          title:
          'Application Details',

          description:
          'Provide additional information required for your application.',
        ),

        const SizedBox(
          height:
          25,
        ),

        _selectedTypeBox(),

        const SizedBox(
          height:
          18,
        ),

        if (widget.service.id ==
            'SRV001') ...[
          _parentHeader(
            'Mother / Guardian Details',
            'Required information',
            Icons.woman_rounded,
            true,
          ),

          const SizedBox(
            height:
            18,
          ),

          _textField(
            controller:
            _motherNameController,

            label:
            "Mother's First Name *",

            icon:
            Icons.person_outline,
          ),

          const SizedBox(
            height:
            14,
          ),

          _textField(
            controller:
            _motherSurnameController,

            label:
            "Mother's Surname *",

            icon:
            Icons.person_outline,
          ),

          const SizedBox(
            height:
            14,
          ),

          _textField(
            controller:
            _motherIdController,

            label:
            "Mother's ID Number *",

            icon:
            Icons.badge_outlined,

            keyboardType:
            TextInputType.number,
          ),

          const SizedBox(
            height:
            14,
          ),

          _textField(
            controller:
            _motherDobController,

            label:
            "Mother's Date of Birth *",

            icon:
            Icons.calendar_month_outlined,

            hint:
            'YYYY-MM-DD',
          ),

          const SizedBox(
            height:
            14,
          ),

          _textField(
            controller:
            _motherPhoneController,

            label:
            "Mother's Phone Number *",

            icon:
            Icons.phone_outlined,

            keyboardType:
            TextInputType.phone,
          ),

          const SizedBox(
            height:
            28,
          ),

          _parentHeader(
            'Father Details',
            'Optional information',
            Icons.man_rounded,
            false,
          ),

          const SizedBox(
            height:
            18,
          ),

          _textField(
            controller:
            _fatherNameController,

            label:
            "Father's First Name (Optional)",

            icon:
            Icons.person_outline,
          ),

          const SizedBox(
            height:
            14,
          ),

          _textField(
            controller:
            _fatherSurnameController,

            label:
            "Father's Surname (Optional)",

            icon:
            Icons.person_outline,
          ),

          const SizedBox(
            height:
            14,
          ),

          _textField(
            controller:
            _fatherIdController,

            label:
            "Father's ID Number (Optional)",

            icon:
            Icons.badge_outlined,

            keyboardType:
            TextInputType.number,
          ),

          const SizedBox(
            height:
            14,
          ),

          _textField(
            controller:
            _fatherDobController,

            label:
            "Father's Date of Birth (Optional)",

            icon:
            Icons.calendar_month_outlined,

            hint:
            'YYYY-MM-DD',
          ),

          const SizedBox(
            height:
            14,
          ),

          _textField(
            controller:
            _fatherPhoneController,

            label:
            "Father's Phone Number (Optional)",

            icon:
            Icons.phone_outlined,

            keyboardType:
            TextInputType.phone,
          ),
        ],

        if (widget.service.id ==
            'SRV002') ...[
          if (_applicationType ==
              'Replacement Passport') ...[
            _textField(
              controller:
              _prevPassportController,

              label:
              'Previous Passport Number',

              icon:
              Icons.public_rounded,
            ),

            const SizedBox(
              height:
              14,
            ),
          ],

          _textField(
            controller:
            _birthPlaceController,

            label:
            'Place of Birth',

            icon:
            Icons.location_city_outlined,
          ),
        ],

        const SizedBox(
          height:
          14,
        ),

        _textField(
          controller:
          _extraController,

          label:
          'Additional Notes (Optional)',

          icon:
          Icons.notes_rounded,

          maxLines:
          3,
        ),
      ],
    );
  }

  Widget _parentHeader(
      String title,
      String subtitle,
      IconData icon,
      bool required,
      ) {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration:
      BoxDecoration(
        color: required
            ? lightGreen
            : Colors.white,

        borderRadius:
        BorderRadius.circular(
          16,
        ),

        border: required
            ? null
            : Border.all(
          color:
          borderColor,
        ),
      ),

      child:
      Row(
        children: [
          Icon(
            icon,
            color:
            civicGreen,
          ),

          const SizedBox(
            width:
            12,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style:
                  const TextStyle(
                    color:
                    darkGreen,

                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height:
                  3,
                ),

                Text(
                  subtitle,

                  style:
                  const TextStyle(
                    color:
                    textGrey,

                    fontSize:
                    10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedTypeBox() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration:
      BoxDecoration(
        color:
        lightGreen,

        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),

      child:
      Row(
        children: [
          const Icon(
            Icons.task_alt_rounded,
            color:
            civicGreen,
          ),

          const SizedBox(
            width:
            12,
          ),

          Expanded(
            child:
            Text(
              _applicationType ??
                  '',

              style:
              const TextStyle(
                color:
                darkGreen,

                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DOCUMENT SCREEN
  // ============================================================

  Widget _buildDocuments() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _buildStepHeading(
          icon:
          Icons.folder_copy_outlined,

          title:
          'Required Documents',

          description:
          'Upload the documents required for this application.',
        ),

        const SizedBox(
          height:
          20,
        ),

        ...widget.service
            .requiredDocumentTypes
            .map(
              (type) {
            return _buildDocumentTile(
              type,
              _findProvidedDocument(
                type,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDocumentTile(
      String type,
      Document? document,
      ) {
    final provided =
        document != null;

    return Container(
      margin:
      const EdgeInsets.only(
        bottom:
        13,
      ),

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          17,
        ),

        border:
        Border.all(
          color: provided
              ? civicGreen
              : borderColor,
        ),
      ),

      child:
      Row(
        children: [
          Icon(
            provided
                ? Icons.check_circle_rounded
                : Icons.upload_file_outlined,

            color:
            civicGreen,
          ),

          const SizedBox(
            width:
            13,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  type,

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                if (provided)
                  Text(
                    document.name,

                    style:
                    const TextStyle(
                      color:
                      textGrey,

                      fontSize:
                      10,
                    ),
                  ),
              ],
            ),
          ),

          if (!provided)
            TextButton(
              onPressed:
                  () {
                _showDocumentPicker(
                  type,
                );
              },

              child:
              const Text(
                'Upload',
              ),
            ),
        ],
      ),
    );
  }

  void _showDocumentPicker(
      String type,
      ) {
    showModalBottomSheet(
      context:
      context,

      showDragHandle:
      true,

      builder:
          (context) {
        return Padding(
          padding:
          const EdgeInsets.all(
            24,
          ),

          child:
          Row(
            children: [
              Expanded(
                child:
                ElevatedButton.icon(
                  onPressed:
                      () {
                    _handleImagePick(
                      ImageSource.gallery,
                      type,
                    );
                  },

                  icon:
                  const Icon(
                    Icons.photo,
                  ),

                  label:
                  const Text(
                    'Gallery',
                  ),
                ),
              ),

              const SizedBox(
                width:
                12,
              ),

              Expanded(
                child:
                ElevatedButton.icon(
                  onPressed:
                      () {
                    _handleFilePick(
                      type,
                    );
                  },

                  icon:
                  const Icon(
                    Icons.folder,
                  ),

                  label:
                  const Text(
                    'Files',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleImagePick(
      ImageSource source,
      String type,
      ) async {
    final result =
    await _picker.pickImage(
      source:
      source,

      imageQuality:
      90,
    );

    if (result ==
        null) {
      return;
    }

    final bytes =
    await result.readAsBytes();

    final fileName =
        result.name;

    await _documentService.addDocument(
      Document(
        id:
        DateTime.now()
            .microsecondsSinceEpoch
            .toString(),

        type:
        type,

        name:
        fileName,

        originalFileName:
        fileName,

        filePath:
        result.path,

        mimeType:
        _getMimeType(
          fileName,
        ),

        fileBytes:
        bytes,

        status:
        'Pending Verification',

        isRequired:
        true,
      ),
    );

    if (!mounted) return;

    Navigator.pop(
      context,
    );

    await _refreshDocuments();
  }

  Future<void> _handleFilePick(
      String type,
      ) async {
    final result =
    await FilePicker.platform
        .pickFiles(
      type:
      FileType.custom,

      allowedExtensions:
      const [
        'pdf',
        'jpg',
        'jpeg',
        'png',
      ],

      withData:
      true,

      allowMultiple:
      false,
    );

    if (result ==
        null ||
        result.files.isEmpty) {
      return;
    }

    final file =
        result.files.single;

    if (file.bytes ==
        null) {
      return;
    }

    await _documentService.addDocument(
      Document(
        id:
        DateTime.now()
            .microsecondsSinceEpoch
            .toString(),

        type:
        type,

        name:
        file.name,

        originalFileName:
        file.name,

        filePath:
        file.path,

        mimeType:
        _getMimeType(
          file.name,
        ),

        fileBytes:
        file.bytes,

        status:
        'Pending Verification',

        isRequired:
        true,
      ),
    );

    if (!mounted) return;

    Navigator.pop(
      context,
    );

    await _refreshDocuments();
  }

  String _getMimeType(
      String fileName,
      ) {
    final lower =
    fileName.toLowerCase();

    if (lower.endsWith(
      '.pdf',
    )) {
      return 'application/pdf';
    }

    if (lower.endsWith(
      '.png',
    )) {
      return 'image/png';
    }

    if (lower.endsWith(
      '.jpg',
    ) ||
        lower.endsWith(
          '.jpeg',
        )) {
      return 'image/jpeg';
    }

    return 'application/octet-stream';
  }

  // ============================================================
  // COLLECTION
  // ============================================================

  Widget _buildCollection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _buildStepHeading(
          icon:
          Icons.storefront_outlined,

          title:
          'Collection / Delivery',

          description:
          'Choose your preferred receiving method.',
        ),

        const SizedBox(
          height:
          25,
        ),

        _selectionCard(
          title:
          'Collection',

          subtitle:
          'Collect when ready.',

          icon:
          Icons.account_balance_outlined,

          selected:
          _deliveryMethod ==
              'Collection',

          onTap:
              () {
            setState(() {
              _deliveryMethod =
              'Collection';
            });
          },
        ),

        const SizedBox(
          height:
          12,
        ),

        _selectionCard(
          title:
          'Home Delivery',

          subtitle:
          'Provide your delivery address.',

          icon:
          Icons.local_shipping_outlined,

          selected:
          _deliveryMethod ==
              'Home Delivery',

          onTap:
              () {
            setState(() {
              _deliveryMethod =
              'Home Delivery';
            });
          },
        ),

        if (_deliveryMethod ==
            'Home Delivery') ...[
          const SizedBox(
            height:
            20,
          ),

          _textField(
            controller:
            _addressController,

            label:
            'Delivery Address',

            icon:
            Icons.location_on_outlined,

            maxLines:
            3,
          ),
        ],
      ],
    );
  }

  Widget _selectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap:
      onTap,

      child:
      Container(
        padding:
        const EdgeInsets.all(
          16,
        ),

        decoration:
        BoxDecoration(
          color: selected
              ? lightGreen
              : Colors.white,

          borderRadius:
          BorderRadius.circular(
            18,
          ),

          border:
          Border.all(
            color: selected
                ? civicGreen
                : borderColor,
          ),
        ),

        child:
        Row(
          children: [
            Icon(
              icon,
              color:
              civicGreen,
            ),

            const SizedBox(
              width:
              14,
            ),

            Expanded(
              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  Text(
                    subtitle,

                    style:
                    const TextStyle(
                      color:
                      textGrey,

                      fontSize:
                      10,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,

              color:
              civicGreen,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  Widget _buildPayment() {
    final fee =
    _getServiceFee();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _buildStepHeading(
          icon:
          Icons.payments_outlined,

          title:
          'Payment Method',

          description:
          'Choose how you want to pay the application fee.',
        ),

        const SizedBox(
          height:
          25,
        ),

        Container(
          width:
          double.infinity,

          padding:
          const EdgeInsets.all(
            24,
          ),

          decoration:
          BoxDecoration(
            gradient:
            const LinearGradient(
              colors: [
                darkGreen,
                civicGreen,
              ],
            ),

            borderRadius:
            BorderRadius.circular(
              22,
            ),
          ),

          child:
          Column(
            children: [
              const Text(
                'APPLICATION FEE',

                style:
                TextStyle(
                  color:
                  Colors.white70,

                  fontSize:
                  10,
                ),
              ),

              const SizedBox(
                height:
                9,
              ),

              Text(
                _getFeeDisplay(),

                style:
                const TextStyle(
                  color:
                  Colors.white,

                  fontSize:
                  32,

                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(
                height:
                7,
              ),

              Text(
                _applicationType ??
                    '',

                style:
                const TextStyle(
                  color:
                  Colors.white70,

                  fontSize:
                  10,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height:
          24,
        ),

        if (_feeIsFree())
          _freePaymentCard()
        else if (fee ==
            null)
          _unknownFeeCard()
        else ...[
            const Text(
              'Select Payment Method',

              style:
              TextStyle(
                fontSize:
                17,

                fontWeight:
                FontWeight.w900,
              ),
            ),

            const SizedBox(
              height:
              14,
            ),

            // ====================================================
            // VISA + MASTERCARD FIXED
            // ====================================================

            _paymentMethodTile(
              value:
              'Visa / Mastercard',

              title:
              'Visa / Mastercard',

              subtitle:
              'Debit or Credit Card',

              logo:
              SizedBox(
                width:
                68,

                height:
                34,

                child:
                Row(
                  children: [
                    Expanded(
                      child:
                      Image.asset(
                        'assets/images/payment_visa.png',

                        fit:
                        BoxFit.contain,
                      ),
                    ),

                    const SizedBox(
                      width:
                      5,
                    ),

                    Expanded(
                      child:
                      Image.asset(
                        'assets/images/payment_mastercard.png',

                        fit:
                        BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height:
              9,
            ),

            _paymentMethodTile(
              value:
              'EFT (Instant)',

              title:
              'EFT (Instant)',

              subtitle:
              'Choose your bank',

              logo:
              const Icon(
                Icons.account_balance_rounded,

                color:
                civicGreen,

                size:
                27,
              ),
            ),

            const SizedBox(
              height:
              9,
            ),

            // ====================================================
            // SNAPSCAN FIXED
            // ====================================================

            _paymentMethodTile(
              value:
              'SnapScan',

              title:
              'SnapScan',

              subtitle:
              'Pay using SnapScan',

              logo:
              Container(
                width:
                66,

                height:
                34,

                alignment:
                Alignment.center,

                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFF1683D8,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    7,
                  ),
                ),

                child:
                const Text(
                  'SnapScan',

                  style:
                  TextStyle(
                    color:
                    Colors.white,

                    fontSize:
                    9,

                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height:
              9,
            ),

            _paymentMethodTile(
              value:
              'PayFast',

              title:
              'PayFast',

              subtitle:
              'Secure online payment',

              logo:
              Image.asset(
                'assets/images/payment_payfast.png',

                fit:
                BoxFit.contain,
              ),
            ),

            const SizedBox(
              height:
              9,
            ),

            _paymentMethodTile(
              value:
              'Capitec Pay',

              title:
              'Capitec Pay',

              subtitle:
              'Pay through Capitec',

              logo:
              Image.asset(
                'assets/images/payment_capitec_pay.png',

                fit:
                BoxFit.contain,
              ),
            ),

            const SizedBox(
              height:
              9,
            ),

            _paymentMethodTile(
              value:
              'Zapper',

              title:
              'Zapper',

              subtitle:
              'Mobile payment',

              logo:
              Image.asset(
                'assets/images/payment_zapper.png',

                fit:
                BoxFit.contain,
              ),
            ),

            const SizedBox(
              height:
              22,
            ),

            if (!_isPaid) ...[
              _buildSelectedPaymentDetails(),

              const SizedBox(
                height:
                20,
              ),

              SizedBox(
                width:
                double.infinity,

                height:
                52,

                child:
                ElevatedButton.icon(
                  onPressed:
                  _confirmPrototypePayment,

                  icon:
                  const Icon(
                    Icons.lock_outline_rounded,
                  ),

                  label:
                  Text(
                    'Continue • ${_getFeeDisplay()}',
                  ),

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    civicGreen,

                    foregroundColor:
                    Colors.white,
                  ),
                ),
              ),
            ] else
              Container(
                padding:
                const EdgeInsets.all(
                  18,
                ),

                decoration:
                BoxDecoration(
                  color:
                  lightGreen,

                  borderRadius:
                  BorderRadius.circular(
                    17,
                  ),
                ),

                child:
                Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,

                      color:
                      civicGreen,
                    ),

                    const SizedBox(
                      width:
                      12,
                    ),

                    Text(
                      'Payment Confirmed • $_paymentMethod',

                      style:
                      const TextStyle(
                        color:
                        darkGreen,

                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
          ],
      ],
    );
  }

  Widget _freePaymentCard() {
    return Container(
      padding:
      const EdgeInsets.all(
        17,
      ),

      decoration:
      BoxDecoration(
        color:
        lightGreen,

        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),

      child:
      const Row(
        children: [
          Icon(
            Icons.check_circle,

            color:
            civicGreen,
          ),

          SizedBox(
            width:
            12,
          ),

          Text(
            'No payment is required.',
          ),
        ],
      ),
    );
  }

  Widget _unknownFeeCard() {
    return Container(
      padding:
      const EdgeInsets.all(
        17,
      ),

      color:
      const Color(
        0xFFFFF8E7,
      ),

      child:
      const Text(
        'No fixed fee is configured for this option.',
      ),
    );
  }

  // ============================================================
  // PAYMENT TILE
  // ============================================================

  Widget _paymentMethodTile({
    required String value,
    required String title,
    required String subtitle,
    required Widget logo,
  }) {
    final selected =
        _paymentMethod ==
            value;

    return InkWell(
      onTap: _isPaid
          ? null
          : () {
        setState(() {
          _paymentMethod =
              value;

          _isPaid =
          false;
        });
      },

      borderRadius:
      BorderRadius.circular(
        15,
      ),

      child:
      Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal:
          14,

          vertical:
          13,
        ),

        decoration:
        BoxDecoration(
          color: selected
              ? const Color(
            0xFFF4FBF6,
          )
              : Colors.white,

          borderRadius:
          BorderRadius.circular(
            15,
          ),

          border:
          Border.all(
            color: selected
                ? civicGreen
                : borderColor,

            width: selected
                ? 1.4
                : 1,
          ),
        ),

        child:
        Row(
          children: [
            Container(
              width:
              84,

              height:
              48,

              padding:
              const EdgeInsets.all(
                6,
              ),

              decoration:
              BoxDecoration(
                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(
                  11,
                ),

                border:
                Border.all(
                  color:
                  borderColor,
                ),
              ),

              child:
              Center(
                child:
                logo,
              ),
            ),

            const SizedBox(
              width:
              13,
            ),

            Expanded(
              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style:
                    const TextStyle(
                      color:
                      darkText,

                      fontSize:
                      13,

                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height:
                    2,
                  ),

                  Text(
                    subtitle,

                    style:
                    const TextStyle(
                      color:
                      textGrey,

                      fontSize:
                      10,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,

              color: selected
                  ? civicGreen
                  : const Color(
                0xFFAFBAB4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT DETAILS
  // ============================================================

  Widget _buildSelectedPaymentDetails() {
    switch (_paymentMethod) {
      case 'Visa / Mastercard':
        return _buildCardPaymentForm();

      case 'EFT (Instant)':
        return _buildInstantEftForm();

      case 'SnapScan':
        return _buildProviderPanel(
          title:
          'SnapScan',

          description:
          'Continue to complete the prototype payment using SnapScan.',

          logo:
          Container(
            width:
            68,

            height:
            38,

            alignment:
            Alignment.center,

            decoration:
            BoxDecoration(
              color:
              const Color(
                0xFF1683D8,
              ),

              borderRadius:
              BorderRadius.circular(
                8,
              ),
            ),

            child:
            const Text(
              'SnapScan',

              style:
              TextStyle(
                color:
                Colors.white,

                fontWeight:
                FontWeight.w900,

                fontSize:
                10,
              ),
            ),
          ),
        );

      case 'PayFast':
        return _buildProviderPanel(
          title:
          'PayFast',

          description:
          'Continue using PayFast.',

          logo:
          Image.asset(
            'assets/images/payment_payfast.png',
          ),
        );

      case 'Capitec Pay':
        return _buildProviderPanel(
          title:
          'Capitec Pay',

          description:
          'Continue using Capitec Pay.',

          logo:
          Image.asset(
            'assets/images/payment_capitec_pay.png',
          ),
        );

      case 'Zapper':
        return _buildProviderPanel(
          title:
          'Zapper',

          description:
          'Continue using Zapper.',

          logo:
          Image.asset(
            'assets/images/payment_zapper.png',
          ),
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildCardPaymentForm() {
    return Container(
      padding:
      const EdgeInsets.all(
        17,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        border:
        Border.all(
          color:
          borderColor,
        ),

        borderRadius:
        BorderRadius.circular(
          17,
        ),
      ),

      child:
      Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/payment_visa.png',

                width:
                45,
              ),

              const SizedBox(
                width:
                8,
              ),

              Image.asset(
                'assets/images/payment_mastercard.png',

                width:
                45,
              ),

              const SizedBox(
                width:
                10,
              ),

              const Text(
                'Card Details',

                style:
                TextStyle(
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
            16,
          ),

          TextField(
            controller:
            _cardholderController,

            decoration:
            _paymentInputDecoration(
              label:
              'Cardholder Name',

              hint:
              'Demo name',

              icon:
              Icons.person_outline,
            ),
          ),

          const SizedBox(
            height:
            12,
          ),

          TextField(
            controller:
            _cardNumberController,

            decoration:
            _paymentInputDecoration(
              label:
              'Card Number',

              hint:
              'Prototype only',

              icon:
              Icons.credit_card,
            ),
          ),

          const SizedBox(
            height:
            12,
          ),

          Row(
            children: [
              Expanded(
                child:
                TextField(
                  controller:
                  _cardExpiryController,

                  decoration:
                  _paymentInputDecoration(
                    label:
                    'Expiry',

                    hint:
                    'MM/YY',

                    icon:
                    Icons.calendar_month,
                  ),
                ),
              ),

              const SizedBox(
                width:
                12,
              ),

              Expanded(
                child:
                TextField(
                  controller:
                  _cardSecurityCodeController,

                  obscureText:
                  true,

                  decoration:
                  _paymentInputDecoration(
                    label:
                    'Security Code',

                    hint:
                    'Demo',

                    icon:
                    Icons.lock,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstantEftForm() {
    const banks = [
      'Capitec',
      'FNB',
      'Standard Bank',
      'Absa',
      'Nedbank',
      'African Bank',
      'Discovery Bank',
      'TymeBank',
    ];

    return Container(
      padding:
      const EdgeInsets.all(
        17,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          17,
        ),

        border:
        Border.all(
          color:
          borderColor,
        ),
      ),

      child:
      DropdownButtonFormField<String>(
        initialValue:
        _selectedBank,

        decoration:
        _paymentInputDecoration(
          label:
          'Bank',

          hint:
          'Choose Bank',

          icon:
          Icons.account_balance,
        ),

        items:
        banks.map(
              (bank) {
            return DropdownMenuItem(
              value:
              bank,

              child:
              Text(
                bank,
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

          setState(() {
            _selectedBank =
                value;
          });
        },
      ),
    );
  }

  Widget _buildProviderPanel({
    required String title,
    required String description,
    required Widget logo,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(
        18,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        border:
        Border.all(
          color:
          borderColor,
        ),

        borderRadius:
        BorderRadius.circular(
          17,
        ),
      ),

      child:
      Row(
        children: [
          SizedBox(
            width:
            80,

            height:
            50,

            child:
            Center(
              child:
              logo,
            ),
          ),

          const SizedBox(
            width:
            12,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                Text(
                  description,

                  style:
                  const TextStyle(
                    color:
                    textGrey,

                    fontSize:
                    10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _paymentInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText:
      label,

      hintText:
      hint,

      prefixIcon:
      Icon(
        icon,

        color:
        civicGreen,
      ),

      filled:
      true,

      fillColor:
      pageBackground,

      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          13,
        ),
      ),
    );
  }

  bool _paymentDetailsAreValid() {
    if (_paymentMethod !=
        'Visa / Mastercard') {
      return true;
    }

    return _cardholderController.text
        .trim()
        .isNotEmpty &&
        _cardNumberController.text
            .trim()
            .isNotEmpty &&
        _cardExpiryController.text
            .trim()
            .isNotEmpty &&
        _cardSecurityCodeController.text
            .trim()
            .isNotEmpty;
  }

  Future<void> _confirmPrototypePayment() async {
    final fee =
    _getServiceFee();

    if (fee ==
        null ||
        fee <= 0) {
      return;
    }

    if (!_paymentDetailsAreValid()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
          Text(
            'Complete the prototype payment details first.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isPaid =
      true;
    });

    await _notificationService
        .addNotification(
      'Payment Received',

      'Prototype application payment confirmed.',
    );
  }

  // ============================================================
  // REVIEW
  // ============================================================

  Widget _buildReview() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _buildStepHeading(
          icon:
          Icons.fact_check,

          title:
          'Review Application',

          description:
          'Check everything before the completeness check.',
        ),

        const SizedBox(
          height:
          25,
        ),

        _reviewSection(
          'SERVICE',
          [
            'Service: ${widget.service.name}',
            'Type: ${_applicationType ?? '-'}',
          ],
        ),

        const SizedBox(
          height:
          14,
        ),

        _reviewSection(
          'PERSONAL INFORMATION',
          [
            'Name: ${_nameController.text}',
            'ID Number: ${_idController.text}',
            'Date of Birth: ${_dobController.text}',
          ],
        ),

        if (widget.service.id ==
            'SRV001') ...[
          const SizedBox(
            height:
            14,
          ),

          _reviewSection(
            'MOTHER / GUARDIAN',
            [
              'Name: ${_motherNameController.text}',
              'Surname: ${_motherSurnameController.text}',
              'ID: ${_motherIdController.text}',
              'Date of Birth: ${_motherDobController.text}',
              'Phone: ${_motherPhoneController.text}',
            ],
          ),

          const SizedBox(
            height:
            14,
          ),

          _reviewSection(
            'FATHER - OPTIONAL',
            [
              'Name: ${_optionalValue(_fatherNameController.text)}',
              'Surname: ${_optionalValue(_fatherSurnameController.text)}',
              'ID: ${_optionalValue(_fatherIdController.text)}',
              'Date of Birth: ${_optionalValue(_fatherDobController.text)}',
              'Phone: ${_optionalValue(_fatherPhoneController.text)}',
            ],
          ),
        ],

        const SizedBox(
          height:
          14,
        ),

        _reviewSection(
          'PAYMENT',
          [
            'Fee: ${_getFeeDisplay()}',
            'Method: ${_requiresInAppPayment() ? _paymentMethod : "Not required"}',
            'Payment: ${_requiresInAppPayment() ? (_isPaid ? "Confirmed" : "Not confirmed") : "Not required"}',
          ],
        ),
      ],
    );
  }

  String _optionalValue(
      String value,
      ) {
    if (value.trim().isEmpty) {
      return 'Not provided';
    }

    return value.trim();
  }

  Widget _reviewSection(
      String title,
      List<String> items,
      ) {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        18,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border:
        Border.all(
          color:
          borderColor,
        ),
      ),

      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style:
            const TextStyle(
              color:
              civicGreen,

              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height:
            12,
          ),

          ...items.map(
                (item) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom:
                  7,
                ),

                child:
                Text(
                  item,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Widget _buildNavigation() {
    final canContinue =
    _canContinue();

    return Container(
      color:
      Colors.white,

      padding:
      const EdgeInsets.all(
        12,
      ),

      child:
      Row(
        children: [
          Expanded(
            child:
            OutlinedButton(
              onPressed:
                  () {
                if (_currentStep >
                    0) {
                  setState(() {
                    _currentStep--;
                  });
                } else {
                  Navigator.pop(
                    context,
                  );
                }
              },

              child:
              const Text(
                'Back',
              ),
            ),
          ),

          const SizedBox(
            width:
            12,
          ),

          Expanded(
            flex:
            2,

            child:
            ElevatedButton(
              onPressed: canContinue
                  ? _nextStep
                  : null,

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                civicGreen,

                foregroundColor:
                Colors.white,
              ),

              child:
              Text(
                _currentStep ==
                    7
                    ? 'Check Completeness'
                    : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _applicationType !=
            null;

      case 1:
        return true;

      case 2:
        return _nameController.text
            .trim()
            .isNotEmpty &&
            _idController.text
                .trim()
                .isNotEmpty;

      case 3:
        if (widget.service.id ==
            'SRV001') {
          return _motherNameController.text
              .trim()
              .isNotEmpty &&
              _motherSurnameController.text
                  .trim()
                  .isNotEmpty &&
              _motherIdController.text
                  .trim()
                  .isNotEmpty &&
              _motherDobController.text
                  .trim()
                  .isNotEmpty &&
              _motherPhoneController.text
                  .trim()
                  .isNotEmpty;
        }

        if (widget.service.id ==
            'SRV002') {
          return _birthPlaceController.text
              .trim()
              .isNotEmpty;
        }

        return true;

      case 4:
        return _hasRequiredDocuments();

      case 5:
        if (_deliveryMethod ==
            'Home Delivery') {
          return _addressController.text
              .trim()
              .isNotEmpty;
        }

        return true;

      case 6:
        if (_feeIsFree()) {
          return true;
        }

        if (_getServiceFee() ==
            null) {
          return true;
        }

        return _isPaid;

      default:
        return true;
    }
  }

  void _nextStep() {
    if (_currentStep <
        7) {
      setState(() {
        _currentStep++;
      });

      return;
    }

    _handleCompletenessCheck();
  }

  // ============================================================
  // CREATE APPLICATION
  // ============================================================

  Future<void> _handleCompletenessCheck() async {
    if (_isCreatingApplication) {
      return;
    }

    setState(() {
      _isCreatingApplication =
      true;
    });

    try {
      final fee =
      _getServiceFee();

      final appData =
      <String, dynamic>{
        'name':
        _nameController.text,

        'idNumber':
        _idController.text,

        'dob':
        _dobController.text,

        'applicationType':
        _applicationType,

        'deliveryMethod':
        _deliveryMethod,

        'address':
        _addressController.text,

        'paymentMethod':
        _requiresInAppPayment()
            ? _paymentMethod
            : 'Not applicable',

        'paymentConfirmed':
        _feeIsFree()
            ? true
            : _isPaid,

        'fee':
        fee,

        'feeDisplay':
        _getFeeDisplay(),

        if (widget.service.id ==
            'SRV001')
          'motherFirstName':
          _motherNameController.text.trim(),

        if (widget.service.id ==
            'SRV001')
          'motherSurname':
          _motherSurnameController.text.trim(),

        if (widget.service.id ==
            'SRV001')
          'motherIdNumber':
          _motherIdController.text.trim(),

        if (widget.service.id ==
            'SRV001')
          'motherDateOfBirth':
          _motherDobController.text.trim(),

        if (widget.service.id ==
            'SRV001')
          'motherPhoneNumber':
          _motherPhoneController.text.trim(),

        if (widget.service.id ==
            'SRV001')
          'fatherFirstName':
          _fatherNameController.text.trim(),

        if (widget.service.id ==
            'SRV001')
          'fatherSurname':
          _fatherSurnameController.text.trim(),

        if (widget.service.id ==
            'SRV001')
          'fatherIdNumber':
          _fatherIdController.text.trim(),

        if (widget.service.id ==
            'SRV001')
          'fatherDateOfBirth':
          _fatherDobController.text.trim(),

        if (widget.service.id ==
            'SRV001')
          'fatherPhoneNumber':
          _fatherPhoneController.text.trim(),

        if (widget.service.id ==
            'SRV002')
          'previousPassportNumber':
          _prevPassportController.text.trim(),

        if (widget.service.id ==
            'SRV002')
          'placeOfBirth':
          _birthPlaceController.text.trim(),
      };

      final application =
      await _applicationService
          .createApplication(
        widget.service.id,
        appData,
      );

      for (final requiredType
      in widget.service.requiredDocumentTypes) {
        final document =
        _findProvidedDocument(
          requiredType,
        );

        if (document !=
            null) {
          await _documentService
              .linkDocumentToApplication(
            document.id,
            application.id,
          );
        }
      }

      if (!mounted) return;

      Navigator.push(
        context,

        MaterialPageRoute(
          builder:
              (context) =>
              CompletenessCheckerScreen(
                application:
                application,

                service:
                widget.service,
              ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingApplication =
          false;
        });
      }
    }
  }

  // ============================================================
  // COMMON UI
  // ============================================================

  Widget _buildStepHeading({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Icon(
          icon,
          color:
          civicGreen,

          size:
          40,
        ),

        const SizedBox(
          height:
          15,
        ),

        Text(
          title,

          style:
          const TextStyle(
            color:
            darkText,

            fontSize:
            23,

            fontWeight:
            FontWeight.w900,
          ),
        ),

        const SizedBox(
          height:
          7,
        ),

        Text(
          description,

          style:
          const TextStyle(
            color:
            textGrey,

            fontSize:
            12,
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextFormField(
      controller:
      controller,

      maxLines:
      maxLines,

      keyboardType:
      keyboardType,

      onChanged:
          (_) {
        setState(() {});
      },

      decoration:
      InputDecoration(
        labelText:
        label,

        hintText:
        hint,

        prefixIcon:
        Icon(
          icon,
          color:
          civicGreen,
        ),

        filled:
        true,

        fillColor:
        Colors.white,

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            15,
          ),
        ),
      ),
    );
  }

  Widget _prototypeNotice() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        13,
      ),

      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFF3F6F4,
        ),

        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),

      child:
      const Text(
        'Academic Prototype — Not an official government service.',

        style:
        TextStyle(
          color:
          textGrey,

          fontSize:
          10,
        ),
      ),
    );
  }
}