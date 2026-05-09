import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../widgets/pt_card.dart';
import '../../widgets/avatar_circle.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  PaymentStatus? _filterPayment;

  final List<_StudentMock> _students = [
    _StudentMock('1', 'Rafael Alves', 'Hipertrofia', 'Intermediário', PaymentStatus.upToDate, true, DateTime.now().subtract(const Duration(hours: 20))),
    _StudentMock('2', 'Marina Costa', 'Emagrecimento', 'Iniciante', PaymentStatus.pending, false, DateTime.now().subtract(const Duration(days: 4))),
    _StudentMock('3', 'Thiago Silva', 'Condicionamento', 'Avançado', PaymentStatus.overdue, true, DateTime.now().subtract(const Duration(days: 1))),
    _StudentMock('4', 'Julia Santos', 'Hipertrofia', 'Intermediário', PaymentStatus.upToDate, false, DateTime.now().subtract(const Duration(hours: 2))),
    _StudentMock('5', 'Carlos Mendes', 'Resistência', 'Iniciante', PaymentStatus.upToDate, true, DateTime.now().subtract(const Duration(days: 2))),
    _StudentMock('6', 'Ana Paula Rocha', 'Reabilitação', 'Iniciante', PaymentStatus.pending, false, DateTime.now().subtract(const Duration(days: 6))),
  ];

  List<_StudentMock> get _filtered {
    return _students.where((s) {
      final matchQuery = _query.isEmpty || s.name.toLowerCase().contains(_query.toLowerCase());
      final matchPayment = _filterPayment == null || s.payment == _filterPayment;
      return matchQuery && matchPayment;
    }).toList();
  }

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
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Alunos', style: t.headlineMedium),
              Text('${_students.length} cadastrados', style: t.bodySmall),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Buscar aluno...',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _FilterChip(label: 'Todos', selected: _filterPayment == null, onTap: () => setState(() => _filterPayment = null)),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Em dia', selected: _filterPayment == PaymentStatus.upToDate, onTap: () => setState(() => _filterPayment = PaymentStatus.upToDate)),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Pendente', selected: _filterPayment == PaymentStatus.pending, onTap: () => setState(() => _filterPayment = PaymentStatus.pending)),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Atrasado', selected: _filterPayment == PaymentStatus.overdue, onTap: () => setState(() => _filterPayment = PaymentStatus.overdue)),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Nenhum aluno encontrado', style: TextStyle(color: PTColors.gray400)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _StudentTile(
                      student: filtered[i],
                      onTap: () => context.push('/trainer/students/${filtered[i].id}'),
                    ),
                  ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: PTColors.primary600,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final _StudentMock student;
  final VoidCallback onTap;

  const _StudentTile({required this.student, required this.onTap});

  String _lastSeen() {
    final diff = DateTime.now().difference(student.lastTraining);
    if (diff.inHours < 24) return 'Treinou hoje';
    if (diff.inDays == 1) return 'Ontem';
    return 'Há ${diff.inDays} dias';
  }

  @override
  Widget build(BuildContext context) {
    final isLate = DateTime.now().difference(student.lastTraining).inDays >= 4;
    return PTCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        AvatarCircle(name: student.name, size: 44),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(student.name, style: Theme.of(context).textTheme.titleSmall)),
            if (student.payment != PaymentStatus.upToDate)
              _Badge(
                label: student.payment == PaymentStatus.pending ? 'pendente' : 'atrasado',
                bg: student.payment == PaymentStatus.pending ? PTColors.amber50 : PTColors.red50,
                fg: student.payment == PaymentStatus.pending ? PTColors.amber600 : PTColors.red600,
              ),
          ]),
          const SizedBox(height: 2),
          Text('${student.goal} · ${student.level}', style: const TextStyle(fontSize: 12, color: PTColors.gray400)),
          const SizedBox(height: 2),
          Text(_lastSeen(), style: TextStyle(fontSize: 11, color: isLate ? PTColors.amber600 : PTColors.gray400)),
        ])),
        const Icon(Icons.chevron_right, color: PTColors.gray200, size: 18),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? PTColors.primary600 : PTColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? PTColors.primary600 : PTColors.border, width: 0.5),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, color: selected ? Colors.white : PTColors.gray600, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
    child: Text(label, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500)),
  );
}

class _StudentMock {
  final String id, name, goal, level;
  final PaymentStatus payment;
  final bool hasWearable;
  final DateTime lastTraining;
  const _StudentMock(this.id, this.name, this.goal, this.level, this.payment, this.hasWearable, this.lastTraining);
}
