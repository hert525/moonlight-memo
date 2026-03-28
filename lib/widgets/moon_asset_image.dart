import 'package:flutter/material.dart';

import '../constants.dart';

class MoonAssetImage extends StatelessWidget {
  const MoonAssetImage({
    super.key,
    required this.asset,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String asset;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Container(color: Colors.white.withAlpha(18)),
            const Center(child: PinkLoading()),
          ],
        );
      },
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: const Color(0x22FFFFFF),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white70,
        ),
      ),
    );
  }
}

class PinkLoading extends StatelessWidget {
  const PinkLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: const AlwaysStoppedAnimation<Color>(kHotPink),
        backgroundColor: Colors.white.withAlpha(140),
      ),
    );
  }
}
