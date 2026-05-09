import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../services/wearable_service.dart';
import '../../services/ai_service.dart';

class ExerciseExecutionScreen extends StatefulWidget {
  final int setIndex;
  const ExerciseExecutionScreen({super.key, required this.setIndex});

  @override
  State<ExerciseExecutionScreen> createState() => _ExerciseExecutionScreenState();
}

class _ExerciseExecutionScreenState extends State<ExerciseExecutionScreen> {
  // Mock — substituir por provider real
  final WorkoutSet _currentSet = WorkoutSet(
    exerciseId: '1',
    exercise: Exercise(
      id: '1',
      name: 'Remada curvada',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      muscleGroup: 'Costas',
      modality: TrainingModality.strength,
      instructions: 'Mantenha a coluna neutra. Puxe os cotovelos para trás.',
    ),
    sets: 4,
    reps: 12,
    weightKg: 40,
    restSeconds: 45,
  );

  int _completedSets = 0;
  int _restSecondsLeft = 0;
  Timer? _restTimer;
  bool _isResting = false;
  double _currentWeight = 40;

  // Wearable
  final _wearable = WearableService();
  int _currentBpm = 0;
  HeartRateZone _currentZone = HeartRateZone.rest;
  StreamSubscription? _wearableSub;

  YoutubePlayerController? _ytController;
  bool _aiProgressionLoading = false;

  @override
  void initState() {
    super.initState();
    _initWearable();
    _initVideo();
  }

  void _initWearable() {
    _wearable.startSimulation('student-1', baseHR: 130);
    _wearableSub = _wearable.snapshots.listen((snap) {
      if (!mounted) return;
      final mockProfile = StudentProfile(
        userId: 'student-1', trainerId: 't1',
        age: 30, weightKg: 80, heightCm: 175,
        primaryModality: TrainingModality.strength,
        goal: 'Hipertrofia', level: 'Intermediário',
      );
      setState(() {
        _currentBpm = snap.heartRateBpm;
        _currentZone = mockProfile.zoneForBpm(snap.heartRateBpm);
      });
      final alert = mockProfile.alertForBpm(snap.heartRateBpm);
      if (alert == AlertLevel.critical) _showCriticalAlert(snap.heartRateBpm);
    });
  }

  void _initVideo() {
    final yt = _currentSet.exercise.youtubeUrl;
    if (yt != null) {
      final videoId = YoutubePlayerController.convertUrlToId(yt) ?? yt.split('?v=').last;
      _ytController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        params: const YoutubePlayerParams(
          showControls: true,
          mute: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final zone = WearableService.zoneInfo(_currentZone);

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_currentSet.exercise.name, style: t.titleMedium),
          Text('Exercício ${widget.setIndex + 1} · Treino B', style: t.bodySmall),
        ]),
        actions: [
          // Botão de dúvida — abre chat com contexto
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Enviar dúvida ao treinador',
            onPressed: _openChatWithContext,
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Vídeo ──────────────────────────────────────────────────
              _buildVideoSection(),
              const SizedBox(height: 16),

              // ── Wearable / FC ───────────────────────────────────────────
              if (_currentBpm > 0) _buildHeartRateSection(zone),
              if (_currentBpm > 0) const SizedBox(height: 16),

              // ── Métricas da série ───────────────────────────────────────
              _buildSetMetrics(t),
              const SizedBox(height: 16),

              // ── Ajuste de carga ─────────────────────────────────────────
              _buildWeightAdjuster(t),
              const SizedBox(height: 16),

              // ── Timer de descanso ───────────────────────────────────────
              if (_isResting) _buildRestTimer(t),
              if (_isResting) const SizedBox(height: 16),

              // ── Instruções ──────────────────────────────────────────────
              if (_currentSet.exercise.instructions != null)
                _buildInstructions(t),
            ]),
          ),
        ),

        // ── Botão de ação principal ─────────────────────────────────────
        _buildActionButton(t),
      ]),
    );
  }

  Widget _buildVideoSection() {
    if (_ytController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: YoutubePlayer(controller: _ytController!),
      );
    }
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: PTColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PTColors.border, width: 0.5),
      ),
      child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.play_circle_outline, size: 40, color: PTColors.gray400),
        SizedBox(height: 6),
        Text('Vídeo demonstrativo', style: TextStyle(color: PTColors.gray400, fontSize: 13)),
      ])),
    );
  }

  Widget _buildHeartRateSection(HeartRateZoneInfo zone) {
    final isAlert = _currentZone == HeartRateZone.maximum || _currentZone == HeartRateZone.anaerobic;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(zone.color).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(zone.color).withValues(alpha: 0.4), width: 0.5),
      ),
      child: Row(children: [
        Icon(isAlert ? Icons.favorite : Icons.favorite_border,
            color: Color(zone.darkColor), size: 22),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$_currentBpm bpm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(zone.darkColor))),
          Text(zone.label, style: TextStyle(fontSize: 12, color: Color(zone.darkColor))),
        ]),
        const Spacer(),
        if (isAlert)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: PTColors.red50, borderRadius: BorderRadius.circular(99), border: Border.all(color: PTColors.red200, width: 0.5)),
            child: const Text('Atenção', style: TextStyle(fontSize: 11, color: PTColors.red600, fontWeight: FontWeight.w500)),
          ),
      ]),
    );
  }

  Widget _buildSetMetrics(TextTheme t) {
    return Row(children: [
      Expanded(child: _MetricBox(value: '${_currentSet.sets}', label: 'Séries', color: PTColors.primary600)),
      const SizedBox(width: 10),
      Expanded(child: _MetricBox(value: '${_currentSet.reps}', label: 'Reps', color: PTColors.primary600)),
      const SizedBox(width: 10),
      Expanded(child: _MetricBox(value: '$_completedSets/${_currentSet.sets}', label: 'Feitas', color: PTColors.teal400)),
    ]);
  }

  Widget _buildWeightAdjuster(TextTheme t) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PTColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PTColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Carga atual', style: t.bodyMedium),
          const Spacer(),
          _RoundButton(icon: Icons.remove, onTap: () => setState(() => _currentWeight = (_currentWeight - 2.5).clamp(0, 999))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text('${_currentWeight.toStringAsFixed(1)} kg', style: t.titleMedium),
          ),
          _RoundButton(icon: Icons.add, onTap: () => setState(() => _currentWeight += 2.5)),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _aiProgressionLoading ? null : _suggestProgression,
            icon: _aiProgressionLoading
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome, size: 16),
            label: Text(_aiProgressionLoading ? 'Analisando...' : 'Sugerir progressão IA'),
            style: OutlinedButton.styleFrom(
              foregroundColor: PTColors.primary600,
              side: const BorderSide(color: PTColors.primary200),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildRestTimer(TextTheme t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PTColors.amber50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PTColors.amber200, width: 0.5),
      ),
      child: Column(children: [
        Text('Descanso', style: TextStyle(fontSize: 13, color: PTColors.amber800, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(
          '${(_restSecondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_restSecondsLeft % 60).toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: PTColors.amber800),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _skipRest,
          style: OutlinedButton.styleFrom(foregroundColor: PTColors.amber600, side: const BorderSide(color: PTColors.amber200)),
          child: const Text('Pular descanso'),
        ),
      ]),
    );
  }

  Widget _buildInstructions(TextTheme t) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PTColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PTColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Instruções', style: t.labelLarge),
        const SizedBox(height: 6),
        Text(_currentSet.exercise.instructions!, style: t.bodySmall),
      ]),
    );
  }

  Widget _buildActionButton(TextTheme t) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: PTColors.surface,
        border: Border(top: BorderSide(color: PTColors.border, width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: PTColors.teal400),
          onPressed: _completedSets < _currentSet.sets && !_isResting ? _completeSeries : null,
          icon: const Icon(Icons.check, color: Colors.white),
          label: Text(
            _isResting ? 'Descansando...' : (_completedSets >= _currentSet.sets ? 'Exercício concluído!' : 'Concluir série ${_completedSets + 1}/${_currentSet.sets}'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // ── Lógica ─────────────────────────────────────────────────────────────────

  void _completeSeries() {
    setState(() {
      _completedSets++;
      if (_completedSets < _currentSet.sets) {
        _startRest();
      } else {
        // Exercício completo — voltar para lista
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) context.pop();
        });
      }
    });
  }

  void _startRest() {
    setState(() { _isResting = true; _restSecondsLeft = _currentSet.restSeconds; });
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _restSecondsLeft--;
        if (_restSecondsLeft <= 0) { _stopRest(); t.cancel(); }
      });
    });
  }

  void _stopRest() => setState(() => _isResting = false);
  void _skipRest() { _restTimer?.cancel(); _stopRest(); }

  Future<void> _suggestProgression() async {
    setState(() => _aiProgressionLoading = true);
    try {
      final result = await AIService('YOUR_API_KEY').suggestProgression(
        studentName: 'Aluno',
        exerciseName: _currentSet.exercise.name,
        currentWeightKg: _currentWeight,
        completedSets: _completedSets,
        targetSets: _currentSet.sets,
        recentFeedbacks: const [],
      );
      if (!mounted) return;
      setState(() => _aiProgressionLoading = false);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AiProgressionSheet(result: result, exerciseName: _currentSet.exercise.name),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _aiProgressionLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void _openChatWithContext() {
    // Navegar para chat com contexto do exercício pré-preenchido
    context.go('/student/chat');
  }

  void _showCriticalAlert(int bpm) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _CriticalAlertSheet(bpm: bpm),
    );
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _wearableSub?.cancel();
    _wearable.stopSimulation();
    _wearable.dispose();
    super.dispose();
  }
}

// ─── ALERTA CRÍTICO ──────────────────────────────────────────────────────────

class _CriticalAlertSheet extends StatelessWidget {
  final int bpm;
  const _CriticalAlertSheet({required this.bpm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: PTColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 48, height: 48,
          decoration: const BoxDecoration(color: PTColors.red50, shape: BoxShape.circle),
          child: const Icon(Icons.favorite, color: PTColors.red600, size: 26),
        ),
        const SizedBox(height: 14),
        const Text('Frequência cardíaca muito alta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: PTColors.red600)),
        const SizedBox(height: 8),
        Text('Sua FC chegou a $bpm bpm.\nO treino foi pausado por segurança.', textAlign: TextAlign.center, style: const TextStyle(color: PTColors.gray600, fontSize: 14)),
        const SizedBox(height: 4),
        const Text('Seu treinador foi notificado.', style: TextStyle(color: PTColors.gray400, fontSize: 13)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Estou bem'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: PTColors.red600),
            onPressed: () {/* launch SAMU 192 */},
            icon: const Icon(Icons.phone, color: Colors.white, size: 16),
            label: const Text('SAMU 192', style: TextStyle(color: Colors.white)),
          )),
        ]),
      ]),
    );
  }
}

// ─── WIDGETS AUXILIARES ──────────────────────────────────────────────────────

class _MetricBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MetricBox({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: PTColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PTColors.border, width: 0.5),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
      ]),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: PTColors.border, width: 0.5),
          color: PTColors.gray50,
        ),
        child: Icon(icon, size: 16, color: PTColors.gray600),
      ),
    );
  }
}

// ── AI Progression Sheet ──────────────────────────────────────────────────────

class _AiProgressionSheet extends StatelessWidget {
  final String result;
  final String exerciseName;
  const _AiProgressionSheet({required this.result, required this.exerciseName});

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
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Sugestão de Progressão', style: t.titleMedium),
                Text(exerciseName, style: const TextStyle(fontSize: 12, color: PTColors.gray400)),
              ]),
            ),
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
