import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // ============================================================
  // CIVICID COLORS
  // ============================================================

  static const Color civicGreen =
  Color(0xFF1F7A3D);

  static const Color darkGreen =
  Color(0xFF145A2A);

  static const Color lightGreen =
  Color(0xFFEAF6EC);

  static const Color pageBackground =
  Color(0xFFF5F7F6);

  static const Color darkText =
  Color(0xFF1F2933);

  static const Color textGrey =
  Color(0xFF667085);

  static const Color borderColor =
  Color(0xFFDCE5DF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      pageBackground,

      body:
      SafeArea(
        child:
        LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            return SingleChildScrollView(
              child:
              Center(
                child:
                ConstrainedBox(
                  constraints:
                  const BoxConstraints(
                    maxWidth:
                    900,
                  ),

                  child:
                  Padding(
                    padding:
                    const EdgeInsets
                        .fromLTRB(
                      20,
                      28,
                      20,
                      35,
                    ),

                    child:
                    Column(
                      children: [
                        // ==================================================
                        // LOGO
                        // ==================================================

                        Container(
                          width:
                          82,
                          height:
                          82,

                          decoration:
                          BoxDecoration(
                            color:
                            lightGreen,

                            borderRadius:
                            BorderRadius
                                .circular(
                              24,
                            ),

                            border:
                            Border.all(
                              color:
                              const Color(
                                0xFFCFE5D7,
                              ),
                            ),
                          ),

                          child:
                          const Icon(
                            Icons
                                .account_balance_rounded,

                            size:
                            46,

                            color:
                            civicGreen,
                          ),
                        ),

                        const SizedBox(
                          height:
                          17,
                        ),

                        // ==================================================
                        // APP NAME
                        // ==================================================

                        const Text(
                          'CivicID',

                          textAlign:
                          TextAlign.center,

                          style:
                          TextStyle(
                            color:
                            darkGreen,

                            fontSize:
                            38,

                            fontWeight:
                            FontWeight
                                .w900,

                            letterSpacing:
                            -1,
                          ),
                        ),

                        const SizedBox(
                          height:
                          5,
                        ),

                        const Text(
                          'Your Digital Citizen Profile',

                          textAlign:
                          TextAlign.center,

                          style:
                          TextStyle(
                            color:
                            textGrey,

                            fontSize:
                            14,

                            fontWeight:
                            FontWeight
                                .w500,
                          ),
                        ),

                        const SizedBox(
                          height:
                          28,
                        ),

                        // ==================================================
                        // BUILDING HERO IMAGE
                        // ==================================================

                        Container(
                          width:
                          double.infinity,

                          constraints:
                          const BoxConstraints(
                            maxWidth:
                            680,
                          ),

                          height:
                          constraints
                              .maxWidth <
                              500
                              ? 245
                              : 300,

                          decoration:
                          BoxDecoration(
                            borderRadius:
                            BorderRadius
                                .circular(
                              24,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color:
                                Colors.black
                                    .withValues(
                                  alpha:
                                  0.10,
                                ),

                                blurRadius:
                                22,

                                offset:
                                const Offset(
                                  0,
                                  8,
                                ),
                              ),
                            ],
                          ),

                          child:
                          ClipRRect(
                            borderRadius:
                            BorderRadius
                                .circular(
                              24,
                            ),

                            child:
                            Stack(
                              fit:
                              StackFit
                                  .expand,

                              children: [
                                Image.asset(
                                  'assets/images/civicid_building.png',

                                  fit:
                                  BoxFit
                                      .cover,

                                  alignment:
                                  Alignment
                                      .center,
                                ),

                                // Dark overlay
                                Container(
                                  decoration:
                                  BoxDecoration(
                                    gradient:
                                    LinearGradient(
                                      begin:
                                      Alignment
                                          .topCenter,

                                      end:
                                      Alignment
                                          .bottomCenter,

                                      colors: [
                                        Colors
                                            .transparent,

                                        Colors
                                            .black
                                            .withValues(
                                          alpha:
                                          0.68,
                                        ),
                                      ],

                                      stops:
                                      const [
                                        0.40,
                                        1.0,
                                      ],
                                    ),
                                  ),
                                ),

                                // SOUTH AFRICA BADGE
                                Positioned(
                                  top:
                                  15,
                                  right:
                                  15,

                                  child:
                                  Container(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal:
                                      12,
                                      vertical:
                                      7,
                                    ),

                                    decoration:
                                    BoxDecoration(
                                      color:
                                      Colors
                                          .white
                                          .withValues(
                                        alpha:
                                        0.94,
                                      ),

                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        30,
                                      ),
                                    ),

                                    child:
                                    const Row(
                                      mainAxisSize:
                                      MainAxisSize
                                          .min,

                                      children: [
                                        Text(
                                          '🇿🇦',
                                          style:
                                          TextStyle(
                                            fontSize:
                                            14,
                                          ),
                                        ),

                                        SizedBox(
                                          width:
                                          6,
                                        ),

                                        Text(
                                          'SOUTH AFRICA',

                                          style:
                                          TextStyle(
                                            color:
                                            darkGreen,

                                            fontSize:
                                            10,

                                            fontWeight:
                                            FontWeight
                                                .w800,

                                            letterSpacing:
                                            0.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // HERO TEXT
                                Positioned(
                                  left:
                                  22,
                                  right:
                                  22,
                                  bottom:
                                  22,

                                  child:
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                    children: [
                                      const Text(
                                        'One profile.',

                                        style:
                                        TextStyle(
                                          color:
                                          Colors.white,

                                          fontSize:
                                          27,

                                          fontWeight:
                                          FontWeight
                                              .w900,
                                        ),
                                      ),

                                      const Text(
                                        'Many possibilities.',

                                        style:
                                        TextStyle(
                                          color:
                                          Colors.white,

                                          fontSize:
                                          27,

                                          fontWeight:
                                          FontWeight
                                              .w900,
                                        ),
                                      ),

                                      const SizedBox(
                                        height:
                                        7,
                                      ),

                                      Text(
                                        'Prepare and manage government-service applications from one secure place.',

                                        style:
                                        TextStyle(
                                          color:
                                          Colors.white
                                              .withValues(
                                            alpha:
                                            0.86,
                                          ),

                                          fontSize:
                                          11,

                                          height:
                                          1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          height:
                          26,
                        ),

                        // ==================================================
                        // DESCRIPTION
                        // ==================================================

                        ConstrainedBox(
                          constraints:
                          const BoxConstraints(
                            maxWidth:
                            620,
                          ),

                          child:
                          Text(
                            'Prepare, check and track your government service applications in one secure digital profile.',

                            textAlign:
                            TextAlign.center,

                            style:
                            TextStyle(
                              color:
                              textGrey,

                              fontSize:
                              14,

                              height:
                              1.55,

                              fontWeight:
                              FontWeight
                                  .w500,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height:
                          24,
                        ),

                        // ==================================================
                        // BENEFITS
                        // ==================================================

                        Container(
                          width:
                          double.infinity,

                          constraints:
                          const BoxConstraints(
                            maxWidth:
                            680,
                          ),

                          padding:
                          const EdgeInsets
                              .symmetric(
                            vertical:
                            18,
                            horizontal:
                            8,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            Colors.white,

                            borderRadius:
                            BorderRadius
                                .circular(
                              20,
                            ),

                            border:
                            Border.all(
                              color:
                              borderColor,
                            ),
                          ),

                          child:
                          const Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,

                            children: [
                              _Benefit(
                                icon:
                                Icons
                                    .shield_outlined,

                                title:
                                'Secure',
                              ),

                              _Benefit(
                                icon:
                                Icons
                                    .person_outline_rounded,

                                title:
                                'One Profile',
                              ),

                              _Benefit(
                                icon:
                                Icons
                                    .check_circle_outline_rounded,

                                title:
                                'Simple',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height:
                          28,
                        ),

                        // ==================================================
                        // GET STARTED BUTTON
                        // ==================================================

                        ConstrainedBox(
                          constraints:
                          const BoxConstraints(
                            maxWidth:
                            680,
                          ),

                          child:
                          SizedBox(
                            width:
                            double.infinity,

                            height:
                            58,

                            child:
                            FilledButton(
                              onPressed:
                                  () {
                                Navigator.pushNamed(
                                  context,
                                  '/register',
                                );
                              },

                              style:
                              FilledButton
                                  .styleFrom(
                                backgroundColor:
                                civicGreen,

                                foregroundColor:
                                Colors.white,

                                elevation:
                                0,

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    15,
                                  ),
                                ),
                              ),

                              child:
                              const Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                                children: [
                                  Text(
                                    'Get Started',

                                    style:
                                    TextStyle(
                                      fontSize:
                                      16,

                                      fontWeight:
                                      FontWeight
                                          .w800,
                                    ),
                                  ),

                                  SizedBox(
                                    width:
                                    10,
                                  ),

                                  Icon(
                                    Icons
                                        .arrow_forward_rounded,

                                    size:
                                    20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height:
                          12,
                        ),

                        // ==================================================
                        // SIGN IN BUTTON
                        // ==================================================

                        ConstrainedBox(
                          constraints:
                          const BoxConstraints(
                            maxWidth:
                            680,
                          ),

                          child:
                          SizedBox(
                            width:
                            double.infinity,

                            height:
                            58,

                            child:
                            OutlinedButton.icon(
                              onPressed:
                                  () {
                                Navigator.pushNamed(
                                  context,
                                  '/login',
                                );
                              },

                              icon:
                              const Icon(
                                Icons
                                    .login_rounded,

                                size:
                                20,
                              ),

                              label:
                              const Text(
                                'Sign In',

                                style:
                                TextStyle(
                                  fontSize:
                                  16,

                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),

                              style:
                              OutlinedButton
                                  .styleFrom(
                                foregroundColor:
                                darkGreen,

                                side:
                                const BorderSide(
                                  color:
                                  civicGreen,

                                  width:
                                  1.3,
                                ),

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height:
                          30,
                        ),

                        // ==================================================
                        // PROTOTYPE NOTICE
                        // ==================================================

                        Container(
                          width:
                          double.infinity,

                          constraints:
                          const BoxConstraints(
                            maxWidth:
                            680,
                          ),

                          padding:
                          const EdgeInsets.all(
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
                            mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                            children: [
                              Icon(
                                Icons
                                    .school_outlined,

                                color:
                                civicGreen,

                                size:
                                17,
                              ),

                              SizedBox(
                                width:
                                8,
                              ),

                              Flexible(
                                child:
                                Text(
                                  'ACADEMIC PROTOTYPE — Not an official South African government service.',

                                  textAlign:
                                  TextAlign
                                      .center,

                                  style:
                                  TextStyle(
                                    color:
                                    darkGreen,

                                    fontSize:
                                    10,

                                    fontWeight:
                                    FontWeight
                                        .w700,

                                    height:
                                    1.4,
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
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// BENEFIT ITEM
// ============================================================

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title;

  const _Benefit({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return SizedBox(
      width:
      95,

      child:
      Column(
        children: [
          Container(
            width:
            45,

            height:
            45,

            decoration:
            BoxDecoration(
              color:
              WelcomeScreen
                  .lightGreen,

              shape:
              BoxShape
                  .circle,
            ),

            child:
            Icon(
              icon,

              color:
              WelcomeScreen
                  .civicGreen,

              size:
              22,
            ),
          ),

          const SizedBox(
            height:
            8,
          ),

          Text(
            title,

            textAlign:
            TextAlign.center,

            style:
            const TextStyle(
              color:
              WelcomeScreen
                  .darkGreen,

              fontSize:
              11,

              fontWeight:
              FontWeight
                  .w700,
            ),
          ),
        ],
      ),
    );
  }
}