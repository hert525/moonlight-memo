import 'dart:math';

import 'package:flutter/material.dart';

class DecorItem {
  DecorItem({
    required this.id,
    required this.path,
    required this.type,
    required this.dx,
    required this.dy,
    required this.baseSize,
    this.scale = 1,
    this.rotation = 0,
  });

  final String id;
  String path;
  String type;
  double dx;
  double dy;
  double baseSize;
  double scale;
  double rotation;

  double get displaySize => max(32, baseSize * scale);

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'type': type,
    'dx': dx,
    'dy': dy,
    'baseSize': baseSize,
    'scale': scale,
    'rotation': rotation,
  };

  factory DecorItem.fromJson(Map<String, dynamic> json) => DecorItem(
    id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
    path: json['path'] as String? ?? '',
    type: json['type'] as String? ?? 'sticker',
    dx: (json['dx'] as num?)?.toDouble() ?? 0,
    dy: (json['dy'] as num?)?.toDouble() ?? 0,
    baseSize: (json['baseSize'] as num?)?.toDouble() ?? 92,
    scale: (json['scale'] as num?)?.toDouble() ?? 1,
    rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
  );
}

class JournalPageData {
  JournalPageData({
    required this.id,
    required this.backgroundAsset,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.folder,
    this.fontFamily = '',
    this.fontSize = 18,
    this.textColor = const Color(0xFF6B2E63),
    this.sortOrder = 0,
    List<DecorItem>? items,
  }) : items = items ?? [];

  final String id;
  String backgroundAsset;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  String folder;
  String fontFamily;
  double fontSize;
  Color textColor;
  int sortOrder;
  List<DecorItem> items;

  List<DecorItem> get stickers => items.where((e) => e.type == 'sticker').toList();
  List<DecorItem> get photos => items.where((e) => e.type == 'photo').toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'backgroundAsset': backgroundAsset,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'folder': folder,
    'fontFamily': fontFamily,
    'fontSize': fontSize,
    'textColor': textColor.toARGB32(),
    'sortOrder': sortOrder,
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory JournalPageData.fromJson(Map<String, dynamic> json) => JournalPageData(
    id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
    backgroundAsset: json['backgroundAsset'] as String? ?? '',
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    folder: json['folder'] as String? ?? '日记',
    fontFamily: json['fontFamily'] as String? ?? '',
    fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18,
    textColor: Color((json['textColor'] as num?)?.toInt() ?? const Color(0xFF6B2E63).value),
    sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    items: ((json['items'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => DecorItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}
