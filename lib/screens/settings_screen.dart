import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_task.dart';
import '../services/notification_service.dart';
import '../services/task_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final Map<String, TimeOfDay> _times = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _phoneCtrl.text = await TaskStore.getPhone();
    _emailCtrl.text = await TaskStore.getEmail();
    final prefs = await SharedPreferences.getInstance();
    for (final p in kDefaultSchedule) {
      final override = prefs.getString('time_${p.taskId}');
      if (override != null) {
        final parts = override.split(':');
        _times[p.taskId] = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } else {
        _times[p.taskId] = TimeOfDay(hour: p.hour, minute: p.minute);
      }
    }
    setState(() {});
  }

  Future<void> _saveContact() async {
    await TaskStore.saveContact(phone: _phoneCtrl.text.trim(), email: _emailCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact saved.')),
      );
    }
  }

  Future<void> _pickTime(String taskId, TimeOfDay current) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    setState(() => _times[taskId] = picked);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'time_$taskId', '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    await NotificationService().scheduleAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule updated.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Nudge Contact', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'WhatsApp number (with country code, e.g. 923001234567)',
              prefixIcon: Icon(Icons.chat),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saveContact,
            icon: const Icon(Icons.save),
            label: const Text('Save Contact'),
          ),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily Prompt Times', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: () async {
                  await NotificationService().scheduleAll();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All daily prompts scheduled.')),
                    );
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reschedule'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...kDefaultSchedule.map((p) {
            final t = _times[p.taskId] ?? TimeOfDay(hour: p.hour, minute: p.minute);
            final task = kDefaultTasks.firstWhere((e) => e.id == p.taskId,
                orElse: () => kDefaultTasks.first);
            return Card(
              child: ListTile(
                leading: Text(task.emoji, style: const TextStyle(fontSize: 22)),
                title: Text(p.title),
                subtitle: const Text('Tap to change prompt time'),
                trailing: Text(
                  t.format(context),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onTap: () => _pickTime(p.taskId, t),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text(
            'Note: For notifications to fire while the app is closed, allow '
            'background/scheduled notifications in your system settings. '
            'WhatsApp nudges open WhatsApp with the message prefilled.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
