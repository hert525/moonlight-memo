from pathlib import Path
path = Path(r'C:\Projects\memo_app\lib\main.dart')
text = path.read_text(encoding='utf-8')

text = text.replace("""const List<String> kTodoCategories = ['默认', '学习', '工作', '生活', '运动', '其他'];
const Map<String, String> kTodoCategoryEmoji = {
  '默认': '📋',
  '学习': '📚',
  '工作': '💼',
  '生活': '🏠',
  '运动': '🏃',
  '其他': '📌',
};
const List<String> kJournalFolders = ['全部', '日记', '心情', '旅行', '美食', '灵感'];
""", """const String kAllCategoryName = '全部';
const String kDefaultCategoryName = '默认';
const String kDefaultJournalFolderName = '日记';

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
""")

text = text.replace("""const List<String> kStickerAssets = [
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
""", "")

text = text.replace("""String _normalizeText(String value) => value.trim();
String _todoCategoryLabel(String category) =>
    '${kTodoCategoryEmoji[category] ?? '📋'} $category';
String _todoCategoryBadgeLabel(String category) =>
    category == '默认' ? '' : category;
String _journalFolderLabel(String folder) =>
    folder == '全部' ? '📂 全部' : '📁 $folder';
String _fontLabel(String fontFamily) => kFontFamilyLabels[fontFamily] ?? '默认';
""", """String _normalizeText(String value) => value.trim();
List<TodoCategory> _cloneCategories(List<TodoCategory> source) =>
    source.map((e) => TodoCategory(name: e.name, iconAsset: e.iconAsset)).toList();

String _safeStickerAsset(String asset) =>
    kStickerAssets.contains(asset) ? asset : kFabAsset;

List<TodoCategory> _sanitizeCategories(
  List<TodoCategory> categories,
  List<TodoCategory> defaults,
) {
  final result = <TodoCategory>[];
  final seen = <String>{};
  for (final item in categories) {
    final name = item.name.trim();
    if (name.isEmpty || name == kAllCategoryName || seen.contains(name)) continue;
    seen.add(name);
    result.add(TodoCategory(name: name, iconAsset: _safeStickerAsset(item.iconAsset)));
  }
  if (result.isEmpty) return _cloneCategories(defaults);
  return result;
}

TodoCategory _resolveCategory(
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

TodoCategory _allCategoryMeta(List<TodoCategory> categories) => TodoCategory(
  name: kAllCategoryName,
  iconAsset: categories.isNotEmpty ? categories.first.iconAsset : kFabAsset,
);

String _normalizedTodoCategoryValue(String? value, List<TodoCategory> categories) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty || raw == kAllCategoryName) return kDefaultCategoryName;
  final exists = categories.any((item) => item.name == raw);
  if (exists) return raw;
  return categories.any((item) => item.name == kDefaultCategoryName)
      ? kDefaultCategoryName
      : categories.first.name;
}

String _normalizedFolderValue(String? value, List<TodoCategory> folders) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty || raw == kAllCategoryName) return kDefaultJournalFolderName;
  final exists = folders.any((item) => item.name == raw);
  if (exists) return raw;
  return folders.any((item) => item.name == kDefaultJournalFolderName)
      ? kDefaultJournalFolderName
      : folders.first.name;
}

String _todoCategoryBadgeLabel(String category) =>
    category == kDefaultCategoryName ? '' : category;
String _fontLabel(String fontFamily) => kFontFamilyLabels[fontFamily] ?? '默认';
""")

text = text.replace("""class BackupPayload {
  BackupPayload({
    required this.todos,
    required this.pages,
    required this.passcode,
  });

  final List<AppTodo> todos;
  final List<JournalPageData> pages;
  final String? passcode;

  Map<String, dynamic> toJson() => {
    'version': 1,
    'todos': todos.map((e) => e.toJson()).toList(),
    'pages': pages.map((e) => e.toJson()).toList(),
    'passcode': passcode,
  };

  factory BackupPayload.fromJson(Map<String, dynamic> json) {
    final todoList = ((json['todos'] as List?) ?? [])
        .map((e) => AppTodo.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final pageList = ((json['pages'] as List?) ?? [])
        .map(
          (e) => JournalPageData.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
    return BackupPayload(
      todos: todoList,
      pages: pageList,
      passcode: json['passcode'] as String?,
    );
  }
}
""", """class BackupPayload {
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
    'version': 2,
    'todos': todos.map((e) => e.toJson()).toList(),
    'pages': pages.map((e) => e.toJson()).toList(),
    'passcode': passcode,
    'todoCategories': todoCategories.map((e) => e.toJson()).toList(),
    'journalFolders': journalFolders.map((e) => e.toJson()).toList(),
  };

  factory BackupPayload.fromJson(Map<String, dynamic> json) {
    final todoList = ((json['todos'] as List?) ?? [])
        .map((e) => AppTodo.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final pageList = ((json['pages'] as List?) ?? [])
        .map(
          (e) => JournalPageData.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
    final todoCategories = ((json['todoCategories'] as List?) ?? [])
        .map((e) => TodoCategory.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final journalFolders = ((json['journalFolders'] as List?) ?? [])
        .map((e) => TodoCategory.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return BackupPayload(
      todos: todoList,
      pages: pageList,
      passcode: json['passcode'] as String?,
      todoCategories: _sanitizeCategories(todoCategories, kDefaultTodoCategories),
      journalFolders: _sanitizeCategories(journalFolders, kDefaultJournalFolders),
    );
  }
}
""")

text = text.replace("""class AppStorage {
  static const _todoKey = 'moonlight_todos';
  static const _journalKey = 'moonlight_journal_pages';
  static const _passcodeKey = 'moonlight_passcode';
""", """class AppStorage {
  static const _todoKey = 'moonlight_todos';
  static const _journalKey = 'moonlight_journal_pages';
  static const _passcodeKey = 'moonlight_passcode';
  static const _todoCategoryKey = 'moonlight_todo_categories';
  static const _journalFolderKey = 'moonlight_journal_folders';
""")

text = text.replace("""  static Future<String?> loadPasscode() async {
""", """  static Future<List<TodoCategory>> loadTodoCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_todoCategoryKey);
      if (raw == null || raw.isEmpty) return _cloneCategories(kDefaultTodoCategories);
      final data = jsonDecode(raw) as List<dynamic>;
      return _sanitizeCategories(
        data
            .map((e) => TodoCategory.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        kDefaultTodoCategories,
      );
    } catch (_) {
      return _cloneCategories(kDefaultTodoCategories);
    }
  }

  static Future<bool> saveTodoCategories(List<TodoCategory> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        _todoCategoryKey,
        jsonEncode(_sanitizeCategories(categories, kDefaultTodoCategories).map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      return false;
    }
  }

  static Future<List<TodoCategory>> loadJournalFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_journalFolderKey);
      if (raw == null || raw.isEmpty) return _cloneCategories(kDefaultJournalFolders);
      final data = jsonDecode(raw) as List<dynamic>;
      return _sanitizeCategories(
        data
            .map((e) => TodoCategory.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        kDefaultJournalFolders,
      );
    } catch (_) {
      return _cloneCategories(kDefaultJournalFolders);
    }
  }

  static Future<bool> saveJournalFolders(List<TodoCategory> folders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        _journalFolderKey,
        jsonEncode(_sanitizeCategories(folders, kDefaultJournalFolders).map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      return false;
    }
  }

  static Future<String?> loadPasscode() async {
""")

text = text.replace("""  static Future<Map<String, dynamic>> exportBackupData() async {
    final todos = await loadTodos();
    final pages = await loadPages();
    final passcode = await loadPasscode();
    return BackupPayload(
      todos: todos,
      pages: pages,
      passcode: passcode,
    ).toJson();
  }
""", """  static Future<Map<String, dynamic>> exportBackupData() async {
    final todos = await loadTodos();
    final pages = await loadPages();
    final passcode = await loadPasscode();
    final todoCategories = await loadTodoCategories();
    final journalFolders = await loadJournalFolders();
    return BackupPayload(
      todos: todos,
      pages: pages,
      passcode: passcode,
      todoCategories: todoCategories,
      journalFolders: journalFolders,
    ).toJson();
  }
""")

text = text.replace("""    final okTodos = await saveTodos(payload.todos);
    final okPages = await savePages(payload.pages);
    final okPasscode = payload.passcode == null
        ? true
        : await savePasscode(payload.passcode!);
    if (!okTodos || !okPages || !okPasscode) {
""", """    final okTodos = await saveTodos(payload.todos);
    final okPages = await savePages(payload.pages);
    final okTodoCategories = await saveTodoCategories(payload.todoCategories);
    final okJournalFolders = await saveJournalFolders(payload.journalFolders);
    final okPasscode = payload.passcode == null
        ? true
        : await savePasscode(payload.passcode!);
    if (!okTodos || !okPages || !okTodoCategories || !okJournalFolders || !okPasscode) {
""")

text = text.replace("""class _TodoTabState extends State<TodoTab> {
  List<AppTodo> _todos = [];
  bool _loading = true;
  String _selectedCategory = '全部';
""", """class _TodoTabState extends State<TodoTab> {
  List<AppTodo> _todos = [];
  List<TodoCategory> _categories = _cloneCategories(kDefaultTodoCategories);
  bool _loading = true;
  String _selectedCategory = kAllCategoryName;
""")

text = text.replace("""  Future<void> _load() async {
    final list = await AppStorage.loadTodos();
    _sortTodos(list);
    await MoonlightNotifications.instance.syncTodoNotifications(list);
    if (!mounted) return;
    setState(() {
      _todos = list;
      _loading = false;
    });
  }
""", """  Future<void> _load() async {
    final list = await AppStorage.loadTodos();
    final categories = await AppStorage.loadTodoCategories();
    for (final todo in list) {
      todo.category = _normalizedTodoCategoryValue(todo.category, categories);
    }
    _sortTodos(list);
    await MoonlightNotifications.instance.syncTodoNotifications(list);
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _selectedCategory = _selectedCategory == kAllCategoryName
          ? kAllCategoryName
          : _normalizedTodoCategoryValue(_selectedCategory, categories);
      _todos = list;
      _loading = false;
    });
  }
""")

text = text.replace("""  List<AppTodo> get _visibleTodos {
    if (_selectedCategory == '全部') return _todos;
    return _todos.where((e) => e.category == _selectedCategory).toList();
  }
""", """  List<AppTodo> get _visibleTodos {
    if (_selectedCategory == kAllCategoryName) return _todos;
    return _todos.where((e) => e.category == _selectedCategory).toList();
  }

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
    final normalized = _sanitizeCategories(result, kDefaultTodoCategories);
    for (final todo in _todos) {
      todo.category = _normalizedTodoCategoryValue(todo.category, normalized);
    }
    setState(() {
      _categories = normalized;
      if (_selectedCategory != kAllCategoryName &&
          !_categories.any((item) => item.name == _selectedCategory)) {
        _selectedCategory = kAllCategoryName;
      }
      _sortTodos(_todos);
    });
    final ok = await AppStorage.saveTodoCategories(_categories);
    await _persist();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('分类保存失败，请稍后重试')),
      );
    }
  }
""")

text = text.replace("""                      _FilterChip(
                        label: '全部',
                        selected: _selectedCategory == '全部',
                        onTap: () => setState(() => _selectedCategory = '全部'),
                      ),
                      ...kTodoCategories.map(
                        (category) => _FilterChip(
                          label: _todoCategoryLabel(category),
                          selected: _selectedCategory == category,
                          onTap: () =>
                              setState(() => _selectedCategory = category),
                        ),
                      ),
""", """                      _FilterChip(
                        label: kAllCategoryName,
                        iconAsset: _allCategoryMeta(_categories).iconAsset,
                        selected: _selectedCategory == kAllCategoryName,
                        onTap: () => setState(() => _selectedCategory = kAllCategoryName),
                      ),
                      ..._categories.map(
                        (category) => _FilterChip(
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
                          icon: const Icon(Icons.settings_rounded, color: Colors.white),
                        ),
                      ),
""")

text = text.replace("""                                      child: _TodoCard(
                                        todo: todo,
                                        onTapStar: () => _toggleTodo(todo),
                                        onEdit: () => _openEditor(todo: todo),
                                        onDelete: () => _deleteTodo(todo),
                                      ),
""", """                                      child: _TodoCard(
                                        todo: todo,
                                        categoryMeta: _resolveCategory(
                                          todo.category,
                                          _categories,
                                          kDefaultTodoCategories,
                                        ),
                                        onTapStar: () => _toggleTodo(todo),
                                        onEdit: () => _openEditor(todo: todo),
                                        onDelete: () => _deleteTodo(todo),
                                      ),
""")

text = text.replace("""      builder: (_) => TodoEditorSheet(todo: todo),
""", """      builder: (_) => TodoEditorSheet(todo: todo, categories: _categories),
""")

text = text.replace("""class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.todo,
    required this.onTapStar,
    required this.onEdit,
    required this.onDelete,
  });

  final AppTodo todo;
  final VoidCallback onTapStar;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
""", """class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.todo,
    required this.categoryMeta,
    required this.onTapStar,
    required this.onEdit,
    required this.onDelete,
  });

  final AppTodo todo;
  final TodoCategory categoryMeta;
  final VoidCallback onTapStar;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
""")

text = text.replace("""                _TinyCategoryBadge(
                  label: _todoCategoryBadgeLabel(todo.category),
                  color: subtitleColor,
                ),
""", """                _TinyCategoryBadge(
                  label: _todoCategoryBadgeLabel(categoryMeta.name),
                  iconAsset: categoryMeta.iconAsset,
                  color: subtitleColor,
                ),
""")

text = text.replace("""class TodoEditorSheet extends StatefulWidget {
  const TodoEditorSheet({super.key, this.todo});

  final AppTodo? todo;
""", """class TodoEditorSheet extends StatefulWidget {
  const TodoEditorSheet({super.key, this.todo, required this.categories});

  final AppTodo? todo;
  final List<TodoCategory> categories;
""")

text = text.replace("""    _selectedCategory = widget.todo?.category ?? '默认';
""", """    _selectedCategory = _normalizedTodoCategoryValue(
      widget.todo?.category,
      widget.categories,
    );
""")

text = text.replace("""                  items: kTodoCategories
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(_todoCategoryLabel(e)),
                        ),
                      )
                      .toList(),
""", """                  items: widget.categories
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
""")

text = text.replace("""class _JournalTabState extends State<JournalTab> {
  final Random _random = Random();
  final List<Color> _cardColors = [kSoftPink, kLavender, kSkyMist, kCreamGold];
  final TextEditingController _searchController = TextEditingController();
  List<JournalPageData> _pages = [];
  String _query = '';
  bool _loading = true;
  String _selectedFolder = '全部';
""", """class _JournalTabState extends State<JournalTab> {
  final Random _random = Random();
  final List<Color> _cardColors = [kSoftPink, kLavender, kSkyMist, kCreamGold];
  final TextEditingController _searchController = TextEditingController();
  List<JournalPageData> _pages = [];
  List<TodoCategory> _folders = _cloneCategories(kDefaultJournalFolders);
  String _query = '';
  bool _loading = true;
  String _selectedFolder = kAllCategoryName;
""")

text = text.replace("""  Future<void> _load() async {
    final pages = await AppStorage.loadPages();
    pages.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (!mounted) return;
    setState(() {
      _pages = pages;
      _loading = false;
    });
  }
""", """  Future<void> _load() async {
    final pages = await AppStorage.loadPages();
    final folders = await AppStorage.loadJournalFolders();
    for (final page in pages) {
      page.folder = _normalizedFolderValue(page.folder, folders);
    }
    pages.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (!mounted) return;
    setState(() {
      _folders = folders;
      _selectedFolder = _selectedFolder == kAllCategoryName
          ? kAllCategoryName
          : _normalizedFolderValue(_selectedFolder, folders);
      _pages = pages;
      _loading = false;
    });
  }
""")

text = text.replace("""      final matchesFolder =
          _selectedFolder == '全部' || page.folder == _selectedFolder;
""", """      final matchesFolder =
          _selectedFolder == kAllCategoryName || page.folder == _selectedFolder;
""")

text = text.replace("""      folder: _selectedFolder == '全部' ? '日记' : _selectedFolder,
""", """      folder: _selectedFolder == kAllCategoryName ? kDefaultJournalFolderName : _selectedFolder,
""")

text = text.replace("""      context,
      MaterialPageRoute(builder: (_) => JournalEditorPage(page: page)),
    );
""", """      context,
      MaterialPageRoute(builder: (_) => JournalEditorPage(page: page, folders: _folders)),
    );
""")

text = text.replace("""      context,
      MaterialPageRoute(builder: (_) => JournalEditorPage(page: page)),
    );
    if (result == 'saved') {
""", """      context,
      MaterialPageRoute(builder: (_) => JournalEditorPage(page: page, folders: _folders)),
    );
    if (result == 'saved') {
""")

text = text.replace("""  @override
  Widget build(BuildContext context) {
    final displayPages = _filteredPages;
    return MoonPageScaffold(
""", """  Future<void> _openFolderManager() async {
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
    final normalized = _sanitizeCategories(result, kDefaultJournalFolders);
    for (final page in _pages) {
      page.folder = _normalizedFolderValue(page.folder, normalized);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('文件夹保存失败，请稍后重试')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayPages = _filteredPages;
    return MoonPageScaffold(
""")

text = text.replace("""                    children: kJournalFolders
                        .map(
                          (folder) => _FilterChip(
                            label: _journalFolderLabel(folder),
                            selected: _selectedFolder == folder,
                            onTap: () =>
                                setState(() => _selectedFolder = folder),
                          ),
                        )
                        .toList(),
""", """                    children: [
                      _FilterChip(
                        label: kAllCategoryName,
                        iconAsset: _allCategoryMeta(_folders).iconAsset,
                        selected: _selectedFolder == kAllCategoryName,
                        onTap: () => setState(() => _selectedFolder = kAllCategoryName),
                      ),
                      ..._folders.map(
                        (folder) => _FilterChip(
                          label: folder.name,
                          iconAsset: folder.iconAsset,
                          selected: _selectedFolder == folder.name,
                          onTap: () => setState(() => _selectedFolder = folder.name),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: IconButton(
                          tooltip: '管理文件夹',
                          onPressed: _openFolderManager,
                          icon: const Icon(Icons.settings_rounded, color: Colors.white),
                        ),
                      ),
                    ],
""")

text = text.replace("""                                              SmallInfoChip(
                                                label: _journalFolderLabel(
                                                  page.folder,
                                                ),
                                              ),
""", """                                              SmallInfoChip(
                                                label: page.folder,
                                                iconAsset: _resolveCategory(
                                                  page.folder,
                                                  _folders,
                                                  kDefaultJournalFolders,
                                                ).iconAsset,
                                              ),
""")

text = text.replace("""class JournalEditorPage extends StatefulWidget {
  const JournalEditorPage({super.key, required this.page});

  final JournalPageData page;
""", """class JournalEditorPage extends StatefulWidget {
  const JournalEditorPage({super.key, required this.page, required this.folders});

  final JournalPageData page;
  final List<TodoCategory> folders;
""")

text = text.replace("""          children: kJournalFolders.where((e) => e != '全部').map((folder) {
            return ListTile(
              title: Text(_journalFolderLabel(folder)),
              trailing: widget.page.folder == folder
                  ? const Icon(Icons.check_rounded, color: kHotPink)
                  : null,
              onTap: () => Navigator.pop(context, folder),
            );
          }).toList(),
""", """          children: widget.folders.map((folder) {
            return ListTile(
              leading: CategoryAssetAvatar(asset: folder.iconAsset, size: 24),
              title: Text(folder.name),
              trailing: widget.page.folder == folder.name
                  ? const Icon(Icons.check_rounded, color: kHotPink)
                  : null,
              onTap: () => Navigator.pop(context, folder.name),
            );
          }).toList(),
""")

text = text.replace("""class SmallInfoChip extends StatelessWidget {
  const SmallInfoChip({super.key, required this.label});

  final String label;
""", """class SmallInfoChip extends StatelessWidget {
  const SmallInfoChip({super.key, required this.label, this.iconAsset});

  final String label;
  final String? iconAsset;
""")

text = text.replace("""      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF8B5C95),
        ),
      ),
""", """      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconAsset != null) ...[
            CategoryAssetAvatar(asset: iconAsset!, size: 14),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF8B5C95),
            ),
          ),
        ],
      ),
""")

text = text.replace("""class _TinyCategoryBadge extends StatelessWidget {
  const _TinyCategoryBadge({required this.label, required this.color});

  final String label;
  final Color color;
""", """class _TinyCategoryBadge extends StatelessWidget {
  const _TinyCategoryBadge({required this.label, required this.iconAsset, required this.color});

  final String label;
  final String iconAsset;
  final Color color;
""")

text = text.replace("""          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: kCreamGold.withAlpha(235),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
""", """          CategoryAssetAvatar(asset: iconAsset, size: 14),
          const SizedBox(width: 5),
""")

text = text.replace("""class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
""", """class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? iconAsset;
  final bool selected;
  final VoidCallback onTap;
""")

text = text.replace("""              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                  shadows: selected
                      ? const [
                          Shadow(
                            color: Color(0x55000000),
                            blurRadius: 6,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
              ),
""", """              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconAsset != null) ...[
                    CategoryAssetAvatar(asset: iconAsset!, size: 18),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                      shadows: selected
                          ? const [
                              Shadow(
                                color: Color(0x55000000),
                                blurRadius: 6,
                                offset: Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
""")

insert_anchor = "class SmallInfoChip extends StatelessWidget {"
new_widgets = """
class CategoryAssetAvatar extends StatelessWidget {
  const CategoryAssetAvatar({super.key, required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withAlpha(180), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: MoonAssetImage(asset: asset, width: size, height: size, fit: BoxFit.cover),
      ),
    );
  }
}

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
    _items = _cloneCategories(widget.initialItems);
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
    final ok = await showMoonConfirmDialog(
      context,
      title: '删除 ${item.name} ？',
      content: '已经使用这个分类/文件夹的内容会自动回到默认项。',
      confirmText: '删除',
    );
    if (ok == true) {
      setState(() => _items.removeWhere((e) => e.name == item.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF7A2E73)),
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
                      leading: CategoryAssetAvatar(asset: _allCategoryMeta(_items).iconAsset, size: 28),
                      title: const Text('全部'),
                      subtitle: const Text('系统保留入口，仅用于筛选，不能删除'),
                      trailing: const Icon(Icons.lock_outline_rounded, color: kHotPink),
                    );
                  }
                  final item = _items[index - 1];
                  return Dismissible(
                    key: ValueKey('cat_${item.name}'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      await _deleteItem(item);
                      return false;
                    },
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD7DF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB23A48)),
                    ),
                    child: ListTile(
                      onLongPress: () => _deleteItem(item),
                      leading: CategoryAssetAvatar(asset: item.iconAsset, size: 28),
                      title: Text(item.name),
                      subtitle: Text(item.iconAsset.split('/').last),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _items),
                child: const Text('完成'),
              ),
            ),
          ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名称重复了，换一个吧')),
      );
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
      ],
    );
  }
}

"""
text = text.replace(insert_anchor, new_widgets + insert_anchor)

path.write_text(text, encoding='utf-8')
print('patched')
