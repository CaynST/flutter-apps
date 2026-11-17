import 'package:flutter/material.dart';

import '../core/theme.dart';

class Seal extends StatelessWidget {
  const Seal({
    super.key,
    required this.label,
    this.size = 56,
    this.color = ink,
    this.fill,
    this.labelColor,
  });

  final String label;
  final double size;
  final Color color;
  final Color? fill;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: color, width: 1.4),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: fraunces(
          size: size * 0.36,
          color: labelColor ?? (fill != null ? paper : color),
        ),
      ),
    );
  }
}
