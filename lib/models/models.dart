// ─── ENUMS ───────────────────────────────────────────────────────────────────

enum UserRole { trainer, student, nutritionist }

enum TrainingModality { strength, bike, running, functional, swimming, home, pilates }

enum HeartRateZone { rest, light, moderate, aerobic, anaerobic, maximum }

enum AlertLevel { none, warning, critical }

enum SessionStatus { pending, confirmed, cancelled, completed }

enum MessageType { text, exerciseQuery, announcement }

// ─── USER ────────────────────────────────────────────────────────────────────

class PTUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final UserRole role;
  final DateTime createdAt;

  const PTUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  factory PTUser.fromJson(Map<String, dynamic> j) => PTUser(
    id: j['id'],
    name: j['name'],
    email: j['email'],
    avatarUrl: j['avatar_url'],
    role: UserRole.values.byName(j['role']),
    createdAt: DateTime.parse(j['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email,
    'avatar_url': avatarUrl, 'role': role.name,
    'created_at': createdAt.toIso8601String(),
  };
}

// ─── STUDENT PROFILE ─────────────────────────────────────────────────────────

class StudentProfile {
  final String userId;
  final String trainerId;
  final int age;
  final double weightKg;
  final double heightCm;
  final TrainingModality primaryModality;
  final String goal;
  final String? restrictions;
  final String level; // beginner / intermediate / advanced
  final bool isActive;
  final bool hasWearable;
  final int? maxHeartRate; // null = calculado automaticamente
  final double? minSpO2;   // null = não monitorado
  final DateTime? lastTraining;
  final PaymentStatus paymentStatus;

  const StudentProfile({
    required this.userId,
    required this.trainerId,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.primaryModality,
    required this.goal,
    this.restrictions,
    required this.level,
    this.isActive = true,
    this.hasWearable = false,
    this.maxHeartRate,
    this.minSpO2,
    this.lastTraining,
    this.paymentStatus = PaymentStatus.upToDate,
  });

  int get calculatedMaxHR => maxHeartRate ?? (220 - age);

  HeartRateZone zoneForBpm(int bpm) {
    final max = calculatedMaxHR;
    final pct = bpm / max;
    if (pct < 0.50) return HeartRateZone.rest;
    if (pct < 0.61) return HeartRateZone.light;
    if (pct < 0.71) return HeartRateZone.moderate;
    if (pct < 0.86) return HeartRateZone.aerobic;
    if (pct < 0.96) return HeartRateZone.anaerobic;
    return HeartRateZone.maximum;
  }

  AlertLevel alertForBpm(int bpm) {
    final zone = zoneForBpm(bpm);
    if (zone == HeartRateZone.maximum) return AlertLevel.critical;
    if (zone == HeartRateZone.anaerobic) return AlertLevel.warning;
    return AlertLevel.none;
  }

  factory StudentProfile.fromJson(Map<String, dynamic> j) => StudentProfile(
    userId: j['user_id'],
    trainerId: j['trainer_id'],
    age: j['age'],
    weightKg: (j['weight_kg'] as num).toDouble(),
    heightCm: (j['height_cm'] as num).toDouble(),
    primaryModality: TrainingModality.values.byName(j['primary_modality']),
    goal: j['goal'],
    restrictions: j['restrictions'],
    level: j['level'],
    isActive: j['is_active'] ?? true,
    hasWearable: j['has_wearable'] ?? false,
    maxHeartRate: j['max_heart_rate'],
    minSpO2: j['min_spo2'] != null ? (j['min_spo2'] as num).toDouble() : null,
    lastTraining: j['last_training'] != null ? DateTime.parse(j['last_training']) : null,
    paymentStatus: PaymentStatus.values.byName(j['payment_status'] ?? 'upToDate'),
  );
}

enum PaymentStatus { upToDate, pending, overdue }

// ─── EXERCISE ────────────────────────────────────────────────────────────────

class Exercise {
  final String id;
  final String name;
  final String? videoUrl;       // vídeo da biblioteca própria
  final String? youtubeUrl;     // link do YouTube
  final String muscleGroup;
  final TrainingModality modality;
  final String? instructions;

  const Exercise({
    required this.id,
    required this.name,
    this.videoUrl,
    this.youtubeUrl,
    required this.muscleGroup,
    required this.modality,
    this.instructions,
  });

  bool get hasVideo => videoUrl != null || youtubeUrl != null;
  bool get isYoutube => youtubeUrl != null;

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
    id: j['id'],
    name: j['name'],
    videoUrl: j['video_url'],
    youtubeUrl: j['youtube_url'],
    muscleGroup: j['muscle_group'],
    modality: TrainingModality.values.byName(j['modality']),
    instructions: j['instructions'],
  );
}

// ─── WORKOUT SET ─────────────────────────────────────────────────────────────

class WorkoutSet {
  final String exerciseId;
  final Exercise exercise;
  final int sets;
  final int reps;
  final double? weightKg;
  final int restSeconds;
  // Para bike/corrida
  final int? durationMinutes;
  final HeartRateZone? targetZone;
  final String? notes;
  bool isCompleted;

  WorkoutSet({
    required this.exerciseId,
    required this.exercise,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.restSeconds = 60,
    this.durationMinutes,
    this.targetZone,
    this.notes,
    this.isCompleted = false,
  });
}

// ─── WORKOUT ─────────────────────────────────────────────────────────────────

class Workout {
  final String id;
  final String studentId;
  final String trainerId;
  final String name;
  final TrainingModality modality;
  final List<WorkoutSet> sets;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isActive;
  final String? aiGenerated; // prompt usado, se gerado por IA

  const Workout({
    required this.id,
    required this.studentId,
    required this.trainerId,
    required this.name,
    required this.modality,
    required this.sets,
    required this.createdAt,
    this.completedAt,
    this.isActive = true,
    this.aiGenerated,
  });

  int get totalExercises => sets.length;
  int get completedExercises => sets.where((s) => s.isCompleted).length;
  double get progressPct => totalExercises == 0 ? 0 : completedExercises / totalExercises;
  bool get isCompleted => completedExercises == totalExercises;
}

// ─── CHECK-IN ────────────────────────────────────────────────────────────────

enum EnergyLevel { exhausted, low, normal, good, great }
enum DiscomfortArea { none, shoulder, knee, lower_back, hip, other }

class PreWorkoutCheckin {
  final String id;
  final String studentId;
  final String workoutId;
  final EnergyLevel energy;
  final List<DiscomfortArea> discomforts;
  final String? notes;
  final DateTime createdAt;

  const PreWorkoutCheckin({
    required this.id,
    required this.studentId,
    required this.workoutId,
    required this.energy,
    required this.discomforts,
    this.notes,
    required this.createdAt,
  });
}

// ─── WEARABLE DATA ───────────────────────────────────────────────────────────

class WearableSnapshot {
  final String studentId;
  final int heartRateBpm;
  final double? spO2Pct;
  final double? hrvMs;
  final double? caloriesBurned;
  final int? stepCount;
  final DateTime timestamp;

  const WearableSnapshot({
    required this.studentId,
    required this.heartRateBpm,
    this.spO2Pct,
    this.hrvMs,
    this.caloriesBurned,
    this.stepCount,
    required this.timestamp,
  });
}

// ─── CHAT ────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final MessageType type;
  final String? linkedExerciseId;
  final String? linkedWorkoutId;
  final DateTime sentAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    this.linkedExerciseId,
    this.linkedWorkoutId,
    required this.sentAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    id: j['id'],
    senderId: j['sender_id'],
    receiverId: j['receiver_id'],
    text: j['text'],
    type: MessageType.values.byName(j['type']),
    linkedExerciseId: j['linked_exercise_id'],
    linkedWorkoutId: j['linked_workout_id'],
    sentAt: DateTime.parse(j['sent_at']),
    isRead: j['is_read'] ?? false,
  );
}

// ─── TRAINING SESSION (AGENDA) ────────────────────────────────────────────────

class TrainingSession {
  final String id;
  final String trainerId;
  final String studentId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String location;
  final SessionStatus status;
  final String? notes;

  const TrainingSession({
    required this.id,
    required this.trainerId,
    required this.studentId,
    required this.scheduledAt,
    this.durationMinutes = 60,
    required this.location,
    this.status = SessionStatus.pending,
    this.notes,
  });
}

// ─── AI GENERATION REQUEST ───────────────────────────────────────────────────

class AIWorkoutRequest {
  final String studentId;
  final String goal;
  final TrainingModality modality;
  final String level;
  final String? restrictions;
  final int sessionsPerWeek;
  final String? additionalNotes;

  const AIWorkoutRequest({
    required this.studentId,
    required this.goal,
    required this.modality,
    required this.level,
    this.restrictions,
    this.sessionsPerWeek = 3,
    this.additionalNotes,
  });

  String toPrompt(String studentName) {
    return '''
Você é um assistente especializado em prescrição de treinos para personal trainers.
Gere um treino completo para o aluno abaixo.

ALUNO: $studentName
OBJETIVO: $goal
MODALIDADE: ${modality.name}
NÍVEL: $level
RESTRIÇÕES: ${restrictions ?? 'Nenhuma'}
SESSÕES POR SEMANA: $sessionsPerWeek
OBSERVAÇÕES: ${additionalNotes ?? 'Nenhuma'}

Responda APENAS em JSON válido, sem texto antes ou depois, no formato:
{
  "workout_name": "Nome do treino",
  "modality": "${modality.name}",
  "sets": [
    {
      "exercise_name": "Nome do exercício",
      "muscle_group": "Grupo muscular",
      "sets": 3,
      "reps": 12,
      "rest_seconds": 60,
      "notes": "Observação opcional"
    }
  ],
  "trainer_notes": "Orientações gerais para o treinador revisar"
}
''';
  }
}

// ─── DASHBOARD STATS ─────────────────────────────────────────────────────────

class TrainerDashboard {
  final int totalActiveStudents;
  final int studentsWithoutWorkout;
  final int pendingPayments;
  final int renewalsToday;
  final List<RecentActivity> recentActivity;

  const TrainerDashboard({
    required this.totalActiveStudents,
    required this.studentsWithoutWorkout,
    required this.pendingPayments,
    required this.renewalsToday,
    required this.recentActivity,
  });
}

class RecentActivity {
  final String studentId;
  final String studentName;
  final String description;
  final ActivityType type;
  final DateTime at;

  const RecentActivity({
    required this.studentId,
    required this.studentName,
    required this.description,
    required this.type,
    required this.at,
  });
}

enum ActivityType { workoutCompleted, inactive, paymentOverdue, newMessage }

// ─── ANAMNESE ────────────────────────────────────────────────────────────────

enum BiologicalSex { male, female, other }
enum StressLevel { low, moderate, high, veryHigh }
enum SmokingStatus { never, former, current }
enum WorkType { sedentary, light, moderate, active }

enum MedicalCondition {
  hypertension, diabetes, heartDisease, asthma,
  depression, anxiety, osteoporosis, arthritis, other
}

class StudentAnamnese {
  final String studentId;
  // Identificação
  final DateTime? birthDate;
  final BiologicalSex? sex;
  final String? profession;
  final String? emergencyContact;
  // Saúde
  final List<MedicalCondition> conditions;
  final String? medications;
  final bool hasSurgery;
  final String? surgeryDetails;
  // PAR-Q (7 perguntas)
  final List<bool> parqAnswers; // 7 respostas — true = sim (atenção)
  // Estilo de vida
  final int? sleepHours;
  final StressLevel? stressLevel;
  final SmokingStatus? smoking;
  final int? alcoholDaysPerWeek;
  final WorkType? workType;
  // Histórico físico
  final bool hasPriorExperience;
  final int? priorExperienceYears;
  final List<TrainingModality> previousActivities;
  final String? injuries;
  // Objetivos
  final String? primaryGoal;
  final String? secondaryGoal;
  final String? timeFrame;
  final List<String> availableDays;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const StudentAnamnese({
    required this.studentId,
    this.birthDate,
    this.sex,
    this.profession,
    this.emergencyContact,
    this.conditions = const [],
    this.medications,
    this.hasSurgery = false,
    this.surgeryDetails,
    this.parqAnswers = const [false, false, false, false, false, false, false],
    this.sleepHours,
    this.stressLevel,
    this.smoking,
    this.alcoholDaysPerWeek,
    this.workType,
    this.hasPriorExperience = false,
    this.priorExperienceYears,
    this.previousActivities = const [],
    this.injuries,
    this.primaryGoal,
    this.secondaryGoal,
    this.timeFrame,
    this.availableDays = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool get hasAlert => parqAnswers.any((a) => a) || conditions.isNotEmpty;
}

// ─── BODY MEASUREMENT ────────────────────────────────────────────────────────

class BodyMeasurement {
  final String studentId;
  final DateTime date;
  final double weightKg;
  final double? bodyFatPct;
  final double? waistCm;
  final double? hipCm;
  final double? chestCm;
  final double? armCm;
  final double? thighCm;

  const BodyMeasurement({
    required this.studentId,
    required this.date,
    required this.weightKg,
    this.bodyFatPct,
    this.waistCm,
    this.hipCm,
    this.chestCm,
    this.armCm,
    this.thighCm,
  });

  double? bmi(double heightCm) => weightKg / ((heightCm / 100) * (heightCm / 100));
}

// ─── NOTIFICATION ────────────────────────────────────────────────────────────

enum AppNotificationType { workoutReady, payment, message, heartRate, achievement }

class AppNotification {
  final String id;
  final String userId;
  final AppNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? actionRoute;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.actionRoute,
  });
}
