import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool initialIsLogin;

  const AuthScreen({
    super.key,
    this.initialIsLogin = true,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);

  late bool _isLogin;

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final AuthService _authService =
  AuthService();

  final NotificationService _notificationService =
  NotificationService();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _surnameController =
  TextEditingController();

  final TextEditingController _idController =
  TextEditingController();

  final TextEditingController _dobController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = true;

  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();

    _isLogin =
        widget.initialIsLogin;

    _checkNotifications();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _idController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<void> _checkNotifications() async {
    final count =
    await _notificationService.getUnreadCount();

    if (!mounted) {
      return;
    }

    setState(() {
      _unreadNotifications =
          count;
    });
  }

  // ============================================================
  // DATE OF BIRTH
  // ============================================================

  Future<void> _selectDateOfBirth() async {
    DateTime initialDate =
    DateTime(
      DateTime.now().year - 18,
      DateTime.now().month,
      DateTime.now().day,
    );

    if (_dobController.text
        .trim()
        .isNotEmpty) {
      try {
        initialDate =
            DateFormat(
              'yyyy-MM-dd',
            ).parse(
              _dobController.text.trim(),
            );
      } catch (_) {}
    }

    final DateTime? picked =
    await showDatePicker(
      context: context,

      initialDate:
      initialDate,

      firstDate:
      DateTime(
        1900,
        1,
        1,
      ),

      lastDate:
      DateTime.now(),

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
              Color(
                0xFF14251C,
              ),
            ),
          ),

          child:
          child!,
        );
      },
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
  // LOGIN / REGISTER
  // ============================================================

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ========================================================
      // LOGIN
      // ========================================================

      if (_isLogin) {
        final email =
        _emailController.text.trim();

        final success =
        await _authService.login(
          email,
          _passwordController.text,
        );

        if (!mounted) {
          return;
        }

        if (success) {
          if (_authService.isAdmin(
            email,
          )) {
            Navigator.pushReplacementNamed(
              context,
              '/admin_home',
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              '/home',
            );
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Invalid credentials',
              ),
            ),
          );
        }
      }

      // ========================================================
      // REGISTER
      // ========================================================

      else {
        await _authService.register(
          name:
          _nameController.text.trim(),

          surname:
          _surnameController.text.trim(),

          idNumber:
          _idController.text.trim(),

          // IMPORTANT:
          // This sends the selected DOB to AuthService.
          dob:
          _dobController.text.trim(),

          email:
          _emailController.text.trim(),

          password:
          _passwordController.text,
        );

        if (!mounted) {
          return;
        }

        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin
                ? 'Unable to sign in. Please try again.'
                : 'Unable to create your account. Please try again.',
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

  // ============================================================
  // SWITCH LOGIN / REGISTER
  // ============================================================

  void _switchMode(
      bool loginMode,
      ) {
    setState(() {
      _isLogin =
          loginMode;

      _formKey.currentState
          ?.reset();
    });
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

      body: SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            35,
          ),

          child: Center(
            child: Container(
              constraints:
              const BoxConstraints(
                maxWidth:
                470,
              ),

              child: Form(
                key:
                _formKey,

                child: Column(
                  children: [
                    _buildTopBar(
                      context,
                    ),

                    const SizedBox(
                      height:
                      10,
                    ),

                    _buildLogo(),

                    const SizedBox(
                      height:
                      16,
                    ),

                    Text(
                      _isLogin
                          ? 'Welcome Back'
                          : 'Create Your Account',

                      textAlign:
                      TextAlign.center,

                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF14251C,
                        ),

                        fontSize:
                        27,

                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height:
                      5,
                    ),

                    Text(
                      _isLogin
                          ? 'Sign in to your CivicID account'
                          : 'Join CivicID today',

                      textAlign:
                      TextAlign.center,

                      style:
                      const TextStyle(
                        color:
                        textGrey,

                        fontSize:
                        11,
                      ),
                    ),

                    const SizedBox(
                      height:
                      24,
                    ),

                    _buildModeToggle(),

                    const SizedBox(
                      height:
                      24,
                    ),

                    // ==================================================
                    // REGISTER FIELDS
                    // ==================================================

                    if (!_isLogin) ...[
                      _buildTextField(
                        controller:
                        _nameController,

                        label:
                        'Name',

                        icon:
                        Icons.person_outline_rounded,

                        validator:
                            (value) {
                          if (value ==
                              null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'Name is required';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height:
                        13,
                      ),

                      _buildTextField(
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
                            return 'Surname is required';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height:
                        13,
                      ),

                      _buildTextField(
                        controller:
                        _idController,

                        label:
                        'ID Number',

                        icon:
                        Icons.badge_outlined,

                        keyboardType:
                        TextInputType.number,

                        validator:
                            (value) {
                          final clean =
                              value?.trim() ??
                                  '';

                          if (clean.length !=
                              13) {
                            return 'Enter a 13-digit ID number';
                          }

                          if (!RegExp(
                            r'^\d{13}$',
                          ).hasMatch(
                            clean,
                          )) {
                            return 'ID number must contain numbers only';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height:
                        13,
                      ),

                      // ================================================
                      // DATE OF BIRTH FIELD
                      // ================================================

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
                            return 'Date of birth is required';
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
                          'Select your date of birth',

                          suffixIcon:
                          IconButton(
                            tooltip:
                            'Choose date',

                            onPressed:
                            _selectDateOfBirth,

                            icon:
                            const Icon(
                              Icons.calendar_today_rounded,

                              color:
                              civicGreen,

                              size:
                              20,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height:
                        13,
                      ),
                    ],

                    // ==================================================
                    // EMAIL
                    // ==================================================

                    _buildTextField(
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
                      13,
                    ),

                    // ==================================================
                    // PASSWORD
                    // ==================================================

                    _buildPasswordField(),

                    // ==================================================
                    // CONFIRM PASSWORD
                    // ==================================================

                    if (!_isLogin) ...[
                      const SizedBox(
                        height:
                        13,
                      ),

                      _buildConfirmPasswordField(),
                    ],

                    // ==================================================
                    // REMEMBER + FORGOT
                    // ==================================================

                    if (_isLogin) ...[
                      const SizedBox(
                        height:
                        8,
                      ),

                      _buildRememberForgotRow(
                        context,
                      ),
                    ],

                    const SizedBox(
                      height:
                      20,
                    ),

                    // ==================================================
                    // MAIN BUTTON
                    // ==================================================

                    SizedBox(
                      width:
                      double.infinity,

                      height:
                      52,

                      child:
                      FilledButton(
                        onPressed:
                        _isLoading
                            ? null
                            : _handleSubmit,

                        style:
                        FilledButton.styleFrom(
                          backgroundColor:
                          civicGreen,

                          disabledBackgroundColor:
                          civicGreen.withValues(
                            alpha:
                            0.45,
                          ),

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              13,
                            ),
                          ),
                        ),

                        child:
                        _isLoading
                            ? const SizedBox(
                          width:
                          20,

                          height:
                          20,

                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2,

                            color:
                            Colors.white,
                          ),
                        )
                            : Text(
                          _isLogin
                              ? 'Sign In'
                              : 'Register',

                          style:
                          const TextStyle(
                            color:
                            Colors.white,

                            fontSize:
                            14,

                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    // ==================================================
                    // LOGIN EXTRA OPTIONS
                    // ==================================================

                    if (_isLogin) ...[
                      const SizedBox(
                        height:
                        23,
                      ),

                      _buildDivider(),

                      const SizedBox(
                        height:
                        20,
                      ),

                      _buildSocialButtons(),

                      const SizedBox(
                        height:
                        20,
                      ),

                      _buildBottomRegisterText(),
                    ]

                    // ==================================================
                    // REGISTER BOTTOM TEXT
                    // ==================================================

                    else ...[
                      const SizedBox(
                        height:
                        20,
                      ),

                      _buildBottomLoginText(),
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
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(
      BuildContext context,
      ) {
    return Row(
      children: [
        IconButton(
          onPressed:
              () {
            if (Navigator.canPop(
              context,
            )) {
              Navigator.pop(
                context,
              );
            } else {
              Navigator.pushReplacementNamed(
                context,
                '/welcome',
              );
            }
          },

          icon:
          const Icon(
            Icons.arrow_back_rounded,

            color:
            darkGreen,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width:
          78,

          height:
          78,

          decoration:
          BoxDecoration(
            color:
            lightGreen,

            shape:
            BoxShape.circle,

            border:
            Border.all(
              color:
              civicGreen.withValues(
                alpha:
                0.15,
              ),
            ),
          ),

          child:
          const Icon(
            Icons.account_balance_rounded,

            color:
            civicGreen,

            size:
            43,
          ),
        ),

        if (_unreadNotifications >
            0) ...[
          const SizedBox(
            height:
            8,
          ),

          Text(
            '$_unreadNotifications notification${_unreadNotifications == 1 ? '' : 's'}',

            style:
            const TextStyle(
              color:
              textGrey,

              fontSize:
              9,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // MODE TOGGLE
  // ============================================================

  Widget _buildModeToggle() {
    return Container(
      padding:
      const EdgeInsets.all(
        4,
      ),

      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFF0F4F1,
        ),

        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child:
            _modeButton(
              title:
              'Sign In',

              selected:
              _isLogin,

              onTap:
                  () {
                _switchMode(
                  true,
                );
              },
            ),
          ),

          Expanded(
            child:
            _modeButton(
              title:
              'Register',

              selected:
              !_isLogin,

              onTap:
                  () {
                _switchMode(
                  false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius:
      BorderRadius.circular(
        11,
      ),

      onTap:
      onTap,

      child: Container(
        height:
        43,

        alignment:
        Alignment.center,

        decoration:
        BoxDecoration(
          color:
          selected
              ? Colors.white
              : Colors.transparent,

          borderRadius:
          BorderRadius.circular(
            11,
          ),

          boxShadow:
          selected
              ? [
            BoxShadow(
              color:
              Colors.black.withValues(
                alpha:
                0.05,
              ),

              blurRadius:
              6,

              offset:
              const Offset(
                0,
                2,
              ),
            ),
          ]
              : null,
        ),

        child: Text(
          title,

          style:
          TextStyle(
            color:
            selected
                ? civicGreen
                : textGrey,

            fontSize:
            11,

            fontWeight:
            selected
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NORMAL FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller:
      controller,

      keyboardType:
      keyboardType,

      validator:
      validator,

      decoration:
      _inputDecoration(
        label:
        label,

        icon:
        icon,
      ),
    );
  }

  // ============================================================
  // PASSWORD
  // ============================================================

  Widget _buildPasswordField() {
    return TextFormField(
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

            size:
            20,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONFIRM PASSWORD
  // ============================================================

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller:
      _confirmPasswordController,

      obscureText:
      !_isConfirmPasswordVisible,

      validator:
          (value) {
        if (value ==
            null ||
            value.isEmpty) {
          return 'Confirm your password';
        }

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

            size:
            20,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DESIGN
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText:
      label,

      labelStyle:
      const TextStyle(
        color:
        textGrey,

        fontSize:
        11,
      ),

      prefixIcon:
      Icon(
        icon,

        color:
        civicGreen,

        size:
        20,
      ),

      filled:
      true,

      fillColor:
      Colors.white,

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal:
        15,

        vertical:
        16,
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          13,
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
          13,
        ),

        borderSide:
        const BorderSide(
          color:
          civicGreen,

          width:
          1.4,
        ),
      ),

      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
          13,
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
          13,
        ),

        borderSide:
        const BorderSide(
          color:
          Colors.redAccent,

          width:
          1.3,
        ),
      ),
    );
  }

  // ============================================================
  // REMEMBER / FORGOT
  // ============================================================

  Widget _buildRememberForgotRow(
      BuildContext context,
      ) {
    return Row(
      children: [
        SizedBox(
          width:
          22,

          height:
          22,

          child:
          Checkbox(
            value:
            _rememberMe,

            onChanged:
                (value) {
              setState(() {
                _rememberMe =
                    value ??
                        false;
              });
            },

            activeColor:
            civicGreen,
          ),
        ),

        const SizedBox(
          width:
          5,
        ),

        const Text(
          'Remember me',

          style:
          TextStyle(
            color:
            textGrey,

            fontSize:
            10,
          ),
        ),

        const Spacer(),

        TextButton(
          onPressed:
              () {
            Navigator.push(
              context,

              MaterialPageRoute(
                builder:
                    (_) =>
                const ForgotPasswordScreen(),
              ),
            );
          },

          child:
          const Text(
            'Forgot Password?',

            style:
            TextStyle(
              color:
              civicGreen,

              fontSize:
              10,

              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child:
          Divider(
            color:
            borderColor,
          ),
        ),

        Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal:
            12,
          ),

          child: Text(
            'or continue with',

            style:
            TextStyle(
              color:
              textGrey.withValues(
                alpha:
                0.9,
              ),

              fontSize:
              9,
            ),
          ),
        ),

        const Expanded(
          child:
          Divider(
            color:
            borderColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SOCIAL BUTTONS
  // ============================================================

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [
        _socialImageButton(
          imagePath:
          'assets/images/google_logo.png',

          tooltip:
          'Google',
        ),

        const SizedBox(
          width:
          14,
        ),

        _socialIconButton(
          icon:
          Icons.apple_rounded,

          tooltip:
          'Apple',
        ),

        const SizedBox(
          width:
          14,
        ),

        _socialIconButton(
          icon:
          Icons.email_outlined,

          tooltip:
          'Email',
        ),
      ],
    );
  }

  Widget _socialImageButton({
    required String imagePath,
    required String tooltip,
  }) {
    return Tooltip(
      message:
      tooltip,

      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          13,
        ),

        onTap:
            () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content:
              Text(
                '$tooltip sign-in is a prototype feature.',
              ),
            ),
          );
        },

        child: Container(
          width:
          53,

          height:
          48,

          padding:
          const EdgeInsets.all(
            13,
          ),

          decoration:
          BoxDecoration(
            color:
            Colors.white,

            borderRadius:
            BorderRadius.circular(
              13,
            ),

            border:
            Border.all(
              color:
              borderColor,
            ),
          ),

          child:
          Image.asset(
            imagePath,

            fit:
            BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _socialIconButton({
    required IconData icon,
    required String tooltip,
  }) {
    return Tooltip(
      message:
      tooltip,

      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          13,
        ),

        onTap:
            () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content:
              Text(
                '$tooltip sign-in is a prototype feature.',
              ),
            ),
          );
        },

        child: Container(
          width:
          53,

          height:
          48,

          decoration:
          BoxDecoration(
            color:
            Colors.white,

            borderRadius:
            BorderRadius.circular(
              13,
            ),

            border:
            Border.all(
              color:
              borderColor,
            ),
          ),

          child:
          Icon(
            icon,

            color:
            tooltip ==
                'Email'
                ? civicGreen
                : Colors.black87,

            size:
            23,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM REGISTER
  // ============================================================

  Widget _buildBottomRegisterText() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [
        const Text(
          'Don\'t have an account? ',

          style:
          TextStyle(
            color:
            textGrey,

            fontSize:
            10,
          ),
        ),

        GestureDetector(
          onTap:
              () {
            _switchMode(
              false,
            );
          },

          child:
          const Text(
            'Register',

            style:
            TextStyle(
              color:
              civicGreen,

              fontSize:
              10,

              fontWeight:
              FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM LOGIN
  // ============================================================

  Widget _buildBottomLoginText() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [
        const Text(
          'Already have an account? ',

          style:
          TextStyle(
            color:
            textGrey,

            fontSize:
            10,
          ),
        ),

        GestureDetector(
          onTap:
              () {
            _switchMode(
              true,
            );
          },

          child:
          const Text(
            'Sign In',

            style:
            TextStyle(
              color:
              civicGreen,

              fontSize:
              10,

              fontWeight:
              FontWeight.w800,
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
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        12,
      ),

      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFF1F5F2,
        ),

        borderRadius:
        BorderRadius.circular(
          13,
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
            17,
          ),

          SizedBox(
            width:
            8,
          ),

          Expanded(
            child:
            Text(
              'Academic Prototype — CivicID is not an official government service. Use demonstration information while testing.',

              style:
              TextStyle(
                color:
                textGrey,

                fontSize:
                9,

                height:
                1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}