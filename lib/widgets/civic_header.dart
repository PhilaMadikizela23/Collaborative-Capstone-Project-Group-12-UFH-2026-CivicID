import 'package:flutter/material.dart';

class CivicHeader extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onMenuTap;
  final int unreadCount;

  const CivicHeader({
    super.key,
    required this.onHomeTap,
    required this.onNotificationsTap,
    required this.onMenuTap,
    this.unreadCount = 0,
  });

  static const Color civicGreen = Color(0xFF08783E);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: civicGreen,
      elevation: 3,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: onHomeTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.14,
                          ),
                          borderRadius:
                          BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CivicID',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight:
                              FontWeight.w900,
                              height: 1,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'Your Digital Citizen Profile',
                            style: TextStyle(
                              color: Color(0xFFEAF7EF),
                              fontSize: 10,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              IconButton(
                onPressed: onNotificationsTap,
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  backgroundColor: Colors.red,
                  smallSize: 8,
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),

              IconButton(
                onPressed: onMenuTap,
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}