// lib/widgets/pt_card.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class PTCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? color;

  const PTCard({super.key, required this.child, this.padding, this.margin, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
        padding: padding ?? const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color ?? PTColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PTColors.border, width: 0.5),
        ),
        child: child,
      ),
    );
  }
}
