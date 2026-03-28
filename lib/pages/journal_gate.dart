import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/storage.dart';
import '../widgets/halo_widgets.dart';
import '../widgets/moon_scaffold.dart';
import '../widgets/passcode_dialog.dart';
import 'journal_tab.dart';

class JournalGateTab extends StatefulWidget {
  const JournalGateTab({super.key});

  @override
  State<JournalGateTab> createState() => _JournalGateTabState();
}

class _JournalGateTabState extends State<JournalGateTab> {
  String? _passcode;
  bool _loading = true;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final code = await AppStorage.loadPasscode();
    if (!mounted) return;
    setState(() {
      _passcode = code;
      _loading = false;
    });
  }

  Future<void> _openPasscodePad() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MoonPasscodeDialog(
        mode: _passcode == null ? PasscodeMode.create : PasscodeMode.verify,
      ),
    );
    if (result == null) return;

    if (_passcode == null) {
      final ok = await AppStorage.savePasscode(result);
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('密码保存失败，请稍后重试')));
        return;
      }
      setState(() {
        _passcode = result;
        _unlocked = true;
      });
      return;
    }

    if (!mounted) return;
    if (result == _passcode) {
      setState(() => _unlocked = true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('密码不对哦，再试一次 ✨')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: kHotPink));
    }
    if (_unlocked) {
      return JournalTab(
        onLock: () => setState(() => _unlocked = false),
        currentPasscode: _passcode,
        onPasscodeChanged: (value) => setState(() => _passcode = value),
      );
    }

    return MoonPageScaffold(
      title: '🌙 月光手账 🌙',
      subtitle: '✨ 秘密只留给月亮知道',
      backgroundAsset: kPasscodeBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black.withAlpha(82)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(205),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withAlpha(155),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(38),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HaloImage(asset: kPasscodeHeroSticker, size: 84),
                    const SizedBox(height: 18),
                    Text(
                      _passcode == null ? '先设置你的月光密码' : '输入密码，进入秘密花园',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF7A3B80),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '🌙✨ 收藏背景、贴纸和照片，把每一天写成魔法日记。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.6,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9B6A94),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: kHotPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                      ),
                      onPressed: _openPasscodePad,
                      child: Text(
                        _passcode == null ? '🔐 设置密码' : '💖 输入密码',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
