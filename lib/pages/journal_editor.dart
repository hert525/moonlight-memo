import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../constants.dart';
import '../models/journal.dart';
import '../models/todo.dart';
import '../services/storage.dart';
import '../widgets/action_icons.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/editable_decor.dart';
import '../widgets/lined_paper.dart';
import '../widgets/moon_asset_image.dart';

enum _PopDecision { discard, cancel, save }

class JournalEditorPage extends StatefulWidget {
  const JournalEditorPage({
    super.key,
    required this.page,
    required this.folders,
  });

  final JournalPageData page;
  final List<TodoCategory> folders;

  @override
  State<JournalEditorPage> createState() => _JournalEditorPageState();
}

class _JournalEditorPageState extends State<JournalEditorPage> {
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _captureKey = GlobalKey();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final String _initialSnapshot;
  String? _selectedItemId;
  bool _handlingPop = false;
  bool _allowDirectPop = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.page.title);
    _contentController = TextEditingController(text: widget.page.content);
    _initialSnapshot = _snapshot();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _snapshot() => jsonEncode({
    'title': normalizeText(_titleController.text),
    'content': normalizeText(_contentController.text),
    'backgroundAsset': widget.page.backgroundAsset,
    'folder': widget.page.folder,
    'fontFamily': widget.page.fontFamily,
    'fontSize': widget.page.fontSize,
    'textColor': widget.page.textColor.toARGB32(),
    'items': widget.page.items.map((e) => e.toJson()).toList(),
  });

  bool get _hasUnsavedChanges => _snapshot() != _initialSnapshot;

  Future<bool> _save({bool exitAfterSave = false}) async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (!isJournalMeaningful(
      title: title,
      content: content,
      items: widget.page.items,
    )) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('内容为空，先写点什么再保存吧')));
      }
      return false;
    }
    widget.page
      ..title = title
      ..content = content
      ..updatedAt = DateTime.now();
    if (!mounted) return false;
    if (exitAfterSave) {
      _allowDirectPop = true;
      Navigator.pop(context, 'saved');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已保存这页月光手账')));
    }
    return true;
  }

  Future<void> _handleBackAttempt() async {
    if (_allowDirectPop || _handlingPop) return;
    if (!_hasUnsavedChanges) {
      _allowDirectPop = true;
      Navigator.pop(context);
      return;
    }
    _handlingPop = true;
    final decision = await showDialog<_PopDecision>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('要保存修改吗？'),
        content: const Text('这页手账有新的内容，还没有保存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _PopDecision.discard),
            child: const Text('丢弃'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _PopDecision.cancel),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _PopDecision.save),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    _handlingPop = false;
    if (!mounted) return;
    switch (decision) {
      case _PopDecision.discard:
        _allowDirectPop = true;
        Navigator.pop(context);
        break;
      case _PopDecision.save:
        await _save(exitAfterSave: true);
        break;
      case _PopDecision.cancel:
      case null:
        break;
    }
  }

  void _changeBackground(String asset) {
    setState(() {
      widget.page.backgroundAsset = asset;
      widget.page.updatedAt = DateTime.now();
    });
  }

  Future<void> _showBackgroundPicker() async {
    final asset = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFFFF5FC),
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: kBackgroundAssets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final asset = kBackgroundAssets[index];
              final selected = asset == widget.page.backgroundAsset;
              return InkWell(
                onTap: () => Navigator.pop(context, asset),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? kHotPink : kGold.withAlpha(140),
                      width: selected ? 2.2 : 1.2,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: kHotPink.withAlpha(50),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        MoonAssetImage(asset: asset, fit: BoxFit.cover),
                        if (selected)
                          Container(
                            color: Colors.black.withAlpha(30),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    if (asset != null) _changeBackground(asset);
  }

  void _addSticker(String asset) {
    setState(() {
      final item = DecorItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        path: asset,
        type: 'sticker',
        dx: 40 + (widget.page.items.length % 3) * 52,
        dy: 70 + (widget.page.items.length % 4) * 44,
        baseSize: 92,
      );
      widget.page.items.add(item);
      _selectedItemId = item.id;
      widget.page.updatedAt = DateTime.now();
    });
  }

  Future<void> _showStickerSheet() async {
    final asset = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFFFF5FC),
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: kStickerAssets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final asset = kStickerAssets[index];
              return InkWell(
                onTap: () => Navigator.pop(context, asset),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kGold.withAlpha(140)),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: MoonAssetImage(asset: asset, fit: BoxFit.contain),
                ),
              );
            },
          ),
        ),
      ),
    );
    if (asset != null) _addSticker(asset);
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      );
      if (picked == null) return;
      final savedPath = await _copyImage(File(picked.path));
      if (savedPath == null) return;
      setState(() {
        final item = DecorItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          path: savedPath,
          type: 'photo',
          dx: 36,
          dy: 56,
          baseSize: 128,
        );
        widget.page.items.add(item);
        _selectedItemId = item.id;
        widget.page.updatedAt = DateTime.now();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('照片选取失败，请稍后再试')));
    }
  }

  Future<String?> _copyImage(File source) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${dir.path}/moonlight_photos');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      final ext = source.path.contains('.')
          ? source.path.split('.').last
          : 'jpg';
      final target = File(
        '${targetDir.path}/${DateTime.now().microsecondsSinceEpoch}.$ext',
      );
      await source.copy(target.path);
      return target.path;
    } catch (_) {
      if (!mounted) return null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('照片保存失败，请重试')));
      return null;
    }
  }

  Future<void> _deletePage() async {
    final ok = await showMoonConfirmDialog(
      context,
      title: '确定要删除这篇手账吗？',
      content: '删除后这页月光手账会永久消失。',
      confirmText: '删除',
    );
    if (ok == true && mounted) {
      _allowDirectPop = true;
      Navigator.pop(context, 'deleted');
    }
  }

  Future<void> _exportToGallery() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      final boundary =
          _captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('boundary missing');
      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('byteData missing');
      final Uint8List bytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: 'moonlight_memo_${DateTime.now().millisecondsSinceEpoch}',
      );
      final success = result is Map
          ? result['isSuccess'] == true || result['success'] == true
          : result != null;
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已保存到相册')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存到相册失败，请重试')));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('保存到相册失败，请重试')));
    }
  }

  void _removeSelectedItem() {
    final id = _selectedItemId;
    if (id == null) return;
    setState(() {
      widget.page.items.removeWhere((e) => e.id == id);
      _selectedItemId = null;
      widget.page.updatedAt = DateTime.now();
    });
  }

  Future<void> _pickFolder() async {
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: widget.folders.map((folder) {
            return ListTile(
              leading: CategoryAssetAvatar(asset: folder.iconAsset, size: 24),
              title: Text(folder.name),
              trailing: widget.page.folder == folder.name
                  ? const Icon(Icons.check_rounded, color: kHotPink)
                  : null,
              onTap: () => Navigator.pop(context, folder.name),
            );
          }).toList(),
        ),
      ),
    );
    if (value != null) {
      setState(() {
        widget.page.folder = value;
        widget.page.updatedAt = DateTime.now();
      });
    }
  }

  Future<void> _showFontPicker() async {
    String tempFont = widget.page.fontFamily;
    double tempSize = widget.page.fontSize;
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setInnerState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '字号 ${tempSize.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Slider(
                  min: 14,
                  max: 32,
                  divisions: 18,
                  value: tempSize,
                  onChanged: (value) => setInnerState(() => tempSize = value),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: kFontFamilyChoices.map((font) {
                      return ListTile(
                        title: Text(
                          fontLabel(font),
                          style: TextStyle(
                            fontFamily: font.isEmpty ? null : font,
                            fontSize: tempSize,
                          ),
                        ),
                        trailing: tempFont == font
                            ? const Icon(Icons.check_rounded, color: kHotPink)
                            : null,
                        onTap: () => setInnerState(() => tempFont = font),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('完成'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (changed == true) {
      setState(() {
        widget.page.fontFamily = tempFont;
        widget.page.fontSize = tempSize;
        widget.page.updatedAt = DateTime.now();
      });
    }
  }

  Future<void> _showColorPicker() async {
    final value = await showModalBottomSheet<Color>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: kTextColorOptions.entries.map((entry) {
              return InkWell(
                onTap: () => Navigator.pop(context, entry.value),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 96,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: entry.value == widget.page.textColor
                          ? kHotPink
                          : kGold.withAlpha(120),
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: entry.value,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
    if (value != null) {
      setState(() {
        widget.page.textColor = value;
        widget.page.updatedAt = DateTime.now();
      });
    }
  }

  Future<void> _showKaomojiPicker() async {
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: kKaomojiList.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final face = kKaomojiList[index];
            return ListTile(
              title: Text(face),
              onTap: () => Navigator.pop(context, face),
            );
          },
        ),
      ),
    );
    if (value == null) return;
    final selection = _contentController.selection;
    final oldText = _contentController.text;
    final start = selection.start >= 0 ? selection.start : oldText.length;
    final end = selection.end >= 0 ? selection.end : oldText.length;
    final newText = oldText.replaceRange(start, end, value);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + value.length),
    );
    setState(() => widget.page.updatedAt = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackAttempt();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            '🌙 编辑月光页',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          leading: IconButton(
            onPressed: _handleBackAttempt,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: '返回',
          ),
          actions: [
            IconButton(
              onPressed: _exportToGallery,
              icon: const Icon(Icons.ios_share_rounded),
              tooltip: '分享',
            ),
            IconButton(
              onPressed: _deletePage,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: '删除',
            ),
            IconButton(
              onPressed: _save,
              icon: const Icon(Icons.favorite_rounded),
              tooltip: '保存',
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: MoonAssetImage(
                asset: widget.page.backgroundAsset,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withAlpha(36)),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: RepaintBoundary(
                  key: _captureKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(158),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withAlpha(184)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(31),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                            child: TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                hintText: '今天这页的标题...',
                                prefixIcon: ActionAssetIcon(
                                  asset: kMoonIconAsset,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                fontFamily: widget.page.fontFamily.isEmpty
                                    ? null
                                    : widget.page.fontFamily,
                                color: widget.page.textColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(184),
                                          borderRadius: BorderRadius.circular(
                                            26,
                                          ),
                                          border: Border.all(
                                            color: kGold.withAlpha(102),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: CustomPaint(
                                                painter: LinedPaperPainter(
                                                  color: kHotPink.withAlpha(46),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    18,
                                                    18,
                                                    18,
                                                    18,
                                                  ),
                                              child: TextField(
                                                controller: _contentController,
                                                maxLines: null,
                                                expands: true,
                                                decoration:
                                                    const InputDecoration(
                                                      hintText:
                                                          '亲爱的月亮，今天发生了什么？',
                                                      filled: false,
                                                      border:
                                                          InputBorder.none,
                                                    ),
                                                style: TextStyle(
                                                  fontSize:
                                                      widget.page.fontSize,
                                                  height: 1.8,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      widget.page.textColor,
                                                  fontFamily: widget
                                                          .page
                                                          .fontFamily
                                                          .isEmpty
                                                      ? null
                                                      : widget.page.fontFamily,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ...widget.page.items.map(
                                      (item) => EditableDecorWidget(
                                        key: ValueKey(item.id),
                                        item: item,
                                        maxWidth: constraints.maxWidth - 32,
                                        maxHeight: constraints.maxHeight - 24,
                                        selected: item.id == _selectedItemId,
                                        onTap: () => setState(
                                          () => _selectedItemId = item.id,
                                        ),
                                        onChanged: () => setState(
                                          () => widget.page.updatedAt =
                                              DateTime.now(),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(232),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: kGold.withAlpha(128)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _pickFolder,
                  icon: const Icon(Icons.folder_open_rounded, size: 26),
                  tooltip: '文件夹',
                ),
                IconButton(
                  onPressed: _showBackgroundPicker,
                  icon: const Icon(Icons.image_rounded, size: 26),
                  tooltip: '背景',
                ),
                IconButton(
                  onPressed: _pickPhoto,
                  icon: const ActionAssetIcon(
                    asset: kPhotoIconAsset,
                    size: 26,
                  ),
                  tooltip: '照片',
                ),
                IconButton(
                  onPressed: _showStickerSheet,
                  icon: const ActionAssetIcon(
                    asset: kMagicIconAsset,
                    size: 26,
                  ),
                  tooltip: '贴纸',
                ),
                IconButton(
                  onPressed: _showFontPicker,
                  icon: const Icon(Icons.font_download_rounded, size: 26),
                  tooltip: '字体',
                ),
                IconButton(
                  onPressed: _showColorPicker,
                  icon: const Icon(Icons.palette_rounded, size: 26),
                  tooltip: '颜色',
                ),
                IconButton(
                  onPressed: _showKaomojiPicker,
                  icon: const Icon(
                    Icons.emoji_emotions_outlined,
                    size: 26,
                  ),
                  tooltip: '颜文字',
                ),
                IconButton(
                  onPressed: _removeSelectedItem,
                  icon: const Icon(Icons.delete_outline_rounded, size: 26),
                  tooltip: '删除选中',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

