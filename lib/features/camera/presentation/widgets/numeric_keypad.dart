import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';

class NumericKeypad extends StatelessWidget {
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<_KeyDef>>[
      [_KeyDef.digit(1), _KeyDef.digit(2), _KeyDef.digit(3)],
      [_KeyDef.digit(4), _KeyDef.digit(5), _KeyDef.digit(6)],
      [_KeyDef.digit(7), _KeyDef.digit(8), _KeyDef.digit(9)],
      [_KeyDef.empty(), _KeyDef.digit(0), _KeyDef.backspace()],
    ];

    return Column(
      children: [
        for (final row in rows) ...[
          Row(
            children: [
              for (int i = 0; i < row.length; i++) ...[
                Expanded(child: _KeyButton(def: row[i], onDigit: onDigit, onBackspace: onBackspace)),
                if (i != row.length - 1) const SizedBox(width: AppSpacing.x12),
              ],
            ],
          ),
          if (row != rows.last) const SizedBox(height: AppSpacing.x12),
        ],
      ],
    );
  }
}

enum _KeyKind { digit, backspace, empty }

class _KeyDef {
  final _KeyKind kind;
  final int? digit;
  const _KeyDef._(this.kind, this.digit);
  factory _KeyDef.digit(int d) => _KeyDef._(_KeyKind.digit, d);
  factory _KeyDef.backspace() => const _KeyDef._(_KeyKind.backspace, null);
  factory _KeyDef.empty() => const _KeyDef._(_KeyKind.empty, null);
}

class _KeyButton extends StatelessWidget {
  final _KeyDef def;
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  const _KeyButton({
    required this.def,
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;

    if (def.kind == _KeyKind.empty) {
      return const SizedBox(height: 64);
    }

    VoidCallback? onTap;
    Widget child;
    if (def.kind == _KeyKind.digit) {
      onTap = () => onDigit(def.digit!);
      child = Text(
        '${def.digit}',
        style: TextStyle(
          color: c.text,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      );
    } else {
      onTap = onBackspace;
      child = JbIcon(JbIcon.backspace, size: 24, color: c.text);
    }

    return Material(
      color: c.bgSubtle,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          height: 64,
          child: Center(child: child),
        ),
      ),
    );
  }
}
