class DailyTask {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String category; // worship | family | work | charity
  final String? promptMessage; // message used for WhatsApp/Email nudges

  const DailyTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.category,
    this.promptMessage,
  });
}

/// The agent's built-in daily mission list.
const List<DailyTask> kDefaultTasks = [
  DailyTask(
    id: 'fajr',
    title: 'Pray Fajr',
    subtitle: 'Start the day with the dawn prayer',
    emoji: '🌅',
    category: 'worship',
    promptMessage: 'Time for Fajr! Begin your day in prayer. 🌅',
  ),
  DailyTask(
    id: 'sadaqah',
    title: 'Give Sadaqah',
    subtitle: 'Even a small amount — it protects you',
    emoji: '🤲',
    category: 'charity',
    promptMessage: 'Have you given sadaqah today? Even a little counts. 🤲',
  ),
  DailyTask(
    id: 'good_deed',
    title: 'One Good Deed',
    subtitle: "Smile, forgive, or make du'a for someone",
    emoji: '✨',
    category: 'charity',
    promptMessage: 'One good deed a day keeps the heart soft. What will yours be? ✨',
  ),
  DailyTask(
    id: 'help_someone',
    title: 'Help Someone',
    subtitle: 'Family, neighbour, colleague — ease a burden',
    emoji: '🤝',
    category: 'charity',
    promptMessage: 'Who can you help today? A small favour goes a long way. 🤝',
  ),
  DailyTask(
    id: 'dhuhr',
    title: 'Pray Dhuhr',
    subtitle: 'Pause the day, return to remembrance',
    emoji: '🕌',
    category: 'worship',
    promptMessage: 'Dhuhr time — step away and pray. 🕌',
  ),
  DailyTask(
    id: 'parents',
    title: 'Give Time to Parents',
    subtitle: "Call them, sit with them, or make du'a for them",
    emoji: '👨‍👩‍👧',
    category: 'family',
    promptMessage: 'Your parents miss you. Give them a call or a moment today. 👨‍👩‍👧',
  ),
  DailyTask(
    id: 'asr',
    title: 'Pray Asr',
    subtitle: 'Guard the middle prayer',
    emoji: '🌤️',
    category: 'worship',
    promptMessage: 'Asr time — do not delay the prayer. 🌤️',
  ),
  DailyTask(
    id: 'family_time',
    title: 'Spouse & Children Time',
    subtitle: 'Undivided attention — no phone, no work',
    emoji: '💞',
    category: 'family',
    promptMessage: 'Put the phone down. Give your spouse & children your full heart today. 💞',
  ),
  DailyTask(
    id: 'maghrib',
    title: 'Pray Maghrib',
    subtitle: 'Close the day as it began',
    emoji: '🌇',
    category: 'worship',
    promptMessage: 'Maghrib time — sunset belongs to Allah. 🌇',
  ),
  DailyTask(
    id: 'project_work',
    title: 'Project Work',
    subtitle: 'Focused deep work — one meaningful block',
    emoji: '🛠️',
    category: 'work',
    promptMessage: 'Time block for your project! 25 focused minutes, starting now. 🛠️',
  ),
  DailyTask(
    id: 'isha',
    title: 'Pray Isha',
    subtitle: 'End the day in peace',
    emoji: '🌙',
    category: 'worship',
    promptMessage: 'Isha time — end your day in prayer and reflection. 🌙',
  ),
  DailyTask(
    id: 'reflection',
    title: 'Night Reflection',
    subtitle: 'What did you achieve today? Plan tomorrow',
    emoji: '📓',
    category: 'work',
    promptMessage: 'Before sleep: reflect on today, plan tomorrow, say Alhamdulillah. 📓',
  ),
];
