import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/pt_card.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final _sessions = _kMockSessions;
  _HistoryFilter _filter = _HistoryFilter.all;

  List<_WorkoutSession> get _filtered => _filter == _HistoryFilter.all
      ? _sessions
      : _sessions.where((s) => s.plan == _filter.name).toList();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final grouped = _groupByWeek(_filtered);

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        title: const Text('Histórico de treinos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _FilterBar(
            current: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
        ),
      ),
      body: _filtered.isEmpty
          ? _EmptyState(filter: _filter)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: grouped.length,
              itemBuilder: (_, i) => _WeekSection(
                week: grouped[i],
                textTheme: t,
              ),
            ),
    );
  }
}

// ── Filter bar ──────────────────────────────────────────────────────────────

enum _HistoryFilter { all, A, B, C }

class _FilterBar extends StatelessWidget {
  final _HistoryFilter current;
  final ValueChanged<_HistoryFilter> onChanged;

  const _FilterBar({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = {
      _HistoryFilter.all: 'Todos',
      _HistoryFilter.A: 'Treino A',
      _HistoryFilter.B: 'Treino B',
      _HistoryFilter.C: 'Treino C',
    };
    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        children: labels.entries.map((e) {
          final sel = current == e.key;
          return GestureDetector(
            onTap: () => onChanged(e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? PTColors.primary600 : PTColors.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: sel ? PTColors.primary600 : PTColors.border,
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 13,
                    color: sel ? Colors.white : PTColors.gray600,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Week section ─────────────────────────────────────────────────────────────

class _WeekSection extends StatelessWidget {
  final _WeekGroup week;
  final TextTheme textTheme;

  const _WeekSection({required this.week, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(children: [
          Text(week.label, style: textTheme.labelLarge?.copyWith(color: PTColors.gray400)),
          const SizedBox(width: 8),
          Text('${week.sessions.length} treino${week.sessions.length != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
          const Spacer(),
          Text('${week.totalMinutes} min total',
              style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
        ]),
      ),
      ...week.sessions.map((s) => _SessionCard(session: s)),
      const SizedBox(height: 8),
    ]);
  }
}

// ── Session card ─────────────────────────────────────────────────────────────

class _SessionCard extends StatefulWidget {
  final _WorkoutSession session;
  const _SessionCard({required this.session});

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  bool _expanded = false;

  Color _planColor(String plan) => switch (plan) {
    'A' => PTColors.primary600,
    'B' => PTColors.teal600,
    'C' => PTColors.amber600,
    _ => PTColors.gray400,
  };

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final color = _planColor(s.plan);

    return PTCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  s.plan,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: PTColors.gray900)),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(s.date)}  ·  ${s.durationMinutes} min  ·  ${s.exerciseCount} exercícios',
                  style: const TextStyle(fontSize: 12, color: PTColors.gray400),
                ),
              ]),
            ),
            _StatusBadge(status: s.status),
            const SizedBox(width: 8),
            Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: PTColors.gray400,
            ),
          ]),
        ),

        if (_expanded) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: PTColors.border),
          const SizedBox(height: 12),
          _StatsRow(session: s),
          if (s.exercises.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...s.exercises.map((e) => _ExerciseRow(exercise: e)),
          ],
          if (s.note != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PTColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                s.note!,
                style: const TextStyle(fontSize: 12, color: PTColors.gray400, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ]),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final _WorkoutSession session;
  const _StatsRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Stat(label: 'Duração', value: '${session.durationMinutes} min', icon: Icons.timer_outlined),
        _Stat(label: 'Exercícios', value: '${session.exerciseCount}', icon: Icons.fitness_center),
        _Stat(label: 'Séries totais', value: '${session.totalSets}', icon: Icons.repeat),
        _Stat(label: 'Volume (kg)', value: session.totalVolume > 0 ? '${session.totalVolume}' : '—', icon: Icons.monitor_weight_outlined),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, size: 16, color: PTColors.primary600),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PTColors.gray900)),
      Text(label, style: const TextStyle(fontSize: 10, color: PTColors.gray400)),
    ]);
  }
}

class _ExerciseRow extends StatelessWidget {
  final _ExerciseLog exercise;
  const _ExerciseRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        const Icon(Icons.circle, size: 5, color: PTColors.gray400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(exercise.name, style: const TextStyle(fontSize: 13, color: PTColors.gray600)),
        ),
        Text(
          '${exercise.sets}×${exercise.reps}${exercise.weightKg > 0 ? " · ${exercise.weightKg}kg" : ""}',
          style: const TextStyle(fontSize: 12, color: PTColors.gray400),
        ),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _SessionStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      _SessionStatus.completed => ('Completo', PTColors.teal50, PTColors.teal600),
      _SessionStatus.partial   => ('Parcial', const Color(0xFFFFFBEB), PTColors.amber600),
      _SessionStatus.skipped   => ('Pulado', const Color(0xFFFEF2F2), PTColors.red400),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _HistoryFilter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.history, size: 48, color: PTColors.gray200),
        const SizedBox(height: 12),
        Text(
          filter == _HistoryFilter.all
              ? 'Nenhum treino registrado'
              : 'Nenhum treino ${filter.name} registrado',
          style: const TextStyle(fontSize: 14, color: PTColors.gray400),
        ),
      ]),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

enum _SessionStatus { completed, partial, skipped }

class _ExerciseLog {
  final String name;
  final int sets;
  final int reps;
  final int weightKg;
  const _ExerciseLog(this.name, this.sets, this.reps, this.weightKg);
}

class _WorkoutSession {
  final String plan;
  final String name;
  final DateTime date;
  final int durationMinutes;
  final int exerciseCount;
  final int totalSets;
  final int totalVolume;
  final _SessionStatus status;
  final List<_ExerciseLog> exercises;
  final String? note;

  const _WorkoutSession({
    required this.plan,
    required this.name,
    required this.date,
    required this.durationMinutes,
    required this.exerciseCount,
    required this.totalSets,
    required this.totalVolume,
    required this.status,
    required this.exercises,
    this.note,
  });
}

class _WeekGroup {
  final String label;
  final List<_WorkoutSession> sessions;
  int get totalMinutes => sessions.fold(0, (s, e) => s + e.durationMinutes);
  const _WeekGroup({required this.label, required this.sessions});
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatDate(DateTime d) {
  const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
  const days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
  return '${days[d.weekday % 7]}, ${d.day} ${months[d.month - 1]}';
}

List<_WeekGroup> _groupByWeek(List<_WorkoutSession> sessions) {
  final map = <String, List<_WorkoutSession>>{};
  for (final s in sessions) {
    final monday = s.date.subtract(Duration(days: s.date.weekday - 1));
    final key = '${monday.day}/${monday.month}/${monday.year}';
    map.putIfAbsent(key, () => []).add(s);
  }
  final now = DateTime.now();
  return map.entries.map((e) {
    final parts = e.key.split('/');
    final monday = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    final sunday = monday.add(const Duration(days: 6));
    final diff = now.difference(monday).inDays;
    String label;
    if (diff < 7) {
      label = 'Esta semana';
    } else if (diff < 14) {
      label = 'Semana passada';
    } else {
      const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
      label = '${monday.day} ${months[monday.month - 1]} – ${sunday.day} ${months[sunday.month - 1]}';
    }
    return _WeekGroup(label: label, sessions: e.value..sort((a, b) => b.date.compareTo(a.date)));
  }).toList()
    ..sort((a, b) {
      final pa = a.sessions.first.date;
      final pb = b.sessions.first.date;
      return pb.compareTo(pa);
    });
}

// ── Mock data ─────────────────────────────────────────────────────────────────

final _kMockSessions = [
  _WorkoutSession(
    plan: 'B', name: 'Treino B – Costas/Bíceps',
    date: DateTime.now().subtract(const Duration(days: 1)),
    durationMinutes: 58, exerciseCount: 6, totalSets: 18, totalVolume: 4320,
    status: _SessionStatus.completed,
    exercises: const [
      _ExerciseLog('Puxada frontal', 4, 12, 50),
      _ExerciseLog('Remada curvada', 4, 10, 60),
      _ExerciseLog('Remada serrote', 3, 12, 30),
      _ExerciseLog('Rosca direta barra', 3, 12, 25),
      _ExerciseLog('Rosca martelo', 2, 15, 14),
      _ExerciseLog('Rosca concentrada', 2, 12, 12),
    ],
  ),
  _WorkoutSession(
    plan: 'A', name: 'Treino A – Peito/Tríceps',
    date: DateTime.now().subtract(const Duration(days: 3)),
    durationMinutes: 62, exerciseCount: 7, totalSets: 21, totalVolume: 5880,
    status: _SessionStatus.completed,
    exercises: const [
      _ExerciseLog('Supino reto', 4, 10, 80),
      _ExerciseLog('Supino inclinado halteres', 3, 12, 28),
      _ExerciseLog('Crossover', 3, 15, 15),
      _ExerciseLog('Tríceps pulley', 4, 12, 30),
      _ExerciseLog('Tríceps testa', 3, 12, 25),
      _ExerciseLog('Mergulho entre bancos', 2, 15, 0),
      _ExerciseLog('Peck deck', 2, 15, 40),
    ],
    note: 'Aumentei carga no supino reto. Próximo treino tentar 82,5kg.',
  ),
  _WorkoutSession(
    plan: 'C', name: 'Treino C – Pernas',
    date: DateTime.now().subtract(const Duration(days: 5)),
    durationMinutes: 45, exerciseCount: 5, totalSets: 14, totalVolume: 0,
    status: _SessionStatus.partial,
    exercises: const [
      _ExerciseLog('Agachamento livre', 4, 10, 70),
      _ExerciseLog('Leg press 45°', 4, 12, 150),
      _ExerciseLog('Cadeira extensora', 3, 15, 45),
      _ExerciseLog('Cadeira flexora', 3, 15, 40),
    ],
    note: 'Tive que sair mais cedo. Não fiz panturrilha.',
  ),
  _WorkoutSession(
    plan: 'B', name: 'Treino B – Costas/Bíceps',
    date: DateTime.now().subtract(const Duration(days: 8)),
    durationMinutes: 55, exerciseCount: 6, totalSets: 18, totalVolume: 4050,
    status: _SessionStatus.completed,
    exercises: const [
      _ExerciseLog('Puxada frontal', 4, 12, 47),
      _ExerciseLog('Remada curvada', 4, 10, 57),
      _ExerciseLog('Remada serrote', 3, 12, 28),
      _ExerciseLog('Rosca direta barra', 3, 12, 22),
      _ExerciseLog('Rosca martelo', 2, 15, 13),
      _ExerciseLog('Rosca concentrada', 2, 12, 10),
    ],
  ),
  _WorkoutSession(
    plan: 'A', name: 'Treino A – Peito/Tríceps',
    date: DateTime.now().subtract(const Duration(days: 10)),
    durationMinutes: 65, exerciseCount: 7, totalSets: 21, totalVolume: 5600,
    status: _SessionStatus.completed,
    exercises: const [
      _ExerciseLog('Supino reto', 4, 10, 77),
      _ExerciseLog('Supino inclinado halteres', 3, 12, 26),
      _ExerciseLog('Crossover', 3, 15, 14),
      _ExerciseLog('Tríceps pulley', 4, 12, 28),
      _ExerciseLog('Tríceps testa', 3, 12, 22),
      _ExerciseLog('Mergulho entre bancos', 2, 15, 0),
      _ExerciseLog('Peck deck', 2, 15, 38),
    ],
  ),
  _WorkoutSession(
    plan: 'C', name: 'Treino C – Pernas',
    date: DateTime.now().subtract(const Duration(days: 12)),
    durationMinutes: 70, exerciseCount: 6, totalSets: 20, totalVolume: 0,
    status: _SessionStatus.completed,
    exercises: const [
      _ExerciseLog('Agachamento livre', 4, 10, 67),
      _ExerciseLog('Leg press 45°', 4, 12, 145),
      _ExerciseLog('Cadeira extensora', 4, 15, 42),
      _ExerciseLog('Cadeira flexora', 3, 15, 38),
      _ExerciseLog('Panturrilha máquina', 3, 20, 50),
      _ExerciseLog('Abdutora', 2, 20, 35),
    ],
  ),
  _WorkoutSession(
    plan: 'A', name: 'Treino A – Peito/Tríceps',
    date: DateTime.now().subtract(const Duration(days: 18)),
    durationMinutes: 0, exerciseCount: 0, totalSets: 0, totalVolume: 0,
    status: _SessionStatus.skipped,
    exercises: const [],
    note: 'Feriado – academia fechada.',
  ),
  _WorkoutSession(
    plan: 'B', name: 'Treino B – Costas/Bíceps',
    date: DateTime.now().subtract(const Duration(days: 20)),
    durationMinutes: 52, exerciseCount: 6, totalSets: 18, totalVolume: 3900,
    status: _SessionStatus.completed,
    exercises: const [
      _ExerciseLog('Puxada frontal', 4, 12, 45),
      _ExerciseLog('Remada curvada', 4, 10, 55),
      _ExerciseLog('Remada serrote', 3, 12, 26),
      _ExerciseLog('Rosca direta barra', 3, 12, 20),
      _ExerciseLog('Rosca martelo', 2, 15, 12),
      _ExerciseLog('Rosca concentrada', 2, 12, 10),
    ],
  ),
];
