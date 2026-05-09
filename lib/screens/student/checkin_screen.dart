import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';

class CheckinScreen extends StatefulWidget {
  final String workoutId;
  const CheckinScreen({super.key, required this.workoutId});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  EnergyLevel _energy = EnergyLevel.good;
  final Set<DiscomfortArea> _discomforts = {};
  final _notesCtrl = TextEditingController();

  final _energyLabels = {
    EnergyLevel.exhausted: ('Exausto', Icons.battery_0_bar, PTColors.red400),
    EnergyLevel.low: ('Cansado', Icons.battery_2_bar, PTColors.amber400),
    EnergyLevel.normal: ('Normal', Icons.battery_4_bar, PTColors.gray400),
    EnergyLevel.good: ('Bem', Icons.battery_full, PTColors.teal400),
    EnergyLevel.great: ('Ótimo!', Icons.bolt, PTColors.primary600),
  };

  final _discomfortLabels = {
    DiscomfortArea.none: 'Nenhuma',
    DiscomfortArea.shoulder: 'Ombro',
    DiscomfortArea.knee: 'Joelho',
    DiscomfortArea.lower_back: 'Lombar',
    DiscomfortArea.hip: 'Quadril',
    DiscomfortArea.other: 'Outro',
  };

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: const Text('Check-in pré-treino'),
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text('Como você está hoje?', style: t.headlineSmall),
              const SizedBox(height: 4),
              Text('Isso ajuda seu treinador a ajustar o treino.', style: t.bodySmall),

              const SizedBox(height: 20),

              // Nível de energia
              Text('Nível de energia', style: t.titleMedium),
              const SizedBox(height: 12),
              Row(children: EnergyLevel.values.map((level) {
                final (label, icon, color) = _energyLabels[level]!;
                final sel = _energy == level;
                return Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => setState(() => _energy = level),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? color.withValues(alpha: 0.12) : PTColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sel ? color : PTColors.border, width: sel ? 1.5 : 0.5),
                      ),
                      child: Column(children: [
                        Icon(icon, color: sel ? color : PTColors.gray400, size: 22),
                        const SizedBox(height: 4),
                        Text(label, style: TextStyle(fontSize: 10, color: sel ? color : PTColors.gray400, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                      ]),
                    ),
                  ),
                ));
              }).toList()),

              const SizedBox(height: 24),

              // Desconfortos
              Text('Algum desconforto?', style: t.titleMedium),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: _discomfortLabels.entries.map((e) {
                final sel = e.key == DiscomfortArea.none
                    ? _discomforts.isEmpty
                    : _discomforts.contains(e.key);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (e.key == DiscomfortArea.none) {
                      _discomforts.clear();
                    } else {
                      _discomforts.contains(e.key) ? _discomforts.remove(e.key) : _discomforts.add(e.key);
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? PTColors.primary50 : PTColors.surface,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: sel ? PTColors.primary200 : PTColors.border, width: 0.5),
                    ),
                    child: Text(e.value, style: TextStyle(
                      fontSize: 13,
                      color: sel ? PTColors.primary600 : PTColors.gray600,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    )),
                  ),
                );
              }).toList()),

              const SizedBox(height: 20),

              // Observações
              TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  hintText: 'Ex: dormi mal, dor muscular...',
                  prefixIcon: Icon(Icons.note_outlined, size: 20),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 80),
            ]),
          ),
        ),

        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          decoration: const BoxDecoration(
            color: PTColors.surface,
            border: Border(top: BorderSide(color: PTColors.border, width: 0.5)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: PTColors.teal400),
              onPressed: () => context.pop(true),
              icon: const Icon(Icons.fitness_center, color: Colors.white),
              label: const Text('Iniciar treino', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ]),
    );
  }
}
