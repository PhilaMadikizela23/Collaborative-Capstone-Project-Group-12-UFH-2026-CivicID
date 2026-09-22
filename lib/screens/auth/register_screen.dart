import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
import 'selfie_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _surnameController =
  TextEditingController();

  final TextEditingController _idController =
  TextEditingController();

  final TextEditingController _dobController =
  TextEditingController();

  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  final AuthService _authService =
  AuthService();

  String? _selectedGender;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

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

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _idController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE OF BIRTH
  // ============================================================

  Future<void> _selectDateOfBirth() async {
    DateTime initialDate = DateTime(
      DateTime.now().year - 18,
      DateTime.now().month,
      DateTime.now().day,
    );

    if (_dobController.text.trim().isNotEmpty) {
      try {
        initialDate = DateFormat(
          'yyyy-MM-dd',
        ).parse(
          _dobController.text.trim(),
        );
      } catch (_) {}
    }

    final DateTime? selectedDate =
    await showDatePicker(
      context: context,

      initialDate: initialDate,

      firstDate: DateTime(
        1900,
        1,
        1,
      ),

      lastDate: DateTime.now(),

      helpText:
      'SELECT DATE OF BIRTH',

      cancelText:
      'CANCEL',

      confirmText:
      'SELECT',

      builder: (
          context,
          child,
          ) {
        return Theme(
          data:
          Theme.of(context).copyWith(
            colorScheme:
            const ColorScheme.light(
              primary:
              civicGreen,

              onPrimary:
              Colors.white,

              surface:
              Colors.white,

              onSurface:
              darkText,
            ),
          ),

          child:
          child!,
        );
      },
    );

    if (selectedDate == null ||
        !mounted) {
      return;
    }

    setState(() {
      _dobController.text =
          DateFormat(
            'yyyy-MM-dd',
          ).format(
            selectedDate,
          );
    });
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.register(
        name:
        _nameController.text.trim(),

        surname:
        _surnameController.text.trim(),

        idNumber:
        _idController.text.trim(),

        dob:
        _dobController.text.trim(),

        phone:
        _phoneController.text.trim(),

        gender:
        _selectedGender ?? '',

        email:
        _emailController.text.trim(),

        password:
        _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const SelfieVerificationScreen(),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to create your account. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      pageBackground,

      body: SafeArea(
        child:
        SingleChildScrollView(
          child:
          Center(
            child:
            Container(
              width:
              double.infinity,

              constraints:
              const BoxConstraints(
                maxWidth:
                650,
              ),

              padding:
              const EdgeInsets.symmetric(
                horizontal:
                24,

                vertical:
                25,
              ),

              child:
              Form(
                key:
                _formKey,

                child:
                Column(
                  children: [
                    // BACK
                    Align(
                      alignment:
                      Alignment.centerLeft,

                      child:
                      IconButton(
                        onPressed:
                            () {
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
                    ),

                    const SizedBox(
                      height:
                      5,
                    ),

                    // LOGO
                    Container(
                      width:
                      72,

                      height:
                      72,

                      decoration:
                      BoxDecoration(
                        color:
                        lightGreen,

                        borderRadius:
                        BorderRadius.circular(
                          22,
                        ),
                      ),

                      child:
                      const Icon(
                        Icons.account_balance_rounded,

                        color:
                        civicGreen,

                        size:
                        42,
                      ),
                    ),

                    const SizedBox(
                      height:
                      15,
                    ),

                    const Text(
                      'CivicID',

                      style:
                      TextStyle(
                        color:
                        darkGreen,

                        fontSize:
                        32,

                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height:
                      24,
                    ),

                    const Text(
                      'Create your account',

                      textAlign:
                      TextAlign.center,

                      style:
                      TextStyle(
                        color:
                        darkText,

                        fontSize:
                        26,

                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height:
                      7,
                    ),

                    const Text(
                      'Create your secure digital citizen profile',

                      textAlign:
                      TextAlign.center,

                      style:
                      TextStyle(
                        color:
                        textGrey,

                        fontSize:
                        14,
                      ),
                    ),

                    const SizedBox(
                      height:
                      28,
                    ),

                    Container(
                      padding:
                      const EdgeInsets.all(
                        24,
                      ),

                      decoration:
                      BoxDecoration(
                        color:
                        Colors.white,

                        borderRadius:
                        BorderRadius.circular(
                          24,
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
                          // FIRST NAME
                          _buildField(
                            controller:
                            _nameController,

                            label:
                            'First Name',

                            icon:
                            Icons.person_outline_rounded,

                            validator:
                                (value) {
                              if (value ==
                                  null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Please enter your first name';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height:
                            16,
                          ),

                          // SURNAME
                          _buildField(
                            controller:
                            _surnameController,

                            label:
                            'Surname',

                            icon:
                            Icons.person_outline_rounded,

                            validator:
                                (value) {
                              if (value ==
                                  null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Please enter your surname';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height:
                            16,
                          ),

                          // ID NUMBER
                          _buildField(
                            controller:
                            _idController,

                            label:
                            'South African ID Number',

                            icon:
                            Icons.badge_outlined,

                            keyboardType:
                            TextInputType.number,

                            maxLength:
                            13,

                            validator:
                                (value) {
                              final clean =
                                  value?.trim() ??
                                      '';

                              if (!RegExp(
                                r'^\d{13}$',
                              ).hasMatch(
                                clean,
                              )) {
                                return 'Enter a valid 13-digit ID number';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height:
                            16,
                          ),

                          // DATE OF BIRTH
                          TextFormField(
                            controller:
                            _dobController,

                            readOnly:
                            true,

                            onTap:
                            _selectDateOfBirth,

                            validator:
                                (value) {
                              if (value ==
                                  null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Please select your date of birth';
                              }

                              return null;
                            },

                            decoration:
                            _inputDecoration(
                              label:
                              'Date of Birth',

                              icon:
                              Icons.calendar_month_outlined,
                            ).copyWith(
                              hintText:
                              'Select date',

                              suffixIcon:
                              IconButton(
                                onPressed:
                                _selectDateOfBirth,

                                icon:
                                const Icon(
                                  Icons.calendar_today_rounded,

                                  color:
                                  civicGreen,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height:
                            16,
                          ),

                          // ==================================================
                          // PHONE NUMBER
                          // ==================================================

                          _buildField(
                            controller:
                            _phoneController,

                            label:
                            'Phone Number',

                            icon:
                            Icons.phone_outlined,

                            keyboardType:
                            TextInputType.phone,

                            validator:
                                (value) {
                              final phone =
                                  value?.trim() ??
                                      '';

                              if (phone.isEmpty) {
                                return 'Please enter your phone number';
                              }

                              if (phone.length <
                                  9) {
                                return 'Enter a valid phone number';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height:
                            16,
                          ),

                          // ==================================================
                          // GENDER
                          // ==================================================

                          DropdownButtonFormField<String>(
                            initialValue:
                            _selectedGender,

                            decoration:
                            _inputDecoration(
                              label:
                              'Gender',

                              icon:
                              Icons.people_outline_rounded,
                            ),

                            hint:
                            const Text(
                              'Select your gender',
                            ),

                            items:
                            const [
                              DropdownMenuItem(
                                value:
                                'Male',

                                child:
                                Text(
                                  'Male',
                                ),
                              ),

                              DropdownMenuItem(
                                value:
                                'Female',

                                child:
                                Text(
                                  'Female',
                                ),
                              ),

                              DropdownMenuItem(
                                value:
                                'Other',

                                child:
                                Text(
                                  'Other',
                                ),
                              ),

                              DropdownMenuItem(
                                value:
                                'Prefer not to say',

                                child:
                                Text(
                                  'Prefer not to say',
                                ),
                              ),
                            ],

                            onChanged:
                                (value) {
                              setState(() {
                                _selectedGender =
                                    value;
                              });
                            },

                            validator:
                                (value) {
                              if (value ==
                                  null) {
                                return 'Please select your gender';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height:
                            16,
                          ),

                          // EMAIL
                          _buildField(
                            controller:
                            _emailController,

                            label:
                            'Email Address',

                            icon:
                            Icons.email_outlined,

                            keyboardType:
                            TextInputType.emailAddress,

                            validator:
                                (value) {
                              final clean =
                                  value?.trim() ??
                                      '';

                              if (clean.isEmpty ||
                                  !clean.contains(
                                    '@',
                                  )) {
                                return 'Enter a valid email address';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height:
                            16,
                          ),

                          // PASSWORD
                          TextFormField(
                            controller:
                            _passwordController,

                            obscureText:
                            !_isPasswordVisible,

                            validator:
                                (value) {
                              if (value ==
                                  null ||
                                  value.length <
                                      6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },

                            decoration:
                            _inputDecoration(
                              label:
                              'Password',

                              icon:
                              Icons.lock_outline_rounded,
                            ).copyWith(
                              suffixIcon:
                              IconButton(
                                onPressed:
                                    () {
                                  setState(() {
                                    _isPasswordVisible =
                                    !_isPasswordVisible;
                                  });
                                },

                                icon:
                                Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,

                                  color:
                                  textGrey,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height:
                            16,
                          ),

                          // CONFIRM PASSWORD
                          TextFormField(
                            controller:
                            _confirmPasswordController,

                            obscureText:
                            !_isConfirmPasswordVisible,

                            validator:
                                (value) {
                              if (value !=
                                  _passwordController.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },

                            decoration:
                            _inputDecoration(
                              label:
                              'Confirm Password',

                              icon:
                              Icons.lock_reset_rounded,
                            ).copyWith(
                              suffixIcon:
                              IconButton(
                                onPressed:
                                    () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                                  });
                                },

                                icon:
                                Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,

                                  color:
                                  textGrey,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height:
                            24,
                          ),

                          // REGISTER BUTTON
                          SizedBox(
                            width:
                            double.infinity,

                            height:
                            56,

                            child:
                            ElevatedButton(
                              onPressed:
                              _isLoading
                                  ? null
                                  : _handleRegister,

                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                civicGreen,

                                foregroundColor:
                                Colors.white,

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    16,
                                  ),
                                ),
                              ),

                              child:
                              _isLoading
                                  ? const SizedBox(
                                width:
                                22,

                                height:
                                22,

                                child:
                                CircularProgressIndicator(
                                  strokeWidth:
                                  2,

                                  color:
                                  Colors.white,
                                ),
                              )
                                  : const Text(
                                'Create Account',

                                style:
                                TextStyle(
                                  fontSize:
                                  16,

                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height:
                      20,
                    ),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [
                        const Text(
                          'Already have an account? ',

                          style:
                          TextStyle(
                            color:
                            textGrey,
                          ),
                        ),

                        TextButton(
                          onPressed:
                              () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            );
                          },

                          child:
                          const Text(
                            'Sign In',

                            style:
                            TextStyle(
                              color:
                              civicGreen,

                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height:
                      15,
                    ),

                    const Text(
                      'ACADEMIC PROTOTYPE • NOT AN OFFICIAL GOVERNMENT SERVICE',

                      textAlign:
                      TextAlign.center,

                      style:
                      TextStyle(
                        color:
                        Color(
                          0xFF8A9690,
                        ),

                        fontSize:
                        11,

                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NORMAL FIELD
  // ============================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return TextFormField(
      controller:
      controller,

      keyboardType:
      keyboardType,

      maxLength:
      maxLength,

      validator:
      validator,

      decoration:
      _inputDecoration(
        label:
        label,

        icon:
        icon,
      ).copyWith(
        counterText:
        '',
      ),
    );
  }

  // ============================================================
  // DESIGN
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText:
      label,

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
          14,
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
          14,
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
          14,
        ),

        borderSide:
        const BorderSide(
          color:
          civicGreen,

          width:
          1.7,
        ),
      ),

      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          14,
        ),

        borderSide:
        const BorderSide(
          color:
          Colors.redAccent,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          14,
        ),

        borderSide:
        const BorderSide(
          color:
          Colors.redAccent,
        ),
      ),
    );
  }
}