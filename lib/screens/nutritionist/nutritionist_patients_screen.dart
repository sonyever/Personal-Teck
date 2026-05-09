import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../widgets/pt_card.dart';
import '../../widgets/avatar_circle.dart';

class NutritionistPatientsScreen extends StatefulWidget {
  const NutritionistPatientsScreen({super.key});

  @override
  State<NutritionistPatientsScreen> createState() => _NutritionistPatientsScreenState();
}

class _NutritionistPatientsScreenState extends State<NutritionistPatientsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _NutritionStatus? _filter;

  final _patients = [
    _PatientMock('1', 'Rafael Alves',    'Hipertrofia',     'Carlos Ferreira', _NutritionStatus.upToDate,  DateTime.now().subtract(const Duration(days: 2))),
    _PatientMock('2', 'Marina Costa',    'Emagrecimento',   'Carlos Ferreira', _NutritionStatus.pending,   DateTime.now().subtract(const Duration(days: 10))),
    _PatientMock('3', 'Thiago Silva',    'Condicionamento', 'Carlos Ferreira', _NutritionStatus.upToDate,  DateTime.now().subtract(const Duration(days: 1))),
    _PatientMock('4', 'Julia Santos',    'Hipertrofia',     'Carlos Ferreira', _NutritionStatus.upToDate,  DateTime.now().subtract(const Duration(hours: 3))),
    _PatientMock('5', 'Carlos Mendes',   'Resistência',     'Carlos Ferreira', _NutritionStatus.pending,   DateTime.now().subtract(const Duration(days: 14))),
    _PatientMock('6', 'Ana Paula Rocha', 'Reabilitação',    'Carlos Ferreira', _NutritionStatus.pending,   DateTime.now().subtract(const Duration(days: 7))),
    _PatientMock('7', 'Beatriz Lima',    'Emagrecimento',   'Carlos Ferreira', _NutritionStatus.upToDate,  DateTime.now().subtract(const Duration(days: 3))),
    _PatientMock('8', 'Lucas Pereira',   'Hipertrofia',     'Carlos Ferreira', _NutritionStatus.upToDate,  DateTime.now().subtract(const Duration(hours: 8))),
  ];

  List<_PatientMock> get _filtered => _patients.where((p) {
    final matchQuery = _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());
    final matchFilter = _filter == null || p.status == _filter;
    return matchQuery && matchFilter;
  }).toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        title: const Text('Meus Pacientes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Buscar paciente...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
        ),
      ),
      body: Column(children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(children: [
            _FilterChip(label: 'Todos', selected: _filter == null, onTap: () => setState(() => _filter = null)),
            const SizedBox(width: 8),
            _FilterChip(label: 'Pendentes', selected: _filter == _NutritionStatus.pending, color: PTColors.amber400, onTap: () => setState(() => _filter = _NutritionStatus.pending)),
            const SizedBox(width: 8),
            _FilterChip(label: 'Em dia', selected: _filter == _NutritionStatus.upToDate, color: PTColors.teal400, onTap: () => setState(() => _filter = _NutritionStatus.upToDate)),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          child: Row(children: [
            Text('${filtered.length} paciente${filtered.length != 1 ? 's' : ''}', style: t.bodySmall),
          ]),
        ),

        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('Nenhum paciente encontrado', style: t.bodySmall))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    return PTCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      onTap: () => context.push('/nutritionist/patients/${p.id}'),
                      child: Row(children: [
                        AvatarCircle(name: p.name, size: 44),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, style: t.titleSmall),
                          const SizedBox(height: 2),
                          Text('${p.goal} · Treino: ${p.trainerName}', style: t.bodySmall),
                          const SizedBox(height: 4),
                          Text(_lastUpdate(p.lastUpdate), style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
                        ])),
                        const SizedBox(width: 8),
                        _StatusBadge(status: p.status),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  String _lastUpdate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 24) return 'Atualizado há ${diff.inHours}h';
    return 'Atualizado há ${diff.inDays} dia${diff.inDays > 1 ? 's' : ''}';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? PTColors.primary600;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.1) : PTColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? c : PTColors.border, width: selected ? 1.5 : 0.5),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, color: selected ? c : PTColors.gray600, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _NutritionStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status == _NutritionStatus.pending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPending ? PTColors.amber50 : PTColors.teal50,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isPending ? 'Pendente' : 'Em dia',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isPending ? PTColors.amber600 : PTColors.teal600),
      ),
    );
  }
}

enum _NutritionStatus { upToDate, pending }

class _PatientMock {
  final String id, name, goal, trainerName;
  final _NutritionStatus status;
  final DateTime lastUpdate;
  _PatientMock(this.id, this.name, this.goal, this.trainerName, this.status, this.lastUpdate);
}
