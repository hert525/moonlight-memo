import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../models/todo.dart';
import '../widgets/action_icons.dart';
import '../widgets/gradient_text.dart';

class TodoEditorSheet extends StatefulWidget {
  const TodoEditorSheet({super.key, this.todo, required this.categories});

  final AppTodo? todo;
  final List<TodoCategory> categories;

  @override
  State<TodoEditorSheet> createState() => _TodoEditorSheetState();
}

class _TodoEditorSheetState extends State<TodoEditorSheet> {
  static const List<DropdownMenuItem<int>> _reminderItems = [
    DropdownMenuItem(value: 0, child: Text('不提醒')),
    DropdownMenuItem(value: 5, child: Text('提前 5 分钟')),
    DropdownMenuItem(value: 15, child: Text('提前 15 分钟')),
    DropdownMenuItem(value: 30, child: Text('提前 30 分钟')),
    DropdownMenuItem(value: 60, child: Text('提前 1 小时')),
  ];

  static const List<MapEntry<String, String>> _repeatItems = [
    MapEntry('none', '🔄不重复'),
    MapEntry('daily', '📅每天'),
    MapEntry('weekly', '📆每周'),
    MapEntry('monthly', '🗓️每月'),
    MapEntry('yearly', '🎂每年'),
  ];

  late final TextEditingController _controller;
  late DateTime _selectedDate;
  late bool _hasExplicitTime;
  late int _reminderMinutes;
  late String _selectedCategory;
  late String _repeatMode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todo?.title ?? '');
    final initial = widget.todo?.date ?? DateTime.now();
    final hasTime = widget.todo?.hasExplicitTime ?? false;
    _hasExplicitTime = hasTime;
    _reminderMinutes = widget.todo?.reminderMinutes ?? 15;
    _selectedCategory = normalizedTodoCategoryValue(
      widget.todo?.category,
      widget.categories,
    );
    _repeatMode = normalizeRepeatMode(widget.todo?.repeatMode);
    _selectedDate = DateTime(
      initial.year,
      initial.month,
      initial.day,
      hasTime ? initial.hour : 0,
      hasTime ? initial.minute : 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(
        () => _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _hasExplicitTime ? _selectedDate.hour : 0,
          _hasExplicitTime ? _selectedDate.minute : 0,
        ),
      );
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (picked != null) {
      setState(() {
        _hasExplicitTime = true;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _clearTime() {
    setState(() {
      _hasExplicitTime = false;
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
    });
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    final finalDate = _hasExplicitTime
        ? _selectedDate
        : DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    Navigator.pop(
      context,
      TodoEditorResult(
        title: title,
        date: finalDate,
        reminderMinutes: _hasExplicitTime ? _reminderMinutes : 0,
        category: _selectedCategory,
        repeatMode: _repeatMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(240),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: kPurple.withAlpha(51),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            GradientText(
              widget.todo == null ? '💖 写下新的闪耀安排' : '💞 修改这条月光日程',
              gradient: LinearGradient(colors: [kHotPink, kPurple, kGold]),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '日程内容',
                hintText: '例如：晚上 8 点写月光手账',
                prefixIcon: Icon(Icons.edit_rounded, color: kHotPink),
              ),
            ),
            const SizedBox(height: 14),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: '分类',
                prefixIcon: Icon(Icons.category_rounded, color: kHotPink),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: widget.categories
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.name,
                          child: Row(
                            children: [
                              CategoryAssetAvatar(asset: e.iconAsset, size: 22),
                              const SizedBox(width: 10),
                              Text(e.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(22),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '日期',
                  prefixIcon: Icon(
                    Icons.calendar_month_rounded,
                    color: kPurple,
                  ),
                ),
                child: Text(
                  DateFormat('yyyy年M月d日').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(22),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '时间',
                  prefixIcon: const Icon(
                    Icons.access_time_rounded,
                    color: kGold,
                  ),
                  suffixIcon: _hasExplicitTime
                      ? IconButton(
                          tooltip: '清除时间',
                          onPressed: _clearTime,
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                ),
                child: Text(
                  _hasExplicitTime
                      ? DateFormat('HH:mm').format(_selectedDate)
                      : '未设置（只显示待办/已完成）',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 14),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: '重复',
                prefixIcon: Icon(Icons.repeat_rounded, color: kPurple),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _repeatMode,
                  isExpanded: true,
                  items: _repeatItems
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item.key,
                          child: Text(item.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _repeatMode = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: '提醒',
                prefixIcon: Icon(
                  Icons.notifications_active_rounded,
                  color: kHotPink,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _hasExplicitTime ? _reminderMinutes : 0,
                  items: _reminderItems,
                  onChanged: _hasExplicitTime
                      ? (value) {
                          if (value == null) return;
                          setState(() => _reminderMinutes = value);
                        }
                      : null,
                ),
              ),
            ),
            if (!_hasExplicitTime)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '未设置具体时间时，不安排本地提醒。',
                  style: TextStyle(
                    color: Color(0xFF8E6A98),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kHotPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submit,
                child: const Text(
                  '💫 保存日程',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
