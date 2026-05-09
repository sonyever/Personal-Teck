import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

const supabaseUrl = 'https://vjstnjnxyfbjvazhkdlo.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqc3Ruam54eWZianZhemhrZGxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgzMzU3ODgsImV4cCI6MjA5MzkxMTc4OH0.mt89v8-yxcEoA-5hVy7Xlws6fuA3uEYAbZoiFQrNXUE';

SupabaseClient get supabase => Supabase.instance.client;

class AuthService {
  static Future<void> initialize() => Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );

  static Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role.name},
    );
    if (res.user != null) {
      await supabase.from('profiles').upsert({
        'id': res.user!.id,
        'name': name,
        'email': email,
        'role': role.name,
      });
    }
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() => supabase.auth.signOut();

  static User? get currentUser => supabase.auth.currentUser;
  static Session? get currentSession => supabase.auth.currentSession;

  static UserRole? get currentRole {
    final r = currentUser?.userMetadata?['role'] as String?;
    if (r == null) return null;
    try {
      return UserRole.values.byName(r);
    } catch (_) {
      return null;
    }
  }

  static String get currentName =>
      (currentUser?.userMetadata?['name'] as String?) ?? 'Usuário';
}
