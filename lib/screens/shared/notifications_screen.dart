import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [
    AppNotification(id: '1', userId: 'u1', type: AppNotificationType.workoutReady, title: 'Novo treino disponível', body: 'Carlos criou o Treino C — Pernas para você.', createdAt: DateTime.now().subtract(const Duration(minutes: 10)), isRead: false, actionRoute: '/student/workout'),
    AppNotification(id: '2', userId: 'u1', type: AppNotificationType.message, title: 'Mensagem de Carlos', body: 'Aumentei a carga no agachamento. Confira!', createdAt: DateTime.now().subtract(const Duration(hours: 1)), isRead: false, actionRoute: '/student/chat'),
    AppNotification(id: '3', userId: 'u1', type: AppNotificationType.achievement, title: 'Conquista desbloqueada!', body: 'Você completou 10 treinos consecutivos. Parabéns! 🏆', createdAt: DateTime.now().subtract(const Duration(hours: 3)), isRead: true),
    AppNotification(id: '4', userId: 'u1', type: AppNotificationType.heartRate, title: 'FC elevada no último treino', body: 'Sua frequência cardíaca chegou a 189 bpm. Fique atento à recuperação.', createdAt: DateTime.now().subtract(const Duration(days: 1)), isRead: true),
    AppNotification(id: '5', userId: 'u1', type: AppNotificationType.payment, title: 'Mensalidade vencendo', body: 'Sua mensalidade vence em 3 dias. Regularize para não perder o acesso.', createdAt: DateTime.now().subtract(const Duration(days: 2)), isRead: true),
    AppNotification(id: '6', userId: 'u1', type: AppNotificationType.workoutReady, title: 'Treino B atualizado', body: 'Carlos ajustou as cargas do Treino B com base no seu progresso.', createdAt: DateTime.now().subtract(const Duration(days: 3)), isRead: true),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() => setState(() {
    _notifications = _notifications.map((n) => AppNotification(
      id: n.id, userId: n.userId, type: n.type, title: n.title,
      body: n.body, createdAt: n.createdAt, isRead: true, actionRoute: n.actionRoute,
    )).toList();
  });

  void _markRead(String id) => setState(() {
    _notifications = _notifications.map((n) => n.id == id
        ? AppNotification(id: n.id, userId: n.userId, type: n.type, title: n.title, body: n.body, createdAt: n.createdAt, isRead: true, actionRoute: n.actionRoute)
        : n).toList();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Row(children: [
          const Text('Notificações'),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: PTColors.primary600, borderRadius: BorderRadius.circular(99)),
              child: Text('$_unreadCount', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
        actions: [
          if (_unreadCount > 0)
            TextButton(onPressed: _markAllRead, child: const Text('Marcar tudo')),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.notifications_none, size: 56, color: PTColors.gray200),
              SizedBox(height: 12),
              Text('Nenhuma notificação', style: TextStyle(color: PTColors.gray400)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notifications.length,
              itemBuilder: (_, i) {
                final n = _notifications[i];
                return _NotifTile(
                  notif: n,
                  onTap: () {
                    _markRead(n.id);
                    if (n.actionRoute != null) context.push(n.actionRoute!);
                  },
                  onDismiss: () => setState(() => _notifications.removeAt(i)),
                );
              },
            ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifTile({required this.notif, required this.onTap, required this.onDismiss});

  IconData get _icon => switch (notif.type) {
    AppNotificationType.workoutReady => Icons.fitness_center,
    AppNotificationType.payment      => Icons.account_balance_wallet_outlined,
    AppNotificationType.message      => Icons.chat_bubble_outline,
    AppNotificationType.heartRate    => Icons.favorite_outline,
    AppNotificationType.achievement  => Icons.emoji_events_outlined,
  };

  Color get _color => switch (notif.type) {
    AppNotificationType.workoutReady => PTColors.teal400,
    AppNotificationType.payment      => PTColors.red400,
    AppNotificationType.message      => PTColors.primary600,
    AppNotificationType.heartRate    => PTColors.amber400,
    AppNotificationType.achievement  => const Color(0xFFE6A817),
  };

  String _timeAgo() {
    final diff = DateTime.now().difference(notif.createdAt);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(color: PTColors.red50, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.delete_outline, color: PTColors.red400),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead ? PTColors.surface : PTColors.primary50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: notif.isRead ? PTColors.border : PTColors.primary100, width: 0.5),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: _color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(_icon, color: _color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(notif.title, style: TextStyle(fontSize: 14, fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700, color: PTColors.gray900))),
                Text(_timeAgo(), style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
              ]),
              const SizedBox(height: 3),
              Text(notif.body, style: const TextStyle(fontSize: 13, color: PTColors.gray600)),
            ])),
            if (!notif.isRead) ...[
              const SizedBox(width: 8),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: PTColors.primary600, shape: BoxShape.circle)),
            ],
          ]),
        ),
      ),
    );
  }
}
