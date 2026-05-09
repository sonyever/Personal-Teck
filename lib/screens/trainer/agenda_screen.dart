import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../widgets/pt_card.dart';
import '../../widgets/avatar_circle.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _selectedDay = DateTime.now();

  final List<TrainingSession> _sessions = [
    TrainingSession(id: '1', trainerId: 't1', studentId: '1', scheduledAt: DateTime.now().copyWith(hour: 7, minute: 0), location: 'Academia Central', status: SessionStatus.confirmed),
    TrainingSession(id: '2', trainerId: 't1', studentId: '2', scheduledAt: DateTime.now().copyWith(hour: 9, minute: 30), location: 'Academia Central', status: SessionStatus.confirmed),
    TrainingSession(id: '3', trainerId: 't1', studentId: '3', scheduledAt: DateTime.now().copyWith(hour: 11, minute: 0), location: 'Online', status: SessionStatus.pending),
    TrainingSession(id: '4', trainerId: 't1', studentId: '4', scheduledAt: DateTime.now().copyWith(hour: 14, minute: 0), location: 'Academia Central', status: SessionStatus.confirmed),
    TrainingSession(id: '5', trainerId: 't1', studentId: '5', scheduledAt: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 8, minute: 0), location: 'Academia Central', status: SessionStatus.pending),
  ];

  final _names = {'1': 'Rafael Alves', '2': 'Marina Costa', '3': 'Thiago Silva', '4': 'Julia Santos', '5': 'Carlos Mendes'};

  List<TrainingSession> get _todaySessions => _sessions
      .where((s) => _isSameDay(s.scheduledAt, _selectedDay))
      .toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _openNewSession() async {
    final result = await showModalBottomSheet<TrainingSession>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewSessionSheet(initialDate: _selectedDay, names: _names),
    );
    if (result != null) {
      setState(() {
        _sessions.add(result);
        _selectedDay = result.scheduledAt;
      });
    }
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
            child: Row(children: [
              Text('Agenda', style: t.headlineMedium),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _openNewSession,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agendar'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
              ),
            ]),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 72,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (_, i) {
                final day = DateTime.now().subtract(Duration(days: 3 - i));
                final isSelected = _isSameDay(day, _selectedDay);
                final hasSession = _sessions.any((s) => _isSameDay(s.scheduledAt, day));
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: Container(
                    width: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? PTColors.primary600 : PTColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? PTColors.primary600 : PTColors.border, width: 0.5),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'][day.weekday % 7],
                        style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : PTColors.gray400),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${day.day}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : PTColors.gray900),
                      ),
                      if (hasSession)
                        Container(
                          width: 4, height: 4,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white54 : PTColors.primary400,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ]),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),

          Expanded(
            child: _todaySessions.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.event_available, size: 48, color: PTColors.gray200),
                    const SizedBox(height: 12),
                    Text('Nenhum treino agendado', style: t.titleSmall?.copyWith(color: PTColors.gray400)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _todaySessions.length,
                    itemBuilder: (_, i) => _SessionTile(
                      session: _todaySessions[i],
                      studentName: _names[_todaySessions[i].studentId] ?? 'Aluno',
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}

// ── New Session Sheet ─────────────────────────────────────────────────────────

class _NewSessionSheet extends StatefulWidget {
  final DateTime initialDate;
  final Map<String, String> names;

  const _NewSessionSheet({required this.initialDate, required this.names});

  @override
  State<_NewSessionSheet> createState() => _NewSessionSheetState();
}

class _NewSessionSheetState extends State<_NewSessionSheet> {
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  String? _studentId;
  int _duration = 60;
  final _locationCtrl = TextEditingController(text: 'Academia Central');

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _confirm() {
    if (_studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um aluno')),
      );
      return;
    }
    final scheduled = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final session = TrainingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      trainerId: 't1',
      studentId: _studentId!,
      scheduledAt: scheduled,
      durationMinutes: _duration,
      location: _locationCtrl.text.trim().isEmpty ? 'Academia Central' : _locationCtrl.text.trim(),
      status: SessionStatus.pending,
    );
    Navigator.pop(context, session);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final timeStr = '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final dateStr = '${_date.day} ${months[_date.month - 1]} ${_date.year}';

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
          Text('Nova sessão', style: t.titleLarge),
          const SizedBox(height: 20),

          Text('Aluno', style: t.labelLarge),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: PTColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: _studentId,
              hint: const Text('Selecionar aluno'),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: widget.names.entries.map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              )).toList(),
              onChanged: (v) => setState(() => _studentId = v),
            ),
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Data', style: t.labelLarge),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: PTColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: PTColors.primary600),
                      const SizedBox(width: 8),
                      Text(dateStr, style: const TextStyle(fontSize: 14)),
                    ]),
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Horário', style: t.labelLarge),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: PTColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Icon(Icons.access_time_outlined, size: 16, color: PTColors.primary600),
                      const SizedBox(width: 8),
                      Text(timeStr, style: const TextStyle(fontSize: 14)),
                    ]),
                  ),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 16),

          Text('Duração', style: t.labelLarge),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [30, 45, 60, 90, 120].map((d) {
            final sel = _duration == d;
            return ChoiceChip(
              label: Text('${d}min'),
              selected: sel,
              onSelected: (_) => setState(() => _duration = d),
              selectedColor: PTColors.primary50,
              labelStyle: TextStyle(
                color: sel ? PTColors.primary600 : PTColors.gray600,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList()),
          const SizedBox(height: 16),

          Text('Local', style: t.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(
              hintText: 'Ex: Academia Central, Online...',
              prefixIcon: Icon(Icons.location_on_outlined, size: 18),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirm,
              child: const Text('Confirmar agendamento'),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final TrainingSession session;
  final String studentName;

  const _SessionTile({required this.session, required this.studentName});

  @override
  Widget build(BuildContext context) {
    final hour = '${session.scheduledAt.hour.toString().padLeft(2, '0')}:${session.scheduledAt.minute.toString().padLeft(2, '0')}';
    final isPending = session.status == SessionStatus.pending;

    return PTCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Column(children: [
          Text(hour, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PTColors.primary600)),
          Text('${session.durationMinutes}min', style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
        ]),
        const SizedBox(width: 14),
        Container(width: 1, height: 40, color: PTColors.border),
        const SizedBox(width: 14),
        AvatarCircle(name: studentName, size: 38),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(studentName, style: Theme.of(context).textTheme.titleSmall),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 12, color: PTColors.gray400),
            const SizedBox(width: 3),
            Text(session.location, style: const TextStyle(fontSize: 12, color: PTColors.gray400)),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isPending ? PTColors.amber50 : PTColors.teal50,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            isPending ? 'pendente' : 'confirmado',
            style: TextStyle(fontSize: 11, color: isPending ? PTColors.amber600 : PTColors.teal600, fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }
}
