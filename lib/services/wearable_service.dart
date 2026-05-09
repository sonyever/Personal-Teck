import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class WearableService {
  // Stream de dados do wearable em tempo real
  final _snapshotController = StreamController<WearableSnapshot>.broadcast();
  Stream<WearableSnapshot> get snapshots => _snapshotController.stream;

  // Alunos monitorados ativamente
  final Map<String, StudentProfile> _monitoredStudents = {};
  Timer? _simulationTimer;

  // Callbacks de alerta
  final List<Function(String studentName, int bpm, AlertLevel level)> _alertCallbacks = [];

  void addAlertCallback(Function(String studentName, int bpm, AlertLevel level) cb) {
    _alertCallbacks.add(cb);
  }

  // ── Iniciar monitoramento ──────────────────────────────────────────────────

  void startMonitoring(StudentProfile profile) {
    _monitoredStudents[profile.userId] = profile;
    debugPrint('[Wearable] Iniciando monitoramento: ${profile.userId}');
  }

  void stopMonitoring(String studentId) {
    _monitoredStudents.remove(studentId);
  }

  // ── Processar dado recebido (BLE / API) ───────────────────────────────────

  void processIncomingData(WearableSnapshot snapshot) {
    _snapshotController.add(snapshot);
    _checkAlerts(snapshot);
  }

  void _checkAlerts(WearableSnapshot snapshot) {
    final profile = _monitoredStudents[snapshot.studentId];
    if (profile == null) return;

    final level = profile.alertForBpm(snapshot.heartRateBpm);
    if (level != AlertLevel.none) {
      for (final cb in _alertCallbacks) {
        cb('Aluno', snapshot.heartRateBpm, level);
      }
    }

    // Verificar SpO2
    if (profile.minSpO2 != null && snapshot.spO2Pct != null) {
      if (snapshot.spO2Pct! < profile.minSpO2!) {
        for (final cb in _alertCallbacks) {
          cb('Aluno', snapshot.heartRateBpm, AlertLevel.critical);
        }
      }
    }
  }

  // ── Zonas de FC ───────────────────────────────────────────────────────────

  static HeartRateZoneInfo zoneInfo(HeartRateZone zone) {
    switch (zone) {
      case HeartRateZone.rest:
        return HeartRateZoneInfo(zone, 'Repouso', '< 50%', 0xFF85B7EB, 0xFF378ADD);
      case HeartRateZone.light:
        return HeartRateZoneInfo(zone, 'Leve', '50–60%', 0xFF9FE1CB, 0xFF1D9E75);
      case HeartRateZone.moderate:
        return HeartRateZoneInfo(zone, 'Moderada', '61–70%', 0xFF5DCAA5, 0xFF0F6E56);
      case HeartRateZone.aerobic:
        return HeartRateZoneInfo(zone, 'Aeróbica — ideal', '71–85%', 0xFF1D9E75, 0xFF085041);
      case HeartRateZone.anaerobic:
        return HeartRateZoneInfo(zone, 'Anaeróbica', '86–95%', 0xFFEF9F27, 0xFF633806);
      case HeartRateZone.maximum:
        return HeartRateZoneInfo(zone, 'Zona máxima', '> 95%', 0xFFE24B4A, 0xFFA32D2D);
    }
  }

  // ── Simulação para desenvolvimento ───────────────────────────────────────

  void startSimulation(String studentId, {int baseHR = 130}) {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final variation = (Random().nextDouble() * 20 - 10).round();
      final bpm = (baseHR + variation).clamp(50, 210);
      processIncomingData(WearableSnapshot(
        studentId: studentId,
        heartRateBpm: bpm,
        spO2Pct: 96.0 + Random().nextDouble() * 3,
        caloriesBurned: 250 + Random().nextDouble() * 100,
        timestamp: DateTime.now(),
      ));
    });
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
  }

  void dispose() {
    _simulationTimer?.cancel();
    _snapshotController.close();
  }
}

class HeartRateZoneInfo {
  final HeartRateZone zone;
  final String label;
  final String range;
  final int color;
  final int darkColor;

  const HeartRateZoneInfo(this.zone, this.label, this.range, this.color, this.darkColor);
}
