import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../models/journal.dart';
import '../models/todo.dart';
import '../services/storage.dart';
import '../widgets/action_icons.dart';
import '../widgets/category_manager.dart';
import '../widgets/filter_chip.dart' as moon_filter;
import '../widgets/moon_asset_image.dart';
import '../widgets/moon_empty_state.dart';
import '../widgets/moon_scaffold.dart';
import 'journal_editor.dart';

class JournalTab extends StatefulWidget {
  const JournalTab({
    super.key,
    required this.onLock,
    required this.currentPasscode,
    required this.onPasscodeChanged,
  });

  final VoidCallback onLock;
  final String? currentPasscode;
  final ValueChanged<String> onPasscodeChanged;

  @override
  State<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<JournalTab> {
  final Random _random = Random();
  final TextEditingController _searchController = TextEditingController();
  List<JournalPageData> _pages = [];
  List<TodoCategory> _folders = cloneCategories(kDefaultJournalFolders);
  String _query = '';
  bool _loading = true;
  String _selectedFolder = kAllCategoryName;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _sortPages(List<JournalPageData> list) {
    list.sort((a, b) {
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) return orderCompare;
      return b.updatedAt.compareTo(a.updatedAt);
    });
  }

  Future<void> _load() async {
    final pages = await AppStorage.loadPages();
    final folders = await AppStorage.loadJournalFolders();
    for (final page in pages) {
      page.folder = normalizedFolderValue(page.folder, folders);
    }
    _sortPages(pages);
    _normalizeSortOrders(pages);
    if (!mounted) return;
    setState(() {
      _folders = folders;
      _selectedFolder = _selectedFolder == kAllCategoryName
          ? kAllCategoryName
          : normalizedFolderValue(_selectedFolder, folders);
      _pages = pages;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    _sortPages(_pages);
    final ok = await AppStorage.savePages(_pages);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('手账保存失败，请稍后重试')));
    }
  }

  String _randomBackground() =>
      kBackgroundAssets[_random.nextInt(kBackgroundAssets.length)];

  List<JournalPageData> get _filteredPages {
    final needle = _query.toLowerCase();
    final result = _pages.where((page) {
      final matchesQuery =
          needle.isEmpty ||
          page.title.toLowerCase().contains(needle) ||
          page.content.toLowerCase().contains(needle);
      final matchesFolder =
          _selectedFolder == kAllCategoryName || page.folder == _selectedFolder;
      return matchesQuery && matchesFolder;
    }).toList();
    _sortPages(result);
    return result;
  }

  void _normalizeSortOrders(List<JournalPageData> list) {
    _sortPages(list);
    for (var i = 0; i < list.length; i++) {
      list[i].sortOrder = i;
    }
  }

  Future<void> _createPage() async {
    final now = DateTime.now();
    final page = JournalPageData(
      id: now.microsecondsSinceEpoch.toString(),
      backgroundAsset: _randomBackground(),
      title: '',
      content: '',
      createdAt: now,
      updatedAt: now,
      folder: _selectedFolder == kAllCategoryName
          ? kDefaultJournalFolderName
          : _selectedFolder,
      sortOrder: _pages.length,
    );
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => JournalEditorPage(page: page, folders: _folders),
      ),
    );
    if (result == 'saved') {
      setState(() {
        _pages.add(page);
        _normalizeSortOrders(_pages);
      });
      await _persist();
    }
  }

  Future<void> _openPage(JournalPageData page) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => JournalEditorPage(page: page, folders: _folders),
      ),
    );
    if (result == 'deleted') {
      setState(() {
        _pages.removeWhere((e) => e.id == page.id);
        _normalizeSortOrders(_pages);
      });
      await _persist();
      return;
    }
    if (result == 'saved') {
      setState(() {
        _sortPages(_pages);
      });
      await _persist();
    }
  }

  Future<void> _showBackupRestoreDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('备份与恢复'),
        content: const Text('可以把当前所有日程、手账和密码导出为 JSON，也可以从备份文件恢复。'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final path = await AppStorage.exportBackupFile();
                if (!mounted) return;
                final pretty = path.replaceAll('\\', '/');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('备份已保存到 $pretty')));
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('导出失败，请稍后重试')));
              }
            },
            child: const Text('导出'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                final path = result?.files.single.path;
                if (path == null || path.isEmpty) return;
                final restored = await AppStorage.importBackupFile(path);
                await _load();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '恢复成功，共 ${restored.todoCount} 条日程，${restored.pageCount} 篇手账',
                    ),
                  ),
                );
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('恢复失败，请确认备份文件有效')));
              }
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasscodeDialog() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(labelText: '旧密码'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(labelText: '新密码'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(labelText: '确认新密码'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final oldValue = oldController.text.trim();
    final newValue = newController.text.trim();
    final confirmValue = confirmController.text.trim();
    if (oldValue != (widget.currentPasscode ?? '')) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('旧密码不正确')));
      return;
    }
    if (newValue.length != 4 || int.tryParse(newValue) == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('新密码必须是 4 位数字')));
      return;
    }
    if (newValue != confirmValue) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('两次新密码输入不一致')));
      return;
    }
    final saved = await AppStorage.savePasscode(newValue);
    if (!mounted) return;
    if (saved) {
      widget.onPasscodeChanged(newValue);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('密码已更新')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('密码更新失败，请稍后重试')));
    }
  }

  Future<void> _openFolderManager() async {
    final result = await showModalBottomSheet<List<TodoCategory>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CategoryManagerSheet(
        title: '管理手账文件夹',
        initialItems: _folders,
        defaultItems: kDefaultJournalFolders,
        protectedName: kAllCategoryName,
      ),
    );
    if (result == null) return;
    final normalized = sanitizeCategories(result, kDefaultJournalFolders);
    for (final page in _pages) {
      page.folder = normalizedFolderValue(page.folder, normalized);
    }
    setState(() {
      _folders = normalized;
      if (_selectedFolder != kAllCategoryName &&
          !_folders.any((item) => item.name == _selectedFolder)) {
        _selectedFolder = kAllCategoryName;
      }
    });
    final ok = await AppStorage.saveJournalFolders(_folders);
    await _persist();
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('文件夹保存失败，请稍后重试')));
    }
  }

  Future<void> _reorderFilteredPages(
    List<JournalPageData> displayPages,
    int oldIndex,
    int newIndex,
  ) async {
    if (displayPages.length <= 1) return;
    if (newIndex > oldIndex) newIndex -= 1;
    final moving = displayPages[oldIndex];
    final reordered = [...displayPages]..removeAt(oldIndex);
    reordered.insert(newIndex, moving);

    final displayIds = reordered.map((e) => e.id).toSet();
    final others = _pages.where((page) => !displayIds.contains(page.id)).toList();
    final merged = <JournalPageData>[...reordered, ...others];
    for (var i = 0; i < merged.length; i++) {
      merged[i].sortOrder = i;
    }

    setState(() {
      _pages = merged;
      _sortPages(_pages);
    });
    await _persist();
  }

  Widget _buildPageCard(JournalPageData page, int index) {
    final folderMeta = resolveCategory(
      page.folder,
      _folders,
      kDefaultJournalFolders,
    );
    final title = page.title.trim().isEmpty ? '🌙 未命名月光页' : page.title.trim();
    final preview = page.content.trim().isEmpty
        ? '写下心情、加上贴纸和照片，让今天发光。'
        : page.content.trim();
    final attachmentCount =
        page.items.where((e) => e.type == 'photo').length +
        page.items.where((e) => e.type == 'sticker').length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openPage(page),
        child: Ink(
          height: 192,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(34),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  page.backgroundAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFB98ACD),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(180),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(90),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withAlpha(72),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MoonAssetImage(
                          asset: folderMeta.iconAsset,
                          width: 18,
                          height: 18,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          page.folder,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (attachmentCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(96),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withAlpha(72),
                            ),
                          ),
                          child: Text(
                            '📎 $attachmentCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      ReorderableDragStartListener(
                        index: index,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(96),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(72),
                            ),
                          ),
                          child: const Icon(
                            Icons.drag_handle_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withAlpha(214),
                          fontFamily: page.fontFamily.isEmpty ? null : page.fontFamily,
                          fontSize: min(page.fontSize, 18),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('M月d日 HH:mm').format(page.updatedAt),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withAlpha(214),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (attachmentCount > 0)
                            Text(
                              '📎 $attachmentCount',
                              style: TextStyle(
                                color: Colors.white.withAlpha(214),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPages = _filteredPages;
    return MoonPageScaffold(
      title: '🌙 月光手账 🌙',
      subtitle: '✨ 记录爱、月亮与每一天的魔法',
      backgroundAsset: kJournalListBackground,
      actions: [
        IconButton(
          tooltip: '备份与恢复',
          onPressed: _showBackupRestoreDialog,
          icon: const Icon(Icons.backup_rounded),
        ),
        IconButton(
          tooltip: '修改密码',
          onPressed: _showChangePasscodeDialog,
          icon: const Icon(Icons.settings_rounded),
        ),
        IconButton(
          tooltip: '锁定',
          onPressed: widget.onLock,
          icon: const ActionAssetIcon(asset: kUnlockIconAsset),
        ),
      ],
      floatingActionButton: MoonImageFab(onPressed: _createPage),
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: kHotPink))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索标题或内容',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _searchController.clear,
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 46,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(18, 2, 18, 4),
                    children: [
                      moon_filter.FilterChip(
                        label: kAllCategoryName,
                        iconAsset: allCategoryMeta(_folders).iconAsset,
                        selected: _selectedFolder == kAllCategoryName,
                        onTap: () =>
                            setState(() => _selectedFolder = kAllCategoryName),
                      ),
                      ..._folders.map(
                        (folder) => moon_filter.FilterChip(
                          label: folder.name,
                          iconAsset: folder.iconAsset,
                          selected: _selectedFolder == folder.name,
                          onTap: () =>
                              setState(() => _selectedFolder = folder.name),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: IconButton(
                          tooltip: '管理文件夹',
                          onPressed: _openFolderManager,
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
                  child: displayPages.isEmpty
                      ? MoonEmptyState(
                          icon: const Text(
                            '🌙',
                            style: TextStyle(fontSize: 64),
                          ),
                          title: _query.isEmpty ? '第一篇月光手账还没出现' : '没有找到相关手账',
                          subtitle: _query.isEmpty
                              ? '点一下底部的魔法道具，用背景、贴纸和照片开启今天的魔法页。'
                              : '换个关键词试试，标题和正文都会被搜索到。',
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
                          buildDefaultDragHandles: false,
                          itemCount: displayPages.length,
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
                                    borderRadius: BorderRadius.circular(16),
                                    child: child,
                                  ),
                                );
                              },
                            );
                          },
                          onReorder: (oldIndex, newIndex) =>
                              _reorderFilteredPages(displayPages, oldIndex, newIndex),
                          itemBuilder: (context, index) {
                            final page = displayPages[index];
                            return Padding(
                              key: ValueKey('journal-${page.id}'),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildPageCard(page, index),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
