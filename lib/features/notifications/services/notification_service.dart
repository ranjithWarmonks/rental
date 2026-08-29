import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification_model.dart';

class NotificationService {
  static const String _storageKey = 'app_notifications';

  /// Get list of notifications, initializing with sample items if empty
  Future<List<AppNotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> rawList = jsonDecode(jsonStr);
        return rawList
            .map((item) => AppNotificationModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {}

    // Initial default notifications for demonstration
    final defaults = [
      AppNotificationModel(
        id: 'notif_1',
        title: 'Rental Item Return Due',
        message: 'Camera Gear Set (Order #RN-8042) is due for return today from Customer Apex Events.',
        timeAgo: '10 mins ago',
        type: NotificationType.rentalDue,
        isRead: false,
      ),
      AppNotificationModel(
        id: 'notif_2',
        title: 'Overdue Rental Alert',
        message: 'Sound System Pro (Order #RN-7921) is 2 days overdue. Follow up with Metro DJ Corp.',
        timeAgo: '2 hours ago',
        type: NotificationType.overdueAlert,
        isRead: false,
      ),
      AppNotificationModel(
        id: 'notif_3',
        title: 'Low Stock Level Notice',
        message: 'Wireless Mics stock level is low (2 units remaining in Main Warehouse).',
        timeAgo: '5 hours ago',
        type: NotificationType.stockAlert,
        isRead: true,
      ),
      AppNotificationModel(
        id: 'notif_4',
        title: 'Rental Payment Received',
        message: 'Payment of ₹15,400 received for Invoice #INV-1092 via Online Transfer.',
        timeAgo: '1 day ago',
        type: NotificationType.paymentReceived,
        isRead: true,
      ),
      AppNotificationModel(
        id: 'notif_5',
        title: 'System Feature Update',
        message: 'New Category Head management feature is now available in your More options menu.',
        timeAgo: '2 days ago',
        type: NotificationType.systemInfo,
        isRead: true,
      ),
    ];

    await saveNotifications(defaults);
    return defaults;
  }

  /// Save notifications list to SharedPreferences
  Future<void> saveNotifications(List<AppNotificationModel> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((item) => item.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Delete single notification by ID
  Future<List<AppNotificationModel>> deleteNotification(String id) async {
    final list = await getNotifications();
    list.removeWhere((item) => item.id == id);
    await saveNotifications(list);
    return list;
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Mark all notifications as read
  Future<List<AppNotificationModel>> markAllAsRead() async {
    final list = await getNotifications();
    final updated = list.map((item) => item.copyWith(isRead: true)).toList();
    await saveNotifications(updated);
    return updated;
  }
}
