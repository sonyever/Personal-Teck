import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../screens/shared/login_screen.dart';
import '../screens/shared/splash_screen.dart';
import '../screens/trainer/trainer_shell.dart';
import '../screens/trainer/dashboard_screen.dart';
import '../screens/trainer/students_screen.dart';
import '../screens/trainer/student_detail_screen.dart';
import '../screens/trainer/new_workout_screen.dart';
import '../screens/trainer/trainer_workout_library_screen.dart';
import '../screens/trainer/ai_workout_screen.dart';
import '../screens/trainer/trainer_chat_screen.dart';
import '../screens/trainer/agenda_screen.dart';
import '../screens/trainer/wearable_live_screen.dart';
import '../screens/trainer/financial_screen.dart';
import '../screens/shared/anamnese_screen.dart';
import '../screens/shared/notifications_screen.dart';
import '../screens/shared/profile_screen.dart';
import '../screens/student/student_shell.dart';
import '../screens/student/checkin_screen.dart';
import '../screens/student/today_workout_screen.dart';
import '../screens/student/exercise_execution_screen.dart';
import '../screens/student/student_chat_screen.dart';
import '../screens/student/progress_screen.dart';
import '../screens/student/community_screen.dart';
import '../screens/student/measurements_screen.dart';
import '../screens/student/workout_history_screen.dart';
import '../screens/nutritionist/nutritionist_shell.dart';
import '../screens/nutritionist/nutritionist_dashboard_screen.dart';
import '../screens/nutritionist/nutritionist_patients_screen.dart';
import '../screens/nutritionist/nutritionist_patient_detail_screen.dart';

// Simula autenticação — substituir por serviço real
UserRole? _currentRole;

final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final isAuth = _currentRole != null;
    final loc = state.matchedLocation;
    final onAuth = loc == '/login' || loc == '/splash';
    if (!isAuth && !onAuth) return '/login';
    if (isAuth && onAuth) {
      return switch (_currentRole!) {
        UserRole.trainer      => '/trainer/dashboard',
        UserRole.student      => '/student/workout',
        UserRole.nutritionist => '/nutritionist/dashboard',
      };
    }
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),

    // ── TREINADOR ──────────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => TrainerShell(child: child),
      routes: [
        GoRoute(path: '/trainer', redirect: (_, __) => '/trainer/dashboard'),
        GoRoute(path: '/trainer/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/trainer/workouts', builder: (_, __) => const TrainerWorkoutLibraryScreen()),
        GoRoute(path: '/trainer/workouts/new', builder: (_, __) => const NewWorkoutScreen()),
        GoRoute(path: '/trainer/students', builder: (_, __) => const StudentsScreen()),
        GoRoute(
          path: '/trainer/students/:id',
          builder: (_, state) => StudentDetailScreen(studentId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/trainer/students/:id/new-workout',
          builder: (_, state) => NewWorkoutScreen(studentId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/trainer/students/:id/ai-workout',
          builder: (_, state) => AIWorkoutScreen(studentId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/trainer/chat', builder: (_, __) => const TrainerChatScreen()),
        GoRoute(path: '/trainer/agenda', builder: (_, __) => const AgendaScreen()),
        GoRoute(path: '/trainer/wearable-live', builder: (_, __) => const WearableLiveScreen()),
        GoRoute(path: '/trainer/financial', builder: (_, __) => const FinancialScreen()),
        GoRoute(path: '/trainer/students/:id/anamnese', builder: (_, state) => AnamneseScreen(studentId: state.pathParameters['id']!, readOnly: true)),
        GoRoute(path: '/trainer/profile', builder: (_, __) => const ProfileScreen(role: UserRole.trainer)),
      ],
    ),

    // ── NUTRICIONISTA ──────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => NutritionistShell(child: child),
      routes: [
        GoRoute(path: '/nutritionist', redirect: (_, __) => '/nutritionist/dashboard'),
        GoRoute(path: '/nutritionist/dashboard', builder: (_, __) => const NutritionistDashboardScreen()),
        GoRoute(path: '/nutritionist/patients',  builder: (_, __) => const NutritionistPatientsScreen()),
        GoRoute(
          path: '/nutritionist/patients/:id',
          builder: (_, state) => NutritionistPatientDetailScreen(patientId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/nutritionist/chat', builder: (_, __) => const TrainerChatScreen()),
        GoRoute(path: '/nutritionist/profile', builder: (_, __) => const ProfileScreen(role: UserRole.nutritionist)),
      ],
    ),

    // ── ALUNO ──────────────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => StudentShell(child: child),
      routes: [
        GoRoute(path: '/student', redirect: (_, __) => '/student/workout'),
        GoRoute(
          path: '/student/checkin/:workoutId',
          builder: (_, state) => CheckinScreen(workoutId: state.pathParameters['workoutId']!),
        ),
        GoRoute(path: '/student/workout', builder: (_, __) => const TodayWorkoutScreen()),
        GoRoute(
          path: '/student/workout/execute/:setIndex',
          builder: (_, state) => ExerciseExecutionScreen(
            setIndex: int.parse(state.pathParameters['setIndex']!),
          ),
        ),
        GoRoute(path: '/student/chat', builder: (_, __) => const StudentChatScreen()),
        GoRoute(path: '/student/progress', builder: (_, __) => const ProgressScreen()),
        GoRoute(path: '/student/community', builder: (_, __) => const CommunityScreen()),
        GoRoute(path: '/student/measurements', builder: (_, __) => const MeasurementsScreen()),
        GoRoute(path: '/student/workout-history', builder: (_, __) => const WorkoutHistoryScreen()),
        GoRoute(path: '/student/anamnese', builder: (_, __) => AnamneseScreen(studentId: 'student-1')),
        GoRoute(path: '/student/profile', builder: (_, __) => const ProfileScreen(role: UserRole.student)),
      ],
    ),
  ],
);

void setCurrentRole(UserRole? role) {
  _currentRole = role;
}
