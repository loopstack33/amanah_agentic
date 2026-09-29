import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';
import '../models/daily_task.dart';

class ScheduledPrompt {
  final int id;
  final String taskId;
  final String title;
  final String body;
  final int hour;
  final int minute;

  const ScheduledPrompt({
    required this.id,
    required this.taskId,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
  });
}

/// Default daily schedule (times are editable in Settings).
final List<ScheduledPrompt> kDefaultSchedule = [
  ScheduledPrompt(id: 101, taskId: 'fajr',        title: '🌅 Fajr',              body: 'Begin your day with prayer.',                    hour: 5,  minute: 0),
  ScheduledPrompt(id: 102, taskId: 'sadaqah',     title: '🤲 Sadaqah',           body: 'Give something today — even a smile is charity.', hour: 8,  minute: 30),
  ScheduledPrompt(id: 103, taskId: 'good_deed',   title: '✨ Good Deed',         body: 'Do one hidden good deed today.',                 hour: 10, minute: 0),
  ScheduledPrompt(id: 104, taskId: 'dhuhr',       title: '🕌 Dhuhr',             body: 'Pause and pray Dhuhr.',                          hour: 13, minute: 15),
  ScheduledPrompt(id: 105, taskId: 'help_someone',title: '🤝 Help Someone',      body: "Ease someone's burden today.",                  hour: 14, minute: 30),
  ScheduledPrompt(id: 106, taskId: 'parents',     title: '👨‍👩‍👧 Parents',          body: 'Call or sit with your parents.',                 hour: 17, minute: 0),
  ScheduledPrompt(id: 107, taskId: 'asr',         title: '🌤️ Asr',              body: 'Guard the middle prayer.',                       hour: 16, minute: 30),
  ScheduledPrompt(id: 108, taskId: 'family_time', title: '💞 Family Time',       body: 'Undivided attention for spouse & children.',     hour: 19, minute: 30),
  ScheduledPrompt(id: 109, taskId: 'maghrib',     title: '🌇 Maghrib',           body: 'Pray Maghrib as the sun sets.',                  hour: 18, minute: 45),
  ScheduledPrompt(id: 110, taskId: 'project_work',title: '🛠️ Project Time',      body: 'One focused block on your project — 25 min.',    hour: 21, minute: 0),
  ScheduledPrompt(id: 111, taskId: 'isha',        title: '🌙 Isha',              body: 'End the day in peace.',                          hour: 20, minute: 15),
  ScheduledPrompt(id: 112, taskId: 'reflection',  title: '📓 Night Reflection',  body: 'Reflect on today. Plan tomorrow.',               hour: 22, minute: 0),
];

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    await notificationsPlugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Schedules (or reschedules) all daily prompts.
  Future<void> scheduleAll() async {
    final prefs = await SharedPreferences.getInstance();
    await notificationsPlugin.cancelAll();

    for (final p in kDefaultSchedule) {
      final override = prefs.getString('time_${p.taskId}');
      var hour = p.hour;
      var minute = p.minute;
      if (override != null) {
        final parts = override.split(':');
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);
      }
      await notificationsPlugin.zonedSchedule(
        id: p.id,
        title: p.title,
        body: p.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'amanah_daily', 'Daily Prompts',
            channelDescription: "Your personal agent's daily reminders",
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        scheduledDate: _nextInstanceOf(hour, minute),
      );
    }
  }

  /// Sends an instant "nudge" notification (used when prompting via WhatsApp/Email).
  Future<void> showInstant(String title, String body) async {
    await notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'amanah_nudge', 'Instant Nudges',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
