enum NotificationType {
  rentalDue,
  overdueAlert,
  stockAlert,
  paymentReceived,
  systemInfo,
}

class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final NotificationType type;
  final bool isRead;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.type = NotificationType.systemInfo,
    this.isRead = false,
  });

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    NotificationType? type,
    bool? isRead,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ?? json['timeAgo']?.toString() ?? 'Just now',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.systemInfo,
      ),
      isRead: json['is_read'] ?? json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time_ago': timeAgo,
      'type': type.name,
      'is_read': isRead,
    };
  }
}
