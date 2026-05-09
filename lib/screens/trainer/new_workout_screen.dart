import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../widgets/pt_card.dart';
import '../../data/exercise_data.dart';
import 'exercise_library_screen.dart';

class NewWorkoutScreen extends StatefulWidget {
  final String? studentId;
  const NewWorkoutScreen({super.key, this.studentId});

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  final _nameCtrl = TextEditingController(text: 'Treino A');
  TrainingModality _modality = TrainingModality.strength;
  final List<_ExerciseEntry> _exercises = [];

  final _modalityLabels = {
    TrainingModality.strength: 'Musculação',
    TrainingModality.bike: 'Bike',
    TrainingModality.running: 'Corrida',
    TrainingModality.functional: 'Funcional',
    TrainingModality.swimming: 'Natação',
    TrainingModality.home: 'Em casa',
    TrainingModality.pilates: 'Pilates',
  };

  Future<void> _addExercise() async {
    final picked = await Navigator.push<ExerciseTemplate>(
      context,
      MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen()),
    );
    if (picked != null) {
      setState(() => _exercises.add(_ExerciseEntry(name: picked.name)));
    }
  }

  void _removeExercise(int index) {
    setState(() => _exercises.removeAt(index));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final e in _exercises) { e.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: Text(widget.studentId != null ? 'Treino para aluno' : 'Novo treino'),
        actions: [
          TextButton(
            onPressed: _exercises.isNotEmpty ? _save : null,
            child: const Text('Salvar'),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Nome
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome do treino'),
                style: t.titleMedium,
              ),

              const SizedBox(height: 16),

              // Modalidade
              Text('Modalidade', style: t.labelLarge),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: _modalityLabels.entries.map((e) {
                final sel = _modality == e.key;
                return ChoiceChip(
                  label: Text(e.value),
                  selected: sel,
                  onSelected: (_) => setState(() => _modality = e.key),
                  selectedColor: PTColors.primary50,
                  labelStyle: TextStyle(color: sel ? PTColors.primary600 : PTColors.gray600, fontWeight: sel ? FontWeight.w600 : FontWeight.w400),
                );
              }).toList()),

              const SizedBox(height: 20),

              Row(children: [
                Text('Exercícios', style: t.titleMedium),
                const Spacer(),
                Text('${_exercises.length} adicionados', style: t.bodySmall),
              ]),
              const SizedBox(height: 10),

              if (_exercises.isEmpty)
                PTCard(
                  child: Column(children: [
                    const Icon(Icons.fitness_center, size: 36, color: PTColors.gray200),
                    const SizedBox(height: 8),
                    Text('Nenhum exercício ainda', style: t.bodySmall),
                  ]),
                ),

              ..._exercises.asMap().entries.map((e) => _ExerciseCard(
                entry: e.value,
                index: e.key + 1,
                onRemove: () => _removeExercise(e.key),
              )),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar exercício'),
                ),
              ),

              const SizedBox(height: 80),
            ]),
          ),
        ),

        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          decoration: const BoxDecoration(
            color: PTColors.surface,
            border: Border(top: BorderSide(color: PTColors.border, width: 0.5)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _exercises.isNotEmpty ? _save : null,
              child: Text(widget.studentId != null ? 'Salvar e enviar ao aluno' : 'Salvar na biblioteca'),
            ),
          ),
        ),
      ]),
    );
  }

  void _save() {
    final msg = widget.studentId != null
        ? 'Treino salvo e enviado ao aluno!'
        : 'Treino salvo na biblioteca!';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    context.pop();
  }
}

class _ExerciseCard extends StatelessWidget {
  final _ExerciseEntry entry;
  final int index;
  final VoidCallback onRemove;

  const _ExerciseCard({required this.entry, required this.index, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return PTCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(color: PTColors.primary50, shape: BoxShape.circle),
            child: Center(child: Text('$index', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: PTColors.primary600))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: entry.nameCtrl,
              decoration: const InputDecoration(
                hintText: 'Nome do exercício',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: PTColors.gray400), onPressed: onRemove, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _NumberField(ctrl: entry.setsCtrl, label: 'Séries')),
          const SizedBox(width: 8),
          Expanded(child: _NumberField(ctrl: entry.repsCtrl, label: 'Reps')),
          const SizedBox(width: 8),
          Expanded(child: _NumberField(ctrl: entry.weightCtrl, label: 'Carga (kg)')),
          const SizedBox(width: 8),
          Expanded(child: _NumberField(ctrl: entry.restCtrl, label: 'Desc. (s)')),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: entry.youtubeCtrl,
          decoration: InputDecoration(
            hintText: 'Cole a URL do YouTube (opcional)',
            prefixIcon: const Icon(Icons.play_circle_outline, size: 18, color: PTColors.red400),
            suffixIcon: entry.youtubeCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: PTColors.gray400),
                    onPressed: () => entry.youtubeCtrl.clear(),
                    padding: EdgeInsets.zero,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ]),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  const _NumberField({required this.ctrl, required this.label});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    decoration: InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    ),
    style: const TextStyle(fontSize: 14),
  );
}

class _ExerciseEntry {
  final TextEditingController nameCtrl;
  final setsCtrl    = TextEditingController(text: '3');
  final repsCtrl    = TextEditingController(text: '12');
  final weightCtrl  = TextEditingController(text: '0');
  final restCtrl    = TextEditingController(text: '60');
  final youtubeCtrl = TextEditingController();

  _ExerciseEntry({String name = ''}) : nameCtrl = TextEditingController(text: name);

  void dispose() {
    nameCtrl.dispose(); setsCtrl.dispose();
    repsCtrl.dispose(); weightCtrl.dispose();
    restCtrl.dispose(); youtubeCtrl.dispose();
  }
}
