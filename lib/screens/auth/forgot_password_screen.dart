import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  // ============================================================
  // CIVICID COLORS
  // ============================================================

  static const Color civicGreen = Color(0xFF1F7A3D);
  static const Color darkGreen = Color(0xFF145A2A);
  static const Color lightGreen = Color(0xFFEAF6EC);
  static const Color pageBackground = Color(0xFFF5F7F6);
  static const Color borderColor = Color(0xFFDCE5DF);
  static const Color textGrey = Color(0xFF667085);

  // ============================================================
  // SERVICES
  // ============================================================

  final AuthService _authService = AuthService();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _codeController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  int _step = 0;

  bool _isLoading = false;

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    return emailRegex.hasMatch(
      email.trim(),
    );
  }

  // ============================================================
  // CHECK IF BUTTON CAN CONTINUE
  // ============================================================

  bool get _canContinue {
    if (_step == 0) {
      return _isValidEmail(
        _emailController.text,
      );
    }

    if (_step == 1) {
      return _codeController.text.trim().length == 4;
    }

    final password =
        _passwordController.text;

    final confirmPassword =
        _confirmPasswordController.text;

    return password.length >= 6 &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword;
  }

  // ============================================================
  // NEXT STEP
  // ============================================================

  Future<void> _next() async {
    if (_isLoading || !_canContinue) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ========================================================
      // STEP 1: SEND RESET CODE
      // ========================================================

      if (_step == 0) {
        final email =
        _emailController.text.trim();

        await _authService.sendResetCode(
          email,
        );

        if (!mounted) return;

        setState(() {
          _step = 1;
        });

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: civicGreen,
              content: Text(
                'Verification code sent.',
              ),
            ),
          );

        return;
      }

      // ========================================================
      // STEP 2: VERIFY CODE
      // ========================================================

      if (_step == 1) {
        final email =
        _emailController.text.trim();

        final code =
        _codeController.text.trim();

        final success =
        await _authService.verifyResetCode(
          email,
          code,
        );

        if (!mounted) return;

        if (success) {
          setState(() {
            _step = 2;
          });
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                behavior:
                SnackBarBehavior.floating,
                backgroundColor:
                Colors.red,
                content: Text(
                  'Invalid verification code.',
                ),
              ),
            );
        }

        return;
      }

      // ========================================================
      // STEP 3: RESET PASSWORD
      // ========================================================

      final password =
          _passwordController.text;

      final confirmPassword =
          _confirmPasswordController.text;

      if (password.length < 6) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              behavior:
              SnackBarBehavior.floating,
              backgroundColor:
              Colors.red,
              content: Text(
                'Password must be at least 6 characters.',
              ),
            ),
          );

        return;
      }

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              behavior:
              SnackBarBehavior.floating,
              backgroundColor:
              Colors.red,
              content: Text(
                'Passwords do not match.',
              ),
            ),
          );

        return;
      }

      await _authService.updatePassword(
        _emailController.text.trim(),
        password,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (
            dialogContext,
            ) {
          return AlertDialog(
            backgroundColor: Colors.white,

            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                20,
              ),
            ),

            title: const Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                  lightGreen,
                  child: Icon(
                    Icons
                        .check_circle_rounded,
                    color:
                    civicGreen,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Password Updated',
                    style: TextStyle(
                      color:
                      darkGreen,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),

            content: const Text(
              'Your password has been changed successfully. You can now sign in using your new password.',
              style: TextStyle(
                color:
                textGrey,
                height:
                1.5,
              ),
            ),

            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child: const Text(
                  'CONTINUE',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior:
            SnackBarBehavior.floating,
            backgroundColor:
            Colors.red,
            content: Text(
              'Something went wrong. Please try again.',
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
  // GO BACK ONE STEP
  // ============================================================

  void _previousStep() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _step--;
    });
  }

  // ============================================================
  // RESEND CODE
  // ============================================================

  Future<void> _resendCode() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.sendResetCode(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior:
            SnackBarBehavior.floating,
            backgroundColor:
            civicGreen,
            content: Text(
              'A new verification code has been sent.',
            ),
          ),
        );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior:
            SnackBarBehavior.floating,
            backgroundColor:
            Colors.red,
            content: Text(
              'Unable to resend code.',
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

        elevation:
        0,

        scrolledUnderElevation:
        0,

        leading:
        IconButton(
          icon:
          const Icon(
            Icons
                .arrow_back_rounded,
          ),

          onPressed:
          _previousStep,
        ),

        title:
        const Text(
          'Password Recovery',

          style:
          TextStyle(
            color:
            darkGreen,

            fontWeight:
            FontWeight.w800,

            fontSize:
            17,
          ),
        ),

        bottom:
        const PreferredSize(
          preferredSize:
          Size.fromHeight(
            1,
          ),

          child:
          Divider(
            height:
            1,

            color:
            borderColor,
          ),
        ),
      ),

      body:
      SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets
              .fromLTRB(
            20,
            24,
            20,
            40,
          ),

          child:
          Center(
            child:
            ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth:
                560,
              ),

              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,

                children: [
                  // ==================================================
                  // PROGRESS
                  // ==================================================

                  _buildProgress(),

                  const SizedBox(
                    height:
                    24,
                  ),

                  // ==================================================
                  // MAIN CARD
                  // ==================================================

                  Container(
                    padding:
                    const EdgeInsets
                        .all(
                      24,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,

                      borderRadius:
                      BorderRadius
                          .circular(
                        22,
                      ),

                      border:
                      Border.all(
                        color:
                        borderColor,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black
                              .withValues(
                            alpha:
                            0.04,
                          ),

                          blurRadius:
                          18,

                          offset:
                          const Offset(
                            0,
                            5,
                          ),
                        ),
                      ],
                    ),

                    child:
                    Column(
                      children: [
                        _buildStepIcon(),

                        const SizedBox(
                          height:
                          20,
                        ),

                        Text(
                          _titleForStep(),

                          textAlign:
                          TextAlign
                              .center,

                          style:
                          const TextStyle(
                            color:
                            darkGreen,

                            fontSize:
                            22,

                            fontWeight:
                            FontWeight
                                .w900,
                          ),
                        ),

                        const SizedBox(
                          height:
                          8,
                        ),

                        Text(
                          _descriptionForStep(),

                          textAlign:
                          TextAlign
                              .center,

                          style:
                          const TextStyle(
                            color:
                            textGrey,

                            fontSize:
                            12,

                            height:
                            1.5,
                          ),
                        ),

                        const SizedBox(
                          height:
                          28,
                        ),

                        _buildCurrentStep(),

                        const SizedBox(
                          height:
                          28,
                        ),

                        SizedBox(
                          width:
                          double.infinity,

                          child:
                          FilledButton(
                            onPressed:
                            _isLoading ||
                                !_canContinue
                                ? null
                                : _next,

                            style:
                            FilledButton
                                .styleFrom(
                              backgroundColor:
                              civicGreen,

                              foregroundColor:
                              Colors.white,

                              disabledBackgroundColor:
                              const Color(
                                0xFFE0E5E2,
                              ),

                              disabledForegroundColor:
                              const Color(
                                0xFF9AA29E,
                              ),

                              padding:
                              const EdgeInsets
                                  .symmetric(
                                vertical:
                                16,
                              ),

                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  14,
                                ),
                              ),
                            ),

                            child:
                            _isLoading
                                ? const SizedBox(
                              height:
                              20,
                              width:
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
                              _step ==
                                  2
                                  ? 'RESET PASSWORD'
                                  : 'CONTINUE',
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        if (_step == 1) ...[
                          const SizedBox(
                            height:
                            10,
                          ),

                          TextButton(
                            onPressed:
                            _isLoading
                                ? null
                                : _resendCode,

                            child:
                            const Text(
                              'RESEND CODE',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(
                    height:
                    18,
                  ),

                  // ==================================================
                  // PROTOTYPE NOTICE
                  // ==================================================

                  Container(
                    padding:
                    const EdgeInsets
                        .all(
                      13,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      lightGreen,

                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
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
                            'Academic Prototype — Password recovery is a demonstration feature unless connected to a real email and authentication service.',

                            style:
                            TextStyle(
                              color:
                              darkGreen,

                              fontSize:
                              10,

                              height:
                              1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CURRENT STEP
  // ============================================================

  Widget _buildCurrentStep() {
    if (_step == 0) {
      return TextField(
        controller:
        _emailController,

        keyboardType:
        TextInputType.emailAddress,

        textInputAction:
        TextInputAction.done,

        onChanged: (_) {
          setState(() {});
        },

        decoration:
        InputDecoration(
          labelText:
          'Email Address',

          hintText:
          'example@email.com',

          prefixIcon:
          const Icon(
            Icons.email_outlined,
          ),

          errorText:
          _emailController
              .text
              .isNotEmpty &&
              !_isValidEmail(
                _emailController
                    .text,
              )
              ? 'Enter a valid email address'
              : null,
        ),
      );
    }

    if (_step == 1) {
      return TextField(
        controller:
        _codeController,

        keyboardType:
        TextInputType.number,

        maxLength:
        4,

        textAlign:
        TextAlign.center,

        style:
        const TextStyle(
          fontSize:
          24,

          fontWeight:
          FontWeight.w800,

          letterSpacing:
          8,
        ),

        onChanged: (_) {
          setState(() {});
        },

        decoration:
        const InputDecoration(
          labelText:
          'Verification Code',

          hintText:
          '0000',

          counterText:
          '',

          prefixIcon:
          Icon(
            Icons
                .verified_user_outlined,
          ),
        ),
      );
    }

    return Column(
      children: [
        TextField(
          controller:
          _passwordController,

          obscureText:
          !_showPassword,

          onChanged: (_) {
            setState(() {});
          },

          decoration:
          InputDecoration(
            labelText:
            'New Password',

            prefixIcon:
            const Icon(
              Icons.lock_outline_rounded,
            ),

            suffixIcon:
            IconButton(
              onPressed: () {
                setState(() {
                  _showPassword =
                  !_showPassword;
                });
              },

              icon:
              Icon(
                _showPassword
                    ? Icons
                    .visibility_off_outlined
                    : Icons
                    .visibility_outlined,
              ),
            ),

            errorText:
            _passwordController
                .text
                .isNotEmpty &&
                _passwordController
                    .text
                    .length <
                    6
                ? 'Password must be at least 6 characters'
                : null,
          ),
        ),

        const SizedBox(
          height:
          16,
        ),

        TextField(
          controller:
          _confirmPasswordController,

          obscureText:
          !_showConfirmPassword,

          onChanged: (_) {
            setState(() {});
          },

          decoration:
          InputDecoration(
            labelText:
            'Confirm Password',

            prefixIcon:
            const Icon(
              Icons
                  .lock_reset_rounded,
            ),

            suffixIcon:
            IconButton(
              onPressed: () {
                setState(() {
                  _showConfirmPassword =
                  !_showConfirmPassword;
                });
              },

              icon:
              Icon(
                _showConfirmPassword
                    ? Icons
                    .visibility_off_outlined
                    : Icons
                    .visibility_outlined,
              ),
            ),

            errorText:
            _confirmPasswordController
                .text
                .isNotEmpty &&
                _passwordController
                    .text !=
                    _confirmPasswordController
                        .text
                ? 'Passwords do not match'
                : null,
          ),
        ),

        const SizedBox(
          height:
          14,
        ),

        Container(
          width:
          double.infinity,

          padding:
          const EdgeInsets.all(
            12,
          ),

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
          const Row(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [
              Icon(
                Icons
                    .shield_outlined,

                color:
                civicGreen,

                size:
                18,
              ),

              SizedBox(
                width:
                8,
              ),

              Expanded(
                child:
                Text(
                  'Use at least 6 characters and choose a password you do not use elsewhere.',

                  style:
                  TextStyle(
                    color:
                    darkGreen,

                    fontSize:
                    10,

                    height:
                    1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STEP ICON
  // ============================================================

  Widget _buildStepIcon() {
    IconData icon;

    if (_step == 0) {
      icon =
          Icons.email_outlined;
    } else if (_step == 1) {
      icon =
          Icons.verified_user_outlined;
    } else {
      icon =
          Icons.lock_reset_rounded;
    }

    return Container(
      width:
      80,

      height:
      80,

      decoration:
      const BoxDecoration(
        color:
        lightGreen,

        shape:
        BoxShape.circle,
      ),

      child:
      Icon(
        icon,

        size:
        38,

        color:
        civicGreen,
      ),
    );
  }

  // ============================================================
  // TITLES
  // ============================================================

  String _titleForStep() {
    switch (_step) {
      case 0:
        return 'Reset Password';

      case 1:
        return 'Enter Verification Code';

      default:
        return 'Create New Password';
    }
  }

  String _descriptionForStep() {
    switch (_step) {
      case 0:
        return 'Enter your registered email address and we will send you a verification code.';

      case 1:
        return 'Enter the 4-digit verification code sent to ${_emailController.text.trim()}.';

      default:
        return 'Choose a new password for your CivicID account.';
    }
  }

  // ============================================================
  // PROGRESS INDICATOR
  // ============================================================

  Widget _buildProgress() {
    return Row(
      children: [
        _progressStep(
          number:
          '1',

          title:
          'Email',

          completed:
          _step > 0,

          active:
          _step == 0,
        ),

        _progressLine(
          completed:
          _step > 0,
        ),

        _progressStep(
          number:
          '2',

          title:
          'Verify',

          completed:
          _step > 1,

          active:
          _step == 1,
        ),

        _progressLine(
          completed:
          _step > 1,
        ),

        _progressStep(
          number:
          '3',

          title:
          'Password',

          completed:
          false,

          active:
          _step == 2,
        ),
      ],
    );
  }

  Widget _progressStep({
    required String number,
    required String title,
    required bool completed,
    required bool active,
  }) {
    final highlighted =
        completed || active;

    return Column(
      children: [
        Container(
          width:
          36,

          height:
          36,

          alignment:
          Alignment.center,

          decoration:
          BoxDecoration(
            color:
            highlighted
                ? civicGreen
                : Colors.white,

            shape:
            BoxShape.circle,

            border:
            Border.all(
              color:
              highlighted
                  ? civicGreen
                  : borderColor,
            ),
          ),

          child:
          completed
              ? const Icon(
            Icons.check_rounded,
            color:
            Colors.white,
            size:
            18,
          )
              : Text(
            number,
            style:
            TextStyle(
              color:
              highlighted
                  ? Colors.white
                  : textGrey,
              fontWeight:
              FontWeight.w800,
              fontSize:
              11,
            ),
          ),
        ),

        const SizedBox(
          height:
          5,
        ),

        Text(
          title,

          style:
          TextStyle(
            color:
            highlighted
                ? darkGreen
                : textGrey,

            fontSize:
            9,

            fontWeight:
            highlighted
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _progressLine({
    required bool completed,
  }) {
    return Expanded(
      child:
      Container(
        height:
        2,

        margin:
        const EdgeInsets.only(
          left:
          6,

          right:
          6,

          bottom:
          18,
        ),

        color:
        completed
            ? civicGreen
            : borderColor,
      ),
    );
  }
}