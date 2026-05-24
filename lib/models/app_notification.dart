enum NotificationKind { order, promo, product, system }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.kind,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationKind kind;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      kind: kind,
      isRead: isRead ?? this.isRead,
    );
  }
}
