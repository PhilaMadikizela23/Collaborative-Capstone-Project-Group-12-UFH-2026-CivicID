import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String type; // 'User' or 'Admin'

  const NotificationsScreen({
    super.key,
    this.type = 'User',
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  // ============================================================
  // CIVICID COLORS
  // ============================================================

  static const Color civicGreen = Color(0xFF08783E);
  static const Color darkGreen = Color(0xFF04542C);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color pageBackground = Color(0xFFF8FBF9);
  static const Color borderColor = Color(0xFFDDE7E1);
  static const Color textGrey = Color(0xFF66756E);

  final NotificationService _notificationService =
  NotificationService();

  late Future<List<AppNotification>> _notificationsFuture;

  String _filter = 'All';

  bool _markingAll = false;

  // ============================================================
  // INITIAL LOAD
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture =
          _notificationService.getNotifications(
            type: widget.type,
          );
    });
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  Future<void> _markAsRead(
      AppNotification notification,
      ) async {
    if (notification.isRead) return;

    await _notificationService.markAsRead(
      notification.id,
    );

    if (!mounted) return;

    _loadNotifications();
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> _markAllAsRead() async {
    if (_markingAll) return;

    setState(() {
      _markingAll = true;
    });

    try {
      await _notificationService.markAllAsRead(
        type: widget.type,
      );

      if (!mounted) return;

      _loadNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: civicGreen,
          content: Text(
            'All notifications marked as read.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _markingAll = false;
        });
      }
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<AppNotification> _filterNotifications(
      List<AppNotification> notifications,
      ) {
    if (_filter == 'Unread') {
      return notifications
          .where(
            (notification) =>
        !notification.isRead,
      )
          .toList();
    }

    if (_filter == 'Read') {
      return notifications
          .where(
            (notification) =>
        notification.isRead,
      )
          .toList();
    }

    return notifications;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              widget.type == 'Admin'
                  ? 'CivicID Admin Portal'
                  : 'CivicID Citizen Portal',
              style: const TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadNotifications,
            icon: const Icon(
              Icons.refresh_rounded,
              color: civicGreen,
            ),
          ),

          const SizedBox(width: 5),
        ],
      ),

      body: FutureBuilder<List<AppNotification>>(
        future: _notificationsFuture,
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: civicGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final notifications =
              snapshot.data ?? [];

          notifications.sort(
                (a, b) => b.timestamp.compareTo(
              a.timestamp,
            ),
          );

          return RefreshIndicator(
            color: civicGreen,
            onRefresh: () async {
              _loadNotifications();

              await Future.delayed(
                const Duration(
                  milliseconds: 400,
                ),
              );
            },
            child: _buildContent(
              notifications,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(
      List<AppNotification> notifications,
      ) {
    final unreadCount = notifications
        .where(
          (notification) =>
      !notification.isRead,
    )
        .length;

    final filtered =
    _filterNotifications(
      notifications,
    );

    return ListView(
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
          child: Container(
            constraints:
            const BoxConstraints(
              maxWidth: 900,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(
                  notifications.length,
                  unreadCount,
                ),

                const SizedBox(height: 22),

                _buildFilters(),

                const SizedBox(height: 22),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Recent Notifications',
                        style: TextStyle(
                          color:
                          Color(0xFF14251C),
                          fontSize: 19,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                    ),

                    if (unreadCount > 0)
                      TextButton.icon(
                        onPressed: _markingAll
                            ? null
                            : _markAllAsRead,
                        icon: _markingAll
                            ? const SizedBox(
                          width: 14,
                          height: 14,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                            civicGreen,
                          ),
                        )
                            : const Icon(
                          Icons
                              .done_all_rounded,
                          size: 17,
                        ),
                        label: const Text(
                          'MARK ALL READ',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                        style: TextButton
                            .styleFrom(
                          foregroundColor:
                          civicGreen,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  widget.type == 'Admin'
                      ? 'System and citizen activity notifications appear here.'
                      : 'Application, document and administrator updates appear here.',
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ...filtered.map(
                    _buildNotificationCard,
                  ),

                const SizedBox(height: 20),

                _buildPrototypeNotice(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeaderCard(
      int total,
      int unread,
      ) {
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
        borderRadius:
        BorderRadius.circular(22),
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final small =
              constraints.maxWidth < 520;

          final information = Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Stay Updated',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                widget.type == 'Admin'
                    ? 'Keep track of important CivicID administrative activity.'
                    : 'Keep track of your CivicID application and document updates.',
                style: TextStyle(
                  color: Colors.white
                      .withValues(
                    alpha: 0.86,
                  ),
                  fontSize: 10,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 15),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _headerBadge(
                    '$total TOTAL',
                  ),
                  _headerBadge(
                    '$unread UNREAD',
                  ),
                ],
              ),
            ],
          );

          if (small) {
            return information;
          }

          return Row(
            children: [
              Expanded(
                child: information,
              ),

              const SizedBox(width: 20),

              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .notifications_active_outlined,
                  color: Colors.white,
                  size: 39,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _headerBadge(
      String text,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.13,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight:
          FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    const filters = [
      'All',
      'Unread',
      'Read',
    ];

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,
      child: Row(
        children:
        filters.map((filter) {
          final selected =
              _filter == filter;

          return Padding(
            padding:
            const EdgeInsets.only(
              right: 8,
            ),
            child: ChoiceChip(
              selected: selected,
              label: Text(filter),
              selectedColor:
              civicGreen,
              backgroundColor:
              Colors.white,
              side: BorderSide(
                color: selected
                    ? civicGreen
                    : borderColor,
              ),
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : textGrey,
                fontSize: 10,
                fontWeight:
                FontWeight.w700,
              ),
              onSelected: (_) {
                setState(() {
                  _filter = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _buildNotificationCard(
      AppNotification notification,
      ) {
    final unread =
    !notification.isRead;

    final icon =
    _notificationIcon(
      notification.title,
    );

    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 11,
      ),
      decoration: BoxDecoration(
        color: unread
            ? lightGreen
            : Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: unread
              ? const Color(
            0xFFCFE5D7,
          )
              : borderColor,
        ),
      ),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(18),
        onTap: () =>
            _markAsRead(
              notification,
            ),
        child: Padding(
          padding:
          const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration:
                BoxDecoration(
                  color: unread
                      ? Colors.white
                      : lightGreen,
                  borderRadius:
                  BorderRadius
                      .circular(13),
                ),
                child: Icon(
                  icon,
                  color: civicGreen,
                  size: 21,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification
                                .title,
                            style:
                            TextStyle(
                              color:
                              darkGreen,
                              fontSize: 12,
                              fontWeight:
                              unread
                                  ? FontWeight
                                  .w900
                                  : FontWeight
                                  .w700,
                            ),
                          ),
                        ),

                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration:
                            const BoxDecoration(
                              color:
                              civicGreen,
                              shape:
                              BoxShape
                                  .circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      notification
                          .message,
                      style:
                      const TextStyle(
                        color: textGrey,
                        fontSize: 10,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(
                      height: 9,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .schedule_rounded,
                          color:
                          textGrey,
                          size: 13,
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Expanded(
                          child: Text(
                            DateFormat(
                              'dd MMM yyyy • HH:mm',
                            ).format(
                              notification
                                  .timestamp,
                            ),
                            style:
                            const TextStyle(
                              color:
                              textGrey,
                              fontSize: 8,
                            ),
                          ),
                        ),

                        Text(
                          unread
                              ? 'UNREAD'
                              : 'READ',
                          style:
                          TextStyle(
                            color: unread
                                ? civicGreen
                                : textGrey,
                            fontSize: 8,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _notificationIcon(
      String title,
      ) {
    final text =
    title.toLowerCase();

    if (text.contains(
      'approved',
    ) ||
        text.contains(
          'verified',
        )) {
      return Icons
          .check_circle_outline_rounded;
    }

    if (text.contains(
      'rejected',
    ) ||
        text.contains(
          'attention',
        )) {
      return Icons
          .error_outline_rounded;
    }

    if (text.contains(
      'more information',
    )) {
      return Icons
          .help_outline_rounded;
    }

    if (text.contains(
      'review',
    )) {
      return Icons
          .manage_search_rounded;
    }

    if (text.contains(
      'application',
    )) {
      return Icons
          .description_outlined;
    }

    if (text.contains(
      'document',
    )) {
      return Icons
          .file_present_outlined;
    }

    if (text.contains(
      'comment',
    )) {
      return Icons
          .chat_bubble_outline_rounded;
    }

    return Icons
        .notifications_none_rounded;
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 55,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration:
            const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .notifications_none_rounded,
              color: civicGreen,
              size: 42,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            _filter == 'Unread'
                ? 'No Unread Notifications'
                : _filter == 'Read'
                ? 'No Read Notifications'
                : 'No Notifications Yet',
            style:
            const TextStyle(
              color: darkGreen,
              fontSize: 18,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'Important CivicID updates will appear here.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color: textGrey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              color:
              Color(0xFFB3261E),
              size: 50,
            ),

            const SizedBox(
              height: 14,
            ),

            const Text(
              'Unable to load notifications.',
              style: TextStyle(
                color: darkGreen,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            OutlinedButton.icon(
              onPressed:
              _loadNotifications,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'TRY AGAIN',
              ),
              style: OutlinedButton
                  .styleFrom(
                foregroundColor:
                civicGreen,
              ),
            ),
          ],
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
      padding:
      const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color:
        const Color(0xFFF1F5F2),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.school_outlined,
            color: textGrey,
            size: 18,
          ),

          SizedBox(width: 9),

          Expanded(
            child: Text(
              'Academic Prototype — Notifications displayed by CivicID are demonstration messages and are not official government notifications.',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}