import 'package:get/get.dart';

class NotificationController extends GetxController {
  // List of notifications
  var notifications = <String>[].obs;

  // Unread count
  var unreadCount = 0.obs;

  // Add new notification
  void addNotification(String message) {
    notifications.add(message);
    unreadCount.value++;
  }

  // Mark all as read
  void markAllRead() {
    unreadCount.value = 0;
  }
}
