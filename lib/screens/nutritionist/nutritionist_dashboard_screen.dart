import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../widgets/pt_card.dart';
import '../../widgets/avatar_circle.dart';
import '../../widgets/stat_box.dart';
import '../../services/auth_service.dart';

class NutritionistDashboardScreen extends StatelessWidget {
  const NutritionistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PTColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: PTColors.background,
              surfaceTintColor: Colors.transparent,
              title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Olá, ${AuthService.currentName}', style: t.headlineMedium),
                Text(_formattedDate(), style: t.bodySmall),
              ]),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined),
                  onPressed: () => context.push('/nutritionist/profile'),
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // Plano Plus badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: PTColors.amber50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PTColors.amber200, width: 0.5),
                  ),
                  child: Row(children: [
                    const Icon(Icons.workspace_premium, size: 16, color: PTColors.amber600),
                    const SizedBox(width: 8),
                    Text('Nutricionista parceira — Plano Plus', style: t.bodySmall?.copyWith(color: PTColors.amber800, fontWeight: FontWeight.w500)),
                  ]),
                ),

                const SizedBox(height: 16),

                // Stats
                Row(children: [
                  Expanded(child: StatBox(value: '8', label: 'Pacientes ativos', color: PTColors.teal400)),
                  const SizedBox(width: 10),
                  Expanded(child: StatBox(value: '3', label: 'Aguardando obs.', color: PTColors.amber400)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: StatBox(value: '5', label: 'Atualizados hoje', color: PTColors.primary600)),
                  const SizedBox(width: 10),
                  Expanded(child: StatBox(value: '2', label: 'Retornos pendentes', color: PTColors.red400)),
                ]),

                const SizedBox(height: 24),

                // Acesso rápido
                Row(children: [
                  Expanded(child: _QuickAction(
                    icon: Icons.people_outline,
                    label: 'Pacientes',
                    color: PTColors.teal50,
                    iconColor: PTColors.teal600,
                    onTap: () => context.go('/nutritionist/patients'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _QuickAction(
                    icon: Icons.chat_bubble_outline,
                    label: 'Mensagens',
                    color: PTColors.primary50,
                    iconColor: PTColors.primary600,
                    onTap: () => context.go('/nutritionist/chat'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _QuickAction(
                    icon: Icons.restaurant_menu_outlined,
                    label: 'Observações',
                    color: PTColors.amber50,
                    iconColor: PTColors.amber600,
                    onTap: () => context.go('/nutritionist/patients'),
                  )),
                ]),

                const SizedBox(height: 24),

                // Pacientes que precisam de atenção
                Text('Aguardando observações', style: t.titleMedium),
                const SizedBox(height: 10),

                ..._pending.map((p) => PTCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  onTap: () => context.push('/nutritionist/patients/${p.$1}'),
                  child: Row(children: [
                    AvatarCircle(name: p.$2, size: 40, bgColor: PTColors.amber50),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.$2, style: t.titleSmall),
                      Text(p.$3, style: t.bodySmall),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: PTColors.amber50, borderRadius: BorderRadius.circular(99)),
                      child: const Text('Pendente', style: TextStyle(fontSize: 11, color: PTColors.amber600, fontWeight: FontWeight.w500)),
                    ),
                  ]),
                )),

                const SizedBox(height: 24),

                Text('Atualizados recentemente', style: t.titleMedium),
                const SizedBox(height: 10),

                ..._recent.map((p) => PTCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  onTap: () => context.push('/nutritionist/patients/${p.$1}'),
                  child: Row(children: [
                    AvatarCircle(name: p.$2, size: 40),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.$2, style: t.titleSmall),
                      Text(p.$3, style: t.bodySmall),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: PTColors.teal50, borderRadius: BorderRadius.circular(99)),
                      child: const Text('Atualizado', style: TextStyle(fontSize: 11, color: PTColors.teal600, fontWeight: FontWeight.w500)),
                    ),
                  ]),
                )),

                const SizedBox(height: 80),
              ])),
            ),
          ],
        ),
      ),
    );
  }

  static const _pending = [
    ('2', 'Marina Costa',   'Sem observações nutricionais'),
    ('5', 'Carlos Mendes',  'Anamnese nutricional incompleta'),
    ('6', 'Ana Paula Rocha','Aguardando plano alimentar'),
  ];

  static const _recent = [
    ('1', 'Rafael Alves',  'Obs. atualizadas há 2 dias'),
    ('3', 'Thiago Silva',  'Suplementação revisada ontem'),
    ('4', 'Julia Santos',  'Restrições alimentares atualizadas'),
  ];

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
  final Color color, iconColor;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: PTColors.border, width: 0.5)),
      child: Column(children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: iconColor, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}
