import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../services/wearable_service.dart';
import '../../widgets/pt_card.dart';
import '../../widgets/avatar_circle.dart';

class WearableLiveScreen extends StatefulWidget {
  const WearableLiveScreen({super.key});

  @override
  State<WearableLiveScreen> createState() => _WearableLiveScreenState();
}

class _WearableLiveScreenState extends State<WearableLiveScreen> {
  final _wearable = WearableService();
  final Map<String, int> _bpm = {};
  final Map<String, HeartRateZone> _zones = {};
  StreamSubscription? _sub;

  final List<_LiveStudent> _students = [
    _LiveStudent('1', 'Rafael Alves', 30, 80),
    _LiveStudent('2', 'Marina Costa', 25, 65),
    _LiveStudent('3', 'Thiago Silva', 35, 90),
    _LiveStudent('4', 'Julia Santos', 28, 72),
  ];

  @override
  void initState() {
    super.initState();
    for (final s in _students) {
      _bpm[s.id] = s.baseHR;
      final profile = StudentProfile(
        userId: s.id, trainerId: 't1', age: s.age,
        weightKg: s.weight, heightCm: 175,
        primaryModality: TrainingModality.strength,
        goal: 'Treino', level: 'Intermediário',
      );
      _zones[s.id] = profile.zoneForBpm(s.baseHR);
    }
    _wearable.startSimulation('1', baseHR: 130);
    _sub = _wearable.snapshots.listen((snap) {
      if (!mounted) return;
      setState(() {
        _bpm[snap.studentId] = snap.heartRateBpm;
        final profile = StudentProfile(
          userId: snap.studentId, trainerId: 't1', age: 30,
          weightKg: 80, heightCm: 175,
          primaryModality: TrainingModality.strength,
          goal: 'Treino', level: 'Intermediário',
        );
        _zones[snap.studentId] = profile.zoneForBpm(snap.heartRateBpm);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _wearable.stopSimulation();
    _wearable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Row(children: [
          const Text('Alunos ao vivo'),
          const SizedBox(width: 8),
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: PTColors.teal400, shape: BoxShape.circle),
          ),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text('${_students.length} monitorados', style: t.bodySmall)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _students.length,
        itemBuilder: (_, i) {
          final s = _students[i];
          final bpm = _bpm[s.id] ?? s.baseHR;
          final zone = _zones[s.id] ?? HeartRateZone.moderate;
          final zoneInfo = WearableService.zoneInfo(zone);
          final isAlert = zone == HeartRateZone.maximum || zone == HeartRateZone.anaerobic;

          return PTCard(
            margin: const EdgeInsets.only(bottom: 10),
            color: isAlert ? Color(0xFFFCEBEB) : PTColors.surface,
            child: Row(children: [
              AvatarCircle(name: s.name, size: 44),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: t.titleSmall),
                const SizedBox(height: 2),
                Text(zoneInfo.label, style: TextStyle(fontSize: 12, color: Color(zoneInfo.darkColor))),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(children: [
                  Icon(
                    isAlert ? Icons.favorite : Icons.favorite_border,
                    color: Color(zoneInfo.darkColor), size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text('$bpm', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(zoneInfo.darkColor))),
                  const SizedBox(width: 2),
                  Text('bpm', style: TextStyle(fontSize: 12, color: Color(zoneInfo.darkColor))),
                ]),
                const SizedBox(height: 4),
                Container(
                  width: 100,
                  height: 6,
                  decoration: BoxDecoration(color: PTColors.gray100, borderRadius: BorderRadius.circular(99)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (bpm / 200).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(zoneInfo.color),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ]),
            ]),
          );
        },
      ),
    );
  }
}

class _LiveStudent {
  final String id, name;
  final int age, baseHR;
  final double weight;
  _LiveStudent(this.id, this.name, this.age, this.baseHR) : weight = 75.0;
}
