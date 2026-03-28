import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/journal.dart';
import '../models/todo.dart';
import 'notifications.dart';
import 'passcode.dart';

bool isJournalMeaningful({
  required String title,
  required String content,
  required List<DecorItem> items,
}) {
  return title.trim().isNotEmpty ||
      content.trim().isNotEmpty ||
      items.isNotEmpty;
}

class BackupPayload {
  BackupPayload({
    required this.todos,
    required this.pages,
    required this.passcode,
    required this.todoCategories,
    required this.journalFolders,
  });

  final List<AppTodo> todos;
  final List<JournalPageData> pages;
  final String? passcode;
  final List<TodoCategory> todoCategories;
  final List<TodoCategory> journalFolders;

  Map<String, dynamic> toJson() => {
    'todos': todos.map((e) => e.toJson()).toList(),
    'pages': pages.map((e) => e.toJson()).toList(),
    'passcode': passcode,
    'todoCategories': todoCategories.map((e) => e.toJson()).toList(),
    'journalFolders': journalFolders.map((e) => e.toJson()).toList(),
  };

  factory BackupPayload.fromJson(Map<String, dynamic> json) => BackupPayload(
    todos: ((json['todos'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => AppTodo.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    pages: ((json['pages'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => JournalPageData.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    passcode: json['passcode'] as String?,
    todoCategories: ((json['todoCategories'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => TodoCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    journalFolders: ((json['journalFolders'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => TodoCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class BackupRestoreResult {
  BackupRestoreResult({required this.todoCount, required this.pageCount});

  final int todoCount;
  final int pageCount;
}

class AppStorage {
  static const _todosKey = 'moon.todos';
  static const _pagesKey = 'moon.pages';
  static const _passcodeKey = 'moon.passcode';
  static const _todoCategoriesKey = 'moon.todo_categories';
  static const _journalFoldersKey = 'moon.journal_folders';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static Future<List<AppTodo>> loadTodos() async {
    try {
      final raw = (await _prefs).getString(_todosKey);
      if (raw == null || raw.isEmpty) return [];
      final list = (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((e) => AppTodo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  static Future<bool> saveTodos(List<AppTodo> todos) async {
    try {
      final ok = await (await _prefs).setString(
        _todosKey,
        jsonEncode(todos.map((e) => e.toJson()).toList()),
      );
      await MoonlightNotifications.instance.syncTodoNotifications(todos);
      return ok;
    } catch (_) {
      return false;
    }
  }

  static Future<List<JournalPageData>> loadPages() async {
    try {
      final raw = (await _prefs).getString(_pagesKey);
      if (raw == null || raw.isEmpty) return [];
      return (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((e) => JournalPageData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> savePages(List<JournalPageData> pages) async {
    try {
      return await (await _prefs).setString(
        _pagesKey,
        jsonEncode(pages.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      return false;
    }
  }

  static Future<String?> loadPasscode() async {
    try {
      return decodePasscode((await _prefs).getString(_passcodeKey));
    } catch (_) {
      return null;
    }
  }

  static Future<bool> savePasscode(String passcode) async {
    try {
      return await (await _prefs).setString(_passcodeKey, encodePasscode(passcode));
    } catch (_) {
      return false;
    }
  }

  static Future<List<TodoCategory>> loadTodoCategories() async {
    try {
      final raw = (await _prefs).getString(_todoCategoriesKey);
      if (raw == null || raw.isEmpty) {
        return cloneCategories(kDefaultTodoCategories);
      }
      final list = (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((e) => TodoCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return sanitizeCategories(list, kDefaultTodoCategories);
    } catch (_) {
      return cloneCategories(kDefaultTodoCategories);
    }
  }

  static Future<bool> saveTodoCategories(List<TodoCategory> categories) async {
    try {
      return await (await _prefs).setString(
        _todoCategoriesKey,
        jsonEncode(sanitizeCategories(categories, kDefaultTodoCategories)
            .map((e) => e.toJson())
            .toList()),
      );
    } catch (_) {
      return false;
    }
  }

  static Future<List<TodoCategory>> loadJournalFolders() async {
    try {
      final raw = (await _prefs).getString(_journalFoldersKey);
      if (raw == null || raw.isEmpty) {
        return cloneCategories(kDefaultJournalFolders);
      }
      final list = (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((e) => TodoCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return sanitizeCategories(list, kDefaultJournalFolders);
    } catch (_) {
      return cloneCategories(kDefaultJournalFolders);
    }
  }

  static Future<bool> saveJournalFolders(List<TodoCategory> folders) async {
    try {
      return await (await _prefs).setString(
        _journalFoldersKey,
        jsonEncode(sanitizeCategories(folders, kDefaultJournalFolders)
            .map((e) => e.toJson())
            .toList()),
      );
    } catch (_) {
      return false;
    }
  }

  static Future<String> exportBackupFile() async {
    final payload = BackupPayload(
      todos: await loadTodos(),
      pages: await loadPages(),
      passcode: await loadPasscode(),
      todoCategories: await loadTodoCategories(),
      journalFolders: await loadJournalFolders(),
    );
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${dir.path}/moonlight_backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    final file = File(
      '${backupDir.path}/moonlight_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json',
    );
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload.toJson()));
    return file.path;
  }

  static Future<BackupRestoreResult> importBackupFile(String path) async {
    final file = File(path);
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final payload = BackupPayload.fromJson(data);
    await saveTodos(payload.todos);
    await savePages(payload.pages);
    if (payload.passcode != null && payload.passcode!.isNotEmpty) {
      await savePasscode(payload.passcode!);
    }
    await saveTodoCategories(payload.todoCategories.isEmpty
        ? kDefaultTodoCategories
        : payload.todoCategories);
    await saveJournalFolders(payload.journalFolders.isEmpty
        ? kDefaultJournalFolders
        : payload.journalFolders);
    return BackupRestoreResult(
      todoCount: payload.todos.length,
      pageCount: payload.pages.length,
    );
  }
}
