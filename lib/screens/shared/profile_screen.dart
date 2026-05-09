import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../widgets/avatar_circle.dart';

class ProfileScreen extends StatefulWidget {
  final UserRole role;
  const ProfileScreen({super.key, required this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _profile = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) { setState(() => _loading = false); return; }
    try {
      final data = await supabase.from('profiles').select().eq('id', uid).single();
      if (mounted) setState(() { _profile = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _name  => _profile['name']  ?? AuthService.currentName;
  String get _email => _profile['email'] ?? AuthService.currentUser?.email ?? '';
  String get _phone => _profile['phone'] ?? '';

  String get _roleLabel => switch (widget.role) {
    UserRole.trainer      => 'Personal Trainer',
    UserRole.student      => 'Aluno',
    UserRole.nutritionist => 'Nutricionista',
  };

  Color get _badgeColor => widget.role == UserRole.nutritionist ? PTColors.teal600 : PTColors.primary600;
  Color get _badgeBg    => widget.role == UserRole.nutritionist ? PTColors.teal50  : PTColors.primary50;

  void _openEdit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSheet(
        profile: _profile,
        role: widget.role,
        onSaved: (updated) async {
          setState(() => _profile = {..._profile, ...updated});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isTrainer      = widget.role == UserRole.trainer;
    final isStudent      = widget.role == UserRole.student;
    final isNutritionist = widget.role == UserRole.nutritionist;

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Perfil'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _openEdit,
            child: const Text('Editar', style: TextStyle(color: PTColors.primary600, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(children: [

                // ── Header ────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
                  color: PTColors.surface,
                  child: Column(children: [
                    GestureDetector(
                      onTap: _openEdit,
                      child: Stack(alignment: Alignment.bottomRight, children: [
                        AvatarCircle(name: _name, size: 80, bgColor: PTColors.primary100),
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: PTColors.primary600,
                            shape: BoxShape.circle,
                            border: Border.all(color: PTColors.surface, width: 2),
                          ),
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Text(_name, style: t.headlineSmall),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: _badgeBg, borderRadius: BorderRadius.circular(99)),
                      child: Text(_roleLabel, style: TextStyle(fontSize: 12, color: _badgeColor, fontWeight: FontWeight.w500)),
                    ),
                    if (isNutritionist) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: PTColors.amber50, borderRadius: BorderRadius.circular(99)),
                        child: const Text('Plano Plus', style: TextStyle(fontSize: 11, color: PTColors.amber800, fontWeight: FontWeight.w700)),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(_email, style: t.bodySmall),
                  ]),
                ),

                const SizedBox(height: 12),

                // ── Identificação ─────────────────────────────────────────
                _Section(title: 'Identificação', items: [
                  _Item(icon: Icons.badge_outlined,  label: 'Nome',     value: _name),
                  _Item(icon: Icons.email_outlined,  label: 'E-mail',   value: _email),
                  _Item(icon: Icons.phone_outlined,  label: 'Telefone', value: _phone.isEmpty ? '—' : _phone),
                  if (isStudent) ...[
                    _Item(icon: Icons.fingerprint,      label: 'CPF',               value: _fmt(_profile['cpf'])),
                    _Item(icon: Icons.cake_outlined,    label: 'Data de nascimento', value: _fmt(_profile['birth_date'])),
                  ],
                  if (isNutritionist) ...[
                    _Item(icon: Icons.verified_outlined, label: 'CRN',         value: _fmt(_profile['crn'])),
                    _Item(icon: Icons.school_outlined,   label: 'Especialidade', value: _fmt(_profile['specialty'])),
                  ],
                ]),

                if (isStudent) ...[
                  const SizedBox(height: 8),
                  _Section(title: 'Meu programa', items: [
                    _Item(icon: Icons.flag_outlined,       label: 'Objetivo', value: '—'),
                    _Item(icon: Icons.bar_chart_outlined,  label: 'Nível',    value: '—'),
                    _Item(
                      icon: Icons.assignment_outlined,
                      label: 'Anamnese',
                      value: 'Visualizar',
                      onTap: () => context.push('/student/anamnese'),
                    ),
                  ]),
                ],

                if (isTrainer) ...[
                  const SizedBox(height: 8),
                  _Section(title: 'Meu negócio', items: [
                    _Item(icon: Icons.people_outline,    label: 'Alunos ativos', value: '—'),
                    _Item(icon: Icons.star_outline,       label: 'CREF',          value: _fmt(_profile['cref'])),
                    _Item(icon: Icons.location_on_outlined, label: 'Academia',   value: _fmt(_profile['academy'])),
                  ]),
                ],

                if (isNutritionist) ...[
                  const SizedBox(height: 8),
                  _Section(title: 'Minha atuação', items: [
                    _Item(icon: Icons.people_outline,           label: 'Pacientes ativos', value: '—'),
                    _Item(icon: Icons.business_outlined,        label: 'Clínica',          value: _fmt(_profile['clinic'])),
                  ]),
                ],

                const SizedBox(height: 8),

                _Section(title: 'Preferências', items: [
                  _Item(icon: Icons.notifications_outlined, label: 'Notificações', value: 'Ativado', onTap: () => context.push('/notifications')),
                  _Item(icon: Icons.lock_outline,           label: 'Segurança',    value: 'Alterar senha', onTap: () => _changePassword(context)),
                ]),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLogout(context),
                      icon: const Icon(Icons.logout, color: PTColors.red400, size: 18),
                      label: const Text('Sair da conta', style: TextStyle(color: PTColors.red400)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: PTColors.red200), foregroundColor: PTColors.red400),
                    ),
                  ),
                ),

                if (isStudent) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _confirmDeleteAccount(context),
                        child: const Text('Encerrar minha conta', style: TextStyle(fontSize: 13, color: PTColors.gray400, decoration: TextDecoration.underline)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Text('Personal Teck v1.0.0', style: t.bodySmall?.copyWith(color: PTColors.gray200)),
                const SizedBox(height: 32),
              ]),
            ),
    );
  }

  String _fmt(dynamic v) => (v == null || v.toString().isEmpty) ? '—' : v.toString();

  void _changePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você será redirecionado para a tela de login.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: PTColors.red400),
            onPressed: () { Navigator.pop(context); AuthService.signOut(); },
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Encerrar conta?'),
        content: const Text('Sua conta será encerrada e o acesso removido.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: PTColors.red600),
            onPressed: () { Navigator.pop(context); _deleteAccount(context); },
            child: const Text('Encerrar conta', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    AuthService.signOut();
  }
}

// ── Bottom sheet de edição ────────────────────────────────────────────────────

class _EditSheet extends StatefulWidget {
  final Map<String, dynamic> profile;
  final UserRole role;
  final void Function(Map<String, dynamic>) onSaved;
  const _EditSheet({required this.profile, required this.role, required this.onSaved});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _cpf;
  late final TextEditingController _birthDate;
  late final TextEditingController _cref;
  late final TextEditingController _crn;
  late final TextEditingController _specialty;
  late final TextEditingController _academy;
  late final TextEditingController _clinic;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name      = TextEditingController(text: widget.profile['name'] ?? AuthService.currentName);
    _phone     = TextEditingController(text: widget.profile['phone'] ?? '');
    _cpf       = TextEditingController(text: widget.profile['cpf'] ?? '');
    _birthDate = TextEditingController(text: widget.profile['birth_date'] ?? '');
    _cref      = TextEditingController(text: widget.profile['cref'] ?? '');
    _crn       = TextEditingController(text: widget.profile['crn'] ?? '');
    _specialty = TextEditingController(text: widget.profile['specialty'] ?? '');
    _academy   = TextEditingController(text: widget.profile['academy'] ?? '');
    _clinic    = TextEditingController(text: widget.profile['clinic'] ?? '');
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _cpf, _birthDate, _cref, _crn, _specialty, _academy, _clinic]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) return;
    setState(() => _saving = true);

    final updated = {
      'name':       _name.text.trim(),
      'phone':      _phone.text.trim(),
      'cpf':        _cpf.text.trim(),
      'birth_date': _birthDate.text.trim(),
      'cref':       _cref.text.trim(),
      'crn':        _crn.text.trim(),
      'specialty':  _specialty.text.trim(),
      'academy':    _academy.text.trim(),
      'clinic':     _clinic.text.trim(),
    };

    try {
      await supabase.from('profiles').update(updated).eq('id', uid);
      // Atualiza também o nome nos metadados do Auth
      if (_name.text.trim() != (widget.profile['name'] ?? '')) {
        await supabase.auth.updateUser(UserAttributes(data: {'name': _name.text.trim()}));
      }
      widget.onSaved(updated);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar. Tente novamente.'), backgroundColor: PTColors.red600),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isStudent      = widget.role == UserRole.student;
    final isTrainer      = widget.role == UserRole.trainer;
    final isNutritionist = widget.role == UserRole.nutritionist;

    return Container(
      decoration: const BoxDecoration(
        color: PTColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
      child: Column(
        children: [
          // Handle + título
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Row(children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: PTColors.gray100, borderRadius: BorderRadius.circular(99)))),
              const Spacer(),
              const Text('Editar perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: PTColors.gray900)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: PTColors.gray400), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad + 16),
              child: Column(children: [

                _EditField(controller: _name,  label: 'Nome completo',  icon: Icons.person_outline),
                const SizedBox(height: 12),
                _EditField(controller: _phone, label: 'Telefone',       icon: Icons.phone_outlined, keyboard: TextInputType.phone),

                if (isStudent) ...[
                  const SizedBox(height: 12),
                  _EditField(controller: _cpf,       label: 'CPF',               icon: Icons.fingerprint, keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  _EditField(controller: _birthDate, label: 'Data de nascimento (DD/MM/AAAA)', icon: Icons.cake_outlined),
                ],

                if (isTrainer) ...[
                  const SizedBox(height: 12),
                  _EditField(controller: _cref,    label: 'CREF',    icon: Icons.star_outline),
                  const SizedBox(height: 12),
                  _EditField(controller: _academy, label: 'Academia', icon: Icons.location_on_outlined),
                ],

                if (isNutritionist) ...[
                  const SizedBox(height: 12),
                  _EditField(controller: _crn,       label: 'CRN',          icon: Icons.verified_outlined),
                  const SizedBox(height: 12),
                  _EditField(controller: _specialty, label: 'Especialidade', icon: Icons.school_outlined),
                  const SizedBox(height: 12),
                  _EditField(controller: _clinic,    label: 'Clínica',       icon: Icons.business_outlined),
                ],

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Salvar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  const _EditField({required this.controller, required this.label, required this.icon, this.keyboard = TextInputType.text});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboard,
    style: const TextStyle(fontSize: 15, color: PTColors.gray900),
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20, color: PTColors.gray400)),
  );
}

// ── Dialog de alteração de senha ──────────────────────────────────────────────

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _ctrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_ctrl.text.length < 6) {
      setState(() => _error = 'Mínimo 6 caracteres.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await supabase.auth.updateUser(UserAttributes(password: _ctrl.text));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso.'), backgroundColor: PTColors.primary600),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Erro ao alterar senha.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nova senha'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(
        controller: _ctrl,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Nova senha', prefixIcon: Icon(Icons.lock_outline)),
      ),
      if (_error != null) ...[
        const SizedBox(height: 8),
        Text(_error!, style: const TextStyle(fontSize: 12, color: PTColors.red600)),
      ],
    ]),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      ElevatedButton(
        onPressed: _saving ? null : _save,
        child: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Salvar'),
      ),
    ],
  );
}

// ── Widgets de layout ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<_Item> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
        child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PTColors.gray400, letterSpacing: 0.5)),
      ),
      Container(
        color: PTColors.surface,
        child: Column(
          children: items.asMap().entries.map((e) {
            final item = e.value;
            final isLast = e.key == items.length - 1;
            return Column(children: [
              GestureDetector(
                onTap: item.onTap,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Icon(item.icon, size: 20, color: PTColors.gray400),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item.label, style: const TextStyle(fontSize: 14, color: PTColors.gray900))),
                    if (item.value.isNotEmpty)
                      Text(item.value, style: const TextStyle(fontSize: 13, color: PTColors.gray400)),
                    if (item.onTap != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16, color: PTColors.gray200),
                    ],
                  ]),
                ),
              ),
              if (!isLast) const Divider(indent: 48, height: 1),
            ]);
          }).toList(),
        ),
      ),
    ],
  );
}

class _Item {
  final IconData icon;
  final String label, value;
  final VoidCallback? onTap;
  const _Item({required this.icon, required this.label, required this.value, this.onTap});
}
