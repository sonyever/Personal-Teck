// ─── AVATAR CIRCLE ───────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/models.dart';

class AvatarCircle extends StatelessWidget {
  final String name;
  final double size;
  final Color? bgColor;
  final Color? textColor;

  const AvatarCircle({super.key, required this.name, this.size = 40, this.bgColor, this.textColor});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: bgColor ?? PTColors.primary50,
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w600,
          color: textColor ?? PTColors.primary600,
        ),
      )),
    );
  }
}

// ─── STAT BOX ─────────────────────────────────────────────────────────────────

class StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatBox({super.key, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PTColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PTColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: PTColors.gray400)),
      ]),
    );
  }
}

// ─── ACTIVITY BADGE ──────────────────────────────────────────────────────────

class ActivityBadge extends StatelessWidget {
  final ActivityType type;

  const ActivityBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    late String label;
    switch (type) {
      case ActivityType.workoutCompleted:
        bg = PTColors.teal50; fg = PTColors.teal600; label = 'feito';
      case ActivityType.inactive:
        bg = PTColors.amber50; fg = PTColors.amber600; label = 'inativo';
      case ActivityType.paymentOverdue:
        bg = PTColors.red50; fg = PTColors.red600; label = 'atraso';
      case ActivityType.newMessage:
        bg = PTColors.primary50; fg = PTColors.primary600; label = 'mensagem';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500)),
    );
  }
}

// ─── HR ZONE BADGE ───────────────────────────────────────────────────────────

class HRZoneBadge extends StatelessWidget {
  final HeartRateZone zone;
  final int bpm;

  const HRZoneBadge({super.key, required this.zone, required this.bpm});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (zone) {
      case HeartRateZone.rest || HeartRateZone.light || HeartRateZone.moderate:
        bg = PTColors.teal50; fg = PTColors.teal600;
      case HeartRateZone.aerobic:
        bg = PTColors.teal50; fg = PTColors.teal800;
      case HeartRateZone.anaerobic:
        bg = PTColors.amber50; fg = PTColors.amber800;
      case HeartRateZone.maximum:
        bg = PTColors.red50; fg = PTColors.red600;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(zone == HeartRateZone.maximum ? Icons.favorite : Icons.favorite_border,
            size: 12, color: fg),
        const SizedBox(width: 4),
        Text('$bpm bpm', style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ─── PAYMENT STATUS BADGE ────────────────────────────────────────────────────

class PaymentBadge extends StatelessWidget {
  final PaymentStatus status;

  const PaymentBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    late String label;
    switch (status) {
      case PaymentStatus.upToDate:
        bg = PTColors.teal50; fg = PTColors.teal600; label = 'em dia';
      case PaymentStatus.pending:
        bg = PTColors.amber50; fg = PTColors.amber600; label = 'pendente';
      case PaymentStatus.overdue:
        bg = PTColors.red50; fg = PTColors.red600; label = 'atrasado';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500)),
    );
  }
}

// ─── SECTION HEADER ──────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: const TextStyle(fontSize: 13, color: PTColors.primary600, fontWeight: FontWeight.w500)),
          ),
      ]),
    );
  }
}

// ─── EMPTY STATE ─────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.icon, required this.title, this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 56, color: PTColors.gray200),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ]),
      ),
    );
  }
}
