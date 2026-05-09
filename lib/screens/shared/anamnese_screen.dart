import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../services/ai_service.dart';

class AnamneseScreen extends StatefulWidget {
  final String studentId;
  final bool readOnly;
  final bool nutritionistMode;
  const AnamneseScreen({super.key, required this.studentId, this.readOnly = false, this.nutritionistMode = false});

  @override
  State<AnamneseScreen> createState() => _AnamneseScreenState();
}

class _AnamneseScreenState extends State<AnamneseScreen> {
  final _pageCtrl = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;

  // ── Step 1 — Identificação ────────────────────────────────────────────────
  DateTime? _birthDate;
  BiologicalSex? _sex;
  final _professionCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();

  // ── Step 2 — Saúde ────────────────────────────────────────────────────────
  final Set<MedicalCondition> _conditions = {};
  final _medicationsCtrl = TextEditingController();
  bool _hasSurgery = false;
  final _surgeryCtrl = TextEditingController();

  // ── Step 3 — PAR-Q ────────────────────────────────────────────────────────
  final List<bool> _parq = List.filled(7, false);

  static const _parqQuestions = [
    'Algum médico já disse que você tem um problema cardíaco e recomendou atividade física supervisionada?',
    'Você sente dor no peito quando pratica atividade física?',
    'No último mês, você sentiu dor no peito sem praticar atividade física?',
    'Você perde o equilíbrio por tontura ou já perdeu a consciência?',
    'Você tem algum problema ósseo ou muscular que poderia ser agravado com atividade física?',
    'Algum médico está presentemente prescrevendo medicamentos para pressão ou condição cardíaca?',
    'Existe alguma outra razão que o impeça de praticar atividade física?',
  ];

  // ── Step 4 — Estilo de vida ───────────────────────────────────────────────
  int _sleepHours = 7;
  StressLevel _stress = StressLevel.moderate;
  SmokingStatus _smoking = SmokingStatus.never;
  int _alcoholDays = 0;
  WorkType _workType = WorkType.sedentary;

  // ── Step 5 — Histórico físico ─────────────────────────────────────────────
  bool _hasPriorExp = false;
  int _expYears = 0;
  final Set<TrainingModality> _prevActivities = {};
  final _injuriesCtrl = TextEditingController();

  // ── Step 6 — Objetivos ────────────────────────────────────────────────────
  String _primaryGoal = 'Hipertrofia';

  final _secondaryCtrl = TextEditingController();
  String _timeFrame = '3 meses';
  final Set<String> _availableDays = {};

  final _goals = ['Hipertrofia', 'Emagrecimento', 'Resistência', 'Condicionamento', 'Reabilitação', 'Qualidade de vida'];
  final _timeFrames = ['1 mês', '3 meses', '6 meses', '1 ano', 'Longo prazo'];
  final _weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  // ── Step 7 — Nutrição ────────────────────────────────────────────────────
  int _waterGlasses = 6;
  int _mealsPerDay = 3;
  String _dietType = 'Onívoro';
  final _foodRestrictionsCtrl = TextEditingController();
  final _supplementsCtrl = TextEditingController();
  final _nutritionNotesCtrl = TextEditingController();

  final _dietTypes = ['Onívoro', 'Vegetariano', 'Vegano', 'Sem glúten', 'Sem lactose', 'Outro'];

  bool _aiLoading = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _professionCtrl.dispose();
    _emergencyCtrl.dispose();
    _medicationsCtrl.dispose();
    _surgeryCtrl.dispose();
    _injuriesCtrl.dispose();
    _secondaryCtrl.dispose();
    _foodRestrictionsCtrl.dispose();
    _supplementsCtrl.dispose();
    _nutritionNotesCtrl.dispose();
    super.dispose();
  }

  bool get _isReadOnly => widget.readOnly && !widget.nutritionistMode;
  bool get _nutritionEditable => widget.nutritionistMode && _currentStep == 6;

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    } else {
      if (_isReadOnly) context.pop();
      else _save();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anamnese salva com sucesso!')),
    );
    context.pop();
  }

  Future<void> _analyzeWithAI() async {
    setState(() => _aiLoading = true);
    try {
      final result = await AIService('YOUR_API_KEY').analyzeAnamnesis(
        studentName: 'Aluno ${widget.studentId}',
        age: _birthDate != null ? DateTime.now().year - _birthDate!.year : 28,
        healthConditions: _conditions.isEmpty ? 'Nenhuma' : _conditions.map((c) => c.name).join(', '),
        injuries: _injuriesCtrl.text.trim().isEmpty ? 'Nenhuma' : _injuriesCtrl.text.trim(),
        medications: _medicationsCtrl.text.trim().isEmpty ? 'Nenhum' : _medicationsCtrl.text.trim(),
        trainingHistory: _hasPriorExp ? '$_expYears anos de experiência' : 'Sem experiência prévia',
      );
      if (!mounted) return;
      setState(() => _aiLoading = false);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AiResultSheet(result: result),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _aiLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stepLabels = ['Identificação', 'Saúde', 'PAR-Q', 'Estilo de Vida', 'Histórico Físico', 'Objetivos', 'Nutrição'];

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: Text(widget.nutritionistMode
            ? 'Anamnese — Nutrição'
            : 'Anamnese${_isReadOnly ? '' : ' — ${stepLabels[_currentStep]}'}'),
        actions: [
          if (widget.readOnly)
            _aiLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : TextButton.icon(
                    onPressed: _analyzeWithAI,
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('Analisar IA'),
                  ),
        ],
      ),
      body: Column(children: [
        // Barra de progresso
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Passo ${_currentStep + 1} de $_totalSteps', style: t.bodySmall),
              Text(stepLabels[_currentStep], style: t.labelLarge?.copyWith(color: PTColors.primary600)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _totalSteps,
                minHeight: 5,
                backgroundColor: PTColors.gray100,
                valueColor: const AlwaysStoppedAnimation(PTColors.primary600),
              ),
            ),
          ]),
        ),

        Expanded(
          child: PageView(
            controller: _pageCtrl,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1(t),
              _buildStep2(t),
              _buildStep3(t),
              _buildStep4(t),
              _buildStep5(t),
              _buildStep6(t),
              _buildStep7(t),
            ],
          ),
        ),

        // Botões de navegação
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          decoration: const BoxDecoration(
            color: PTColors.surface,
            border: Border(top: BorderSide(color: PTColors.border, width: 0.5)),
          ),
          child: Row(children: [
            if (_currentStep > 0)
              Expanded(child: OutlinedButton(onPressed: _back, child: const Text('Voltar'))),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(() {
                  if (_currentStep == _totalSteps - 1) {
                    if (widget.nutritionistMode) return 'Salvar observações';
                    if (_isReadOnly) return 'Fechar';
                    return 'Salvar anamnese';
                  }
                  return 'Próximo';
                }()),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Step 1 ─────────────────────────────────────────────────────────────────

  Widget _buildStep1(TextTheme t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionInfo(
          icon: Icons.person_outline,
          title: 'Dados pessoais',
          subtitle: 'Informações básicas do aluno para o prontuário.',
        ),

        const SizedBox(height: 16),

        // Sexo biológico
        Text('Sexo biológico', style: t.labelLarge),
        const SizedBox(height: 8),
        Row(children: [
          _ChoiceBtn(label: 'Masculino', selected: _sex == BiologicalSex.male, onTap: () => setState(() => _sex = BiologicalSex.male)),
          const SizedBox(width: 8),
          _ChoiceBtn(label: 'Feminino', selected: _sex == BiologicalSex.female, onTap: () => setState(() => _sex = BiologicalSex.female)),
          const SizedBox(width: 8),
          _ChoiceBtn(label: 'Outro', selected: _sex == BiologicalSex.other, onTap: () => setState(() => _sex = BiologicalSex.other)),
        ]),

        const SizedBox(height: 16),

        // Data de nascimento
        _DateField(
          label: 'Data de nascimento',
          value: _birthDate,
          onChanged: (d) => setState(() => _birthDate = d),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _professionCtrl,
          decoration: const InputDecoration(labelText: 'Profissão', prefixIcon: Icon(Icons.work_outline, size: 20)),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _emergencyCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Contato de emergência',
            hintText: 'Nome e telefone',
            prefixIcon: Icon(Icons.emergency_outlined, size: 20),
          ),
        ),
      ]),
    );
  }

  // ── Step 2 ─────────────────────────────────────────────────────────────────

  Widget _buildStep2(TextTheme t) {
    final conditionLabels = {
      MedicalCondition.hypertension: 'Hipertensão',
      MedicalCondition.diabetes: 'Diabetes',
      MedicalCondition.heartDisease: 'Cardiopatia',
      MedicalCondition.asthma: 'Asma',
      MedicalCondition.depression: 'Depressão',
      MedicalCondition.anxiety: 'Ansiedade',
      MedicalCondition.osteoporosis: 'Osteoporose',
      MedicalCondition.arthritis: 'Artrite/Artrose',
      MedicalCondition.other: 'Outra',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionInfo(icon: Icons.health_and_safety_outlined, title: 'Histórico de saúde', subtitle: 'Condições médicas que podem influenciar o treino.'),

        const SizedBox(height: 16),

        Text('Condições médicas (marque todas que se aplicam)', style: t.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: conditionLabels.entries.map((e) {
          final sel = _conditions.contains(e.key);
          return GestureDetector(
            onTap: () => setState(() => sel ? _conditions.remove(e.key) : _conditions.add(e.key)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? PTColors.red50 : PTColors.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: sel ? PTColors.red200 : PTColors.border, width: 0.5),
              ),
              child: Text(e.value, style: TextStyle(fontSize: 13, color: sel ? PTColors.red600 : PTColors.gray600, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
            ),
          );
        }).toList()),

        if (_conditions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: PTColors.amber50, borderRadius: BorderRadius.circular(10), border: Border.all(color: PTColors.amber200, width: 0.5)),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 16, color: PTColors.amber600),
              const SizedBox(width: 8),
              Expanded(child: Text('Consulte um médico antes de iniciar o programa.', style: const TextStyle(fontSize: 12, color: PTColors.amber800))),
            ]),
          ),
        ],

        const SizedBox(height: 16),

        TextField(
          controller: _medicationsCtrl,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Medicamentos em uso', hintText: 'Nome e dosagem...', prefixIcon: Icon(Icons.medication_outlined, size: 20)),
        ),

        const SizedBox(height: 16),

        _SwitchRow(label: 'Realizou cirurgia recentemente?', value: _hasSurgery, onChanged: (v) => setState(() => _hasSurgery = v)),

        if (_hasSurgery) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _surgeryCtrl,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Descreva a cirurgia e quando foi'),
          ),
        ],
      ]),
    );
  }

  // ── Step 3 — PAR-Q ─────────────────────────────────────────────────────────

  Widget _buildStep3(TextTheme t) {
    final hasAlert = _parq.any((a) => a);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionInfo(
          icon: Icons.assignment_outlined,
          title: 'PAR-Q',
          subtitle: 'Physical Activity Readiness Questionnaire — questionário de prontidão para atividade física.',
        ),

        const SizedBox(height: 12),

        ..._parqQuestions.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _parq[e.key] ? PTColors.red50 : PTColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _parq[e.key] ? PTColors.red200 : PTColors.border, width: 0.5),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text('${e.key + 1}. ${e.value}', style: TextStyle(fontSize: 13, color: _parq[e.key] ? PTColors.red800 : PTColors.gray900))),
            const SizedBox(width: 12),
            Column(children: [
              _ParqBtn(label: 'Sim', selected: _parq[e.key], danger: true, onTap: () => setState(() => _parq[e.key] = true)),
              const SizedBox(height: 4),
              _ParqBtn(label: 'Não', selected: !_parq[e.key], danger: false, onTap: () => setState(() => _parq[e.key] = false)),
            ]),
          ]),
        )),

        if (hasAlert) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: PTColors.red50, borderRadius: BorderRadius.circular(12), border: Border.all(color: PTColors.red200, width: 0.5)),
            child: Row(children: [
              const Icon(Icons.warning_amber_outlined, color: PTColors.red600, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Uma ou mais respostas positivas. Recomenda-se avaliação médica antes de iniciar.', style: const TextStyle(fontSize: 13, color: PTColors.red800))),
            ]),
          ),
        ],
      ]),
    );
  }

  // ── Step 4 — Estilo de vida ─────────────────────────────────────────────────

  Widget _buildStep4(TextTheme t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionInfo(icon: Icons.self_improvement_outlined, title: 'Estilo de vida', subtitle: 'Hábitos do dia a dia que afetam a performance e recuperação.'),

        const SizedBox(height: 16),

        // Horas de sono
        Text('Horas de sono por noite: $_sleepHours h', style: t.labelLarge),
        Slider(
          value: _sleepHours.toDouble(),
          min: 3, max: 12,
          divisions: 9,
          activeColor: PTColors.primary600,
          label: '$_sleepHours h',
          onChanged: (v) => setState(() => _sleepHours = v.round()),
        ),

        const SizedBox(height: 12),

        // Estresse
        Text('Nível de estresse', style: t.labelLarge),
        const SizedBox(height: 8),
        Row(children: [
          for (final s in StressLevel.values)
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _ChoiceBtn(
                label: _stressLabel(s),
                selected: _stress == s,
                color: _stressColor(s),
                onTap: () => setState(() => _stress = s),
              ),
            )),
        ]),

        const SizedBox(height: 16),

        // Tabagismo
        Text('Tabagismo', style: t.labelLarge),
        const SizedBox(height: 8),
        Row(children: [
          _ChoiceBtn(label: 'Nunca', selected: _smoking == SmokingStatus.never, onTap: () => setState(() => _smoking = SmokingStatus.never)),
          const SizedBox(width: 8),
          _ChoiceBtn(label: 'Ex-fumante', selected: _smoking == SmokingStatus.former, onTap: () => setState(() => _smoking = SmokingStatus.former)),
          const SizedBox(width: 8),
          _ChoiceBtn(label: 'Fumante', selected: _smoking == SmokingStatus.current, color: PTColors.red400, onTap: () => setState(() => _smoking = SmokingStatus.current)),
        ]),

        const SizedBox(height: 16),

        // Álcool
        Text('Consumo de álcool: $_alcoholDays dias/semana', style: t.labelLarge),
        Slider(
          value: _alcoholDays.toDouble(),
          min: 0, max: 7,
          divisions: 7,
          activeColor: PTColors.amber400,
          label: _alcoholDays == 0 ? 'Não bebo' : '$_alcoholDays dias',
          onChanged: (v) => setState(() => _alcoholDays = v.round()),
        ),

        const SizedBox(height: 12),

        // Tipo de trabalho
        Text('Tipo de trabalho/rotina', style: t.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: WorkType.values.map((w) => _ChoiceBtn(
          label: _workLabel(w),
          selected: _workType == w,
          onTap: () => setState(() => _workType = w),
        )).toList()),
      ]),
    );
  }

  // ── Step 5 — Histórico físico ───────────────────────────────────────────────

  Widget _buildStep5(TextTheme t) {
    final modalityLabels = {
      TrainingModality.strength: 'Musculação',
      TrainingModality.bike: 'Bike',
      TrainingModality.running: 'Corrida',
      TrainingModality.functional: 'Funcional',
      TrainingModality.swimming: 'Natação',
      TrainingModality.home: 'Em casa',
      TrainingModality.pilates: 'Pilates',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionInfo(icon: Icons.fitness_center_outlined, title: 'Histórico físico', subtitle: 'Experiência e limitações que guiam a prescrição do treino.'),

        const SizedBox(height: 16),

        _SwitchRow(label: 'Tem experiência prévia com exercícios?', value: _hasPriorExp, onChanged: (v) => setState(() => _hasPriorExp = v)),

        if (_hasPriorExp) ...[
          const SizedBox(height: 14),
          Text('Anos de experiência: $_expYears anos', style: t.labelLarge),
          Slider(
            value: _expYears.toDouble(),
            min: 0, max: 20,
            divisions: 20,
            activeColor: PTColors.primary600,
            label: _expYears == 0 ? '< 1 ano' : '$_expYears anos',
            onChanged: (v) => setState(() => _expYears = v.round()),
          ),
          const SizedBox(height: 12),
          Text('Atividades praticadas', style: t.labelLarge),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: modalityLabels.entries.map((e) {
            final sel = _prevActivities.contains(e.key);
            return GestureDetector(
              onTap: () => setState(() => sel ? _prevActivities.remove(e.key) : _prevActivities.add(e.key)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? PTColors.primary50 : PTColors.surface,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: sel ? PTColors.primary200 : PTColors.border, width: 0.5),
                ),
                child: Text(e.value, style: TextStyle(fontSize: 13, color: sel ? PTColors.primary600 : PTColors.gray600, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
              ),
            );
          }).toList()),
        ],

        const SizedBox(height: 16),

        TextField(
          controller: _injuriesCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Lesões ou limitações físicas',
            hintText: 'Ex: hérnias, tendinites, dores crônicas...',
            prefixIcon: Icon(Icons.warning_amber_outlined, size: 20),
          ),
        ),
      ]),
    );
  }

  // ── Step 6 — Objetivos ──────────────────────────────────────────────────────

  Widget _buildStep6(TextTheme t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionInfo(icon: Icons.flag_outlined, title: 'Objetivos', subtitle: 'Metas que orientarão todo o planejamento do treino.'),

        const SizedBox(height: 16),

        // Objetivo principal
        Text('Objetivo principal', style: t.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _goals.map((g) => GestureDetector(
          onTap: () => setState(() => _primaryGoal = g),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _primaryGoal == g ? PTColors.primary50 : PTColors.surface,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: _primaryGoal == g ? PTColors.primary200 : PTColors.border, width: 0.5),
            ),
            child: Text(g, style: TextStyle(fontSize: 13, color: _primaryGoal == g ? PTColors.primary600 : PTColors.gray600, fontWeight: _primaryGoal == g ? FontWeight.w600 : FontWeight.w400)),
          ),
        )).toList()),

        const SizedBox(height: 16),

        TextField(
          controller: _secondaryCtrl,
          decoration: const InputDecoration(labelText: 'Objetivo secundário (opcional)', hintText: 'Ex: melhorar postura, aliviar dores...'),
        ),

        const SizedBox(height: 16),

        // Prazo
        Text('Prazo para o objetivo', style: t.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _timeFrames.map((tf) => GestureDetector(
          onTap: () => setState(() => _timeFrame = tf),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _timeFrame == tf ? PTColors.teal50 : PTColors.surface,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: _timeFrame == tf ? PTColors.teal200 : PTColors.border, width: 0.5),
            ),
            child: Text(tf, style: TextStyle(fontSize: 13, color: _timeFrame == tf ? PTColors.teal600 : PTColors.gray600, fontWeight: _timeFrame == tf ? FontWeight.w600 : FontWeight.w400)),
          ),
        )).toList()),

        const SizedBox(height: 16),

        // Dias disponíveis
        Text('Dias disponíveis para treinar', style: t.labelLarge),
        const SizedBox(height: 8),
        Row(children: _weekDays.map((d) {
          final sel = _availableDays.contains(d);
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => setState(() => sel ? _availableDays.remove(d) : _availableDays.add(d)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? PTColors.primary600 : PTColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sel ? PTColors.primary600 : PTColors.border, width: 0.5),
                ),
                child: Column(children: [
                  Text(d, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : PTColors.gray600)),
                ]),
              ),
            ),
          ));
        }).toList()),

        const SizedBox(height: 80),
      ]),
    );
  }

  // ── Step 7 — Nutrição ──────────────────────────────────────────────────────

  Widget _buildStep7(TextTheme t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionInfo(
          icon: Icons.restaurant_menu_outlined,
          title: 'Nutrição',
          subtitle: 'Hábitos alimentares que complementam o planejamento do treino.',
        ),

        const SizedBox(height: 16),

        // Consumo de água
        Text('Consumo de água: $_waterGlasses copos/dia', style: t.labelLarge),
        Slider(
          value: _waterGlasses.toDouble(),
          min: 1, max: 15,
          divisions: 14,
          activeColor: PTColors.teal400,
          label: '$_waterGlasses copos',
          onChanged: (_isReadOnly && !_nutritionEditable) ? null : (v) => setState(() => _waterGlasses = v.round()),
        ),

        const SizedBox(height: 12),

        // Refeições por dia
        Text('Refeições por dia: $_mealsPerDay', style: t.labelLarge),
        Slider(
          value: _mealsPerDay.toDouble(),
          min: 1, max: 8,
          divisions: 7,
          activeColor: PTColors.primary600,
          label: '$_mealsPerDay refeições',
          onChanged: (_isReadOnly && !_nutritionEditable) ? null : (v) => setState(() => _mealsPerDay = v.round()),
        ),

        const SizedBox(height: 16),

        // Tipo de dieta
        Text('Tipo de dieta', style: t.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _dietTypes.map((d) => GestureDetector(
          onTap: (_isReadOnly && !_nutritionEditable) ? null : () => setState(() => _dietType = d),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _dietType == d ? PTColors.teal50 : PTColors.surface,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: _dietType == d ? PTColors.teal200 : PTColors.border, width: 0.5),
            ),
            child: Text(d, style: TextStyle(fontSize: 13, color: _dietType == d ? PTColors.teal600 : PTColors.gray600, fontWeight: _dietType == d ? FontWeight.w600 : FontWeight.w400)),
          ),
        )).toList()),

        const SizedBox(height: 16),

        TextField(
          controller: _foodRestrictionsCtrl,
          readOnly: _isReadOnly && !_nutritionEditable,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Alergias e restrições alimentares',
            hintText: 'Ex: lactose, glúten, amendoim...',
            prefixIcon: Icon(Icons.remove_circle_outline, size: 20),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _supplementsCtrl,
          readOnly: _isReadOnly && !_nutritionEditable,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Suplementos em uso',
            hintText: 'Ex: whey, creatina, multivitamínico...',
            prefixIcon: Icon(Icons.science_outlined, size: 20),
          ),
        ),

        const SizedBox(height: 20),

        // Campo exclusivo da nutricionista
        Container(
          decoration: BoxDecoration(
            color: PTColors.amber50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PTColors.amber200, width: 0.5),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Row(children: [
                const Icon(Icons.local_hospital_outlined, size: 16, color: PTColors.amber600),
                const SizedBox(width: 6),
                Text('Observações da nutricionista', style: t.labelLarge?.copyWith(color: PTColors.amber800)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: PTColors.amber200, borderRadius: BorderRadius.circular(99)),
                  child: const Text('Plano Plus', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: PTColors.amber800)),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: TextField(
                controller: _nutritionNotesCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Campo reservado para orientações da nutricionista da plataforma...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: PTColors.amber200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: PTColors.amber200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: PTColors.amber400, width: 1.5)),
                  fillColor: PTColors.surface,
                  filled: true,
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 80),
      ]),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _stressLabel(StressLevel s) => switch (s) {
    StressLevel.low => 'Baixo',
    StressLevel.moderate => 'Médio',
    StressLevel.high => 'Alto',
    StressLevel.veryHigh => 'Muito alto',
  };

  Color _stressColor(StressLevel s) => switch (s) {
    StressLevel.low => PTColors.teal400,
    StressLevel.moderate => PTColors.primary600,
    StressLevel.high => PTColors.amber400,
    StressLevel.veryHigh => PTColors.red400,
  };

  String _workLabel(WorkType w) => switch (w) {
    WorkType.sedentary => 'Sedentário',
    WorkType.light => 'Leve',
    WorkType.moderate => 'Moderado',
    WorkType.active => 'Ativo',
  };
}

// ─── WIDGETS AUXILIARES ──────────────────────────────────────────────────────

class _SectionInfo extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _SectionInfo({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: PTColors.primary50, borderRadius: BorderRadius.circular(12), border: Border.all(color: PTColors.primary100, width: 0.5)),
    child: Row(children: [
      Icon(icon, color: PTColors.primary600, size: 24),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: PTColors.primary800)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: PTColors.primary600)),
      ])),
    ]),
  );
}

class _ChoiceBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _ChoiceBtn({required this.label, required this.selected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? PTColors.primary600;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.1) : PTColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? c : PTColors.border, width: selected ? 1.5 : 0.5),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, color: selected ? c : PTColors.gray600, fontWeight: selected ? FontWeight.w600 : FontWeight.w400), textAlign: TextAlign.center),
      ),
    );
  }
}

class _ParqBtn extends StatelessWidget {
  final String label;
  final bool selected, danger;
  final VoidCallback onTap;
  const _ParqBtn({required this.label, required this.selected, required this.danger, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = danger && selected ? PTColors.red600 : PTColors.primary600;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.1) : PTColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? c : PTColors.border, width: selected ? 1.5 : 0.5),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: selected ? c : PTColors.gray400, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PTColors.gray900))),
    Switch(value: value, onChanged: onChanged, activeThumbColor: PTColors.primary600),
  ]);
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  const _DateField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () async {
      final d = await showDatePicker(
        context: context,
        initialDate: value ?? DateTime(1990),
        firstDate: DateTime(1930),
        lastDate: DateTime.now(),
      );
      if (d != null) onChanged(d);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: PTColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PTColors.border, width: 0.5),
      ),
      child: Row(children: [
        const Icon(Icons.cake_outlined, size: 20, color: PTColors.gray400),
        const SizedBox(width: 12),
        Expanded(child: Text(
          value != null ? '${value!.day.toString().padLeft(2,'0')}/${value!.month.toString().padLeft(2,'0')}/${value!.year}' : label,
          style: TextStyle(fontSize: 14, color: value != null ? PTColors.gray900 : PTColors.gray400),
        )),
        const Icon(Icons.edit_calendar_outlined, size: 16, color: PTColors.gray400),
      ]),
    ),
  );
}

// ── AI Result Sheet ───────────────────────────────────────────────────────────

class _AiResultSheet extends StatelessWidget {
  final String result;
  const _AiResultSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        color: PTColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: PTColors.gray200, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: PTColors.primary50, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.auto_awesome, color: PTColors.primary600, size: 20),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Análise de Anamnese', style: t.titleMedium),
              Text('Gerado por IA · ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const TextStyle(fontSize: 12, color: PTColors.gray400)),
            ]),
          ]),
          const SizedBox(height: 16),
          const Divider(height: 1, color: PTColors.border),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PTColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PTColors.border, width: 0.5),
            ),
            child: Text(result, style: const TextStyle(fontSize: 14, color: PTColors.gray900, height: 1.6)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ),
        ]),
      ),
    );
  }
}

