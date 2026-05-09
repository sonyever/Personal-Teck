import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../router.dart';
import '../../widgets/avatar_circle.dart';

class ProfileScreen extends StatelessWidget {
  final UserRole role;
  const ProfileScreen({super.key, required this.role});

  String get _name => switch (role) {
    UserRole.trainer      => 'Carlos Ferreira',
    UserRole.student      => 'Rafael Alves',
    UserRole.nutritionist => 'Dra. Ana Souza',
  };

  String get _email => switch (role) {
    UserRole.trainer      => 'carlos@personalteck.com.br',
    UserRole.student      => 'rafael@email.com',
    UserRole.nutritionist => 'ana@nutricao.com.br',
  };

  String get _roleLabel => switch (role) {
    UserRole.trainer      => 'Personal Trainer',
    UserRole.student      => 'Aluno',
    UserRole.nutritionist => 'Nutricionista',
  };

  Color get _roleBadgeColor => switch (role) {
    UserRole.trainer      => PTColors.primary600,
    UserRole.student      => PTColors.primary600,
    UserRole.nutritionist => PTColors.teal600,
  };

  Color get _roleBadgeBg => switch (role) {
    UserRole.trainer      => PTColors.primary50,
    UserRole.student      => PTColors.primary50,
    UserRole.nutritionist => PTColors.teal50,
  };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isTrainer = role == UserRole.trainer;
    final isNutritionist = role == UserRole.nutritionist;
    final isStudent = role == UserRole.student;

    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [

          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
            color: PTColors.surface,
            child: Column(children: [
              Stack(alignment: Alignment.bottomRight, children: [
                AvatarCircle(name: _name, size: 80, bgColor: PTColors.primary100),
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: PTColors.primary600, shape: BoxShape.circle, border: Border.all(color: PTColors.surface, width: 2)),
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ]),
              const SizedBox(height: 12),
              Text(_name, style: t.headlineSmall),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: _roleBadgeBg, borderRadius: BorderRadius.circular(99)),
                child: Text(_roleLabel, style: TextStyle(fontSize: 12, color: _roleBadgeColor, fontWeight: FontWeight.w500)),
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

          // Identificação
          _Section(title: 'Identificação', items: [
            _Item(icon: Icons.badge_outlined, label: 'Identificação', value: _name),
            _Item(icon: Icons.email_outlined, label: 'E-mail', value: _email),
            _Item(icon: Icons.phone_outlined, label: 'Telefone', value: '(11) 99999-0000'),
            if (isStudent) ...[
              _Item(icon: Icons.fingerprint, label: 'CPF', value: '000.000.000-00'),
              _Item(icon: Icons.cake_outlined, label: 'Data de nascimento', value: '15/03/1996'),
            ],
            if (isNutritionist) ...[
              _Item(icon: Icons.verified_outlined, label: 'CRN', value: '000000-SP'),
              _Item(icon: Icons.school_outlined, label: 'Especialidade', value: 'Nutrição Esportiva'),
            ],
          ]),

          if (isStudent) ...[
            const SizedBox(height: 8),
            _Section(title: 'Meu programa', items: [
              _Item(icon: Icons.fitness_center_outlined, label: 'Treinador', value: 'Carlos Ferreira'),
              _Item(icon: Icons.flag_outlined, label: 'Objetivo', value: 'Hipertrofia'),
              _Item(icon: Icons.bar_chart_outlined, label: 'Nível', value: 'Intermediário'),
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
              _Item(icon: Icons.people_outline, label: 'Alunos ativos', value: '24'),
              _Item(icon: Icons.star_outline, label: 'CREF', value: '000000-G/SP'),
              _Item(icon: Icons.location_on_outlined, label: 'Academia', value: 'Academia Central'),
            ]),
          ],

          if (isNutritionist) ...[
            const SizedBox(height: 8),
            _Section(title: 'Minha atuação', items: [
              _Item(icon: Icons.people_outline, label: 'Pacientes ativos', value: '8'),
              _Item(icon: Icons.workspace_premium_outlined, label: 'Plano', value: 'Plus — parceria ativa'),
              _Item(icon: Icons.business_outlined, label: 'Clínica', value: 'NutriSport SP'),
            ]),
          ],

          const SizedBox(height: 8),

          _Section(title: 'Preferências', items: [
            _Item(icon: Icons.notifications_outlined, label: 'Notificações', value: 'Ativado', onTap: () => context.push('/notifications')),
            _Item(icon: Icons.lock_outline, label: 'Segurança', value: 'Alterar senha', onTap: () {}),
            _Item(icon: Icons.privacy_tip_outlined, label: 'Privacidade', value: '', onTap: () {}),
          ]),

          const SizedBox(height: 8),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout, color: PTColors.red400, size: 18),
                label: const Text('Sair da conta', style: TextStyle(color: PTColors.red400)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: PTColors.red200),
                  foregroundColor: PTColors.red400,
                ),
              ),
            ),
          ),

          // Encerrar conta (apenas aluno)
          if (isStudent) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _confirmDeleteAccount(context),
                  child: const Text(
                    'Encerrar minha conta',
                    style: TextStyle(fontSize: 13, color: PTColors.gray400, decoration: TextDecoration.underline),
                  ),
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
            onPressed: () {
              Navigator.pop(context);
              setCurrentRole(null);
              context.go('/login');
            },
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
        content: const Text(
          'Seu histórico completo será enviado para o seu e-mail antes do encerramento.\n\n'
          'Após confirmado, sua conta será encerrada e o acesso removido.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: PTColors.red600),
            onPressed: () {
              Navigator.pop(context);
              _sendAccountReport(context);
            },
            child: const Text('Encerrar e enviar relatório', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendAccountReport(BuildContext context) async {
    final now = DateTime.now();
    final report = _buildAccountReport(now);

    final uri = Uri(
      scheme: 'mailto',
      path: 'rafael@email.com',
      queryParameters: {
        'subject': '[Personal Teck] Relatório de encerramento de conta — Rafael Alves',
        'body': report,
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relatório gerado. Verifique seu cliente de e-mail.'),
          backgroundColor: PTColors.teal600,
        ),
      );
      setCurrentRole(null);
      context.go('/login');
    }
  }

  String _buildAccountReport(DateTime now) {
    final date = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return '''
RELATÓRIO DE ENCERRAMENTO DE CONTA — PERSONAL TECK
Gerado em: $date às $time
================================================================

IDENTIFICAÇÃO
  Nome: Rafael Alves
  CPF: 000.000.000-00
  Data de nascimento: 15/03/1996
  E-mail: rafael@email.com
  Telefone: (11) 99999-0000
  Data de cadastro: 01/01/2025

----------------------------------------------------------------
PROGRAMA
  Treinador: Carlos Ferreira (CREF 000000-G/SP)
  Objetivo: Hipertrofia
  Nível: Intermediário
  Status do pagamento: Em dia

----------------------------------------------------------------
HISTÓRICO DE TREINOS
  Total de treinos realizados: 47
  Último treino: 08/05/2026
  Frequência média: 3,8x por semana

  Treino A — Peito/Tríceps (última realização: 06/05/2026)
    Supino reto:          4 séries x 10 reps — 80 kg
    Supino inclinado:     3 séries x 12 reps — 60 kg
    Crossover:            3 séries x 15 reps — 20 kg
    Tríceps pulley:       4 séries x 12 reps — 35 kg

  Treino B — Costas/Bíceps (última realização: 07/05/2026)
    Puxada frontal:       4 séries x 10 reps — 70 kg
    Remada cavalinho:     3 séries x 12 reps — 80 kg
    Barra fixa:           3 séries x 8 reps — corporal
    Rosca direta:         3 séries x 12 reps — 30 kg

  Treino C — Pernas (última realização: 08/05/2026)
    Agachamento livre:    4 séries x 10 reps — 100 kg
    Leg press 45:         3 séries x 15 reps — 200 kg
    Cadeira extensora:    3 séries x 15 reps — 60 kg
    Stiff:                3 séries x 12 reps — 70 kg

----------------------------------------------------------------
MEDIDAS CORPORAIS
  Data da última avaliação: 01/05/2026
  Peso: 82,0 kg
  Altura: 178 cm
  IMC: 25,9
  % Gordura: 14,2%
  Massa magra: 70,3 kg
  Circunferência abdominal: 84 cm
  Circunferência de braço (D): 37 cm
  Circunferência de coxa (D): 60 cm

----------------------------------------------------------------
ANAMNESE
  Sexo biológico: Masculino
  Profissão: Engenheiro
  Contato de emergência: Maria Alves — (11) 98888-0001

  Saúde:
    Condições médicas: Nenhuma
    Medicamentos: Nenhum
    Cirurgias recentes: Não

  PAR-Q: Todas as respostas negativas

  Estilo de vida:
    Sono: 7 horas/noite
    Estresse: Moderado
    Tabagismo: Nunca
    Álcool: 1 dia/semana
    Tipo de trabalho: Sedentário

  Histórico físico:
    Experiência prévia: Sim — 3 anos
    Atividades: Musculação, Funcional
    Lesões: Dor lombar leve

  Objetivos:
    Principal: Hipertrofia
    Prazo: 6 meses
    Dias disponíveis: Seg, Ter, Qui, Sex, Sáb

  Nutrição:
    Consumo de água: 8 copos/dia
    Refeições/dia: 4
    Tipo de dieta: Onívoro
    Restrições: Nenhuma
    Suplementos: Whey protein, Creatina

----------------------------------------------------------------
CHECK-INS REGISTRADOS
  Total: 44 check-ins
  Nível de energia mais frequente: Bem
  Desconfortos relatados: Lombar (3x), Joelho (1x)

----------------------------------------------------------------
EVOLUÇÃO REGISTRADA
  Peso inicial: 79,5 kg → atual: 82,0 kg (+2,5 kg)
  % Gordura inicial: 16,1% → atual: 14,2% (-1,9%)
  Supino reto PR: 60 kg → 80 kg (+20 kg)
  Agachamento PR: 80 kg → 100 kg (+20 kg)

================================================================
Este relatório foi gerado automaticamente pelo Personal Teck
em atendimento à solicitação de encerramento de conta.
O histórico físico do usuário é de sua propriedade e pode ser
requisitado a qualquer momento, inclusive por ordem judicial.
================================================================
''';
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_Item> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PTColors.gray400, letterSpacing: 0.5)),
    ),
    Container(
      color: PTColors.surface,
      child: Column(children: items.asMap().entries.map((e) {
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
      }).toList()),
    ),
  ]);
}

class _Item {
  final IconData icon;
  final String label, value;
  final VoidCallback? onTap;
  const _Item({required this.icon, required this.label, required this.value, this.onTap});
}
