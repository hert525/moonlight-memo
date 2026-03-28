import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/todo.dart';
import 'action_icons.dart';

class SmallInfoChip extends StatelessWidget {
  const SmallInfoChip({super.key, required this.label, this.iconAsset});

  final String label;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(199),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kGold.withAlpha(102)),
      ),
      child: Row(
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
    );
  }
}

class TinyCategoryBadge extends StatelessWidget {
  const TinyCategoryBadge({
    required this.label,
    required this.iconAsset,
    required this.color,
  });

  final String label;
  final String iconAsset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kHotPink.withAlpha(176), kPurple.withAlpha(164)],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kGold.withAlpha(72), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(kPurple, color, 0.35)!.withAlpha(32),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoryAssetAvatar(asset: iconAsset, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  const FilterChip({
    required this.label,
    this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : const Color(0xFF9E4C93);
    final gradient = selected
        ? const LinearGradient(
            colors: [Color(0xE8FF7CCF), Color(0xD89B59B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              const Color(0xFFFFE6F4).withAlpha(196),
              const Color(0xFFF6D8FF).withAlpha(172),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? kGold.withAlpha(90)
                    : const Color(0xFFFFC9E8).withAlpha(140),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: (selected ? kPurple : kHotPink).withAlpha(22),
                  blurRadius: selected ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
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
            ),
          ),
        ),
      ),
    );
  }
}
