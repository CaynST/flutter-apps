import 'package:flutter/material.dart';

import '../core/theme.dart';

class TaskCheck extends StatelessWidget {
  const TaskCheck({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      label: value ? 'Hecha' : 'Pendiente',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? moss : paper,
              border: Border.all(color: value ? moss : ink, width: 1.4),
            ),
            child: value
                ? const Icon(Icons.check, size: 15, color: paper)
                : null,
          ),
        ),
      ),
    );
  }
}
