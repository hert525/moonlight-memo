import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../models/todo.dart';
import '../services/notifications.dart';
import '../services/storage.dart';
import '../widgets/action_icons.dart';
import '../widgets/category_manager.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/filter_chip.dart' as moon_filter;
import '../widgets/moon_empty_state.dart';
import '../widgets/moon_scaffold.dart';
import '../widgets/todo_card.dart';
import 'todo_editor.dart';

class TodoTab extends StatefulWidget {
  const TodoTab({super.key});

  @override
  State<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends State<TodoTab> {
  List<AppTodo> _todos = [];
  List<TodoCategory> _categories = cloneCategories(kDefaultTodoCategories);
  bool _loading = true;
  bool _showArchived = false;
  String _selectedCategory = kAllCategoryName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AppStorage.loadTodos();
    final categories = await AppStorage.loadTodoCategories();
    var upgradedLegacyCompletedAt = false;
    for (final todo in list) {
      todo.category = normalizedTodoCategoryValue(todo.category, categories);
      todo.repeatMode = normalizeRepeatMode(todo.repeatMode);
      if (todo.isDone && todo.completedAt == null) {
        todo.completedAt = DateTime.now();
        upgradedLegacyCompletedAt = true;
      }
    }
    sortTodos(list);
    await MoonlightNotifications.instance.syncTodoNotifications(list);
    if (upgradedLegacyCompletedAt) {
      await AppStorage.saveTodos(list);
    }
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _selectedCategory = _selectedCategory == kAllCategoryName
          ? kAllCategoryName
          : normalizedTodoCategoryValue(_selectedCategory, categories);
      _todos = list;
      _loading = false;
    });
  }

  void sortTodos(List<AppTodo> list) {
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) return orderCompare;
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  Future<void> _persist() async {
    final ok = await AppStorage.saveTodos(_todos);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('日程保存失败，请稍后重试')));
    }
  }

  Future<void> _openEditor({AppTodo? todo}) async {
    final oldId = todo?.id;
    final result = await showModalBottomSheet<TodoEditorResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TodoEditorSheet(todo: todo, categories: _categories),
    );
    if (result == null) return;

    late AppTodo target;
    setState(() {
      if (todo == null) {
        target = AppTodo(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: result.title,
          date: result.date,
          createdAt: DateTime.now(),
          reminderMinutes: result.reminderMinutes,
          category: result.category,
          repeatMode: result.repeatMode,
          sortOrder: _nextSortOrderForDay(result.date),
        );
        _todos.add(target);
      } else {
        final movedDay = !_isSameDay(todo.date, result.date);
        todo.title = result.title;
        todo.date = result.date;
        todo.reminderMinutes = result.reminderMinutes;
        todo.category = result.category;
        todo.repeatMode = result.repeatMode;
        if (movedDay) {
          todo.sortOrder = _nextSortOrderForDay(
            result.date,
            excludeId: todo.id,
          );
        }
        target = todo;
      }
      sortTodos(_todos);
      _normalizeTodoSortOrders();
    });
    if (oldId != null) {
      await MoonlightNotifications.instance.cancelTodo(oldId);
    }
    await MoonlightNotifications.instance.scheduleTodo(target);
    await _persist();
  }

  Future<void> _deleteTodo(AppTodo todo) async {
    final ok = await showMoonConfirmDialog(
      context,
      title: '确定要删除这条日程吗？',
      content: '《${todo.title}》会从月光计划里移除。',
      confirmText: '删除',
    );
    if (ok != true) return;
    setState(() {
      _todos.removeWhere((e) => e.id == todo.id);
      _normalizeTodoSortOrders();
    });
    await MoonlightNotifications.instance.cancelTodo(todo.id);
    await _persist();
  }

  Future<void> _toggleTodo(AppTodo todo) async {
    AppTodo? generatedTodo;
    setState(() {
      final becomingDone = !todo.isDone;
      todo.isDone = becomingDone;
      todo.completedAt = becomingDone ? DateTime.now() : null;
      if (becomingDone && todo.repeatMode != 'none') {
        final nextDateValue = nextDate(todo.date, todo.repeatMode);
        final next = AppTodo(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: todo.title,
          date: nextDateValue,
          createdAt: DateTime.now(),
          reminderMinutes: todo.reminderMinutes,
          category: todo.category,
          repeatMode: todo.repeatMode,
          isPinned: todo.isPinned,
          sortOrder: _nextSortOrderForDay(nextDateValue),
        );
        generatedTodo = next;
        _todos.add(next);
      }
      sortTodos(_todos);
      _normalizeTodoSortOrders();
    });
    if (todo.isDone) {
      await MoonlightNotifications.instance.cancelTodo(todo.id);
      if (generatedTodo != null) {
        await MoonlightNotifications.instance.scheduleTodo(generatedTodo!);
      }
    } else {
      await MoonlightNotifications.instance.scheduleTodo(todo);
    }
    await _persist();
  }

  List<AppTodo> get _categoryTodos => _selectedCategory == kAllCategoryName
      ? _todos
      : _todos.where((e) => e.category == _selectedCategory).toList();

  List<AppTodo> get _visibleTodos =>
      _categoryTodos.where((e) => !e.isArchived).toList();

  List<AppTodo> get _visiblePinnedTodos =>
      _visibleTodos.where((e) => e.isPinned).toList();

  List<AppTodo> get _visibleUnpinnedTodos =>
      _visibleTodos.where((e) => !e.isPinned).toList();

  List<AppTodo> get _archivedTodos =>
      _categoryTodos.where((e) => e.isArchived).toList();

  Future<void> _openCategoryManager() async {
    final result = await showModalBottomSheet<List<TodoCategory>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CategoryManagerSheet(
        title: '管理日程分类',
        initialItems: _categories,
        defaultItems: kDefaultTodoCategories,
        protectedName: kAllCategoryName,
      ),
    );
    if (result == null) return;
    final normalized = sanitizeCategories(result, kDefaultTodoCategories);
    for (final todo in _todos) {
      todo.category = normalizedTodoCategoryValue(todo.category, normalized);
    }
    setState(() {
      _categories = normalized;
      if (_selectedCategory != kAllCategoryName &&
          !_categories.any((item) => item.name == _selectedCategory)) {
        _selectedCategory = kAllCategoryName;
      }
      sortTodos(_todos);
      _normalizeTodoSortOrders();
    });
    final ok = await AppStorage.saveTodoCategories(_categories);
    await _persist();
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('分类保存失败，请稍后重试')));
    }
  }

  Future<void> _togglePin(AppTodo todo) async {
    setState(() {
      todo.isPinned = !todo.isPinned;
      sortTodos(_todos);
      _normalizeTodoSortOrders();
    });
    await _persist();
  }

  Map<DateTime, List<AppTodo>> _groupTodos(List<AppTodo> source) {
    final map = <DateTime, List<AppTodo>>{};
    for (final todo in source) {
      final day = DateTime(todo.date.year, todo.date.month, todo.date.day);
      map.putIfAbsent(day, () => []).add(todo);
    }
    final entries = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in entries) {
      sortTodos(entry.value);
    }
    return Map.fromEntries(entries);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _nextSortOrderForDay(DateTime date, {String? excludeId}) {
    final sameDay = _todos.where(
      (todo) =>
          (excludeId == null || todo.id != excludeId) &&
          _isSameDay(todo.date, date),
    );
    if (sameDay.isEmpty) return 0;
    return sameDay
            .map((todo) => todo.sortOrder)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  void _normalizeTodoSortOrders() {
    final grouped = <String, List<AppTodo>>{};
    for (final todo in _todos) {
      final key = DateFormat('yyyy-MM-dd').format(todo.date);
      grouped.putIfAbsent(key, () => []).add(todo);
    }
    for (final entry in grouped.entries) {
      entry.value.sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        final orderCompare = a.sortOrder.compareTo(b.sortOrder);
        if (orderCompare != 0) return orderCompare;
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
        return a.createdAt.compareTo(b.createdAt);
      });
      for (var i = 0; i < entry.value.length; i++) {
        entry.value[i].sortOrder = i;
      }
    }
    sortTodos(_todos);
  }

  Future<void> _reorderDayTodos(
    DateTime day,
    int oldIndex,
    int newIndex,
  ) async {
    final dayTodos = _todos
        .where((todo) => _isSameDay(todo.date, day) && !todo.isPinned)
        .toList();
    if (dayTodos.length <= 1) return;
    sortTodos(dayTodos);
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = dayTodos.removeAt(oldIndex);
    dayTodos.insert(newIndex, moved);
    for (var i = 0; i < dayTodos.length; i++) {
      dayTodos[i].sortOrder = i;
    }
    setState(() => sortTodos(_todos));
    await _persist();
  }

  Widget _buildPinnedTodoSection(List<AppTodo> todos) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: kGold.withAlpha(44),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: kGold.withAlpha(180)),
            ),
            child: const Text(
              '📌 置顶日程',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
          ...todos.map(
            (todo) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TodoCard(
                key: ValueKey('pinned-${todo.id}'),
                todo: todo,
                categoryMeta: resolveCategory(
                  todo.category,
                  _categories,
                  kDefaultTodoCategories,
                ),
                onTapStar: () => _toggleTodo(todo),
                onEdit: () => _openEditor(todo: todo),
                onDelete: () => _deleteTodo(todo),
                onTogglePin: () => _togglePin(todo),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderableTodoGroup(DateTime day, List<AppTodo> todos) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodoDateHeader(date: day),
          const SizedBox(height: 12),
          ReorderableListView.builder(
            key: ValueKey('todo-group-${day.toIso8601String()}'),
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todos.length,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final t = Curves.easeOut.transform(animation.value);
                  return Transform.scale(
                    scale: 1 + (0.04 * t),
                    child: Material(
                      color: Colors.transparent,
                      elevation: 10 + (10 * t),
                      shadowColor: Colors.black45,
                      borderRadius: BorderRadius.circular(26),
                      child: child,
                    ),
                  );
                },
              );
            },
            onReorder: (oldIndex, newIndex) =>
                _reorderDayTodos(day, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final todo = todos[index];
              return Padding(
                key: ValueKey('todo-${todo.id}'),
                padding: const EdgeInsets.only(bottom: 12),
                child: TodoCard(
                  todo: todo,
                  categoryMeta: resolveCategory(
                    todo.category,
                    _categories,
                    kDefaultTodoCategories,
                  ),
                  onTapStar: () => _toggleTodo(todo),
                  onEdit: () => _openEditor(todo: todo),
                  onDelete: () => _deleteTodo(todo),
                  onTogglePin: () => _togglePin(todo),
                  dragHandle: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(
                      Icons.drag_handle_rounded,
                      color: kPurple,
                      size: 28,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinnedVisible = _visiblePinnedTodos;
    final groupedVisible = _groupTodos(_visibleUnpinnedTodos);
    final groupedArchived = _groupTodos(_archivedTodos);
    return MoonPageScaffold(
      title: '✨ 我的日程 ✨',
      subtitle: '💖 把今天的闪亮安排写下来',
      backgroundAsset: kTodoListBackground,
      floatingActionButton: MoonImageFab(onPressed: () => _openEditor()),
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: kHotPink))
          : Column(
              children: [
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 2),
                    children: [
                      moon_filter.FilterChip(
                        label: kAllCategoryName,
                        iconAsset: allCategoryMeta(_categories).iconAsset,
                        selected: _selectedCategory == kAllCategoryName,
                        onTap: () => setState(
                          () => _selectedCategory = kAllCategoryName,
                        ),
                      ),
                      ..._categories.map(
                        (category) => moon_filter.FilterChip(
                          label: category.name,
                          iconAsset: category.iconAsset,
                          selected: _selectedCategory == category.name,
                          onTap: () =>
                              setState(() => _selectedCategory = category.name),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: IconButton(
                          tooltip: '管理分类',
                          onPressed: _openCategoryManager,
                          icon: const Icon(
                            Icons.settings_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      pinnedVisible.isEmpty &&
                          groupedVisible.isEmpty &&
                          groupedArchived.isEmpty
                      ? const MoonEmptyState(
                          icon: Text('✨', style: TextStyle(fontSize: 64)),
                          title: '还没有日程哦~',
                          subtitle: '点击下面的月亮道具，把新的闪耀计划添加进来吧。',
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
                          children: [
                            if (pinnedVisible.isNotEmpty)
                              _buildPinnedTodoSection(pinnedVisible),
                            ...groupedVisible.entries.map(
                              (entry) => _buildReorderableTodoGroup(
                                entry.key,
                                entry.value,
                              ),
                            ),
                            if (_archivedTodos.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  bottom: 12,
                                ),
                                child: TextButton.icon(
                                  onPressed: () => setState(
                                    () => _showArchived = !_showArchived,
                                  ),
                                  icon: Icon(
                                    _showArchived
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                  label: Text(
                                    _showArchived
                                        ? '隐藏 ${_archivedTodos.length} 条已完成日程'
                                        : '查看 ${_archivedTodos.length} 条已完成日程',
                                  ),
                                ),
                              ),
                              SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  '显示已归档',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                subtitle: Text(
                                  '已完成超过 24 小时的日程会归档隐藏',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(220),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                value: _showArchived,
                                onChanged: (value) =>
                                    setState(() => _showArchived = value),
                              ),
                            ],
                            if (_showArchived) ...[
                              const SizedBox(height: 8),
                              if (groupedArchived.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(118),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(138),
                                    ),
                                  ),
                                  child: const Text(
                                    '🗂️ 已归档日程',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ...groupedArchived.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TodoDateHeader(date: entry.key),
                                      const SizedBox(height: 12),
                                      ...entry.value.map(
                                        (todo) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: TodoCard(
                                            key: ValueKey(
                                              'archived-${todo.id}',
                                            ),
                                            todo: todo,
                                            categoryMeta: resolveCategory(
                                              todo.category,
                                              _categories,
                                              kDefaultTodoCategories,
                                            ),
                                            onTapStar: () => _toggleTodo(todo),
                                            onEdit: () =>
                                                _openEditor(todo: todo),
                                            onDelete: () => _deleteTodo(todo),
                                            onTogglePin: () => _togglePin(todo),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}
