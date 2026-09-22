import 'mock_data.dart';
import 'sound_service.dart';
import '../models/notification.dart';

class NotificationService {
  final MockData _mockData = MockData();
  static final List<Function(String, String)> _listeners = [];

  static void addGlobalListener(Function(String, String) listener) {
    _listeners.add(listener);
  }

  Future<List<AppNotification>> getNotifications({String type = 'User'}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockData.notifications.where((n) => n.targetType == type).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockData.notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _mockData.notifications[index] = _mockData.notifications[index].copyWith(isRead: true);
    }
  }

  Future<void> markAllAsRead({String type = 'User'}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (int i = 0; i < _mockData.notifications.length; i++) {
      if (_mockData.notifications[i].targetType == type) {
        _mockData.notifications[i] = _mockData.notifications[i].copyWith(isRead: true);
      }
    }
  }

  Future<int> getUnreadCount({String type = 'User'}) async {
    return _mockData.notifications.where((n) => !n.isRead && n.targetType == type).length;
  }

  Future<void> addNotification(String title, String message, {String targetType = 'User'}) async {
    _mockData.notifications.insert(0, AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
      targetType: targetType,
    ));
    
    // Play notification sound automatically
    await SoundService.playNotificationSound();

    // Trigger listeners for "outside of app" effect
    for (var listener in _listeners) {
      listener(title, message);
    }
  }
}
