import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/theme.dart';
import '../../widgets/pt_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PTColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Evolução', style: t.headlineMedium),
              Text('Últimos 30 dias', style: t.bodySmall),
              const SizedBox(height: 12),
            ]),
          ),

          // Stats rápidos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: _MiniStat(value: '18', label: 'Treinos', color: PTColors.primary600)),
              const SizedBox(width: 8),
              Expanded(child: _MiniStat(value: '87%', label: 'Presença', color: PTColors.teal400)),
              const SizedBox(width: 8),
              Expanded(child: _MiniStat(value: '4.2kg', label: 'Ganho', color: PTColors.primary400)),
              const SizedBox(width: 8),
              Expanded(child: _MiniStat(value: '12.4h', label: 'Tempo total', color: PTColors.gray400)),
            ]),
          ),

          const SizedBox(height: 16),

          TabBar(
            controller: _tabCtrl,
            labelColor: PTColors.primary600,
            unselectedLabelColor: PTColors.gray400,
            indicatorColor: PTColors.primary600,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Treinos'),
              Tab(text: 'Carga'),
              Tab(text: 'Frequência'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _WorkoutsTab(),
                _LoadTab(),
                _HRTab(),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _WorkoutsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final data = [3.0, 4.0, 3.0, 5.0, 4.0, 3.0, 4.0];
    final days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PTCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Treinos por semana', style: t.titleSmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 6,
                barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [BarChartRodData(
                    toY: e.value,
                    color: PTColors.primary600,
                    width: 22,
                    borderRadius: BorderRadius.circular(4),
                  )],
                )).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Text(days[v.toInt()], style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
                  )),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              )),
            ),
          ]),
        ),

        const SizedBox(height: 16),
        Text('Histórico recente', style: t.titleMedium),
        const SizedBox(height: 10),

        ..._history.map((h) => PTCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: PTColors.teal50, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.check, color: PTColors.teal400, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.name, style: t.titleSmall),
              Text(h.subtitle, style: t.bodySmall),
            ])),
            Text(h.date, style: t.bodySmall),
          ]),
        )),
      ]),
    );
  }

  List<({String name, String subtitle, String date})> get _history => [
    (name: 'Treino B — Costas', subtitle: '6 exercícios · 58 min', date: 'Hoje'),
    (name: 'Treino A — Peito', subtitle: '5 exercícios · 50 min', date: 'Ontem'),
    (name: 'Treino C — Pernas', subtitle: '7 exercícios · 65 min', date: 'Há 3d'),
    (name: 'Treino A — Peito', subtitle: '5 exercícios · 48 min', date: 'Há 4d'),
  ];
}

class _LoadTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final spots = [30.0, 32.5, 32.5, 35.0, 35.0, 37.5, 40.0];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PTCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Remada curvada — carga (kg)', style: t.titleSmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: LineChart(LineChartData(
                lineBarsData: [LineChartBarData(
                  spots: spots.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                  isCurved: true,
                  color: PTColors.teal400,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: PTColors.teal400.withValues(alpha: 0.1)),
                )],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: PTColors.gray400)),
                  )),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: PTColors.border, strokeWidth: 0.5)),
                borderData: FlBorderData(show: false),
              )),
            ),
          ]),
        ),

        const SizedBox(height: 16),
        Text('Progressão por exercício', style: t.titleMedium),
        const SizedBox(height: 10),

        ..._exercises.map((e) => PTCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.name, style: t.titleSmall),
              Text(e.muscle, style: t.bodySmall),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${e.current} kg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: PTColors.primary600)),
              Text('+${e.gain} kg (30d)', style: const TextStyle(fontSize: 11, color: PTColors.teal400)),
            ]),
          ]),
        )),
      ]),
    );
  }

  List<({String name, String muscle, double current, double gain})> get _exercises => [
    (name: 'Remada curvada', muscle: 'Costas', current: 40.0, gain: 5.0),
    (name: 'Supino reto', muscle: 'Peito', current: 70.0, gain: 10.0),
    (name: 'Agachamento', muscle: 'Pernas', current: 100.0, gain: 15.0),
    (name: 'Rosca direta', muscle: 'Bíceps', current: 20.0, gain: 2.5),
  ];
}

class _HRTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PTCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Zonas de FC — últimos treinos', style: t.titleSmall),
            const SizedBox(height: 16),
            ..._zones.map((z) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: z.color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(z.label, style: const TextStyle(fontSize: 13, color: PTColors.gray600))),
                  Text('${z.pct}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: z.pct / 100,
                    minHeight: 8,
                    backgroundColor: PTColors.gray100,
                    valueColor: AlwaysStoppedAnimation(z.color),
                  ),
                ),
              ]),
            )),
          ]),
        ),

        const SizedBox(height: 16),
        PTCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('FC média por treino', style: t.titleSmall),
            const SizedBox(height: 6),
            Row(children: [
              Text('138', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: PTColors.teal400)),
              const SizedBox(width: 8),
              const Text('bpm\nmédia', style: TextStyle(fontSize: 12, color: PTColors.gray400)),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('172 bpm', style: t.bodySmall),
                Text('FC máxima', style: TextStyle(fontSize: 10, color: PTColors.gray400)),
                const SizedBox(height: 4),
                Text('98 bpm', style: t.bodySmall),
                Text('FC mínima', style: TextStyle(fontSize: 10, color: PTColors.gray400)),
              ]),
            ]),
          ]),
        ),
      ]),
    );
  }

  List<({String label, Color color, int pct})> get _zones => [
    (label: 'Repouso (< 50%)', color: const Color(0xFF85B7EB), pct: 5),
    (label: 'Leve (50–60%)', color: const Color(0xFF9FE1CB), pct: 10),
    (label: 'Moderada (61–70%)', color: const Color(0xFF5DCAA5), pct: 20),
    (label: 'Aeróbica (71–85%)', color: const Color(0xFF1D9E75), pct: 45),
    (label: 'Anaeróbica (86–95%)', color: const Color(0xFFEF9F27), pct: 15),
    (label: 'Máxima (> 95%)', color: const Color(0xFFE24B4A), pct: 5),
  ];
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _MiniStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    decoration: BoxDecoration(color: PTColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: PTColors.border, width: 0.5)),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: PTColors.gray400)),
    ]),
  );
}
