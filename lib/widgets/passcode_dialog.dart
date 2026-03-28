import 'package:flutter/material.dart';

import '../constants.dart';
import 'moon_asset_image.dart';

enum PasscodeMode { create, verify }

class MoonPasscodeDialog extends StatefulWidget {
  const MoonPasscodeDialog({super.key, required this.mode});

  final PasscodeMode mode;

  @override
  State<MoonPasscodeDialog> createState() => _MoonPasscodeDialogState();
}

class _MoonPasscodeDialogState extends State<MoonPasscodeDialog> {
  String _value = '';
  String? _error;

  void _tap(String input) {
    if (_value.length >= 4) return;
    setState(() {
      _value += input;
      _error = null;
    });
    if (_value.length == 4) {
      Future<void>.delayed(const Duration(milliseconds: 100), _submit);
    }
  }

  void _backspace() {
    if (_value.isEmpty) return;
    setState(() {
      _value = _value.substring(0, _value.length - 1);
      _error = null;
    });
  }

  void _submit() {
    if (_value.length != 4) {
      setState(() => _error = '请输入 4 位数字密码');
      return;
    }
    Navigator.pop(context, _value);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(242),
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(56),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: const MoonAssetImage(
                asset: kJournalTabIcon,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.mode == PasscodeMode.create ? '设置月光密码' : '输入月光密码',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF7A2E73),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.mode == PasscodeMode.create
                  ? '设置一个 4 位数字密码，守护你的秘密手账。'
                  : '输入之前设置的 4 位数字密码。',
              textAlign: TextAlign.center,
              style: const TextStyle(
                height: 1.6,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9B6A94),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _value.length ? kHotPink : Colors.white,
                    border: Border.all(color: kHotPink.withAlpha(140), width: 1.5),
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                  color: Color(0xFFD94B5C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                for (final n in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
                  PasscodeButton(label: n, onTap: () => _tap(n)),
                const SizedBox.shrink(),
                PasscodeButton(label: '0', onTap: () => _tap('0')),
                PasscodeButton(
                  label: '⌫',
                  onTap: _backspace,
                  backgroundColor: const Color(0xFFFFE6F1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PasscodeButton extends StatelessWidget {
  const PasscodeButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withAlpha(248),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kGold.withAlpha(118)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: kPurple,
            ),
          ),
        ),
      ),
    );
  }
}
