import 'package:flutter/material.dart';

import '../widgets/gradient_text.dart';
import 'moon_asset_image.dart';

class MoonPageScaffold extends StatelessWidget {
  const MoonPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.backgroundAsset,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String backgroundAsset;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MoonAssetImage(asset: backgroundAsset, fit: BoxFit.cover),
        Container(color: Colors.black.withAlpha(102)),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: GradientText(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.4,
              ),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD7F1), Colors.white, Color(0xFFFFE79A)],
              ),
            ),
            actions: actions,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(28),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(224),
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(color: Color(0xAA000000), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: child,
          floatingActionButton: floatingActionButton,
        ),
      ],
    );
  }
}
