import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../data/exercise_data.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _group = 'Todos';

  List<ExerciseTemplate> get _filtered => kExercises.where((e) {
    final matchGroup = _group == 'Todos' || e.muscleGroup == _group;
    final matchQuery = _query.isEmpty || e.name.toLowerCase().contains(_query.toLowerCase());
    return matchGroup && matchQuery;
  }).toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        title: const Text('Biblioteca de exercícios'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Buscar exercício...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
        ),
      ),
      body: Column(children: [
        // Filtros por grupo muscular
        SizedBox(
          height: 44,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: kMuscleGroups.length,
            itemBuilder: (_, i) {
              final g = kMuscleGroups[i];
              final sel = _group == g;
              return GestureDetector(
                onTap: () => setState(() => _group = g),
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel ? PTColors.primary600 : PTColors.surface,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: sel ? PTColors.primary600 : PTColors.border, width: 0.5),
                  ),
                  child: Center(child: Text(g, style: TextStyle(fontSize: 13, color: sel ? Colors.white : PTColors.gray600, fontWeight: sel ? FontWeight.w600 : FontWeight.w400))),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(children: [
            Text('${filtered.length} exercícios', style: const TextStyle(fontSize: 12, color: PTColors.gray400)),
          ]),
        ),

        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Nenhum exercício encontrado', style: TextStyle(color: PTColors.gray400)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _ExerciseTile(
                    exercise: filtered[i],
                    onTap: () => Navigator.pop(context, filtered[i]),
                  ),
                ),
        ),
      ]),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final ExerciseTemplate exercise;
  final VoidCallback onTap;

  const _ExerciseTile({required this.exercise, required this.onTap});

  Color _groupColor(String group) => switch (group) {
    'Peito'   => PTColors.primary600,
    'Costas'  => PTColors.teal400,
    'Ombros'  => PTColors.amber400,
    'Bíceps'  => PTColors.primary400,
    'Tríceps' => PTColors.teal600,
    'Pernas'  => PTColors.red400,
    'Glúteos' => PTColors.red400,
    'Abdômen' => PTColors.amber600,
    'Pilates' => PTColors.teal200,
    _         => PTColors.gray400,
  };

  @override
  Widget build(BuildContext context) {
    final color = _groupColor(exercise.muscleGroup);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PTColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PTColors.border, width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.fitness_center, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(exercise.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: PTColors.gray900)),
            Text('${exercise.muscleGroup} · ${exercise.equipment}', style: const TextStyle(fontSize: 12, color: PTColors.gray400)),
          ])),
          const Icon(Icons.add_circle_outline, color: PTColors.primary600, size: 22),
        ]),
      ),
    );
  }
}
