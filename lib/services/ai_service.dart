import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class AIService {
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-6';

  // API key deve vir de variável de ambiente / configuração segura
  // NUNCA hardcodar a chave no código
  final String _apiKey;

  AIService(this._apiKey);

  // ── Gera treino completo ──────────────────────────────────────────────────

  Future<AIWorkoutResult> generateWorkout({
    required AIWorkoutRequest request,
    required String studentName,
  }) async {
    final prompt = request.toPrompt(studentName);

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 2000,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw AIServiceException('Erro na API: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final content = data['content'][0]['text'] as String;

      // Remove possíveis marcadores de código
      final clean = content
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final json = jsonDecode(clean) as Map<String, dynamic>;
      return AIWorkoutResult.fromJson(json);
    } on AIServiceException {
      rethrow;
    } catch (e) {
      throw AIServiceException('Falha ao gerar treino: $e');
    }
  }

  // ── Sugere progressão de carga ────────────────────────────────────────────

  Future<String> suggestProgression({
    required String studentName,
    required String exerciseName,
    required double currentWeightKg,
    required int completedSets,
    required int targetSets,
    required List<String> recentFeedbacks,
  }) async {
    final feedbackText = recentFeedbacks.isEmpty
        ? 'Sem feedbacks recentes'
        : recentFeedbacks.join('; ');

    final prompt = '''
Você é um assistente de personal trainer. Sugira se o aluno deve progredir, manter ou regredir a carga.

ALUNO: $studentName
EXERCÍCIO: $exerciseName
CARGA ATUAL: ${currentWeightKg}kg
SÉRIES COMPLETADAS: $completedSets de $targetSets
FEEDBACKS RECENTES: $feedbackText

Responda em uma frase curta e direta, como um personal trainer escreveria para si mesmo.
''';

    return await _sendMessage(prompt, maxTokens: 200);
  }

  // ── Gera relatório de evolução ────────────────────────────────────────────

  Future<String> generateProgressReport({
    required String studentName,
    required int workoutsCompleted,
    required double weightChange,
    required int daysActive,
    required List<String> achievements,
  }) async {
    final prompt = '''
Gere um relatório de evolução para o aluno abaixo. Use linguagem positiva, motivadora e profissional.
O relatório será enviado pelo treinador ao aluno.

ALUNO: $studentName
TREINOS COMPLETADOS NO MÊS: $workoutsCompleted
VARIAÇÃO DE PESO: ${weightChange > 0 ? '+' : ''}${weightChange}kg
DIAS ATIVOS: $daysActive
CONQUISTAS: ${achievements.join(', ')}

Escreva em português, 3-4 frases, tom pessoal e encorajador.
''';

    return await _sendMessage(prompt, maxTokens: 400);
  }

  // ── Sugere substituição de exercício ─────────────────────────────────────

  Future<String> suggestExerciseReplacement({
    required String originalExercise,
    required String muscleGroup,
    required String reason,
  }) async {
    final prompt = '''
Sugira um exercício substituto para o exercício abaixo.

EXERCÍCIO ORIGINAL: $originalExercise
GRUPO MUSCULAR: $muscleGroup
MOTIVO DA SUBSTITUIÇÃO: $reason

Responda com apenas o nome do exercício substituto e uma breve justificativa (1 frase).
''';

    return await _sendMessage(prompt, maxTokens: 150);
  }

  // ── Analisa anamnese ──────────────────────────────────────────────────────

  Future<String> analyzeAnamnesis({
    required String studentName,
    required int age,
    required String healthConditions,
    required String injuries,
    required String medications,
    required String trainingHistory,
  }) async {
    final prompt = '''
Analise a anamnese do aluno e liste os principais pontos de atenção para o personal trainer.

ALUNO: $studentName
IDADE: $age anos
CONDIÇÕES DE SAÚDE: $healthConditions
LESÕES / HISTÓRICO: $injuries
MEDICAMENTOS: $medications
HISTÓRICO DE TREINO: $trainingHistory

Liste os pontos de atenção em formato de tópicos curtos. Máximo 5 pontos.
Finalize com o nível de risco geral: BAIXO, MODERADO ou ALTO.
''';

    return await _sendMessage(prompt, maxTokens: 500);
  }

  // ── Método privado base ───────────────────────────────────────────────────

  Future<String> _sendMessage(String prompt, {int maxTokens = 1000}) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': maxTokens,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw AIServiceException('Erro na API: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return data['content'][0]['text'] as String;
  }
}

// ─── RESULTADO DA IA ─────────────────────────────────────────────────────────

class AIWorkoutResult {
  final String workoutName;
  final String modality;
  final List<AIExerciseSuggestion> sets;
  final String trainerNotes;

  const AIWorkoutResult({
    required this.workoutName,
    required this.modality,
    required this.sets,
    required this.trainerNotes,
  });

  factory AIWorkoutResult.fromJson(Map<String, dynamic> j) => AIWorkoutResult(
    workoutName: j['workout_name'] ?? 'Treino gerado',
    modality: j['modality'] ?? 'strength',
    sets: (j['sets'] as List)
        .map((s) => AIExerciseSuggestion.fromJson(s))
        .toList(),
    trainerNotes: j['trainer_notes'] ?? '',
  );
}

class AIExerciseSuggestion {
  final String exerciseName;
  final String muscleGroup;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;

  const AIExerciseSuggestion({
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes,
  });

  factory AIExerciseSuggestion.fromJson(Map<String, dynamic> j) =>
      AIExerciseSuggestion(
        exerciseName: j['exercise_name'],
        muscleGroup: j['muscle_group'],
        sets: j['sets'],
        reps: j['reps'],
        restSeconds: j['rest_seconds'] ?? 60,
        notes: j['notes'],
      );
}

class AIServiceException implements Exception {
  final String message;
  AIServiceException(this.message);

  @override
  String toString() => 'AIServiceException: $message';
}
