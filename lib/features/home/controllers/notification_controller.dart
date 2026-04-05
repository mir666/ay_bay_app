import 'package:ay_bay_app/features/common/models/app_notification.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  // List of notifications
  var notifications = <AppNotification>[].obs;

  // Unread count
  var unreadCount = 0.obs;

  // Add new notification
  void addNotification(String title, String body) {
    notifications.add(AppNotification(title: title, body: body));
    unreadCount.value++;
  }

  // Mark all as read
  void markAllRead() {
    unreadCount.value = 0;
  }
}