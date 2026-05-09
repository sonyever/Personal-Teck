import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../widgets/pt_card.dart';
import '../../widgets/avatar_circle.dart';

class TrainerWorkoutLibraryScreen extends StatefulWidget {
  const TrainerWorkoutLibraryScreen({super.key});

  @override
  State<TrainerWorkoutLibraryScreen> createState() => _TrainerWorkoutLibraryScreenState();
}

class _TrainerWorkoutLibraryScreenState extends State<TrainerWorkoutLibraryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filter = 'Todos';

  final _filters = ['Todos', 'Musculação', 'Funcional', 'Pilates', 'Cardio', 'Natação', 'Corrida'];

  final List<_WorkoutTemplate> _workouts = [
    _WorkoutTemplate(id: '1', name: 'Treino A — Peito e Tríceps',    modality: 'Musculação', exerciseCount: 6,  linkedCount: 3, createdAt: DateTime(2026, 4, 15)),
    _WorkoutTemplate(id: '2', name: 'Treino B — Costas e Bíceps',    modality: 'Musculação', exerciseCount: 5,  linkedCount: 3, createdAt: DateTime(2026, 4, 15)),
    _WorkoutTemplate(id: '3', name: 'Treino C — Pernas',              modality: 'Musculação', exerciseCount: 7,  linkedCount: 2, createdAt: DateTime(2026, 4, 16)),
    _WorkoutTemplate(id: '4', name: 'Treino D — Ombros e Abdômen',   modality: 'Musculação', exerciseCount: 6,  linkedCount: 2, createdAt: DateTime(2026, 4, 16)),
    _WorkoutTemplate(id: '5', name: 'Cardio HIIT 30 min',             modality: 'Cardio',     exerciseCount: 4,  linkedCount: 5, createdAt: DateTime(2026, 4, 20)),
    _WorkoutTemplate(id: '6', name: 'Emagrecimento Full Body',        modality: 'Funcional',  exerciseCount: 8,  linkedCount: 1, createdAt: DateTime(2026, 5, 1)),
    _WorkoutTemplate(id: '7', name: 'Hipertrofia Iniciante',          modality: 'Musculação', exerciseCount: 5,  linkedCount: 0, createdAt: DateTime(2026, 5, 3)),
    _WorkoutTemplate(id: '8', name: 'Pilates Solo — Iniciante',       modality: 'Pilates',    exerciseCount: 10, linkedCount: 0, createdAt: DateTime(2026, 5, 5)),
    _WorkoutTemplate(id: '9', name: 'Reabilitação Lombar',            modality: 'Funcional',  exerciseCount: 6,  linkedCount: 1, createdAt: DateTime(2026, 5, 6)),
  ];

  List<_WorkoutTemplate> get _filtered => _workouts.where((w) {
    final matchFilter = _filter == 'Todos' || w.modality == _filter;
    final matchQuery = _query.isEmpty || w.name.toLowerCase().contains(_query.toLowerCase());
    return matchFilter && matchQuery;
  }).toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        title: const Text('Meus Treinos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Novo treino',
            onPressed: () => context.push('/trainer/workouts/new'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Buscar treino...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
        ),
      ),
      body: Column(children: [
        // Filtros por modalidade
        SizedBox(
          height: 44,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            itemBuilder: (_, i) {
              final f = _filters[i];
              final sel = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel ? PTColors.primary600 : PTColors.surface,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: sel ? PTColors.primary600 : PTColors.border, width: 0.5),
                  ),
                  child: Center(
                    child: Text(f, style: TextStyle(
                      fontSize: 13,
                      color: sel ? Colors.white : PTColors.gray600,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    )),
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(children: [
            Text('${filtered.length} treinos', style: t.bodySmall),
          ]),
        ),

        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('Nenhum treino encontrado', style: t.bodySmall))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _WorkoutCard(
                    workout: filtered[i],
                    onLink: () => _showLinkSheet(context, filtered[i]),
                    onEdit: () => context.push('/trainer/workouts/new'),
                    onDelete: () => _confirmDelete(context, filtered[i]),
                  ),
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trainer/workouts/new'),
        backgroundColor: PTColors.primary600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo treino'),
      ),
    );
  }

  void _showLinkSheet(BuildContext context, _WorkoutTemplate workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LinkStudentSheet(workout: workout),
    );
  }

  void _confirmDelete(BuildContext context, _WorkoutTemplate workout) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir treino?'),
        content: Text('O treino "${workout.name}" será removido da biblioteca. Alunos vinculados não serão afetados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: PTColors.red600),
            onPressed: () {
              setState(() => _workouts.remove(workout));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${workout.name}" removido.')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Card do treino ─────────────────────────────────────────────────────────────

class _WorkoutCard extends StatelessWidget {
  final _WorkoutTemplate workout;
  final VoidCallback onLink;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WorkoutCard({required this.workout, required this.onLink, required this.onEdit, required this.onDelete});

  Color _modalityColor(String m) => switch (m) {
    'Musculação' => PTColors.primary600,
    'Funcional'  => PTColors.teal400,
    'Pilates'    => PTColors.teal200,
    'Cardio'     => PTColors.red400,
    'Natação'    => PTColors.primary400,
    'Corrida'    => PTColors.amber400,
    _            => PTColors.gray400,
  };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final color = _modalityColor(workout.modality);
    final months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    final dateStr = '${workout.createdAt.day} ${months[workout.createdAt.month - 1]}';

    return PTCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.fitness_center, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(workout.name, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(99)),
                child: Text(workout.modality, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Text('${workout.exerciseCount} exercícios · criado $dateStr', style: t.bodySmall),
            ]),
          ])),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: PTColors.gray400),
            onSelected: (v) {
              if (v == 'link') onLink();
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'link',   child: Text('Vincular a aluno')),
              PopupMenuItem(value: 'edit',   child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: PTColors.red400))),
            ],
          ),
        ]),

        if (workout.linkedCount > 0) ...[
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.people_outline, size: 13, color: PTColors.gray400),
            const SizedBox(width: 4),
            Text('Vinculado a ${workout.linkedCount} aluno${workout.linkedCount > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12, color: PTColors.gray400)),
            const Spacer(),
            GestureDetector(
              onTap: onLink,
              child: const Text('+ Vincular outro', style: TextStyle(fontSize: 12, color: PTColors.primary600, fontWeight: FontWeight.w500)),
            ),
          ]),
        ] else ...[
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onLink,
            child: Row(children: [
              const Icon(Icons.add_circle_outline, size: 14, color: PTColors.primary600),
              const SizedBox(width: 4),
              const Text('Vincular a um aluno', style: TextStyle(fontSize: 12, color: PTColors.primary600, fontWeight: FontWeight.w500)),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ── Bottom sheet: vincular a aluno ────────────────────────────────────────────

class _LinkStudentSheet extends StatefulWidget {
  final _WorkoutTemplate workout;
  const _LinkStudentSheet({required this.workout});

  @override
  State<_LinkStudentSheet> createState() => _LinkStudentSheetState();
}

class _LinkStudentSheetState extends State<_LinkStudentSheet> {
  String? _selected;

  final _students = [
    ('1', 'Rafael Alves',   'Hipertrofia'),
    ('2', 'Marina Costa',  'Emagrecimento'),
    ('3', 'Thiago Silva',  'Condicionamento'),
    ('4', 'Julia Santos',  'Hipertrofia'),
    ('5', 'Carlos Mendes', 'Resistência'),
    ('6', 'Ana Paula Rocha', 'Reabilitação'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: PTColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(
          width: 36, height: 4,
          decoration: BoxDecoration(color: PTColors.gray100, borderRadius: BorderRadius.circular(99)),
        )),
        const SizedBox(height: 16),
        Text('Vincular treino a aluno', style: t.titleMedium),
        const SizedBox(height: 4),
        Text(widget.workout.name, style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 16),

        ..._students.map((s) {
          final sel = _selected == s.$1;
          return GestureDetector(
            onTap: () => setState(() => _selected = s.$1),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? PTColors.primary50 : PTColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? PTColors.primary200 : PTColors.border, width: sel ? 1.5 : 0.5),
              ),
              child: Row(children: [
                AvatarCircle(name: s.$2, size: 36),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.$2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: sel ? PTColors.primary800 : PTColors.gray900)),
                  Text(s.$3, style: t.bodySmall),
                ])),
                if (sel) const Icon(Icons.check_circle, color: PTColors.primary600, size: 20),
              ]),
            ),
          );
        }),

        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selected == null ? null : () {
              Navigator.pop(context);
              final name = _students.firstWhere((s) => s.$1 == _selected).$2;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Treino vinculado a $name com sucesso!'),
                  backgroundColor: PTColors.teal600,
                ),
              );
            },
            child: const Text('Confirmar vínculo'),
          ),
        ),
      ]),
    );
  }
}

// ── Modelo local ──────────────────────────────────────────────────────────────

class _WorkoutTemplate {
  final String id, name, modality;
  final int exerciseCount, linkedCount;
  final DateTime createdAt;

  _WorkoutTemplate({
    required this.id,
    required this.name,
    required this.modality,
    required this.exerciseCount,
    required this.linkedCount,
    required this.createdAt,
  });
}
