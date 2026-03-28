import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/todo.dart';

class MoonlightNotifications {
  MoonlightNotifications._();

  static final MoonlightNotifications instance = MoonlightNotifications._();
  static const String _channelId = 'moonlight_todo_reminder';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _permissionGranted = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      try {
        final timezoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezoneName));
        debugPrint('[Notifications] timezone: $timezoneName');
      } catch (e) {
        tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
        debugPrint('[Notifications] timezone fallback to Asia/Shanghai: $e');
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      final ok = await _plugin.initialize(settings);
      debugPrint('[Notifications] initialized: $ok');

      // Create notification channel explicitly
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // Create the channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            '月光手账提醒',
            description: '日程开始前提醒',
            importance: Importance.max,
          ),
        );
        debugPrint('[Notifications] channel created');

        // Request permissions
        final notifPermission = await androidPlugin.requestNotificationsPermission();
        debugPrint('[Notifications] notification permission: $notifPermission');
        _permissionGranted = notifPermission ?? false;

        final alarmPermission = await androidPlugin.requestExactAlarmsPermission();
        debugPrint('[Notifications] exact alarm permission: $alarmPermission');
      }

      _initialized = true;
      debugPrint('[Notifications] fully initialized, permission=$_permissionGranted');
    } catch (e) {
      debugPrint('[Notifications] ERROR during init: $e');
    }
  }

  bool get hasPermission => _permissionGranted;

  NotificationDetails get _details => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      '月光手账提醒',
      channelDescription: '日程开始前提醒',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
  );

  int notificationIdFor(String todoId) {
    var value = 0;
    for (final code in todoId.codeUnits) {
      value = ((value * 31) + code) & 0x7fffffff;
    }
    return value;
  }

  /// Send a test notification immediately to verify the channel works
  Future<bool> sendTestNotification() async {
    if (!_initialized) await initialize();
    try {
      await _plugin.show(
        999999,
        '🌙 月光手账',
        '通知测试成功！你可以收到提醒啦 ✨',
        _details,
      );
      return true;
    } catch (e) {
      debugPrint('[Notifications] test failed: $e');
      return false;
    }
  }

  Future<void> syncTodoNotifications(List<AppTodo> todos) async {
    for (final todo in todos) {
      await cancelTodo(todo.id);
      await scheduleTodo(todo);
    }
  }

  Future<void> scheduleTodo(AppTodo todo) async {
    if (!_initialized) await initialize();
    if (todo.isDone || !todo.hasExplicitTime || todo.reminderMinutes <= 0) {
      return;
    }
    final now = DateTime.now();
    final scheduledAt = todo.date.subtract(
      Duration(minutes: todo.reminderMinutes),
    );
    final notificationId = notificationIdFor(todo.id);

    debugPrint('[Notifications] scheduling "${todo.title}" at $scheduledAt (now=$now)');

    if (!scheduledAt.isAfter(now)) {
      debugPrint('[Notifications] time passed, showing immediately');
      await _plugin.show(
        notificationId,
        '🌙 月光手账提醒',
        todo.title,
        _details,
        payload: todo.id,
      );
      return;
    }

    await _plugin.zonedSchedule(
      notificationId,
      '🌙 月光手账提醒',
      todo.title,
      tz.TZDateTime.from(scheduledAt, tz.local),
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: todo.id,
    );
    debugPrint('[Notifications] scheduled for $scheduledAt');
  }

  Future<void> cancelTodo(String todoId) =>
      _plugin.cancel(notificationIdFor(todoId));
}
