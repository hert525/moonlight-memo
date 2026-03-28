import 'dart:math';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/todo.dart';
import 'action_icons.dart';
import 'confirm_dialog.dart';
import 'moon_asset_image.dart';

class CategoryManagerSheet extends StatefulWidget {
  const CategoryManagerSheet({
    super.key,
    required this.title,
    required this.initialItems,
    required this.defaultItems,
    required this.protectedName,
  });

  final String title;
  final List<TodoCategory> initialItems;
  final List<TodoCategory> defaultItems;
  final String protectedName;

  @override
  State<CategoryManagerSheet> createState() => _CategoryManagerSheetState();
}

class _CategoryManagerSheetState extends State<CategoryManagerSheet> {
  late List<TodoCategory> _items;

  @override
  void initState() {
    super.initState();
    _items = cloneCategories(widget.initialItems);
  }

  Future<void> _addItem() async {
    final result = await showDialog<TodoCategory>(
      context: context,
      builder: (_) => _CategoryEditDialog(
        title: widget.title.replaceFirst('管理', '添加'),
        existingNames: _items.map((e) => e.name).toSet(),
      ),
    );
    if (result == null) return;
    setState(() => _items.add(result));
  }

  Future<void> _deleteItem(TodoCategory item) async {
    setState(() => _items.removeWhere((e) => e.name == item.name));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_items);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(248),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: kPurple.withAlpha(51),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF7A2E73),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('添加'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: CategoryAssetAvatar(
                          asset: allCategoryMeta(_items).iconAsset,
                          size: 28,
                        ),
                        title: const Text('全部'),
                        subtitle: const Text('系统保留入口，仅用于筛选，不能删除'),
                        trailing: const Icon(
                          Icons.lock_outline_rounded,
                          color: kHotPink,
                        ),
                      );
                    }
                    final item = _items[index - 1];
                    return ListTile(
                      leading: CategoryAssetAvatar(
                        asset: item.iconAsset,
                        size: 28,
                      ),
                      title: Text(item.name),
                      subtitle: Text(item.iconAsset.split('/').last),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: kHotPink,
                          size: 20,
                        ),
                        onPressed: () => _deleteItem(item),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_items),
                  child: const Text('完成'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryEditDialog extends StatefulWidget {
  const _CategoryEditDialog({required this.title, required this.existingNames});

  final String title;
  final Set<String> existingNames;

  @override
  State<_CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<_CategoryEditDialog> {
  final TextEditingController _controller = TextEditingController();
  String _selectedAsset = kStickerAssets.first;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickAsset() async {
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => const _StickerPickerDialog(),
    );
    if (picked != null) setState(() => _selectedAsset = picked);
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    if (name == kAllCategoryName || widget.existingNames.contains(name)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('名称重复了，换一个吧')));
      return;
    }
    Navigator.pop(context, TodoCategory(name: name, iconAsset: _selectedAsset));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: '名称'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickAsset,
            borderRadius: BorderRadius.circular(20),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: '图标素材'),
              child: Row(
                children: [
                  CategoryAssetAvatar(asset: _selectedAsset, size: 28),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_selectedAsset.split('/').last)),
                  const Icon(Icons.grid_view_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('添加')),
      ],
    );
  }
}

class _StickerPickerDialog extends StatelessWidget {
  const _StickerPickerDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择图标素材'),
      content: SizedBox(
        width: min(MediaQuery.of(context).size.width * 0.8, 360),
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: kStickerAssets.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final asset = kStickerAssets[index];
            return InkWell(
              onTap: () => Navigator.pop(context, asset),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kGold.withAlpha(120)),
                ),
                child: MoonAssetImage(asset: asset, fit: BoxFit.contain),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ],
    );
  }
}
