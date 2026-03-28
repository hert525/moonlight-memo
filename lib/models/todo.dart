import 'dart:math';

import 'package:intl/intl.dart';

class TodoCategory {
  TodoCategory({required this.name, required this.iconAsset});

  String name;
  String iconAsset;

  Map<String, dynamic> toJson() => {'name': name, 'iconAsset': iconAsset};

  factory TodoCategory.fromJson(Map<String, dynamic> json) => TodoCategory(
    name: (json['name'] as String? ?? '').trim(),
    iconAsset: (json['iconAsset'] as String? ?? '').trim(),
  );
}

enum TodoStatus { pending, upcoming, overdue, completed }

extension TodoStatusX on TodoStatus {
  String get icon => switch (this) {
    TodoStatus.pending => '⭐',
    TodoStatus.upcoming => '🔥',
    TodoStatus.overdue => '⚠️',
    TodoStatus.completed => '🌟',
  };
}

class AppTodo {
  AppTodo({
    required this.id,
    required this.title,
    required this.date,
    required this.createdAt,
    this.isDone = false,
    this.isPinned = false,
    this.completedAt,
    this.reminderMinutes = 15,
    this.category = '默认',
    this.repeatMode = 'none',
    this.sortOrder = 0,
  });

  final String id;
  String title;
  DateTime date;
  DateTime createdAt;
  bool isDone;
  bool isPinned;
  DateTime? completedAt;
  int reminderMinutes;
  String category;
  String repeatMode;
  int sortOrder;

  bool get hasExplicitTime => date.hour != 0 || date.minute != 0;
  DateTime? get effectiveCompletedAt =>
      isDone ? (completedAt ?? createdAt) : null;

  bool get isArchived {
    final completed = effectiveCompletedAt;
    if (!isDone || completed == null) return false;
    return DateTime.now().difference(completed) > const Duration(hours: 24);
  }

  TodoStatus get status {
    if (isDone) return TodoStatus.completed;
    if (!hasExplicitTime) return TodoStatus.pending;
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) return TodoStatus.overdue;
    if (diff <= const Duration(minutes: 30)) return TodoStatus.upcoming;
    return TodoStatus.pending;
  }

  String statusSubtitle() {
    final timeText = hasExplicitTime
        ? '⏰ ${DateFormat('HH:mm').format(date)}  '
        : '';
    return switch (status) {
      TodoStatus.completed => '🌙 完成啦，今天也很闪耀',
      TodoStatus.upcoming => '${timeText}🔥 30 分钟内就要开始啦',
      TodoStatus.overdue => '${timeText}⚠️ ${_overdueLabel()}',
      TodoStatus.pending =>
        hasExplicitTime ? '${timeText}✨ 还在等待你的月光魔法' : '✨ 等待你点亮这一项',
    };
  }

  String _overdueLabel() {
    final overdue = DateTime.now().difference(date);
    if (overdue.inMinutes < 60) {
      return '已超时 ${max(1, overdue.inMinutes)} 分钟';
    }
    final hours = overdue.inMinutes / 60;
    final text = hours >= 10
        ? hours.toStringAsFixed(0)
        : hours.toStringAsFixed(hours == hours.floorToDouble() ? 0 : 1);
    return '已超时 $text 小时';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isDone': isDone,
    'isPinned': isPinned,
    'completedAt': completedAt?.toIso8601String(),
    'reminderMinutes': reminderMinutes,
    'category': category,
    'repeatMode': repeatMode,
    'sortOrder': sortOrder,
  };

  factory AppTodo.fromJson(Map<String, dynamic> json) => AppTodo(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    date: DateTime.parse(json['date'] as String),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    isDone: json['isDone'] as bool? ?? false,
    isPinned: json['isPinned'] as bool? ?? false,
    completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    reminderMinutes: (json['reminderMinutes'] as num?)?.toInt() ?? 15,
    category: (json['category'] as String?)?.trim().isNotEmpty == true
        ? json['category'] as String
        : '默认',
    repeatMode: normalizeRepeatMode(json['repeatMode'] as String?),
    sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  );
}

String normalizeRepeatMode(String? value) {
  switch ((value ?? '').trim()) {
    case 'daily':
    case 'weekly':
    case 'monthly':
    case 'yearly':
      return value!.trim();
    default:
      return 'none';
  }
}

DateTime nextDate(DateTime current, String repeatMode) {
  switch (normalizeRepeatMode(repeatMode)) {
    case 'daily':
      return current.add(const Duration(days: 1));
    case 'weekly':
      return current.add(const Duration(days: 7));
    case 'monthly':
      return DateTime(
        current.year,
        current.month + 1,
        current.day,
        current.hour,
        current.minute,
      );
    case 'yearly':
      return DateTime(
        current.year + 1,
        current.month,
        current.day,
        current.hour,
        current.minute,
      );
    default:
      return current;
  }
}

String repeatModeLabel(String repeatMode) {
  switch (normalizeRepeatMode(repeatMode)) {
    case 'daily':
      return '📅每天';
    case 'weekly':
      return '📆每周';
    case 'monthly':
      return '🗓️每月';
    case 'yearly':
      return '🎂每年';
    default:
      return '🔄不重复';
  }
}

class TodoEditorResult {
  TodoEditorResult({
    required this.title,
    required this.date,
    required this.reminderMinutes,
    required this.category,
    required this.repeatMode,
  });

  final String title;
  final DateTime date;
  final int reminderMinutes;
  final String category;
  final String repeatMode;
}
