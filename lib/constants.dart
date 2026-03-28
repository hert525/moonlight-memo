import 'package:flutter/material.dart';

import 'models/todo.dart';

const Color kHotPink = Color(0xFFFF69B4);
const Color kGold = Color(0xFFFFD700);
const Color kPurple = Color(0xFF9B59B6);
const Color kSoftPink = Color(0xFFFFE1F1);
const Color kLavender = Color(0xFFECD9FF);
const Color kSkyMist = Color(0xFFE2F0FF);
const Color kCreamGold = Color(0xFFFFF4C9);

const String kSplashBackground = 'assets/backgrounds/user_01.jpg';
const String kHomeBackground = 'assets/backgrounds/user_04.jpg';
const String kPasscodeBackground = 'assets/backgrounds/user_03.jpg';
const String kJournalListBackground = 'assets/backgrounds/user_05.jpg';
const String kTodoListBackground = 'assets/backgrounds/user_02.jpg';
const String kTodoTabIcon = 'assets/stickers/icon_gold_brooch.jpg';
const String kJournalTabIcon = 'assets/stickers/icon_star_locket.jpg';
const String kFabAsset = 'assets/stickers/icon_star_compact.jpg';
const String kPasscodeHeroSticker = 'assets/stickers/icon_usagi_phone.jpg';
const String kSplashLogoAsset = 'assets/stickers/icon_moon_silhouette.jpg';
const String kMoonIconAsset = 'assets/stickers/icon_flower.jpg';
const String kSaveIconAsset = 'assets/stickers/icon_heart_brooch.jpg';
const String kMagicIconAsset = 'assets/stickers/icon_flower.jpg';
const String kUnlockIconAsset = 'assets/stickers/icon_luna.jpg';
const String kPhotoIconAsset = 'assets/stickers/icon_drink.jpg';

const String kAllCategoryName = '全部';
const String kDefaultCategoryName = '默认';
const String kDefaultJournalFolderName = '日记';

const List<String> kStickerAssets = [
  'assets/stickers/icon_drink.jpg',
  'assets/stickers/icon_peace.jpg',
  'assets/stickers/icon_luna.jpg',
  'assets/stickers/icon_flower.jpg',
  'assets/stickers/icon_bride.jpg',
  'assets/stickers/icon_star_compact.jpg',
  'assets/stickers/icon_heart_brooch.jpg',
  'assets/stickers/icon_usagi_phone.jpg',
  'assets/stickers/icon_gold_brooch.jpg',
  'assets/stickers/icon_star_locket.jpg',
  'assets/stickers/icon_moon_silhouette.jpg',
  'assets/stickers/icon_candidate_01.jpg',
  'assets/stickers/icon_candidate_02.jpg',
  'assets/stickers/icon_candidate_03.png',
  'assets/stickers/icon_candidate_04.jpg',
  'assets/stickers/icon_candidate_05.jpg',
  'assets/stickers/icon_candidate_06.jpg',
  'assets/stickers/icon_candidate_07.jpg',
  'assets/stickers/icon_candidate_08.jpg',
  'assets/stickers/icon_candidate_09.png',
  'assets/stickers/item_01.jpg',
  'assets/stickers/item_02.jpg',
  'assets/stickers/item_03.jpg',
  'assets/stickers/item_04.jpg',
  'assets/stickers/item_05.jpg',
  'assets/stickers/luna_01.jpg',
  'assets/stickers/luna_04.jpg',
  'assets/stickers/sticker_04.jpg',
  'assets/stickers/sticker_06.jpg',
];

final List<TodoCategory> kDefaultTodoCategories = [
  TodoCategory(name: '默认', iconAsset: 'assets/stickers/icon_star_compact.jpg'),
  TodoCategory(name: '学习', iconAsset: 'assets/stickers/icon_gold_brooch.jpg'),
  TodoCategory(name: '工作', iconAsset: 'assets/stickers/icon_heart_brooch.jpg'),
  TodoCategory(name: '生活', iconAsset: 'assets/stickers/icon_luna.jpg'),
  TodoCategory(name: '运动', iconAsset: 'assets/stickers/icon_peace.jpg'),
];

final List<TodoCategory> kDefaultJournalFolders = [
  TodoCategory(name: '日记', iconAsset: 'assets/stickers/icon_star_compact.jpg'),
  TodoCategory(name: '心情', iconAsset: 'assets/stickers/icon_heart_brooch.jpg'),
  TodoCategory(name: '旅行', iconAsset: 'assets/stickers/icon_usagi_phone.jpg'),
  TodoCategory(name: '美食', iconAsset: 'assets/stickers/icon_drink.jpg'),
  TodoCategory(name: '灵感', iconAsset: 'assets/stickers/icon_moon_silhouette.jpg'),
];

const List<String> kFontFamilyChoices = ['', 'serif', 'monospace', 'cursive'];
const Map<String, String> kFontFamilyLabels = {
  '': '默认',
  'serif': 'serif',
  'monospace': 'monospace',
  'cursive': 'cursive',
};
const List<String> kKaomojiList = [
  '(◕‿◕)',
  '(｡◕‿◕｡)',
  '✧(≖ ◡ ≖✧)',
  '(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧',
  'ʕ•ᴥ•ʔ',
  '(=^‥^=)',
  '☆*:.｡.o(≧▽≦)o.｡.:*☆',
  '(◠‿◠)',
  '♡＾▽＾♡',
  '(◕ᴗ◕✿)',
  '٩(◕‿◕｡)۶',
  '(*^‿^*)',
  '(≧◡≦)',
  '✿◕ ‿ ◕✿',
  '(─‿‿─)',
  '☾ ⋆*・゚:⋆*・゚',
  '⊂(◉‿◉)つ',
  '(◕‿◕)♡',
  '✨🌙✨',
  '💖✨💫',
];
const Map<String, Color> kTextColorOptions = {
  '粉色': Color(0xFFFF69B4),
  '紫色': Color(0xFF9B59B6),
  '蓝色': Color(0xFF4A90E2),
  '金色': Color(0xFFFFB800),
  '红色': Color(0xFFE53935),
  '黑色': Colors.black,
  '白色': Colors.white,
  '灰色': Color(0xFF757575),
};

const List<String> kBackgroundAssets = [
  'assets/backgrounds/user_16.jpg',
  'assets/backgrounds/user_17.jpg',
  'assets/backgrounds/user_18.jpg',
  'assets/backgrounds/user_19.jpg',
  'assets/backgrounds/user_13.jpg',
  'assets/backgrounds/user_14.jpg',
  'assets/backgrounds/user_15.jpg',
  'assets/backgrounds/user_08.jpg',
  'assets/backgrounds/user_09.jpg',
  'assets/backgrounds/user_10.jpg',
  'assets/backgrounds/user_11.jpg',
  'assets/backgrounds/user_12.jpg',
  'assets/backgrounds/user_01.jpg',
  'assets/backgrounds/user_02.jpg',
  'assets/backgrounds/user_03.jpg',
  'assets/backgrounds/user_04.jpg',
  'assets/backgrounds/user_05.jpg',
  'assets/backgrounds/user_06.jpg',
  'assets/backgrounds/user_07.jpg',
  'assets/backgrounds/match_01.jpg',
  'assets/backgrounds/match_02.png',
  'assets/backgrounds/match_03.jpg',
  'assets/backgrounds/match_06.jpg',
  'assets/backgrounds/match_08.jpg',
  'assets/backgrounds/match_09.jpg',
  'assets/backgrounds/match_15.jpg',
];

String normalizeText(String value) => value.trim();

List<TodoCategory> cloneCategories(List<TodoCategory> source) =>
    source.map((e) => TodoCategory(name: e.name, iconAsset: e.iconAsset)).toList();

String safeStickerAsset(String asset) =>
    kStickerAssets.contains(asset) ? asset : kFabAsset;

List<TodoCategory> sanitizeCategories(
  List<TodoCategory> categories,
  List<TodoCategory> defaults,
) {
  final result = <TodoCategory>[];
  final seen = <String>{};
  for (final item in categories) {
    final name = item.name.trim();
    if (name.isEmpty || name == kAllCategoryName || seen.contains(name)) continue;
    seen.add(name);
    result.add(TodoCategory(name: name, iconAsset: safeStickerAsset(item.iconAsset)));
  }
  if (result.isEmpty) return cloneCategories(defaults);
  return result;
}

TodoCategory resolveCategory(
  String name,
  List<TodoCategory> categories,
  List<TodoCategory> defaults,
) {
  for (final item in categories) {
    if (item.name == name) return item;
  }
  for (final item in defaults) {
    if (item.name == name) return item;
  }
  return categories.firstWhere(
    (item) => item.name == kDefaultCategoryName,
    orElse: () => defaults.first,
  );
}

TodoCategory allCategoryMeta(List<TodoCategory> categories) => TodoCategory(
  name: kAllCategoryName,
  iconAsset: categories.isNotEmpty ? categories.first.iconAsset : kFabAsset,
);

String normalizedTodoCategoryValue(String? value, List<TodoCategory> categories) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty || raw == kAllCategoryName) return kDefaultCategoryName;
  if (categories.any((item) => item.name == raw)) return raw;
  return categories.any((item) => item.name == kDefaultCategoryName)
      ? kDefaultCategoryName
      : categories.first.name;
}

String normalizedFolderValue(String? value, List<TodoCategory> folders) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty || raw == kAllCategoryName) return kDefaultJournalFolderName;
  if (folders.any((item) => item.name == raw)) return raw;
  return folders.any((item) => item.name == kDefaultJournalFolderName)
      ? kDefaultJournalFolderName
      : folders.first.name;
}

String todoCategoryBadgeLabel(String category) =>
    category == kDefaultCategoryName ? '' : category;

String fontLabel(String fontFamily) => kFontFamilyLabels[fontFamily] ?? '默认';
