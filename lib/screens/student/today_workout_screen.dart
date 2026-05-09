import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../widgets/pt_card.dart';

// ─── DADOS DO PLANO SEMANAL ───────────────────────────────────────────────────

class _WorkoutPlan {
  final String tag;        // A, B, C
  final String name;
  final List<WorkoutSet> sets;
  const _WorkoutPlan({required this.tag, required this.name, required this.sets});
}

final _kPlans = [
  _WorkoutPlan(
    tag: 'A', name: 'Peito e Tríceps',
    sets: [
      WorkoutSet(exerciseId: '1', exercise: Exercise(id: '1', name: 'Supino reto', muscleGroup: 'Peito', modality: TrainingModality.strength), sets: 4, reps: 10, weightKg: 70, restSeconds: 90),
      WorkoutSet(exerciseId: '2', exercise: Exercise(id: '2', name: 'Supino inclinado halteres', muscleGroup: 'Peito', modality: TrainingModality.strength), sets: 3, reps: 12, weightKg: 28, restSeconds: 75),
      WorkoutSet(exerciseId: '3', exercise: Exercise(id: '3', name: 'Crossover', muscleGroup: 'Peito', modality: TrainingModality.strength), sets: 3, reps: 15, weightKg: 15, restSeconds: 60),
      WorkoutSet(exerciseId: '4', exercise: Exercise(id: '4', name: 'Tríceps pulley', muscleGroup: 'Tríceps', modality: TrainingModality.strength), sets: 4, reps: 12, weightKg: 35, restSeconds: 60),
      WorkoutSet(exerciseId: '5', exercise: Exercise(id: '5', name: 'Tríceps testa', muscleGroup: 'Tríceps', modality: TrainingModality.strength), sets: 3, reps: 12, weightKg: 30, restSeconds: 60),
    ],
  ),
  _WorkoutPlan(
    tag: 'B', name: 'Costas e Bíceps',
    sets: [
      WorkoutSet(exerciseId: '6', exercise: Exercise(id: '6', name: 'Remada curvada', muscleGroup: 'Costas', modality: TrainingModality.strength), sets: 4, reps: 12, weightKg: 40, restSeconds: 90, isCompleted: true),
      WorkoutSet(exerciseId: '7', exercise: Exercise(id: '7', name: 'Puxada frontal', muscleGroup: 'Costas', modality: TrainingModality.strength), sets: 3, reps: 10, weightKg: 55, restSeconds: 75),
      WorkoutSet(exerciseId: '8', exercise: Exercise(id: '8', name: 'Remada cavalinho', muscleGroup: 'Costas', modality: TrainingModality.strength), sets: 3, reps: 15, weightKg: 70, restSeconds: 60),
      WorkoutSet(exerciseId: '9', exercise: Exercise(id: '9', name: 'Rosca direta barra', muscleGroup: 'Bíceps', modality: TrainingModality.strength), sets: 3, reps: 12, weightKg: 30, restSeconds: 60),
      WorkoutSet(exerciseId: '10', exercise: Exercise(id: '10', name: 'Rosca martelo', muscleGroup: 'Bíceps', modality: TrainingModality.strength), sets: 3, reps: 12, weightKg: 16, restSeconds: 45),
    ],
  ),
  _WorkoutPlan(
    tag: 'C', name: 'Pernas e Glúteos',
    sets: [
      WorkoutSet(exerciseId: '11', exercise: Exercise(id: '11', name: 'Agachamento livre', muscleGroup: 'Pernas', modality: TrainingModality.strength), sets: 4, reps: 10, weightKg: 80, restSeconds: 120),
      WorkoutSet(exerciseId: '12', exercise: Exercise(id: '12', name: 'Leg press 45°', muscleGroup: 'Pernas', modality: TrainingModality.strength), sets: 4, reps: 12, weightKg: 150, restSeconds: 90),
      WorkoutSet(exerciseId: '13', exercise: Exercise(id: '13', name: 'Cadeira extensora', muscleGroup: 'Pernas', modality: TrainingModality.strength), sets: 3, reps: 15, weightKg: 60, restSeconds: 60),
      WorkoutSet(exerciseId: '14', exercise: Exercise(id: '14', name: 'Hip thrust', muscleGroup: 'Glúteos', modality: TrainingModality.strength), sets: 4, reps: 12, weightKg: 70, restSeconds: 75),
      WorkoutSet(exerciseId: '15', exercise: Exercise(id: '15', name: 'Mesa flexora', muscleGroup: 'Pernas', modality: TrainingModality.strength), sets: 3, reps: 12, weightKg: 40, restSeconds: 60),
      WorkoutSet(exerciseId: '16', exercise: Exercise(id: '16', name: 'Panturrilha máquina', muscleGroup: 'Pernas', modality: TrainingModality.strength), sets: 4, reps: 20, weightKg: 80, restSeconds: 45),
    ],
  ),
];

// ─── TELA ─────────────────────────────────────────────────────────────────────

class TodayWorkoutScreen extends StatefulWidget {
  const TodayWorkoutScreen({super.key});

  @override
  State<TodayWorkoutScreen> createState() => _TodayWorkoutScreenState();
}

class _TodayWorkoutScreenState extends State<TodayWorkoutScreen> {
  // B é o treino "de hoje" no mock (índice 1)
  int _activePlan = 1;
  bool _checkinDone = false;

  _WorkoutPlan get _plan => _kPlans[_activePlan];

  Future<void> _openCheckin() async {
    final result = await context.push<bool>('/student/checkin/w1');
    if (result == true && mounted) setState(() => _checkinDone = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final plan = _plan;
    final completed = plan.sets.where((s) => s.isCompleted).length;
    final total = plan.sets.length;
    final pct = total == 0 ? 0.0 : completed / total;

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
                Text('Treino de hoje', style: t.headlineMedium),
                Text(_formattedDate(), style: t.bodySmall),
              ]),
              actions: [
                IconButton(icon: const Icon(Icons.history), tooltip: 'Histórico', onPressed: () => context.push('/student/workout-history')),
                IconButton(icon: const Icon(Icons.monitor_weight_outlined), tooltip: 'Medidas', onPressed: () => context.push('/student/measurements')),
                IconButton(icon: const Icon(Icons.notifications_outlined), tooltip: 'Notificações', onPressed: () => context.push('/notifications')),
                IconButton(icon: const Icon(Icons.account_circle_outlined), tooltip: 'Perfil', onPressed: () => context.push('/student/profile')),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // ── Seletor A/B/C ───────────────────────────────────────────
                _PlanSelector(
                  plans: _kPlans,
                  activeIndex: _activePlan,
                  onSelect: (i) => setState(() {
                    _activePlan = i;
                    _checkinDone = false;
                  }),
                ),

                const SizedBox(height: 12),

                // ── Banner check-in ─────────────────────────────────────────
                if (!_checkinDone) _CheckinBanner(onTap: _openCheckin),
                if (_checkinDone) _CheckinDoneBadge(),
                const SizedBox(height: 12),

                // ── Cartão do treino ────────────────────────────────────────
                PTCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: PTColors.primary50, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.fitness_center, color: PTColors.primary600, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Treino ${plan.tag} — ${plan.name}', style: t.titleSmall),
                        Text('$total exercícios · ~${_estimatedTime(plan)} min', style: t.bodySmall),
                      ])),
                    ]),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: PTColors.gray100,
                        valueColor: const AlwaysStoppedAnimation(PTColors.teal400),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('$completed de $total concluídos', style: t.bodySmall),
                  ]),
                ),

                const SizedBox(height: 16),
                Text('Exercícios', style: t.titleMedium),
                const SizedBox(height: 10),

                ...plan.sets.asMap().entries.map((e) => _ExerciseTile(
                  set: e.value,
                  index: e.key,
                  locked: !_checkinDone,
                  onTap: () => context.push('/student/workout/execute/${e.key}'),
                  onLockedTap: _openCheckin,
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

  int _estimatedTime(_WorkoutPlan p) =>
      p.sets.fold(0, (t, s) => t + s.sets * 2 + (s.sets - 1) * (s.restSeconds ~/ 60 + 1));
}

// ─── SELETOR DE PLANO A/B/C ───────────────────────────────────────────────────

class _PlanSelector extends StatelessWidget {
  final List<_WorkoutPlan> plans;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  const _PlanSelector({required this.plans, required this.activeIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) => Row(
    children: plans.asMap().entries.map((e) {
      final i = e.key;
      final p = e.value;
      final sel = i == activeIndex;
      return Expanded(child: Padding(
        padding: EdgeInsets.only(right: i < plans.length - 1 ? 8 : 0),
        child: GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: sel ? PTColors.primary600 : PTColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sel ? PTColors.primary600 : PTColors.border, width: 0.5),
            ),
            child: Column(children: [
              Text('Treino ${p.tag}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: sel ? Colors.white : PTColors.gray600)),
              const SizedBox(height: 2),
              Text(p.name, style: TextStyle(fontSize: 10, color: sel ? Colors.white70 : PTColors.gray400), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('${p.sets.length} exerc.', style: TextStyle(fontSize: 10, color: sel ? Colors.white54 : PTColors.gray200)),
            ]),
          ),
        ),
      ));
    }).toList(),
  );
}

// ─── BANNER DE CHECK-IN ───────────────────────────────────────────────────────

class _CheckinBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CheckinBanner({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PTColors.amber50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PTColors.amber200, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(color: PTColors.amber200, shape: BoxShape.circle),
          child: const Icon(Icons.fact_check_outlined, color: PTColors.amber800, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Check-in obrigatório', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PTColors.amber800)),
          const Text('Responda o check-in para desbloquear os exercícios.', style: TextStyle(fontSize: 12, color: PTColors.amber600)),
        ])),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: PTColors.amber400, borderRadius: BorderRadius.circular(99)),
          child: const Text('Fazer agora', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ]),
    ),
  );
}

class _CheckinDoneBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: PTColors.teal50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: PTColors.teal100, width: 0.5),
    ),
    child: const Row(children: [
      Icon(Icons.check_circle_outline, color: PTColors.teal400, size: 20),
      SizedBox(width: 10),
      Text('Check-in concluído — boa sessão!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: PTColors.teal800)),
    ]),
  );
}

// ─── TILE DE EXERCÍCIO ────────────────────────────────────────────────────────

class _ExerciseTile extends StatelessWidget {
  final WorkoutSet set;
  final int index;
  final bool locked;
  final VoidCallback onTap;
  final VoidCallback onLockedTap;

  const _ExerciseTile({required this.set, required this.index, required this.locked, required this.onTap, required this.onLockedTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isBlocked = locked && !set.isCompleted;

    return PTCard(
      onTap: set.isCompleted ? null : (isBlocked ? onLockedTap : onTap),
      margin: const EdgeInsets.only(bottom: 8),
      color: set.isCompleted ? PTColors.teal50 : isBlocked ? PTColors.gray50 : PTColors.surface,
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: set.isCompleted ? PTColors.teal400 : isBlocked ? PTColors.gray100 : PTColors.gray50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            set.isCompleted ? Icons.check : isBlocked ? Icons.lock_outline : Icons.fitness_center,
            size: 18,
            color: set.isCompleted ? Colors.white : isBlocked ? PTColors.gray200 : PTColors.gray400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(set.exercise.name, style: t.titleSmall?.copyWith(
            color: set.isCompleted ? PTColors.teal800 : isBlocked ? PTColors.gray200 : PTColors.gray900,
            decoration: set.isCompleted ? TextDecoration.lineThrough : null,
          )),
          Text(
            '${set.sets}x${set.reps}${set.weightKg != null ? ' · ${set.weightKg!.toInt()}kg' : ''} · ${set.exercise.muscleGroup}',
            style: t.bodySmall?.copyWith(color: isBlocked ? PTColors.gray200 : null),
          ),
        ])),
        if (set.isCompleted)
          const SizedBox.shrink()
        else if (isBlocked)
          const Icon(Icons.lock_outline, color: PTColors.gray200, size: 18)
        else
          const Icon(Icons.play_circle_outline, color: PTColors.teal400, size: 28),
      ]),
    );
  }
}
