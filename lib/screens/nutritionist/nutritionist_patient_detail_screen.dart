import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../widgets/pt_card.dart';
import '../../widgets/avatar_circle.dart';
import '../shared/anamnese_screen.dart';

class NutritionistPatientDetailScreen extends StatelessWidget {
  final String patientId;
  const NutritionistPatientDetailScreen({super.key, required this.patientId});

  static const _names = {
    '1': 'Rafael Alves',   '2': 'Marina Costa',    '3': 'Thiago Silva',
    '4': 'Julia Santos',   '5': 'Carlos Mendes',   '6': 'Ana Paula Rocha',
    '7': 'Beatriz Lima',   '8': 'Lucas Pereira',
  };

  String get _name => _names[patientId] ?? 'Paciente';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PTColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: PTColors.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
            title: Text(_name, style: t.titleMedium),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () => context.push('/nutritionist/chat'),
                tooltip: 'Mensagem',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Header do paciente
                PTCard(
                  child: Row(children: [
                    AvatarCircle(name: _name, size: 56, bgColor: PTColors.teal50),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_name, style: t.headlineSmall),
                      const SizedBox(height: 2),
                      Text('Hipertrofia · Intermediário', style: t.bodySmall),
                      const SizedBox(height: 6),
                      Row(children: [
                        _InfoChip(label: '28 anos', icon: Icons.cake_outlined),
                        const SizedBox(width: 6),
                        _InfoChip(label: '75 kg', icon: Icons.monitor_weight_outlined),
                        const SizedBox(width: 6),
                        _InfoChip(label: '178 cm', icon: Icons.height),
                      ]),
                    ])),
                  ]),
                ),

                const SizedBox(height: 12),

                // Aviso de permissão
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: PTColors.teal50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PTColors.teal100, width: 0.5),
                  ),
                  child: Row(children: [
                    const Icon(Icons.shield_outlined, size: 16, color: PTColors.teal600),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'Você pode visualizar todos os dados e editar apenas as observações nutricionais.',
                      style: const TextStyle(fontSize: 12, color: PTColors.teal800),
                    )),
                  ]),
                ),

                const SizedBox(height: 20),

                // Medidas rápidas
                Text('Composição corporal', style: t.titleMedium),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _MeasureCard(value: '75,2 kg', label: 'Peso', delta: '+0,7 kg', positive: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _MeasureCard(value: '16,4%',  label: 'Gordura', delta: '-0,8%', positive: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _MeasureCard(value: '25,1',   label: 'IMC', delta: '+0,2', positive: false)),
                ]),

                const SizedBox(height: 20),

                // Dados nutricionais (leitura rápida)
                Text('Perfil nutricional', style: t.titleMedium),
                const SizedBox(height: 10),
                PTCard(
                  child: Column(children: [
                    _NutritionRow(icon: Icons.water_drop_outlined,    label: 'Consumo de água',   value: '8 copos/dia',  color: PTColors.primary400),
                    const Divider(height: 1),
                    _NutritionRow(icon: Icons.restaurant_outlined,    label: 'Refeições/dia',      value: '4 refeições',  color: PTColors.teal400),
                    const Divider(height: 1),
                    _NutritionRow(icon: Icons.eco_outlined,           label: 'Tipo de dieta',      value: 'Onívoro',      color: PTColors.primary600),
                    const Divider(height: 1),
                    _NutritionRow(icon: Icons.remove_circle_outline,  label: 'Restrições',         value: 'Nenhuma',      color: PTColors.gray400),
                    const Divider(height: 1),
                    _NutritionRow(icon: Icons.science_outlined,       label: 'Suplementos',        value: 'Whey, Creatina', color: PTColors.amber400),
                  ]),
                ),

                const SizedBox(height: 20),

                // Observações da nutricionista
                Row(children: [
                  Text('Minhas observações', style: t.titleMedium),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: PTColors.amber200, borderRadius: BorderRadius.circular(99)),
                    child: const Text('Plano Plus', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: PTColors.amber800)),
                  ),
                ]),
                const SizedBox(height: 10),
                PTCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text(
                      'Paciente com boa adesão ao protocolo. Recomendada ingestão de 2g/kg de proteína. '
                      'Ajuste de horário de suplementação: whey no pós-treino imediato. '
                      'Monitorar hidratação nos dias de treino intenso.',
                      style: TextStyle(fontSize: 13, color: PTColors.gray600, height: 1.55),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openNutritionAnamnese(context),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Editar observações nutricionais'),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 20),

                // Dados gerais (somente leitura)
                Text('Dados completos do paciente', style: t.titleMedium),
                const SizedBox(height: 10),
                PTCard(
                  child: Column(children: [
                    _InfoRow(label: 'Treinador', value: 'Carlos Ferreira'),
                    const Divider(height: 1),
                    _InfoRow(label: 'Objetivo', value: 'Hipertrofia'),
                    const Divider(height: 1),
                    _InfoRow(label: 'Sono', value: '7h/noite'),
                    const Divider(height: 1),
                    _InfoRow(label: 'Estresse', value: 'Moderado'),
                    const Divider(height: 1),
                    _InfoRow(label: 'Tabagismo', value: 'Nunca'),
                    const Divider(height: 1),
                    _InfoRow(label: 'Álcool', value: '1 dia/semana'),
                  ]),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openFullAnamnese(context),
                    icon: const Icon(Icons.assignment_outlined, size: 16),
                    label: const Text('Ver anamnese completa'),
                  ),
                ),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _openNutritionAnamnese(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnamneseScreen(studentId: patientId, nutritionistMode: true),
      ),
    );
  }

  void _openFullAnamnese(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnamneseScreen(studentId: patientId, readOnly: true),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: PTColors.gray400),
    const SizedBox(width: 3),
    Text(label, style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
  ]);
}

class _MeasureCard extends StatelessWidget {
  final String value, label, delta;
  final bool positive;
  const _MeasureCard({required this.value, required this.label, required this.delta, required this.positive});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: PTColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: PTColors.border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PTColors.gray900)),
      Text(label, style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
      const SizedBox(height: 4),
      Text(delta, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: positive ? PTColors.teal600 : PTColors.red400)),
    ]),
  );
}

class _NutritionRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _NutritionRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
    child: Row(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: PTColors.gray600))),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: PTColors.gray900)),
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: PTColors.gray600))),
      Text(value, style: const TextStyle(fontSize: 13, color: PTColors.gray900, fontWeight: FontWeight.w500)),
    ]),
  );
}
