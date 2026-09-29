import 'package:flutter/material.dart';
import '../models/daily_task.dart';
import '../services/notification_service.dart';
import '../services/prompt_service.dart';
import '../services/task_store.dart';
import '../widgets/task_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<String> _completed = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await TaskStore.clearOldDays();
    final done = await TaskStore.loadCompleted();
    setState(() => _completed = done);
  }

  List<DailyTask> get _visibleTasks {
    if (_selectedIndex == 0) return kDefaultTasks;
    const cats = ['worship', 'charity', 'family', 'work'];
    return kDefaultTasks.where((t) => t.category == cats[_selectedIndex - 1]).toList();
  }

  Future<void> _nudge(DailyTask task) async {
    final phone = await TaskStore.getPhone();
    final email = await TaskStore.getEmail();
    if (!mounted) return;

    final message = task.promptMessage ?? task.title;
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('Send a nudge: "${task.title}"',
                style: Theme.of(ctx).textTheme.titleMedium),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
              title: const Text('WhatsApp'),
              subtitle: Text(phone.isEmpty ? 'Pick a chat manually' : 'To: $phone'),
              onTap: () => Navigator.pop(ctx, 'whatsapp'),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFFEA4335)),
              title: const Text('Email'),
              subtitle: Text(email.isEmpty ? 'Set email in Settings' : 'To: $email'),
              onTap: () => Navigator.pop(ctx, 'email'),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy message'),
              onTap: () => Navigator.pop(ctx, 'copy'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (choice == 'whatsapp') {
      await PromptService.sendWhatsApp(message: message, phone: phone);
    } else if (choice == 'email') {
      if (email.isEmpty) {
        _showSnack('Set your email in Settings first.');
        return;
      }
      await PromptService.sendEmail(
        email: email,
        subject: 'Amanah Agent Reminder: ${task.title}',
        body: message,
      );
    } else if (choice == 'copy') {
      await PromptService.copyToClipboard(message);
      _showSnack('Copied to clipboard.');
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final visible = _visibleTasks;
    final doneCount = visible.where((t) => _completed.contains(t.id)).length;
    final progress = visible.isEmpty ? 0.0 : doneCount / visible.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🤲 Amanah Agent'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(progress, doneCount, visible.length),
          _buildFilterChips(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: visible.length,
                itemBuilder: (_, i) {
                  final task = visible[i];
                  return TaskCard(
                    task: task,
                    completed: _completed.contains(task.id),
                    onToggle: () async {
                      await TaskStore.toggle(task.id);
                      await _load();
                    },
                    onNudge: () => _nudge(task),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await NotificationService().showInstant(
            '🤲 Amanah Agent',
            '${kDefaultTasks.length - _completed.length} missions remaining today. Keep going!',
          );
        },
        icon: const Icon(Icons.notifications_active),
        label: const Text('Agent Status'),
      ),
    );
  }

  Widget _buildHeader(double progress, int done, int total) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E6B5C), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
                Text('${(progress * 100).round()}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Mission",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text('$done of $total complete',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  progress == 1.0
                      ? 'MashaAllah — all done! 🎉'
                      : 'Your agent is watching over your day.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    const labels = ['All', 'Worship', 'Charity', 'Family', 'Work'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ChoiceChip(
          label: Text(labels[i]),
          selected: _selectedIndex == i,
          onSelected: (_) => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }
}
