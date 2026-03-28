import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/storage.dart';
import '../widgets/moon_asset_image.dart';
import 'home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final watch = Stopwatch()..start();
    final initFuture = Future.wait([
      AppStorage.loadTodos(),
      AppStorage.loadPages(),
      AppStorage.loadPasscode(),
    ]);
    await Future.any([
      initFuture,
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    final remain = Duration(
      milliseconds: max(0, 800 - watch.elapsedMilliseconds),
    );
    if (remain > Duration.zero) {
      await Future<void>.delayed(remain);
    }
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MoonAssetImage(asset: kSplashBackground, fit: BoxFit.cover),
          Container(color: Colors.black.withAlpha(118)),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  ClipOval(
                    child: MoonAssetImage(
                      asset: kSplashLogoAsset,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 22),
                  Text(
                    '月光手账',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(color: Color(0xCC000000), blurRadius: 18),
                        Shadow(color: Color(0x99A13BE5), blurRadius: 24),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Moonlight notes, real magic vibes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
