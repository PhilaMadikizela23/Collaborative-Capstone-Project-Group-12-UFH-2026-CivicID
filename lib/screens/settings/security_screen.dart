import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() =>
      _SecurityScreenState();
}

class _SecurityScreenState
    extends State<SecurityScreen> {
  static const Color civicGreen =
  Color(0xFF1F7A3D);

  static const Color darkGreen =
  Color(0xFF145A2A);

  static const Color lightGreen =
  Color(0xFFEAF6EC);

  static const Color pageBackground =
  Color(0xFFF5F7F6);

  static const Color borderColor =
  Color(0xFFDCE5DF);

  static const Color textGrey =
  Color(0xFF667085);

  bool _biometricsEnabled = false;
  bool _twoFactorEnabled = false;
  bool _loginAlertsEnabled = true;

  // ============================================================
  // CHANGE PASSWORD DIALOG
  // ============================================================

  void _showChangePasswordDialog() {
    final currentPasswordController =
    TextEditingController();

    final newPasswordController =
    TextEditingController();

    final confirmPasswordController =
    TextEditingController();

    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            final currentPassword =
            currentPasswordController.text.trim();

            final newPassword =
            newPasswordController.text.trim();

            final confirmPassword =
            confirmPasswordController.text.trim();

            final hasCurrentPassword =
                currentPassword.isNotEmpty;

            final hasNewPassword =
                newPassword.isNotEmpty;

            final newPasswordLongEnough =
                newPassword.length >= 6;

            final passwordsMatch =
                newPassword ==
                    confirmPassword &&
                    confirmPassword.isNotEmpty;

            final passwordChanged =
                currentPassword != newPassword;

            final canUpdate =
                hasCurrentPassword &&
                    hasNewPassword &&
                    newPasswordLongEnough &&
                    passwordsMatch &&
                    passwordChanged;

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

              titlePadding:
              const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                0,
              ),

              contentPadding:
              const EdgeInsets.fromLTRB(
                24,
                20,
                24,
                10,
              ),

              actionsPadding:
              const EdgeInsets.fromLTRB(
                20,
                5,
                20,
                20,
              ),

              title: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                    lightGreen,
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: civicGreen,
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        color: darkGreen,
                        fontWeight:
                        FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),

              content:
              SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your current password and choose a new password.',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // CURRENT PASSWORD
                    TextField(
                      controller:
                      currentPasswordController,

                      obscureText:
                      !showCurrentPassword,

                      onChanged: (_) {
                        setDialogState(
                              () {},
                        );
                      },

                      decoration:
                      InputDecoration(
                        labelText:
                        'Current Password',

                        prefixIcon:
                        const Icon(
                          Icons
                              .lock_outline_rounded,
                        ),

                        suffixIcon:
                        IconButton(
                          tooltip:
                          showCurrentPassword
                              ? 'Hide password'
                              : 'Show password',

                          onPressed: () {
                            setDialogState(
                                  () {
                                showCurrentPassword =
                                !showCurrentPassword;
                              },
                            );
                          },

                          icon: Icon(
                            showCurrentPassword
                                ? Icons
                                .visibility_off_outlined
                                : Icons
                                .visibility_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // NEW PASSWORD
                    TextField(
                      controller:
                      newPasswordController,

                      obscureText:
                      !showNewPassword,

                      onChanged: (_) {
                        setDialogState(
                              () {},
                        );
                      },

                      decoration:
                      InputDecoration(
                        labelText:
                        'New Password',

                        prefixIcon:
                        const Icon(
                          Icons.password_rounded,
                        ),

                        suffixIcon:
                        IconButton(
                          tooltip:
                          showNewPassword
                              ? 'Hide password'
                              : 'Show password',

                          onPressed: () {
                            setDialogState(
                                  () {
                                showNewPassword =
                                !showNewPassword;
                              },
                            );
                          },

                          icon: Icon(
                            showNewPassword
                                ? Icons
                                .visibility_off_outlined
                                : Icons
                                .visibility_outlined,
                          ),
                        ),

                        errorText:
                        newPassword
                            .isNotEmpty &&
                            newPassword
                                .length <
                                6
                            ? 'Password must be at least 6 characters'
                            : currentPassword
                            .isNotEmpty &&
                            newPassword
                                .isNotEmpty &&
                            currentPassword ==
                                newPassword
                            ? 'New password must be different'
                            : null,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // CONFIRM PASSWORD
                    TextField(
                      controller:
                      confirmPasswordController,

                      obscureText:
                      !showConfirmPassword,

                      onChanged: (_) {
                        setDialogState(
                              () {},
                        );
                      },

                      decoration:
                      InputDecoration(
                        labelText:
                        'Confirm New Password',

                        prefixIcon:
                        const Icon(
                          Icons
                              .verified_user_outlined,
                        ),

                        suffixIcon:
                        IconButton(
                          tooltip:
                          showConfirmPassword
                              ? 'Hide password'
                              : 'Show password',

                          onPressed: () {
                            setDialogState(
                                  () {
                                showConfirmPassword =
                                !showConfirmPassword;
                              },
                            );
                          },

                          icon: Icon(
                            showConfirmPassword
                                ? Icons
                                .visibility_off_outlined
                                : Icons
                                .visibility_outlined,
                          ),
                        ),

                        errorText:
                        confirmPassword
                            .isNotEmpty &&
                            newPassword !=
                                confirmPassword
                            ? 'Passwords do not match'
                            : null,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Container(
                      width:
                      double.infinity,

                      padding:
                      const EdgeInsets.all(
                        11,
                      ),

                      decoration:
                      BoxDecoration(
                        color: lightGreen,

                        borderRadius:
                        BorderRadius
                            .circular(
                          12,
                        ),
                      ),

                      child: const Row(
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
                            child: Text(
                              'Your new password must contain at least 6 characters.',
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
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                  const Text(
                    'CANCEL',
                  ),
                ),

                FilledButton.icon(
                  onPressed:
                  canUpdate
                      ? () {
                    Navigator.pop(
                      dialogContext,
                    );

                    ScaffoldMessenger
                        .of(this.context)
                        .showSnackBar(
                      const SnackBar(
                        backgroundColor:
                        civicGreen,

                        behavior:
                        SnackBarBehavior
                            .floating,

                        content:
                        Row(
                          children: [
                            Icon(
                              Icons
                                  .check_circle_outline_rounded,
                              color:
                              Colors.white,
                            ),

                            SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                              Text(
                                'Prototype password update completed.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                      : null,

                  icon:
                  const Icon(
                    Icons
                        .lock_reset_rounded,
                    size: 18,
                  ),

                  label:
                  const Text(
                    'UPDATE',
                  ),

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
                      horizontal: 20,
                      vertical: 13,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      currentPasswordController
          .dispose();

      newPasswordController
          .dispose();

      confirmPasswordController
          .dispose();
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

      appBar: AppBar(
        backgroundColor:
        Colors.white,

        surfaceTintColor:
        Colors.white,

        elevation: 0,

        title: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Text(
              'Security & Biometrics',

              style: TextStyle(
                color:
                darkGreen,

                fontSize: 17,

                fontWeight:
                FontWeight.w900,
              ),
            ),

            Text(
              'CivicID security preferences',

              style: TextStyle(
                color:
                textGrey,

                fontSize: 10,
              ),
            ),
          ],
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets
            .fromLTRB(
          20,
          20,
          20,
          40,
        ),

        children: [
          Center(
            child: Container(
              constraints:
              const BoxConstraints(
                maxWidth: 850,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  _header(),

                  const SizedBox(
                    height: 24,
                  ),

                  _sectionTitle(
                    'Security Options',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _securitySwitch(
                    icon:
                    Icons
                        .fingerprint_rounded,

                    title:
                    'Biometrics',

                    subtitle:
                    'Prototype option for fingerprint or face authentication.',

                    value:
                    _biometricsEnabled,

                    onChanged:
                        (value) {
                      setState(() {
                        _biometricsEnabled =
                            value;
                      });
                    },
                  ),

                  _securitySwitch(
                    icon:
                    Icons
                        .phonelink_lock_outlined,

                    title:
                    'Two-Factor Authentication',

                    subtitle:
                    'Prototype additional account verification option.',

                    value:
                    _twoFactorEnabled,

                    onChanged:
                        (value) {
                      setState(() {
                        _twoFactorEnabled =
                            value;
                      });
                    },
                  ),

                  _securitySwitch(
                    icon:
                    Icons
                        .notifications_active_outlined,

                    title:
                    'Login Alerts',

                    subtitle:
                    'Receive CivicID notifications about prototype login activity.',

                    value:
                    _loginAlertsEnabled,

                    onChanged:
                        (value) {
                      setState(() {
                        _loginAlertsEnabled =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  _sectionTitle(
                    'Account Access',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,

                      borderRadius:
                      BorderRadius
                          .circular(
                        17,
                      ),

                      border:
                      Border.all(
                        color:
                        borderColor,
                      ),
                    ),

                    child: ListTile(
                      contentPadding:
                      const EdgeInsets
                          .symmetric(
                        horizontal:
                        15,
                        vertical:
                        7,
                      ),

                      leading:
                      Container(
                        width: 42,
                        height: 42,

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
                        const Icon(
                          Icons
                              .password_rounded,

                          color:
                          civicGreen,
                        ),
                      ),

                      title:
                      const Text(
                        'Change Password',

                        style:
                        TextStyle(
                          color:
                          darkGreen,

                          fontSize:
                          11,

                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),

                      subtitle:
                      const Text(
                        'Change the password used by this prototype account.',

                        style:
                        TextStyle(
                          color:
                          textGrey,

                          fontSize:
                          9,
                        ),
                      ),

                      trailing:
                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,

                        size: 14,

                        color:
                        textGrey,
                      ),

                      onTap:
                      _showChangePasswordDialog,
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  _prototypeNotice(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        21,
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
      const Row(
        children: [
          Icon(
            Icons
                .security_rounded,

            color:
            Colors.white,

            size: 40,
          ),

          SizedBox(
            width: 15,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Text(
                  'Security Centre',

                  style:
                  TextStyle(
                    color:
                    Colors.white,

                    fontSize:
                    20,

                    fontWeight:
                    FontWeight
                        .w900,
                  ),
                ),

                SizedBox(
                  height: 4,
                ),

                Text(
                  'Manage demonstration security preferences for your CivicID account.',

                  style:
                  TextStyle(
                    color:
                    Colors
                        .white70,

                    fontSize:
                    9,
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
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      String title,
      ) {
    return Text(
      title.toUpperCase(),

      style:
      const TextStyle(
        color:
        civicGreen,

        fontSize: 10,

        fontWeight:
        FontWeight.w900,

        letterSpacing:
        1.0,
      ),
    );
  }

  // ============================================================
  // SECURITY SWITCH
  // ============================================================

  Widget _securitySwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>
    onChanged,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
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
      SwitchListTile(
        contentPadding:
        const EdgeInsets
            .symmetric(
          horizontal:
          15,
          vertical:
          7,
        ),

        secondary:
        Container(
          width: 42,
          height: 42,

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

          child: Icon(
            icon,

            color:
            civicGreen,

            size: 20,
          ),
        ),

        title: Text(
          title,

          style:
          const TextStyle(
            color:
            darkGreen,

            fontSize:
            11,

            fontWeight:
            FontWeight
                .w800,
          ),
        ),

        subtitle:
        Text(
          subtitle,

          style:
          const TextStyle(
            color:
            textGrey,

            fontSize:
            9,

            height:
            1.4,
          ),
        ),

        value:
        value,

        onChanged:
        onChanged,

        activeThumbColor:
        civicGreen,

        activeTrackColor:
        civicGreen
            .withValues(
          alpha: 0.25,
        ),
      ),
    );
  }

  // ============================================================
  // PROTOTYPE NOTICE
  // ============================================================

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
        CrossAxisAlignment
            .start,

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
              'Academic Prototype — Biometrics, two-factor authentication and password changes on this screen are demonstration features unless connected to a real authentication backend later.',

              style:
              TextStyle(
                color:
                textGrey,

                fontSize:
                9,

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