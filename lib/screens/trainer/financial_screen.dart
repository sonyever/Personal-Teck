import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../widgets/pt_card.dart';
import '../../widgets/avatar_circle.dart';

class FinancialScreen extends StatefulWidget {
  const FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  final List<_PaymentMock> _payments = [
    _PaymentMock('1', 'Rafael Alves', 280.0, PaymentStatus.upToDate, '05/05'),
    _PaymentMock('2', 'Marina Costa', 280.0, PaymentStatus.pending, '01/05'),
    _PaymentMock('3', 'Thiago Silva', 350.0, PaymentStatus.overdue, '20/04'),
    _PaymentMock('4', 'Julia Santos', 280.0, PaymentStatus.upToDate, '03/05'),
    _PaymentMock('5', 'Carlos Mendes', 310.0, PaymentStatus.upToDate, '04/05'),
    _PaymentMock('6', 'Ana Paula Rocha', 280.0, PaymentStatus.pending, '28/04'),
  ];

  double get _totalReceived => _payments
      .where((p) => p.status == PaymentStatus.upToDate)
      .fold(0, (s, p) => s + p.amount);

  double get _totalPending => _payments
      .where((p) => p.status != PaymentStatus.upToDate)
      .fold(0, (s, p) => s + p.amount);

  void _markAsPaid(int index) {
    final p = _payments[index];
    if (p.status == PaymentStatus.upToDate) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar pagamento'),
        content: Text('Marcar pagamento de ${p.name} (R\$ ${p.amount.toStringAsFixed(0)}) como recebido?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _payments[index] = _PaymentMock(p.id, p.name, p.amount, PaymentStatus.upToDate, p.dueDate));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pagamento de ${p.name} registrado!')),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addPayment() async {
    final result = await showModalBottomSheet<_PaymentMock>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddPaymentSheet(),
    );
    if (result != null) {
      setState(() => _payments.add(result));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pagamento de ${result.name} adicionado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Financeiro'),
        actions: [
          IconButton(icon: const Icon(Icons.add), tooltip: 'Novo lançamento', onPressed: _addPayment),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Resumo do mês
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [PTColors.primary800, PTColors.primary600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Receita de maio', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 4),
              Text(
                'R\$ ${_totalReceived.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Row(children: [
                _SummaryChip(label: 'Recebido', value: 'R\$ ${_totalReceived.toStringAsFixed(0)}', color: PTColors.teal200),
                const SizedBox(width: 10),
                _SummaryChip(label: 'Pendente', value: 'R\$ ${_totalPending.toStringAsFixed(0)}', color: PTColors.amber200),
              ]),
            ]),
          ),

          const SizedBox(height: 20),

          // Stats rápidos
          Row(children: [
            Expanded(child: _StatBox(value: '${_payments.length}', label: 'Alunos ativos', color: PTColors.primary600)),
            const SizedBox(width: 10),
            Expanded(child: _StatBox(value: '${_payments.where((p) => p.status != PaymentStatus.upToDate).length}', label: 'Pendências', color: PTColors.amber400)),
            const SizedBox(width: 10),
            Expanded(child: _StatBox(value: '5', label: 'Renovações', color: PTColors.teal400)),
          ]),

          const SizedBox(height: 20),

          Text('Pagamentos — Maio/2026', style: t.titleMedium),
          const SizedBox(height: 10),

          ...List.generate(_payments.length, (i) {
            final p = _payments[i];
            final isPending = p.status != PaymentStatus.upToDate;
            return PTCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isPending ? () => _markAsPaid(i) : null,
                child: Row(children: [
                  AvatarCircle(name: p.name, size: 40),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name, style: t.titleSmall),
                    Text('Venc. ${p.dueDate}', style: t.bodySmall),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('R\$ ${p.amount.toStringAsFixed(0)}', style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: p.status == PaymentStatus.overdue ? PTColors.red600 : PTColors.gray900,
                    )),
                    const SizedBox(height: 3),
                    _StatusBadge(status: p.status),
                  ]),
                  if (isPending) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle_outline, size: 20, color: PTColors.teal600),
                  ],
                ]),
              ),
            );
          }),

          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}

// ── Add Payment Sheet ─────────────────────────────────────────────────────────

class _AddPaymentSheet extends StatefulWidget {
  const _AddPaymentSheet();

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '280');
  final _dueDateCtrl = TextEditingController();
  PaymentStatus _status = PaymentStatus.pending;
  DateTime _dueDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dueDateCtrl.text = '${_dueDate.day.toString().padLeft(2, '0')}/${_dueDate.month.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _dueDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2026, 1),
      lastDate: DateTime(2027, 12),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateCtrl.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}';
      });
    }
  }

  void _confirm() {
    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome do aluno')));
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valor inválido')));
      return;
    }
    Navigator.pop(context, _PaymentMock(
      DateTime.now().millisecondsSinceEpoch.toString(),
      name, amount, _status,
      _dueDateCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        color: PTColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: PTColors.gray200, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Novo lançamento', style: t.titleLarge),
          const SizedBox(height: 20),

          Text('Nome do aluno', style: t.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'Ex: Rafael Alves'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Valor (R\$)', style: t.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(prefixText: 'R\$ '),
              ),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Vencimento', style: t.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _dueDateCtrl,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined, size: 16),
                ),
              ),
            ])),
          ]),
          const SizedBox(height: 16),

          Text('Status', style: t.labelLarge),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: PaymentStatus.values.map((s) {
            final label = switch (s) {
              PaymentStatus.upToDate => 'Em dia',
              PaymentStatus.pending  => 'Pendente',
              PaymentStatus.overdue  => 'Atrasado',
            };
            final sel = _status == s;
            return ChoiceChip(
              label: Text(label),
              selected: sel,
              onSelected: (_) => setState(() => _status = s),
              selectedColor: PTColors.primary50,
              labelStyle: TextStyle(
                color: sel ? PTColors.primary600 : PTColors.gray600,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList()),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirm,
              child: const Text('Salvar lançamento'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
    Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
  ]);
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatBox({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: PTColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: PTColors.border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
    ]),
  );
}

class _StatusBadge extends StatelessWidget {
  final PaymentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      PaymentStatus.upToDate => ('em dia', PTColors.teal50, PTColors.teal600),
      PaymentStatus.pending  => ('pendente', PTColors.amber50, PTColors.amber600),
      PaymentStatus.overdue  => ('atrasado', PTColors.red50, PTColors.red600),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500)),
    );
  }
}

class _PaymentMock {
  final String id, name, dueDate;
  final double amount;
  final PaymentStatus status;
  const _PaymentMock(this.id, this.name, this.amount, this.status, this.dueDate);
}
