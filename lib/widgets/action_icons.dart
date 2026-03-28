import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/todo.dart';
import 'moon_asset_image.dart';

class ActionAssetIcon extends StatelessWidget {
  const ActionAssetIcon({
    required this.asset,
    this.size = 24,
    this.fit = BoxFit.cover,
  });

  final String asset;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return _assetIcon(asset, size: size, fit: fit);
  }
}

class TabAssetIcon extends StatelessWidget {
  const TabAssetIcon({required this.asset, this.selected = false});

  final String asset;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? kGold : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: SizedBox(
          width: 24,
          height: 24,
          child: MoonAssetImage(asset: asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class MoonImageFab extends StatelessWidget {
  const MoonImageFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(56),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.white.withAlpha(242),
        child: const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: MoonAssetImage(
              asset: kFabAsset,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryAssetAvatar extends StatelessWidget {
  const CategoryAssetAvatar({
    super.key,
    required this.asset,
    required this.size,
  });

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
        child: MoonAssetImage(
          asset: asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}


Widget _assetIcon(
  String assetPath, {
  double size = 24,
  double radiusFactor = 0.25,
  BoxFit fit = BoxFit.cover,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(size * radiusFactor),
    child: MoonAssetImage(
      asset: assetPath,
      width: size,
      height: size,
      fit: fit,
    ),
  );
}
