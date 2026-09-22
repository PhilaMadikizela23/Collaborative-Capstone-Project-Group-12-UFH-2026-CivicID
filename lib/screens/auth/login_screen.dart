import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);

  final AuthService _authService = AuthService();

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await _authService.login(
        email,
        password,
      );

      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid email or password.',
            ),
          ),
        );

        return;
      }

      // Check the account role after successful login.
      final bool isAdmin =
      _authService.isAdmin(email);

      if (isAdmin) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin_home',
              (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login failed. Please try again.',
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
  // FORGOT PASSWORD
  // ============================================================

  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const ForgotPasswordScreen(),
      ),
    );
  }

  // ============================================================
  // REGISTER
  // ============================================================

  void _openRegister() {
    Navigator.pushReplacementNamed(
      context,
      '/register',
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 30,
            ),
            child: Container(
              width: double.infinity,
              constraints:
              const BoxConstraints(
                maxWidth: 520,
              ),
              child: Column(
                children: [
                  _buildLogo(),

                  const SizedBox(height: 25),

                  _buildLoginCard(),

                  const SizedBox(height: 20),

                  _buildPrototypeNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: civicGreen,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                civicGreen.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: Colors.white,
            size: 36,
          ),
        ),

        const SizedBox(height: 13),

        const Text(
          'CivicID',
          style: TextStyle(
            color: darkGreen,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Secure Digital Citizen Profile',
          style: TextStyle(
            color: textGrey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGIN CARD
  // ============================================================

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(
                color: darkGreen,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Sign in to continue to your CivicID account.',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            // EMAIL
            _fieldLabel('Email Address'),

            const SizedBox(height: 7),

            TextFormField(
              controller: _emailController,
              enabled: !_isLoading,
              keyboardType:
              TextInputType.emailAddress,
              textInputAction:
              TextInputAction.next,
              decoration: _inputDecoration(
                hint: 'Enter your email address',
                icon: Icons.email_outlined,
              ),
              validator: (value) {
                final email =
                    value?.trim() ?? '';

                if (email.isEmpty) {
                  return 'Please enter your email address';
                }

                if (!email.contains('@') ||
                    !email.contains('.')) {
                  return 'Please enter a valid email address';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // PASSWORD
            _fieldLabel('Password'),

            const SizedBox(height: 7),

            TextFormField(
              controller: _passwordController,
              enabled: !_isLoading,
              obscureText: !_showPassword,
              textInputAction:
              TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!_isLoading) {
                  _handleLogin();
                }
              },
              decoration: _inputDecoration(
                hint: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  tooltip: _showPassword
                      ? 'Hide password'
                      : 'Show password',
                  onPressed: () {
                    setState(() {
                      _showPassword =
                      !_showPassword;
                    });
                  },
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: textGrey,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'Please enter your password';
                }

                return null;
              },
            ),

            const SizedBox(height: 5),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : _openForgotPassword,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: civicGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 9),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed:
                _isLoading ? null : _handleLogin,
                style: FilledButton.styleFrom(
                  backgroundColor: civicGreen,
                  disabledBackgroundColor:
                  civicGreen.withValues(
                    alpha: 0.55,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 21,
                  height: 21,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
                    : const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      'SIGN IN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons
                          .arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                const Expanded(
                  child: Divider(
                    color: borderColor,
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Text(
                    'NEW TO CIVICID?',
                    style: TextStyle(
                      color: textGrey.withValues(
                        alpha: 0.8,
                      ),
                      fontSize: 8,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(
                    color: borderColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 19),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : _openRegister,
                style: OutlinedButton.styleFrom(
                  foregroundColor: civicGreen,
                  side: const BorderSide(
                    color: civicGreen,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FIELD HELPERS
  // ============================================================

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF263B31),
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA7A0),
        fontSize: 10,
      ),
      prefixIcon: Icon(
        icon,
        color: civicGreen,
        size: 20,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FBF9),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: civicGreen,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
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
        color: lightGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFCFE5D7),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.school_outlined,
            color: civicGreen,
            size: 18,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Academic Prototype — Not an official government service.',
              style: TextStyle(
                color: darkGreen,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}