import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';
import '../services/profile_service.dart';
import 'settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  static const Color darkText =
  Color(0xFF14251C);

  final ProfileService _profileService =
  ProfileService();

  UserProfile? _profile;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _idController =
  TextEditingController();

  final TextEditingController _dobController =
  TextEditingController();

  final TextEditingController _nationalityController =
  TextEditingController();

  final TextEditingController _genderController =
  TextEditingController();

  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final profile =
      await _profileService.getProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;

        _nameController.text =
            profile.name;

        _idController.text =
            profile.idNumber;

        _dobController.text =
            profile.dob;

        _nationalityController.text =
            profile.nationality;

        _genderController.text =
            profile.gender;

        _phoneController.text =
            profile.phone;

        _emailController.text =
            profile.email;

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load your profile.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile() async {
    if (_profile == null ||
        _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updated =
    _profile!.copyWith(
      name:
      _nameController.text.trim(),

      idNumber:
      _idController.text.trim(),

      dob:
      _dobController.text.trim(),

      nationality:
      _nationalityController.text.trim(),

      gender:
      _genderController.text.trim(),

      phone:
      _phoneController.text.trim(),

      email:
      _emailController.text.trim(),
    );

    try {
      await _profileService.updateProfile(
        updated,
      );

      if (!mounted) return;

      setState(() {
        _profile = updated;

        _isEditing = false;

        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          backgroundColor:
          civicGreen,
          content: Text(
            'Profile updated successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save profile changes.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CANCEL EDITING
  // ============================================================

  void _cancelEditing() {
    if (_profile == null) {
      return;
    }

    setState(() {
      _nameController.text =
          _profile!.name;

      _idController.text =
          _profile!.idNumber;

      _dobController.text =
          _profile!.dob;

      _nationalityController.text =
          _profile!.nationality;

      _genderController.text =
          _profile!.gender;

      _phoneController.text =
          _profile!.phone;

      _emailController.text =
          _profile!.email;

      _isEditing = false;
    });
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    DateTime initialDate =
    DateTime.now().subtract(
      const Duration(
        days: 365 * 18,
      ),
    );

    try {
      if (_dobController.text
          .trim()
          .isNotEmpty) {
        initialDate =
            DateTime.parse(
              _dobController.text.trim(),
            );
      }
    } catch (_) {}

    final picked =
    await showDatePicker(
      context: context,

      initialDate:
      initialDate,

      firstDate:
      DateTime(1900),

      lastDate:
      DateTime.now(),
    );

    if (picked != null &&
        mounted) {
      setState(() {
        _dobController.text =
            DateFormat(
              'yyyy-MM-dd',
            ).format(
              picked,
            );
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    if (_isLoading &&
        _profile == null) {
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

        centerTitle: true,

        title:
        const Column(
          children: [
            Text(
              'My Profile',
              style: TextStyle(
                color:
                darkGreen,
                fontSize:
                17,
                fontWeight:
                FontWeight.w900,
              ),
            ),

            Text(
              'CivicID Citizen Portal',
              style: TextStyle(
                color:
                textGrey,
                fontSize:
                10,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip:
            'Settings',

            icon:
            const Icon(
              Icons.settings_outlined,
              color:
              civicGreen,
            ),

            onPressed:
                () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder:
                      (_) =>
                  const SettingsScreen(),
                ),
              );
            },
          ),

          const SizedBox(
            width:
            6,
          ),
        ],
      ),

      body:
      RefreshIndicator(
        color:
        civicGreen,

        onRefresh:
        _loadProfile,

        child:
        ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            40,
          ),

          children: [
            Center(
              child:
              Container(
                constraints:
                const BoxConstraints(
                  maxWidth:
                  850,
                ),

                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    _buildProfileHeader(),

                    const SizedBox(
                      height:
                      20,
                    ),

                    _buildEditButton(),

                    const SizedBox(
                      height:
                      28,
                    ),

                    const Text(
                      'Personal Information',
                      style:
                      TextStyle(
                        color:
                        darkText,

                        fontSize:
                        18,

                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height:
                      5,
                    ),

                    const Text(
                      'Keep your profile information accurate before preparing applications.',
                      style:
                      TextStyle(
                        color:
                        textGrey,

                        fontSize:
                        10,

                        height:
                        1.5,
                      ),
                    ),

                    const SizedBox(
                      height:
                      15,
                    ),

                    _buildPersonalDetails(),

                    if (_isEditing) ...[
                      const SizedBox(
                        height:
                        18,
                      ),

                      SizedBox(
                        width:
                        double.infinity,

                        child:
                        FilledButton.icon(
                          onPressed:
                          _isSaving
                              ? null
                              : _saveProfile,

                          style:
                          FilledButton.styleFrom(
                            backgroundColor:
                            civicGreen,

                            padding:
                            const EdgeInsets.symmetric(
                              vertical:
                              15,
                            ),

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),

                          icon:
                          _isSaving
                              ? const SizedBox(
                            width:
                            17,
                            height:
                            17,
                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2,
                              color:
                              Colors.white,
                            ),
                          )
                              : const Icon(
                            Icons.save_outlined,
                          ),

                          label:
                          Text(
                            _isSaving
                                ? 'SAVING...'
                                : 'SAVE CHANGES',
                          ),
                        ),
                      ),

                      const SizedBox(
                        height:
                        9,
                      ),

                      SizedBox(
                        width:
                        double.infinity,

                        child:
                        OutlinedButton(
                          onPressed:
                          _isSaving
                              ? null
                              : _cancelEditing,

                          style:
                          OutlinedButton.styleFrom(
                            foregroundColor:
                            civicGreen,

                            side:
                            const BorderSide(
                              color:
                              civicGreen,
                            ),

                            padding:
                            const EdgeInsets.symmetric(
                              vertical:
                              14,
                            ),

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),

                          child:
                          const Text(
                            'CANCEL',
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(
                      height:
                      26,
                    ),

                    _buildPrototypeNotice(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    final profile =
        _profile;

    final verified =
        profile?.isVerified ==
            true;

    final id =
        profile?.idNumber ??
            '';

    final maskedId =
    id.length > 4
        ? '••••••••${id.substring(id.length - 4)}'
        : id.isEmpty
        ? 'Not provided'
        : id;

    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        22,
      ),

      decoration:
      BoxDecoration(
        gradient:
        const LinearGradient(
          colors: [
            darkGreen,
            civicGreen,
          ],

          begin:
          Alignment.topLeft,

          end:
          Alignment.bottomRight,
        ),

        borderRadius:
        BorderRadius.circular(
          24,
        ),
      ),

      child:
      LayoutBuilder(
        builder:
            (
            context,
            constraints,
            ) {
          final narrow =
              constraints.maxWidth <
                  550;

          final info =
          Column(
            crossAxisAlignment:
            narrow
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,

            children: [
              const CircleAvatar(
                radius:
                40,

                backgroundColor:
                Colors.white24,

                child:
                Icon(
                  Icons.person_rounded,

                  size:
                  42,

                  color:
                  Colors.white,
                ),
              ),

              const SizedBox(
                height:
                14,
              ),

              Text(
                profile?.name.isNotEmpty ==
                    true
                    ? profile!.name
                    : 'CivicID Citizen',

                textAlign:
                narrow
                    ? TextAlign.center
                    : TextAlign.left,

                style:
                const TextStyle(
                  color:
                  Colors.white,

                  fontSize:
                  21,

                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(
                height:
                6,
              ),

              Row(
                mainAxisSize:
                MainAxisSize.min,

                children: [
                  Icon(
                    verified
                        ? Icons.verified_outlined
                        : Icons.pending_actions_outlined,

                    color:
                    Colors.white,

                    size:
                    15,
                  ),

                  const SizedBox(
                    width:
                    5,
                  ),

                  Text(
                    verified
                        ? 'PROFILE VERIFIED'
                        : 'PENDING VERIFICATION',

                    style:
                    const TextStyle(
                      color:
                      Colors.white,

                      fontSize:
                      9,

                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                13,
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal:
                  12,

                  vertical:
                  7,
                ),

                decoration:
                BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha:
                    0.13,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child:
                Text(
                  'ID $maskedId',

                  style:
                  const TextStyle(
                    color:
                    Colors.white,

                    fontSize:
                    10,

                    fontWeight:
                    FontWeight.w700,

                    letterSpacing:
                    0.7,
                  ),
                ),
              ),
            ],
          );

          if (narrow) {
            return Center(
              child:
              info,
            );
          }

          return Row(
            children: [
              Expanded(
                child:
                info,
              ),

              const SizedBox(
                width:
                20,
              ),

              Container(
                width:
                92,

                height:
                92,

                decoration:
                BoxDecoration(
                  color:
                  Colors.white.withValues(
                    alpha:
                    0.11,
                  ),

                  shape:
                  BoxShape.circle,
                ),

                child:
                const Icon(
                  Icons.person_outline_rounded,

                  color:
                  Colors.white,

                  size:
                  43,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // EDIT BUTTON
  // ============================================================

  Widget _buildEditButton() {
    return SizedBox(
      width:
      double.infinity,

      child:
      Material(
        color:
        Colors.transparent,

        child:
        InkWell(
          onTap:
          _isEditing
              ? _cancelEditing
              : () {
            setState(() {
              _isEditing =
              true;
            });
          },

          borderRadius:
          BorderRadius.circular(
            16,
          ),

          child:
          Ink(
            padding:
            const EdgeInsets.symmetric(
              vertical:
              17,

              horizontal:
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
              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [
                Icon(
                  _isEditing
                      ? Icons.close_rounded
                      : Icons.edit_outlined,

                  color:
                  civicGreen,

                  size:
                  21,
                ),

                const SizedBox(
                  width:
                  8,
                ),

                Text(
                  _isEditing
                      ? 'Cancel Edit'
                      : 'Edit Profile',

                  style:
                  const TextStyle(
                    color:
                    darkGreen,

                    fontSize:
                    11,

                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PERSONAL DETAILS
  // ============================================================

  Widget _buildPersonalDetails() {
    return Container(
      width:
      double.infinity,

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
          19,
        ),

        border:
        Border.all(
          color:
          borderColor,
        ),
      ),

      child:
      Column(
        children: [
          _detailField(
            Icons.person_outline_rounded,
            'Full Name',
            _nameController,
          ),

          _detailField(
            Icons.badge_outlined,
            'ID Number',
            _idController,
          ),

          _detailField(
            Icons.calendar_today_outlined,
            'Date of Birth',
            _dobController,
            isDate:
            true,
          ),

          _detailField(
            Icons.public_rounded,
            'Nationality',
            _nationalityController,
          ),

          _detailField(
            Icons.person_search_outlined,
            'Gender',
            _genderController,
          ),

          _detailField(
            Icons.phone_outlined,
            'Phone',
            _phoneController,
          ),

          _detailField(
            Icons.email_outlined,
            'Email',
            _emailController,
            isLast:
            true,
          ),
        ],
      ),
    );
  }

  Widget _detailField(
      IconData icon,
      String label,
      TextEditingController controller, {
        bool isDate = false,
        bool isLast = false,
      }) {
    return Padding(
      padding:
      EdgeInsets.only(
        bottom:
        isLast
            ? 0
            : 17,
      ),

      child:
      Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Container(
            width:
            40,

            height:
            40,

            decoration:
            BoxDecoration(
              color:
              lightGreen,

              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child:
            Icon(
              icon,

              color:
              civicGreen,

              size:
              19,
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
                  label,

                  style:
                  const TextStyle(
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

                if (_isEditing)
                  isDate
                      ? InkWell(
                    onTap:
                    _selectDate,

                    child:
                    IgnorePointer(
                      child:
                      TextField(
                        controller:
                        controller,

                        decoration:
                        _fieldDecoration(),

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
                    ),
                  )
                      : TextField(
                    controller:
                    controller,

                    decoration:
                    _fieldDecoration(),

                    style:
                    const TextStyle(
                      color:
                      darkText,

                      fontSize:
                      13,

                      fontWeight:
                      FontWeight.w800,
                    ),
                  )
                else
                  Text(
                    controller.text
                        .trim()
                        .isEmpty
                        ? 'Not provided'
                        : controller.text,

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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD DECORATION
  // ============================================================

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      isDense:
      true,

      filled:
      true,

      fillColor:
      pageBackground,

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal:
        11,

        vertical:
        10,
      ),

      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          11,
        ),

        borderSide:
        const BorderSide(
          color:
          borderColor,
        ),
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          11,
        ),

        borderSide:
        const BorderSide(
          color:
          borderColor,
        ),
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          11,
        ),

        borderSide:
        const BorderSide(
          color:
          civicGreen,
        ),
      ),
    );
  }

  // ============================================================
  // PROTOTYPE NOTICE
  // ============================================================

  Widget _buildPrototypeNotice() {
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
            Icons.school_outlined,

            color:
            textGrey,

            size:
            18,
          ),

          SizedBox(
            width:
            9,
          ),

          Expanded(
            child:
            Text(
              'Academic Prototype — CivicID is not an official government service.',
              style:
              TextStyle(
                color:
                textGrey,

                fontSize:
                10,

                height:
                1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}