import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../widgets/pt_card.dart';
import '../../widgets/avatar_circle.dart';

// Mock measurements for the student
final _kMockMeasurements = [
  BodyMeasurement(studentId: '1', date: DateTime(2026, 5, 1), weightKg: 75.2, bodyFatPct: 16.4, waistCm: 82, hipCm: 96, chestCm: 101, armCm: 36, thighCm: 58),
  BodyMeasurement(studentId: '1', date: DateTime(2026, 4, 1), weightKg: 74.5, bodyFatPct: 17.2, waistCm: 83, hipCm: 97, chestCm: 100, armCm: 35, thighCm: 57),
  BodyMeasurement(studentId: '1', date: DateTime(2026, 3, 1), weightKg: 73.8, bodyFatPct: 18.0, waistCm: 85, hipCm: 98, chestCm: 99, armCm: 34.5, thighCm: 56),
];

class StudentDetailScreen extends StatelessWidget {
  final String studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  // Mock
  StudentProfile get _profile => StudentProfile(
    userId: studentId, trainerId: 't1',
    age: 28, weightKg: 75, heightCm: 178,
    primaryModality: TrainingModality.strength,
    goal: 'Hipertrofia', level: 'Intermediário',
    hasWearable: true,
    paymentStatus: PaymentStatus.upToDate,
    lastTraining: DateTime.now().subtract(const Duration(hours: 20)),
  );

  static const _names = {'1': 'Rafael Alves', '2': 'Marina Costa', '3': 'Thiago Silva', '4': 'Julia Santos', '5': 'Carlos Mendes', '6': 'Ana Paula Rocha'};
  String get _name => _names[studentId] ?? 'Aluno';

  @override
  Widget build(BuildContext context) {
    final p = _profile;
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
              IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => context.push('/trainer/chat'), tooltip: 'Mensagem'),
              IconButton(icon: const Icon(Icons.assignment_outlined), tooltip: 'Anamnese', onPressed: () => context.push('/trainer/students/$studentId/anamnese')),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Perfil header
                PTCard(
                  child: Row(children: [
                    AvatarCircle(name: _name, size: 56),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_name, style: t.headlineSmall),
                      const SizedBox(height: 2),
                      Text('${p.goal} · ${p.level}', style: t.bodySmall),
                      const SizedBox(height: 4),
                      Row(children: [
                        _InfoBadge(label: '${p.age} anos', icon: Icons.cake_outlined),
                        const SizedBox(width: 6),
                        _InfoBadge(label: '${p.weightKg.toInt()} kg', icon: Icons.monitor_weight_outlined),
                        const SizedBox(width: 6),
                        if (p.hasWearable) _InfoBadge(label: 'Wearable', icon: Icons.watch_outlined),
                      ]),
                    ])),
                  ]),
                ),

                const SizedBox(height: 16),

                // Stats rápidos
                Row(children: [
                  Expanded(child: _StatCard(value: '12', label: 'Treinos no mês', color: PTColors.primary600)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(value: '87%', label: 'Presença', color: PTColors.teal400)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(value: '4.2 kg', label: 'Ganho (3 meses)', color: PTColors.primary400)),
                ]),

                const SizedBox(height: 20),

                // Ações
                Text('Ações rápidas', style: t.titleMedium),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _ActionButton(
                    icon: Icons.fitness_center,
                    label: 'Atribuir treino',
                    onTap: () => _showAssignSheet(context),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _ActionButton(
                    icon: Icons.auto_awesome,
                    label: 'Treino IA',
                    onTap: () => context.push('/trainer/students/$studentId/ai-workout'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _ActionButton(
                    icon: Icons.monitor_heart_outlined,
                    label: 'Ao vivo',
                    onTap: () => context.push('/trainer/wearable-live'),
                  )),
                ]),

                const SizedBox(height: 20),

                // Treinos recentes
                Text('Treinos recentes', style: t.titleMedium),
                const SizedBox(height: 10),

                ..._recentWorkouts.map((w) => PTCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: PTColors.primary50, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.fitness_center, color: PTColors.primary600, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(w.name, style: t.titleSmall),
                      Text(w.subtitle, style: t.bodySmall),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: PTColors.teal50, borderRadius: BorderRadius.circular(99)),
                      child: Text(w.tag, style: const TextStyle(fontSize: 11, color: PTColors.teal600, fontWeight: FontWeight.w500)),
                    ),
                  ]),
                )),

                const SizedBox(height: 20),

                // Medidas corporais
                Row(children: [
                  Text('Medidas corporais', style: t.titleMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('Ver histórico'),
                  ),
                ]),
                const SizedBox(height: 10),
                _MeasurementsSummaryCard(measurements: _kMockMeasurements),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssignWorkoutSheet(studentId: studentId, studentName: _name),
    );
  }

  List<({String name, String subtitle, String tag})> get _recentWorkouts => [
    (name: 'Treino A — Peito e Tríceps', subtitle: 'Hoje · 6 exercícios · 58 min', tag: 'completo'),
    (name: 'Treino B — Costas e Bíceps', subtitle: 'Ontem · 5 exercícios · 52 min', tag: 'completo'),
    (name: 'Treino C — Pernas', subtitle: 'Há 3 dias · 7 exercícios · 65 min', tag: 'completo'),
  ];
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: PTColors.gray400),
    const SizedBox(width: 3),
    Text(label, style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
  ]);
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: PTColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: PTColors.border, width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
    ]),
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: PTColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PTColors.border, width: 0.5),
      ),
      child: Column(children: [
        Icon(icon, size: 22, color: PTColors.primary600),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: PTColors.primary600, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

class _MeasurementsSummaryCard extends StatelessWidget {
  final List<BodyMeasurement> measurements;
  const _MeasurementsSummaryCard({required this.measurements});

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return PTCard(
        child: Center(
          child: Text('Nenhuma medida registrada', style: const TextStyle(color: PTColors.gray400, fontSize: 13)),
        ),
      );
    }

    final latest = measurements.first;
    final prev = measurements.length > 1 ? measurements[1] : null;

    double? delta(double? a, double? b) => (a != null && b != null) ? a - b : null;
    String deltaStr(double? d, {bool inverse = false}) {
      if (d == null) return '';
      final sign = d > 0 ? '+' : '';
      return ' ($sign${d.toStringAsFixed(1)})';
    }

    return PTCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.straighten, size: 14, color: PTColors.primary600),
          const SizedBox(width: 6),
          Text('Última avaliação: ${_formatDate(latest.date)}',
              style: const TextStyle(fontSize: 12, color: PTColors.gray400)),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 10, children: [
          _MeasureChip(
            label: 'Peso',
            value: '${latest.weightKg.toStringAsFixed(1)} kg',
            delta: deltaStr(delta(latest.weightKg, prev?.weightKg), inverse: false),
          ),
          if (latest.bodyFatPct != null)
            _MeasureChip(
              label: 'Gordura',
              value: '${latest.bodyFatPct!.toStringAsFixed(1)}%',
              delta: deltaStr(delta(latest.bodyFatPct, prev?.bodyFatPct), inverse: true),
            ),
          if (latest.waistCm != null)
            _MeasureChip(
              label: 'Cintura',
              value: '${latest.waistCm!.toStringAsFixed(0)} cm',
              delta: deltaStr(delta(latest.waistCm, prev?.waistCm), inverse: true),
            ),
          if (latest.chestCm != null)
            _MeasureChip(
              label: 'Peito',
              value: '${latest.chestCm!.toStringAsFixed(0)} cm',
              delta: deltaStr(delta(latest.chestCm, prev?.chestCm), inverse: false),
            ),
          if (latest.armCm != null)
            _MeasureChip(
              label: 'Braço',
              value: '${latest.armCm!.toStringAsFixed(1)} cm',
              delta: deltaStr(delta(latest.armCm, prev?.armCm), inverse: false),
            ),
          if (latest.thighCm != null)
            _MeasureChip(
              label: 'Coxa',
              value: '${latest.thighCm!.toStringAsFixed(0)} cm',
              delta: deltaStr(delta(latest.thighCm, prev?.thighCm), inverse: false),
            ),
        ]),
      ]),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _MeasureChip extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  const _MeasureChip({required this.label, required this.value, required this.delta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: PTColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PTColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: PTColors.gray400)),
        const SizedBox(height: 2),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PTColors.gray900)),
          if (delta.isNotEmpty)
            Text(delta, style: TextStyle(
              fontSize: 11,
              color: delta.contains('+') ? PTColors.teal600 : PTColors.red400,
            )),
        ]),
      ]),
    );
  }
}

// ── Bottom sheet: atribuir treino ao aluno ────────────────────────────────────

class _AssignWorkoutSheet extends StatelessWidget {
  final String studentId;
  final String studentName;

  const _AssignWorkoutSheet({required this.studentId, required this.studentName});

  static const _library = [
    ('1', 'Treino A — Peito e Tríceps',  'Musculação', 6),
    ('2', 'Treino B — Costas e Bíceps',  'Musculação', 5),
    ('3', 'Treino C — Pernas',            'Musculação', 7),
    ('4', 'Treino D — Ombros e Abdômen', 'Musculação', 6),
    ('5', 'Cardio HIIT 30 min',           'Cardio',     4),
    ('6', 'Emagrecimento Full Body',      'Funcional',  8),
    ('7', 'Hipertrofia Iniciante',        'Musculação', 5),
    ('8', 'Pilates Solo — Iniciante',     'Pilates',    10),
    ('9', 'Reabilitação Lombar',          'Funcional',  6),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: PTColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(
          margin: const EdgeInsets.only(top: 12),
          width: 36, height: 4,
          decoration: BoxDecoration(color: PTColors.gray100, borderRadius: BorderRadius.circular(99)),
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Text('Atribuir treino a $studentName', style: t.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text('Selecione da biblioteca ou crie um novo.', style: t.bodySmall),
        ),
        const Divider(height: 1),

        // Opção: criar novo
        ListTile(
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: PTColors.primary50, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.add, color: PTColors.primary600, size: 20),
          ),
          title: const Text('Criar novo treino', style: TextStyle(fontWeight: FontWeight.w600, color: PTColors.primary600)),
          subtitle: const Text('Prescrever do zero para este aluno'),
          trailing: const Icon(Icons.chevron_right, color: PTColors.gray200),
          onTap: () {
            Navigator.pop(context);
            context.push('/trainer/students/$studentId/new-workout');
          },
        ),
        const Divider(indent: 16, height: 1),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text('Da biblioteca', style: t.labelLarge),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _library.length,
            itemBuilder: (_, i) {
              final w = _library[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: PTColors.primary50, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.fitness_center, color: PTColors.primary600, size: 18),
                ),
                title: Text(w.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text('${w.$3} · ${w.$4} exercícios', style: t.bodySmall),
                trailing: const Icon(Icons.chevron_right, size: 16, color: PTColors.gray200),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${w.$2}" atribuído a $studentName!'),
                      backgroundColor: PTColors.teal600,
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}
