import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../services/ai_service.dart';

class AIWorkoutScreen extends StatefulWidget {
  final String studentId;
  const AIWorkoutScreen({super.key, required this.studentId});

  @override
  State<AIWorkoutScreen> createState() => _AIWorkoutScreenState();
}

class _AIWorkoutScreenState extends State<AIWorkoutScreen> {
  final _aiService = AIService('YOUR_API_KEY'); // injetar via provider em produção

  // Parâmetros — pré-preenchidos do perfil do aluno
  String _goal = 'Hipertrofia';
  TrainingModality _modality = TrainingModality.strength;
  String _level = 'Intermediário';
  final _restrictionsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _sessionsPerWeek = 3;

  bool _isLoading = false;
  AIWorkoutResult? _result;
  String? _error;

  final _goals = ['Hipertrofia', 'Emagrecimento', 'Resistência', 'Condicionamento', 'Reabilitação'];
  final _levels = ['Iniciante', 'Intermediário', 'Avançado'];
  final _modalityLabels = {
    TrainingModality.strength: 'Musculação',
    TrainingModality.bike: 'Bike',
    TrainingModality.running: 'Corrida',
    TrainingModality.functional: 'Funcional',
    TrainingModality.swimming: 'Natação',
    TrainingModality.home: 'Em casa',
    TrainingModality.pilates: 'Pilates',
  };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        title: const Text('Gerar treino com IA'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        actions: [
          // Badge "só você vê isso"
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: PTColors.amber50,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: PTColors.amber200, width: 0.5),
            ),
            child: Row(children: [
              const Icon(Icons.lock_outline, size: 12, color: PTColors.amber600),
              const SizedBox(width: 4),
              Text('Só você vê', style: TextStyle(fontSize: 11, color: PTColors.amber800, fontWeight: FontWeight.w500)),
            ]),
          ),
        ],
      ),
      body: _result != null ? _buildResult(t) : _buildForm(t),
    );
  }

  // ── Formulário de parâmetros ───────────────────────────────────────────────

  Widget _buildForm(TextTheme t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Aviso de bastidores
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: PTColors.amber50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PTColors.amber200, width: 0.5),
          ),
          child: Row(children: [
            const Icon(Icons.auto_awesome, color: PTColors.amber400, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'A IA gera uma proposta. Você revisa e decide o que o aluno recebe.',
              style: TextStyle(fontSize: 13, color: PTColors.amber800),
            )),
          ]),
        ),

        const SizedBox(height: 20),
        Text('Parâmetros do aluno', style: t.titleMedium),
        const SizedBox(height: 12),

        // Objetivo
        _DropdownField(
          label: 'Objetivo',
          value: _goal,
          items: _goals,
          onChanged: (v) => setState(() => _goal = v!),
        ),
        const SizedBox(height: 12),

        // Modalidade
        _SectionLabel('Modalidade'),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _modalityLabels.entries.map((e) {
          final selected = _modality == e.key;
          return ChoiceChip(
            label: Text(e.value),
            selected: selected,
            onSelected: (_) => setState(() => _modality = e.key),
            selectedColor: PTColors.primary50,
            labelStyle: TextStyle(
              color: selected ? PTColors.primary600 : PTColors.gray600,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          );
        }).toList()),

        const SizedBox(height: 12),

        // Nível
        _DropdownField(
          label: 'Nível',
          value: _level,
          items: _levels,
          onChanged: (v) => setState(() => _level = v!),
        ),

        const SizedBox(height: 12),

        // Sessões por semana
        _SectionLabel('Sessões por semana'),
        const SizedBox(height: 8),
        Row(children: [
          for (final n in [2, 3, 4, 5])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('${n}x'),
                selected: _sessionsPerWeek == n,
                onSelected: (_) => setState(() => _sessionsPerWeek = n),
                selectedColor: PTColors.primary50,
                labelStyle: TextStyle(color: _sessionsPerWeek == n ? PTColors.primary600 : PTColors.gray600),
              ),
            ),
        ]),

        const SizedBox(height: 12),

        // Restrições
        TextField(
          controller: _restrictionsCtrl,
          decoration: const InputDecoration(
            labelText: 'Restrições e lesões',
            hintText: 'Ex: joelho direito, lombar...',
            prefixIcon: Icon(Icons.warning_amber_outlined, size: 20),
          ),
          maxLines: 2,
        ),

        const SizedBox(height: 12),

        // Observações
        TextField(
          controller: _notesCtrl,
          decoration: const InputDecoration(
            labelText: 'Observações adicionais',
            hintText: 'Ex: prefere exercícios compostos...',
            prefixIcon: Icon(Icons.note_outlined, size: 20),
          ),
          maxLines: 2,
        ),

        const SizedBox(height: 28),

        if (_error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PTColors.red50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PTColors.red200, width: 0.5),
            ),
            child: Text(_error!, style: const TextStyle(color: PTColors.red600, fontSize: 13)),
          ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _generate,
            icon: _isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: Text(_isLoading ? 'Gerando treino...' : 'Gerar proposta'),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Montar manualmente'),
          ),
        ),

        const SizedBox(height: 80),
      ]),
    );
  }

  // ── Resultado gerado pela IA ───────────────────────────────────────────────

  Widget _buildResult(TextTheme t) {
    final r = _result!;
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Header do resultado
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PTColors.primary50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PTColors.primary200, width: 0.5),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.auto_awesome, color: PTColors.primary600, size: 16),
                  const SizedBox(width: 6),
                  Text('Proposta da IA — revise antes de enviar', style: TextStyle(fontSize: 12, color: PTColors.primary800, fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 6),
                Text(r.workoutName, style: t.headlineSmall?.copyWith(color: PTColors.primary800)),
              ]),
            ),

            const SizedBox(height: 16),

            // Exercícios sugeridos
            Text('Exercícios sugeridos', style: t.titleMedium),
            const SizedBox(height: 10),

            ...r.sets.asMap().entries.map((e) => _ExerciseTile(
              index: e.key + 1,
              suggestion: e.value,
            )),

            if (r.trainerNotes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PTColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PTColors.border, width: 0.5),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Notas da IA para o treinador', style: t.labelLarge),
                  const SizedBox(height: 6),
                  Text(r.trainerNotes, style: t.bodySmall),
                ]),
              ),
            ],

            const SizedBox(height: 80),
          ]),
        ),
      ),

      // Ações fixas no rodapé
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: PTColors.surface,
          border: Border(top: BorderSide(color: PTColors.border, width: 0.5)),
        ),
        child: Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => setState(() { _result = null; }),
            child: const Text('Refazer'),
          )),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: ElevatedButton.icon(
            onPressed: _approveAndSend,
            icon: const Icon(Icons.send),
            label: const Text('Aprovar e usar'),
          )),
        ]),
      ),
    ]);
  }

  // ── Lógica ────────────────────────────────────────────────────────────────

  Future<void> _generate() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final request = AIWorkoutRequest(
        studentId: widget.studentId,
        goal: _goal,
        modality: _modality,
        level: _level,
        restrictions: _restrictionsCtrl.text.isNotEmpty ? _restrictionsCtrl.text : null,
        sessionsPerWeek: _sessionsPerWeek,
        additionalNotes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      );
      final result = await _aiService.generateWorkout(request: request, studentName: 'Aluno');
      setState(() { _result = result; });
    } on AIServiceException catch (e) {
      setState(() { _error = e.message; });
    } catch (e) {
      setState(() { _error = 'Erro inesperado. Tente novamente.'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _approveAndSend() {
    // Converter AIWorkoutResult em Workout e navegar para edição
    context.push('/trainer/students/${widget.studentId}/new-workout');
  }

  @override
  void dispose() {
    _restrictionsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: PTColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    ]);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: PTColors.gray600));
  }
}

class _ExerciseTile extends StatelessWidget {
  final int index;
  final AIExerciseSuggestion suggestion;

  const _ExerciseTile({required this.index, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PTColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PTColors.border, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(color: PTColors.primary50, shape: BoxShape.circle),
          child: Center(child: Text('$index', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PTColors.primary600))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(suggestion.exerciseName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text('${suggestion.sets}x${suggestion.reps} · ${suggestion.restSeconds}s · ${suggestion.muscleGroup}',
              style: const TextStyle(fontSize: 12, color: PTColors.gray400)),
          if (suggestion.notes != null)
            Text(suggestion.notes!, style: const TextStyle(fontSize: 11, color: PTColors.gray400, fontStyle: FontStyle.italic)),
        ])),
      ]),
    );
  }
}
