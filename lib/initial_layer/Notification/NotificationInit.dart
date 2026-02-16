import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:signals/signals.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class LocalNotificationService {
  // 1. Create the plugin instance
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Whether notifications are currently enabled
  final notificationsEnabled = signal<bool>(true);

  Future<void> init() async {
    // Initialize Timezones
    try {
      tz.initializeTimeZones();
      dynamic timeZoneName = await FlutterTimezone.getLocalTimezone();

      // Convert to string safely to handle Object return types
      String timeZoneString = timeZoneName.toString();

      // Clean up timezone string if it comes in a wrapper format (e.g. on some macOS setups)
      if (timeZoneString.startsWith("TimezoneInfo(")) {
        // Format: TimezoneInfo(ID, ...)
        final parts = timeZoneString.split(',');
        if (parts.isNotEmpty) {
          timeZoneString = parts[0].replaceAll("TimezoneInfo(", "").trim();
        }
      }

      try {
        tz.setLocalLocation(tz.getLocation(timeZoneString));
      } catch (e) {
        print("Error setting local location '$timeZoneString': $e");
        // Fallback to UTC or a known timezone if local fails
        try {
          tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
        } catch (_) {
          tz.setLocalLocation(tz.UTC);
        }
      }
    } catch (e) {
      print("Timezone initialization failed: $e");
      // Ensure local is set to avoid crashes later
      try {
        tz.setLocalLocation(tz.UTC);
      } catch (_) {}
    }

    // 2. Android Initialization Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS Initialization Settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          macOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle tap logic here
      },
    );

    // Schedule daily briefing
    await scheduleDailyNotification();
  }

  /// Toggle notifications on or off
  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled.value = enabled;
    if (enabled) {
      await scheduleDailyNotification();
      print('🔔 Notifications enabled');
    } else {
      await cancelAllNotifications();
      print('🔕 Notifications disabled');
    }
  }

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleDailyNotification() async {
    if (!notificationsEnabled.value) return;

    await _notificationsPlugin.zonedSchedule(
      id: 888,
      title: 'Good Morning! ☀️',
      body: 'Check your widgets for today\'s updates.',
      scheduledDate: _nextInstanceOfSevenAM(),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Reminder',
          channelDescription: 'Daily 7 AM briefing',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfSevenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      7,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // 4. Show a simple notification (respects enabled toggle)
  Future<void> showNotification(int id, String title, String body) async {
    if (!notificationsEnabled.value) return;

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel', // Channel ID
          'Main Channel', // Channel Name
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }
}
