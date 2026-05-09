import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../widgets/pt_card.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final List<BodyMeasurement> _history = [
    BodyMeasurement(studentId: 's1', date: DateTime.now().subtract(const Duration(days: 90)), weightKg: 82.0, bodyFatPct: 24.0, waistCm: 88, hipCm: 100, chestCm: 96, armCm: 34, thighCm: 58),
    BodyMeasurement(studentId: 's1', date: DateTime.now().subtract(const Duration(days: 60)), weightKg: 80.5, bodyFatPct: 22.5, waistCm: 86, hipCm: 99, chestCm: 97, armCm: 35, thighCm: 59),
    BodyMeasurement(studentId: 's1', date: DateTime.now().subtract(const Duration(days: 30)), weightKg: 78.0, bodyFatPct: 20.5, waistCm: 83, hipCm: 98, chestCm: 98, armCm: 36, thighCm: 60),
    BodyMeasurement(studentId: 's1', date: DateTime.now(), weightKg: 75.5, bodyFatPct: 18.5, waistCm: 80, hipCm: 97, chestCm: 100, armCm: 37, thighCm: 62),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final latest = _history.last;
    final oldest = _history.first;

    double _delta(double? now, double? before) => (now ?? 0) - (before ?? 0);

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Medidas corporais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nova medição',
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Resumo atual
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [PTColors.teal800, PTColors.teal400], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Última medição', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 6),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${latest.weightKg}', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700, color: Colors.white)),
                const Padding(padding: EdgeInsets.only(bottom: 6, left: 4), child: Text('kg', style: TextStyle(fontSize: 16, color: Colors.white70))),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if (latest.bmi(178) != null)
                    Text('IMC ${latest.bmi(178)!.toStringAsFixed(1)}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  if (latest.bodyFatPct != null)
                    Text('${latest.bodyFatPct}% gordura', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                ]),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _DeltaChip(label: 'Peso', delta: _delta(latest.weightKg, oldest.weightKg), unit: 'kg', reverse: true),
                const SizedBox(width: 8),
                if (latest.bodyFatPct != null && oldest.bodyFatPct != null)
                  _DeltaChip(label: 'Gordura', delta: _delta(latest.bodyFatPct, oldest.bodyFatPct), unit: '%', reverse: true),
                const SizedBox(width: 8),
                if (latest.armCm != null && oldest.armCm != null)
                  _DeltaChip(label: 'Braço', delta: _delta(latest.armCm, oldest.armCm), unit: 'cm', reverse: false),
              ]),
            ]),
          ),

          const SizedBox(height: 20),

          // Gráfico de peso
          Text('Evolução do peso', style: t.titleMedium),
          const SizedBox(height: 10),
          PTCard(
            child: SizedBox(
              height: 150,
              child: LineChart(LineChartData(
                lineBarsData: [LineChartBarData(
                  spots: _history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weightKg)).toList(),
                  isCurved: true,
                  color: PTColors.teal400,
                  barWidth: 2.5,
                  dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: PTColors.teal400, strokeWidth: 0)),
                  belowBarData: BarAreaData(show: true, color: PTColors.teal400.withValues(alpha: 0.08)),
                )],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true, reservedSize: 36,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}kg', style: const TextStyle(fontSize: 10, color: PTColors.gray400)),
                  )),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      const labels = ['90d', '60d', '30d', 'Hoje'];
                      return Text(labels[v.toInt()], style: const TextStyle(fontSize: 10, color: PTColors.gray400));
                    },
                  )),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: PTColors.border, strokeWidth: 0.5)),
                borderData: FlBorderData(show: false),
                minY: 72,
              )),
            ),
          ),

          const SizedBox(height: 20),

          // Medidas detalhadas
          Text('Medidas atuais', style: t.titleMedium),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              if (latest.waistCm != null)  _MeasureCard(label: 'Cintura', value: '${latest.waistCm!.toInt()} cm', delta: _delta(latest.waistCm, oldest.waistCm), reverse: true),
              if (latest.hipCm != null)    _MeasureCard(label: 'Quadril', value: '${latest.hipCm!.toInt()} cm', delta: _delta(latest.hipCm, oldest.hipCm), reverse: true),
              if (latest.chestCm != null)  _MeasureCard(label: 'Peitoral', value: '${latest.chestCm!.toInt()} cm', delta: _delta(latest.chestCm, oldest.chestCm), reverse: false),
              if (latest.armCm != null)    _MeasureCard(label: 'Braço', value: '${latest.armCm!.toInt()} cm', delta: _delta(latest.armCm, oldest.armCm), reverse: false),
              if (latest.thighCm != null)  _MeasureCard(label: 'Coxa', value: '${latest.thighCm!.toInt()} cm', delta: _delta(latest.thighCm, oldest.thighCm), reverse: false),
              if (latest.bodyFatPct != null) _MeasureCard(label: '% Gordura', value: '${latest.bodyFatPct}%', delta: _delta(latest.bodyFatPct, oldest.bodyFatPct), reverse: true),
            ],
          ),

          const SizedBox(height: 20),

          // Histórico
          Text('Histórico', style: t.titleMedium),
          const SizedBox(height: 10),
          ..._history.reversed.map((m) => PTCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: PTColors.teal50, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.monitor_weight_outlined, color: PTColors.teal400, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${m.weightKg} kg', style: t.titleSmall),
                Text(_formatDate(m.date), style: t.bodySmall),
              ])),
              if (m.bodyFatPct != null)
                Text('${m.bodyFatPct}% gordura', style: t.bodySmall),
            ]),
          )),

          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const meses = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return '${d.day.toString().padLeft(2, '0')} ${meses[d.month - 1]} ${d.year}';
  }

  void _showAddSheet(BuildContext context) {
    final weightCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    final waistCtrl = TextEditingController();
    final armCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PTColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nova medição', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Peso (kg)'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: fatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '% Gordura'))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: waistCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cintura (cm)'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: armCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Braço (cm)'))),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: PTColors.teal400),
              onPressed: () {
                final w = double.tryParse(weightCtrl.text);
                if (w != null) {
                  setState(() => _history.add(BodyMeasurement(
                    studentId: 's1', date: DateTime.now(), weightKg: w,
                    bodyFatPct: double.tryParse(fatCtrl.text),
                    waistCm: double.tryParse(waistCtrl.text),
                    armCm: double.tryParse(armCtrl.text),
                  )));
                }
                Navigator.pop(context);
              },
              child: const Text('Salvar medição', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final String label, unit;
  final double delta;
  final bool reverse;
  const _DeltaChip({required this.label, required this.delta, required this.unit, required this.reverse});

  @override
  Widget build(BuildContext context) {
    final isGood = reverse ? delta <= 0 : delta >= 0;
    final color = isGood ? PTColors.teal200 : PTColors.red200;
    final sign = delta >= 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(99)),
      child: Text('$label $sign${delta.toStringAsFixed(1)}$unit', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _MeasureCard extends StatelessWidget {
  final String label, value;
  final double delta;
  final bool reverse;
  const _MeasureCard({required this.label, required this.value, required this.delta, required this.reverse});

  @override
  Widget build(BuildContext context) {
    final isGood = reverse ? delta <= 0 : delta >= 0;
    final sign = delta >= 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: PTColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: PTColors.border, width: 0.5)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PTColors.gray900)),
        ])),
        Text('$sign${delta.toStringAsFixed(1)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isGood ? PTColors.teal400 : PTColors.red400)),
      ]),
    );
  }
}
