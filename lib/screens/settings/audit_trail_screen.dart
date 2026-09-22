import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/mock_data.dart';

class AuditTrailScreen extends StatelessWidget {
  const AuditTrailScreen({super.key});

  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);

  @override
  Widget build(BuildContext context) {
    final auditEvents =
        MockData().auditEvents;

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit Trail',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'CivicID activity history',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          40,
        ),
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 850,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _header(
                    auditEvents.length,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      color: Color(0xFF14251C),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (auditEvents.isEmpty)
                    _emptyState()
                  else
                    ...auditEvents.map(
                          (event) => Container(
                        margin:
                        const EdgeInsets.only(
                          bottom: 10,
                        ),
                        padding:
                        const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                            17,
                          ),
                          border: Border.all(
                            color: borderColor,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration:
                              BoxDecoration(
                                color: lightGreen,
                                borderRadius:
                                BorderRadius
                                    .circular(12),
                              ),
                              child: const Icon(
                                Icons.history_rounded,
                                color: civicGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    event.eventType,
                                    style:
                                    const TextStyle(
                                      color: darkGreen,
                                      fontSize: 11,
                                      fontWeight:
                                      FontWeight
                                          .w800,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    event.description,
                                    style:
                                    const TextStyle(
                                      color: textGrey,
                                      fontSize: 9,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd MMM yyyy • HH:mm:ss',
                                    ).format(
                                      event.timestamp,
                                    ),
                                    style:
                                    const TextStyle(
                                      color: textGrey,
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 15),
                  _prototypeNotice(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            darkGreen,
            civicGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Review actions recorded inside the CivicID prototype.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            color: civicGreen,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'No Activity Yet',
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _prototypeNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Text(
        'Academic Prototype — Audit events are demonstration records generated within CivicID.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textGrey,
          fontSize: 9,
        ),
      ),
    );
  }
}