import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../models/todo.dart';
import 'filter_chip.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    required this.categoryMeta,
    required this.onTapStar,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePin,
    this.dragHandle,
  });

  final AppTodo todo;
  final TodoCategory categoryMeta;
  final VoidCallback onTapStar;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final status = todo.status;
    final done = status == TodoStatus.completed;
    final baseBackgroundColor = switch (status) {
      TodoStatus.completed => const Color(0xFFFFE1F1).withAlpha(232),
      TodoStatus.upcoming => const Color(0xFFFFE6AE).withAlpha(236),
      TodoStatus.overdue => const Color(0xFFFFD7D7).withAlpha(236),
      TodoStatus.pending => Colors.white.withAlpha(214),
    };
    final backgroundColor = todo.isPinned
        ? Color.alphaBlend(kGold.withAlpha(26), baseBackgroundColor)
        : baseBackgroundColor;
    final borderColor = todo.isPinned
        ? kGold
        : switch (status) {
            TodoStatus.completed => kHotPink.withAlpha(138),
            TodoStatus.upcoming => const Color(0xFFFFB347),
            TodoStatus.overdue => const Color(0xFFE57373),
            TodoStatus.pending => kGold.withAlpha(107),
          };
    final titleColor = switch (status) {
      TodoStatus.completed => kHotPink,
      TodoStatus.upcoming => const Color(0xFF9A5200),
      TodoStatus.overdue => const Color(0xFFB23A48),
      TodoStatus.pending => const Color(0xFF6B2E63),
    };
    final subtitleColor = switch (status) {
      TodoStatus.completed => kHotPink,
      TodoStatus.upcoming => const Color(0xFFAA6A00),
      TodoStatus.overdue => const Color(0xFFB74B57),
      TodoStatus.pending => const Color(0xFF8E6A98),
    };

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: borderColor,
              width: todo.isPinned ? 1.6 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: GestureDetector(
                    onTap: onTapStar,
                    child: Text(
                      status.icon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: titleColor,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: kHotPink,
                      decorationThickness: 2,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          todo.statusSubtitle(),
                          style: TextStyle(
                            color: subtitleColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        if (todo.repeatMode != 'none')
                          _TinyTextBadge(
                            label: repeatModeLabel(todo.repeatMode),
                            color: subtitleColor,
                          ),
                        if (todoCategoryBadgeLabel(
                          categoryMeta.name,
                        ).isNotEmpty)
                          TinyCategoryBadge(
                            label: todoCategoryBadgeLabel(
                              categoryMeta.name,
                            ),
                            iconAsset: categoryMeta.iconAsset,
                            color: subtitleColor,
                          ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded, color: kPurple),
                    onSelected: (value) {
                      if (value == 'pin') onTogglePin();
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(todo.isPinned ? '取消置顶' : '📌 置顶'),
                      ),
                      const PopupMenuItem(value: 'edit', child: Text('编辑')),
                      const PopupMenuItem(value: 'delete', child: Text('删除')),
                    ],
                  ),
                ),
              ),
              if (dragHandle != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: dragHandle!,
                ),
            ],
          ),
        ),
        if (todo.isPinned)
          Positioned(
            top: -6,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kGold,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: kGold.withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text('📌', style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }
}

class _TinyTextBadge extends StatelessWidget {
  const _TinyTextBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(170),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class TodoDateHeader extends StatelessWidget {
  const TodoDateHeader({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = date.difference(today).inDays;
    String tail;
    if (diff == 0) {
      tail = '今天';
    } else if (diff == 1) {
      tail = '明天';
    } else if (diff == -1) {
      tail = '昨天';
    } else {
      tail = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][date.weekday - 1];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(112),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(138)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(36),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        '✨ ${DateFormat('M月d日').format(date)} · $tail ✨',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
