import 'package:flutter/material.dart';

import 'halo_widgets.dart';

class MoonEmptyState extends StatelessWidget {
  const MoonEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Widget icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HaloIcon(size: 84, child: icon),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.65,
                fontWeight: FontWeight.w700,
                color: Colors.white.withAlpha(230),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
