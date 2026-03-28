import 'package:flutter/material.dart';

import '../constants.dart';
import 'moon_asset_image.dart';

class HaloIcon extends StatelessWidget {
  const HaloIcon({required this.child, required this.size});

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 44,
      height: size + 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(36),
        border: Border.all(color: kGold.withAlpha(209), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(56),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class HaloImage extends StatelessWidget {
  const HaloImage({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 34,
      height: size + 34,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(41),
        border: Border.all(color: kGold.withAlpha(214), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(56),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: MoonAssetImage(asset: asset, fit: BoxFit.cover),
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
