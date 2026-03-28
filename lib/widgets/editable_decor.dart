import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/journal.dart';
import 'moon_asset_image.dart';

class EditableDecorWidget extends StatefulWidget {
  const EditableDecorWidget({
    super.key,
    required this.item,
    required this.maxWidth,
    required this.maxHeight,
    required this.selected,
    required this.onTap,
    required this.onChanged,
  });

  final DecorItem item;
  final double maxWidth;
  final double maxHeight;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onChanged;

  @override
  State<EditableDecorWidget> createState() => _EditableDecorWidgetState();
}

class _EditableDecorWidgetState extends State<EditableDecorWidget> {
  late double _startScale;
  late double _startRotation;

  void _clamp() {
    final size = widget.item.displaySize;
    widget.item.dx = widget.item.dx.clamp(
      0.0,
      max(0.0, widget.maxWidth - size),
    );
    widget.item.dy = widget.item.dy.clamp(
      0.0,
      max(0.0, widget.maxHeight - size),
    );
  }

  @override
  Widget build(BuildContext context) {
    _clamp();
    final item = widget.item;
    final isPhoto = item.type == 'photo';
    return Positioned(
      left: item.dx,
      top: item.dy,
      child: GestureDetector(
        onTap: widget.onTap,
        onScaleStart: (_) {
          _startScale = item.scale;
          _startRotation = item.rotation;
          widget.onTap();
        },
        onScaleUpdate: (details) {
          setState(() {
            item.scale = (_startScale * details.scale).clamp(
              0.55,
              isPhoto ? 2.6 : 2.2,
            );
            item.rotation = _startRotation + details.rotation;
            item.dx = (item.dx + details.focalPointDelta.dx).clamp(
              0.0,
              max(0.0, widget.maxWidth - item.displaySize),
            );
            item.dy = (item.dy + details.focalPointDelta.dy).clamp(
              0.0,
              max(0.0, widget.maxHeight - item.displaySize),
            );
          });
          widget.onChanged();
        },
        child: Transform.rotate(
          angle: item.rotation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: item.displaySize,
            height: item.displaySize,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isPhoto
                  ? Colors.white.withAlpha(235)
                  : Colors.white.withAlpha(46),
              borderRadius: BorderRadius.circular(isPhoto ? 20 : 18),
              border: Border.all(
                color: widget.selected ? kGold : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(38),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isPhoto ? 16 : 14),
              child: isPhoto
                  ? _PhotoDecorImage(path: item.path)
                  : MoonAssetImage(asset: item.path, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoDecorImage extends StatelessWidget {
  const _PhotoDecorImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    if (!file.existsSync()) {
      return const _MissingPhotoPlaceholder();
    }
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _MissingPhotoPlaceholder(),
    );
  }
}

class _MissingPhotoPlaceholder extends StatelessWidget {
  const _MissingPhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9E7F4),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_outlined, color: kPurple, size: 28),
          SizedBox(height: 8),
          Text(
            '照片不见啦',
            style: TextStyle(color: kPurple, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
