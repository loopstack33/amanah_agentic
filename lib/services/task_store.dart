import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_task.dart';

/// Persists daily task completion state, keyed by date so each day resets.
class TaskStore {
  static const _key = 'completed_tasks';

  static String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  static Future<Set<String>> loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_key$_todayKey');
    if (raw == null) return {};
    return Set<String>.from(jsonDecode(raw) as List);
  }

  static Future<void> toggle(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await loadCompleted();
    if (completed.contains(taskId)) {
      completed.remove(taskId);
    } else {
      completed.add(taskId);
    }
    await prefs.setString('$_key$_todayKey', jsonEncode(completed.toList()));
  }

  static Future<void> clearOldDays() async {
    final prefs = await SharedPreferences.getInstance();
    // Clean up keys older than today (best-effort housekeeping).
    final keys = prefs.getKeys().where((k) => k.startsWith('$_key')).toList();
    final today = _todayKey();
    for (final k in keys) {
      if (k != '$_key$today') await prefs.remove(k);
    }
  }

  static Future<void> saveContact({String? phone, String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    if (phone != null) await prefs.setString('contact_phone', phone);
    if (email != null) await prefs.setString('contact_email', email);
  }

  static Future<String> getPhone() async =>
      (await SharedPreferences.getInstance()).getString('contact_phone') ?? '';

  static Future<String> getEmail() async =>
      (await SharedPreferences.getInstance()).getString('contact_email') ?? '';
}
