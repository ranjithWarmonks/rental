import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_dialog.dart';
import 'package:rental/shared/widgets/app_text.dart';
import '../models/app_notification_model.dart';
import '../services/notification_service.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<AppNotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await NotificationService().getNotifications();
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(int index, AppNotificationModel item) async {
    setState(() {
      _notifications.removeAt(index);
    });

    await NotificationService().saveNotifications(_notifications);

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification dismissed',
          style: const TextStyle(fontFamily: 'Urbanist'),
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: buttonColor1,
          onPressed: () async {
            setState(() {
              _notifications.insert(index, item);
            });
            await NotificationService().saveNotifications(_notifications);
          },
        ),
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    final list = await NotificationService().markAllAsRead();
    if (mounted) {
      setState(() {
        _notifications = list;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read', style: TextStyle(fontFamily: 'Urbanist')),
          backgroundColor: buttonColor1,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _clearAllNotifications() async {
    AppDialog.show(
      context: context,
      title: 'Clear Notifications',
      message: 'Are you sure you want to clear all notifications?',
      type: AppDialogType.warning,
      primaryButtonText: 'Clear All',
      secondaryButtonText: 'Cancel',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        await NotificationService().clearAll();
        if (mounted) {
          setState(() {
            _notifications.clear();
          });
        }
      },
    );
  }

  Widget _buildTypeIcon(NotificationType type) {
    IconData icon;
    Color bg;
    Color fg;

    switch (type) {
      case NotificationType.rentalDue:
        icon = Icons.event_available_rounded;
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        break;
      case NotificationType.overdueAlert:
        icon = Icons.warning_amber_rounded;
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      case NotificationType.stockAlert:
        icon = Icons.inventory_2_outlined;
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case NotificationType.paymentReceived:
        icon = Icons.payments_outlined;
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        break;
      case NotificationType.systemInfo:
        icon = Icons.info_outline_rounded;
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF9333EA);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: fg, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const AppText.h2('Notifications', fontSize: 20),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: buttonColor1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount new',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: primaryColor),
              onSelected: (value) {
                if (value == 'mark_read') {
                  _markAllAsRead();
                } else if (value == 'clear_all') {
                  _clearAllNotifications();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all_rounded, size: 18, color: primaryColor),
                      SizedBox(width: 10),
                      Text('Mark all as read', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text('Clear all', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(buttonColor1),
              ),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_off_outlined,
                            size: 56,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppText.h3('No Notifications', fontSize: 18),
                        const SizedBox(height: 8),
                        AppText.caption(
                          'You are all caught up! Check back later for alerts, returns, and inventory reminders.',
                          textAlign: TextAlign.center,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Hint bar explaining swipe to delete
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      color: primaryColor.withValues(alpha: 0.04),
                      child: Row(
                        children: [
                          Icon(Icons.swipe_rounded, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Swipe horizontal on any notification to delete',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: _notifications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.horizontal,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                                ],
                              ),
                            ),
                            onDismissed: (direction) {
                              _deleteItem(index, item);
                            },
                            child: Material(
                              color: item.isRead ? Colors.white : const Color(0xFFF0FDF4),
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: item.isRead
                                      ? Colors.grey.shade200
                                      : buttonColor1.withValues(alpha: 0.3),
                                ),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  if (!item.isRead) {
                                    setState(() {
                                      _notifications[index] = item.copyWith(isRead: true);
                                    });
                                    await NotificationService().saveNotifications(_notifications);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildTypeIcon(item.type),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.title,
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontWeight: item.isRead
                                                          ? FontWeight.w600
                                                          : FontWeight.bold,
                                                      fontSize: 15,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                ),
                                                if (!item.isRead) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      color: buttonColor1,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.message,
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 13,
                                                color: Colors.grey.shade700,
                                                height: 1.3,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item.timeAgo,
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w500,
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
