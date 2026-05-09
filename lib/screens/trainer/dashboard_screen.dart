import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../widgets/pt_card.dart';
import '../../widgets/stat_box.dart';
import '../../widgets/avatar_circle.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Mock data — substituir por Riverpod providers conectados ao backend
  TrainerDashboard get _mock => TrainerDashboard(
    totalActiveStudents: 24,
    studentsWithoutWorkout: 3,
    pendingPayments: 2,
    renewalsToday: 5,
    recentActivity: [
      RecentActivity(studentId: '1', studentName: 'Rafael Alves', description: 'Concluiu Treino A', type: ActivityType.workoutCompleted, at: DateTime.now().subtract(const Duration(minutes: 20))),
      RecentActivity(studentId: '2', studentName: 'Marina Costa', description: 'Sem treino há 4 dias', type: ActivityType.inactive, at: DateTime.now().subtract(const Duration(hours: 4))),
      RecentActivity(studentId: '3', studentName: 'Thiago Silva', description: 'Pagamento em atraso', type: ActivityType.paymentOverdue, at: DateTime.now().subtract(const Duration(days: 1))),
      RecentActivity(studentId: '4', studentName: 'Julia Santos', description: 'Concluiu Treino B', type: ActivityType.workoutCompleted, at: DateTime.now().subtract(const Duration(hours: 2))),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final d = _mock;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PTColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: PTColors.background,
              surfaceTintColor: Colors.transparent,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Olá, Carlos', style: t.headlineMedium),
                  Text(_formattedDate(), style: t.bodySmall),
                ],
              ),
              actions: [
                // Botão ao vivo de wearable
                IconButton(
                  icon: Stack(children: [
                    const Icon(Icons.monitor_heart_outlined),
                    Positioned(top: 0, right: 0, child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: PTColors.teal400, shape: BoxShape.circle),
                    )),
                  ]),
                  onPressed: () => context.push('/trainer/wearable-live'),
                  tooltip: 'Alunos ao vivo',
                ),
                IconButton(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  onPressed: () => context.push('/trainer/financial'),
                  tooltip: 'Financeiro',
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                  tooltip: 'Notificações',
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined),
                  onPressed: () => context.push('/trainer/profile'),
                  tooltip: 'Perfil',
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // ── Stats Grid ──────────────────────────────────────────
                Row(children: [
                  Expanded(child: StatBox(value: '${d.totalActiveStudents}', label: 'Alunos ativos', color: PTColors.primary600)),
                  const SizedBox(width: 10),
                  Expanded(child: StatBox(value: '${d.studentsWithoutWorkout}', label: 'Sem treino', color: d.studentsWithoutWorkout > 0 ? PTColors.amber400 : PTColors.teal400)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: StatBox(value: '${d.pendingPayments}', label: 'Pgto. pendente', color: d.pendingPayments > 0 ? PTColors.red600 : PTColors.teal400)),
                  const SizedBox(width: 10),
                  Expanded(child: StatBox(value: '${d.renewalsToday}', label: 'Renovações hoje', color: PTColors.primary400)),
                ]),

                const SizedBox(height: 24),

                // ── Ação rápida ──────────────────────────────────────────
                Row(children: [
                  Expanded(child: _QuickAction(
                    icon: Icons.fitness_center_outlined,
                    label: 'Meus Treinos',
                    color: PTColors.primary50,
                    iconColor: PTColors.primary600,
                    onTap: () => context.push('/trainer/workouts'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _QuickAction(
                    icon: Icons.people_outline,
                    label: 'Alunos',
                    color: PTColors.teal50,
                    iconColor: PTColors.teal400,
                    onTap: () => context.go('/trainer/students'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _QuickAction(
                    icon: Icons.calendar_today_outlined,
                    label: 'Agenda',
                    color: PTColors.amber50,
                    iconColor: PTColors.amber400,
                    onTap: () => context.go('/trainer/agenda'),
                  )),
                ]),

                const SizedBox(height: 24),

                // ── Atividade recente ────────────────────────────────────
                Text('Atividade recente', style: t.titleMedium),
                const SizedBox(height: 12),

                ...d.recentActivity.map((a) => _ActivityTile(
                  activity: a,
                  onTap: () => context.go('/trainer/students/${a.studentId}'),
                )),

                const SizedBox(height: 80),
              ])),
            ),
          ],
        ),
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const dias = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
    const meses = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return '${dias[now.weekday % 7]}, ${now.day} de ${meses[now.month - 1]}';
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PTColors.border, width: 0.5),
        ),
        child: Column(children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: iconColor, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final RecentActivity activity;
  final VoidCallback onTap;

  const _ActivityTile({required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PTCard(
      margin: const EdgeInsets.only(bottom: 8),
      onTap: onTap,
      child: Row(children: [
        AvatarCircle(name: activity.studentName, size: 36),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(activity.studentName, style: Theme.of(context).textTheme.titleSmall),
          Text(activity.description, style: Theme.of(context).textTheme.bodySmall),
        ])),
        ActivityBadge(type: activity.type),
      ]),
    );
  }
}
