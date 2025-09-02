import 'notification_type.dart';

class Notification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final String? deepLink;
  final Map<String, dynamic>? data;
  final bool isRead;
  final bool isActionable;
  final String? actionText;
  final String? actionLink;
  final String? imageUrl;
  final int? priority; // 1: High, 2: Medium, 3: Low

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.deepLink,
    this.data,
    this.isRead = false,
    this.isActionable = false,
    this.actionText,
    this.actionLink,
    this.imageUrl,
    this.priority = 2,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.systemUpdate,
      ),
      deepLink: json['deepLink'],
      data: json['data'],
      isRead: json['isRead'] ?? false,
      isActionable: json['isActionable'] ?? false,
      actionText: json['actionText'],
      actionLink: json['actionLink'],
      imageUrl: json['imageUrl'],
      priority: json['priority'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'deepLink': deepLink,
      'data': data,
      'isRead': isRead,
      'isActionable': isActionable,
      'actionText': actionText,
      'actionLink': actionLink,
      'imageUrl': imageUrl,
      'priority': priority,
    };
  }

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationType? type,
    String? deepLink,
    Map<String, dynamic>? data,
    bool? isRead,
    bool? isActionable,
    String? actionText,
    String? actionLink,
    String? imageUrl,
    int? priority,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      deepLink: deepLink ?? this.deepLink,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      isActionable: isActionable ?? this.isActionable,
      actionText: actionText ?? this.actionText,
      actionLink: actionLink ?? this.actionLink,
      imageUrl: imageUrl ?? this.imageUrl,
      priority: priority ?? this.priority,
    );
  }
}