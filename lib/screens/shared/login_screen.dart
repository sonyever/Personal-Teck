import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/theme.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  UserRole _selectedRole = UserRole.trainer;

  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    final name  = _nameCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Preencha email e senha.');
      return;
    }
    if (!_isLogin && name.isEmpty) {
      setState(() => _error = 'Preencha seu nome.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      if (_isLogin) {
        await AuthService.signIn(email: email, password: pass);
      } else {
        await AuthService.signUp(email: email, password: pass, name: name, role: _selectedRole);
      }
      // Router redireciona automaticamente via onAuthStateChange
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = _translate(e.message));
    } catch (_) {
      if (mounted) setState(() => _error = 'Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _translate(String msg) {
    if (msg.contains('Invalid login credentials')) return 'Email ou senha incorretos.';
    if (msg.contains('already registered') || msg.contains('already been registered')) return 'Email já cadastrado.';
    if (msg.contains('Password should be at least')) return 'Senha deve ter ao menos 6 caracteres.';
    if (msg.contains('Unable to validate email') || msg.contains('invalid')) return 'Email inválido.';
    return msg;
  }

  void _toggle() => setState(() { _isLogin = !_isLogin; _error = null; });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0D2B1E),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SizedBox.expand(child: CustomPaint(painter: _LoginBgPainter())),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Zona superior: logo + título ────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1),
                          ),
                          child: const Icon(Icons.fitness_center, color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            key: ValueKey(_isLogin),
                            _isLogin ? 'Bem-vindo ao\nPersonal Teck' : 'Criar sua conta',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isLogin ? 'Entre com seu email e senha.' : 'Preencha os dados para continuar.',
                          style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.68)),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Zona inferior: formulário ────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: PTColors.background,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 28,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.78,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle visual
                        Container(
                          width: 36, height: 4,
                          decoration: BoxDecoration(color: PTColors.gray100, borderRadius: BorderRadius.circular(99)),
                        ),
                        const SizedBox(height: 22),

                        // Campos do formulário
                        if (!_isLogin) ...[
                          _Field(controller: _nameCtrl, label: 'Nome completo', icon: Icons.person_outline),
                          const SizedBox(height: 12),
                        ],
                        _Field(
                          controller: _emailCtrl,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboard: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _passCtrl,
                          label: 'Senha',
                          icon: Icons.lock_outline,
                          obscure: true,
                        ),

                        // Seleção de perfil no cadastro
                        if (!_isLogin) ...[
                          const SizedBox(height: 18),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Você é:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PTColors.gray600)),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: UserRole.values.map((r) {
                              final isLast = r == UserRole.nutritionist;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: isLast ? 0 : 8),
                                  child: _RoleChip(
                                    role: r,
                                    selected: _selectedRole == r,
                                    onTap: () => setState(() => _selectedRole = r),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        // Mensagem de erro
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: PTColors.red50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: PTColors.red200),
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline, size: 16, color: PTColors.red600),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: const TextStyle(fontSize: 13, color: PTColors.red600))),
                            ]),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Botão principal
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(
                                    _isLogin ? 'Entrar' : 'Criar conta',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Alternância login / cadastro
                        Center(
                          child: GestureDetector(
                            onTap: _toggle,
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 13, color: PTColors.gray400),
                                children: [
                                  TextSpan(text: _isLogin ? 'Não tem conta? ' : 'Já tem conta? '),
                                  TextSpan(
                                    text: _isLogin ? 'Criar conta' : 'Entrar',
                                    style: const TextStyle(color: PTColors.primary600, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Links legais
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 4,
                            children: [
                              _LegalLink(label: 'Sobre nós',    onTap: () => _showSheet(context, _SobreNos())),
                              _Dot(),
                              _LegalLink(label: 'Privacidade',  onTap: () => _showSheet(context, _Privacidade())),
                              _Dot(),
                              _LegalLink(label: 'Termos de uso', onTap: () => _showSheet(context, _Termos())),
                              _Dot(),
                              _LegalLink(label: 'Contato',      onTap: () => _showSheet(context, _Contato())),
                              _Dot(),
                              _LegalLink(label: 'Cookies',      onTap: () => _showSheet(context, _Cookies())),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            '© 2026 Tércio Informática. Todos os direitos reservados.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: PTColors.gray200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => content,
    );
  }
}

// ── Campo de texto reutilizável ───────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboard;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboard,
    style: const TextStyle(fontSize: 15, color: PTColors.gray900),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: PTColors.gray400),
    ),
  );
}

// ── Chip de seleção de role ───────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({required this.role, required this.selected, required this.onTap});

  String get _label => switch (role) {
    UserRole.trainer      => 'Treinador',
    UserRole.student      => 'Aluno',
    UserRole.nutritionist => 'Nutricionista',
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? PTColors.primary600 : PTColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? PTColors.primary600 : PTColors.border),
      ),
      child: Center(
        child: Text(
          _label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : PTColors.gray600,
          ),
        ),
      ),
    ),
  );
}

// ── Pintor do fundo da tela de login ─────────────────────────────────────────

class _LoginBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D2B1E),
          Color(0xFF174D34),
          Color(0xFF2E7D52),
          Color(0xFF5FAD7C),
          Color(0xFFAAC9B4),
          Color(0xFFF3F0E8),
        ],
        stops: [0.0, 0.16, 0.32, 0.46, 0.60, 0.72],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.55)..style = PaintingStyle.fill;
    const stars = [
      (0.10, 0.04), (0.22, 0.08), (0.35, 0.03), (0.48, 0.07), (0.60, 0.02),
      (0.74, 0.06), (0.85, 0.04), (0.92, 0.09), (0.15, 0.13), (0.55, 0.11),
      (0.78, 0.14), (0.42, 0.10), (0.66, 0.16), (0.30, 0.17), (0.88, 0.18),
    ];
    for (final s in stars) {
      canvas.drawCircle(Offset(w * s.$1, h * s.$2), 1.3, starPaint);
    }

    final moonX = w * 0.82;
    final moonY = h * 0.10;
    canvas.drawCircle(Offset(moonX, moonY), 16, Paint()..color = const Color(0xE0FFF8DC));
    canvas.drawCircle(Offset(moonX + 9, moonY - 3), 13, Paint()..color = const Color(0xFF12322A));

    final auroraPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.1, -0.6),
        radius: 0.9,
        colors: [const Color(0x1E4ADE8F), const Color(0x10237A4A), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), auroraPaint);

    final hill3 = Path();
    hill3.moveTo(0, h * 0.50);
    hill3.quadraticBezierTo(w * 0.12, h * 0.34, w * 0.28, h * 0.40);
    hill3.quadraticBezierTo(w * 0.46, h * 0.30, w * 0.62, h * 0.37);
    hill3.quadraticBezierTo(w * 0.80, h * 0.44, w, h * 0.38);
    hill3.lineTo(w, h); hill3.lineTo(0, h); hill3.close();
    canvas.drawPath(hill3, Paint()..color = const Color(0xFF14402E));

    final hill2 = Path();
    hill2.moveTo(0, h * 0.58);
    hill2.quadraticBezierTo(w * 0.18, h * 0.47, w * 0.35, h * 0.53);
    hill2.quadraticBezierTo(w * 0.52, h * 0.44, w * 0.70, h * 0.51);
    hill2.quadraticBezierTo(w * 0.86, h * 0.57, w, h * 0.50);
    hill2.lineTo(w, h); hill2.lineTo(0, h); hill2.close();
    canvas.drawPath(hill2, Paint()..color = const Color(0xFF1D5C40));

    _drawPines(canvas, w, h, const Color(0xFF0F2E1E), [
      (0.05, 0.56, 0.11, 0.060), (0.13, 0.59, 0.08, 0.045), (0.20, 0.54, 0.13, 0.072),
      (0.44, 0.52, 0.10, 0.058), (0.54, 0.55, 0.12, 0.068), (0.72, 0.50, 0.13, 0.072),
      (0.81, 0.53, 0.09, 0.050), (0.90, 0.51, 0.11, 0.062),
    ]);

    final hill1 = Path();
    hill1.moveTo(0, h * 0.67);
    hill1.quadraticBezierTo(w * 0.10, h * 0.60, w * 0.24, h * 0.64);
    hill1.quadraticBezierTo(w * 0.40, h * 0.57, w * 0.56, h * 0.62);
    hill1.quadraticBezierTo(w * 0.72, h * 0.56, w * 0.88, h * 0.63);
    hill1.quadraticBezierTo(w * 0.95, h * 0.66, w, h * 0.60);
    hill1.lineTo(w, h); hill1.lineTo(0, h); hill1.close();
    canvas.drawPath(hill1, Paint()..color = const Color(0xFF266B47));

    _drawPines(canvas, w, h, const Color(0xFF163D26), [
      (0.02, 0.65, 0.10, 0.056), (0.28, 0.63, 0.11, 0.062), (0.38, 0.66, 0.08, 0.045),
      (0.62, 0.61, 0.12, 0.068), (0.78, 0.65, 0.09, 0.052), (0.96, 0.62, 0.10, 0.058),
    ]);

    final fadePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Color(0xFFF3F0E8)],
        stops: [0.58, 0.74],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), fadePaint);
  }

  void _drawPines(Canvas canvas, double w, double h, Color color, List<(double, double, double, double)> pines) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    for (final p in pines) {
      final cx = w * p.$1; final baseY = h * p.$2;
      final treeH = h * p.$3; final hw = w * p.$4;
      canvas.drawPath(Path()..moveTo(cx, baseY - treeH)..lineTo(cx - hw, baseY)..lineTo(cx + hw, baseY)..close(), paint);
      canvas.drawPath(Path()..moveTo(cx, baseY - treeH * 0.72)..lineTo(cx - hw * 0.72, baseY - treeH * 0.28)..lineTo(cx + hw * 0.72, baseY - treeH * 0.28)..close(), paint);
      canvas.drawPath(Path()..moveTo(cx, baseY - treeH)..lineTo(cx - hw * 0.42, baseY - treeH * 0.58)..lineTo(cx + hw * 0.42, baseY - treeH * 0.58)..close(), paint);
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, baseY + treeH * 0.04), width: hw * 0.18, height: treeH * 0.10), paint);
    }
  }

  @override
  bool shouldRepaint(_LoginBgPainter oldDelegate) => false;
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _LegalLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LegalLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Text(label, style: const TextStyle(fontSize: 11, color: PTColors.gray400, decoration: TextDecoration.underline, decorationColor: PTColors.gray200)),
  );
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Text('·', style: TextStyle(fontSize: 11, color: PTColors.gray200));
}

// ── Bottom sheets legais ──────────────────────────────────────────────────────

class _LegalSheet extends StatelessWidget {
  final String title;
  final Widget body;
  const _LegalSheet({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: PTColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(margin: const EdgeInsets.only(top: 12), width: 36, height: 4, decoration: BoxDecoration(color: PTColors.gray100, borderRadius: BorderRadius.circular(99)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: PTColors.gray900))),
              IconButton(icon: const Icon(Icons.close, size: 20, color: PTColors.gray400), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero),
            ]),
          ),
          const Divider(height: 1),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child: body)),
        ],
      ),
    );
  }
}

class _SobreNos extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _LegalSheet(
    title: 'Sobre nós',
    body: const _LegalBody(sections: [
      _LegalSection(heading: 'O que é o Personal Teck?', text: 'O Personal Teck é uma plataforma digital desenvolvida para conectar personal trainers e seus alunos, facilitando a prescrição, o acompanhamento e a evolução de programas de treinamento físico personalizado.'),
      _LegalSection(heading: 'Nossa missão', text: 'Tornar o acompanhamento profissional de saúde e atividade física acessível, organizado e eficiente, tanto para profissionais quanto para quem deseja transformar sua qualidade de vida.'),
      _LegalSection(heading: 'O que oferecemos', text: 'Prescrição de treinos personalizados, monitoramento cardíaco em tempo real, integração com inteligência artificial para análise de anamnese e geração de programas, histórico físico permanente do aluno, e canal direto de comunicação entre treinador e aluno.'),
      _LegalSection(heading: 'Desenvolvedor', text: 'Personal Teck é desenvolvido e mantido pela Tércio Informática, empresa brasileira especializada em soluções tecnológicas para saúde e bem-estar.'),
      _LegalSection(heading: 'Responsabilidade profissional', text: 'O aplicativo é uma ferramenta de suporte ao profissional de educação física. Não substitui avaliação médica, orientação nutricional ou diagnóstico clínico. Todo programa de exercícios deve ser prescrito por profissional habilitado e registrado no CREF.'),
    ]),
  );
}

class _Privacidade extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _LegalSheet(
    title: 'Política de Privacidade',
    body: const _LegalBody(sections: [
      _LegalSection(heading: 'Dados coletados', text: 'Coletamos informações fornecidas diretamente por você: nome completo, CPF, data de nascimento, e-mail, telefone, dados de saúde (anamnese, PAR-Q, condições médicas), medidas corporais, histórico de treinos e dados de frequência cardíaca quando disponíveis via wearable.'),
      _LegalSection(heading: 'Finalidade do uso dos dados', text: 'Os dados coletados são utilizados exclusivamente para: (i) prestação dos serviços contratados, (ii) personalização do programa de treino, (iii) comunicação entre treinador e aluno, (iv) geração de relatórios de evolução, e (v) cumprimento de obrigações legais.'),
      _LegalSection(heading: 'Compartilhamento de dados', text: 'Seus dados não são vendidos a terceiros. Podem ser compartilhados apenas com o seu treinador vinculado na plataforma, com nutricionistas parceiros (plano Plus), ou mediante ordem judicial.'),
      _LegalSection(heading: 'Armazenamento e segurança', text: 'Os dados são armazenados em servidores seguros com criptografia em trânsito (TLS) e em repouso (AES-256). Adotamos boas práticas de segurança da informação conforme a norma ISO 27001.'),
      _LegalSection(heading: 'Retenção dos dados', text: 'O histórico físico do aluno é retido permanentemente enquanto a conta estiver ativa. Após o encerramento da conta, os dados são mantidos por 5 anos para fins legais e, posteriormente, anonimizados ou excluídos mediante solicitação expressa.'),
      _LegalSection(heading: 'Direitos do titular', text: 'Em conformidade com a LGPD (Lei 13.709/2018), você pode a qualquer momento: acessar seus dados, solicitar correção, portabilidade ou exclusão, e revogar consentimentos. Entre em contato pelo e-mail privacidade@personalteck.com.br.'),
      _LegalSection(heading: 'Menores de idade', text: 'O uso da plataforma por menores de 18 anos requer autorização expressa dos responsáveis legais. Não coletamos intencionalmente dados de crianças menores de 13 anos.'),
    ]),
  );
}

class _Termos extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _LegalSheet(
    title: 'Termos de Uso',
    body: const _LegalBody(sections: [
      _LegalSection(heading: 'Aceitação dos termos', text: 'Ao utilizar o Personal Teck, você concorda com estes Termos de Uso. Caso não concorde, não utilize o aplicativo.'),
      _LegalSection(heading: 'Cadastro e conta', text: 'Para usar a plataforma, é necessário criar uma conta com informações verdadeiras e atualizadas. Você é responsável pela confidencialidade de suas credenciais e por todas as atividades realizadas em sua conta.'),
      _LegalSection(heading: 'Uso permitido', text: 'O aplicativo é destinado ao uso pessoal e profissional legítimo relacionado à atividade física e saúde. É proibido usar a plataforma para fins ilegais, assediar outros usuários, ou violar direitos de terceiros.'),
      _LegalSection(heading: 'Responsabilidade sobre o conteúdo', text: 'O treinador é responsável pelas prescrições de treino inseridas na plataforma. A Tércio Informática não se responsabiliza por lesões decorrentes de programas elaborados pelos profissionais cadastrados.'),
      _LegalSection(heading: 'Planos e pagamentos', text: 'Os planos disponíveis (Basic, Pro e Plus) possuem cobranças mensais conforme tabela vigente. O cancelamento pode ser feito a qualquer momento, com acesso até o fim do período pago. Não há reembolso proporcional.'),
      _LegalSection(heading: 'Propriedade intelectual', text: 'Todo o conteúdo do aplicativo, incluindo código, design, textos e marca "Personal Teck", é propriedade da Tércio Informática e protegido por lei de direitos autorais.'),
      _LegalSection(heading: 'Rescisão', text: 'A Tércio Informática reserva-se o direito de suspender ou encerrar contas que violem estes Termos de Uso, sem aviso prévio e sem direito a reembolso.'),
      _LegalSection(heading: 'Foro', text: 'Estes Termos são regidos pelas leis brasileiras. Fica eleito o foro da Comarca de São Paulo/SP para dirimir qualquer controvérsia.'),
    ]),
  );
}

class _Contato extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _LegalSheet(
    title: 'Contato',
    body: const _LegalBody(sections: [
      _LegalSection(heading: 'Suporte ao usuário', text: 'suporte@personalteck.com.br\nAtendimento de segunda a sexta, das 9h às 18h (horário de Brasília).'),
      _LegalSection(heading: 'Privacidade e dados (LGPD)', text: 'privacidade@personalteck.com.br\nPara solicitações de acesso, correção, portabilidade ou exclusão de dados pessoais.'),
      _LegalSection(heading: 'Denúncias e abusos', text: 'denuncias@personalteck.com.br\nPara reportar uso indevido da plataforma ou comportamento inadequado.'),
      _LegalSection(heading: 'Comercial e parcerias', text: 'comercial@personalteck.com.br\nPara planos corporativos, parcerias com academias ou nutricionistas.'),
      _LegalSection(heading: 'Razão social', text: 'Tércio Informática\nCNPJ: 00.000.000/0001-00\nSão Paulo — SP — Brasil'),
    ]),
  );
}

class _Cookies extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _LegalSheet(
    title: 'Política de Cookies',
    body: const _LegalBody(sections: [
      _LegalSection(heading: 'O que são cookies?', text: 'Cookies são pequenos arquivos armazenados no seu dispositivo que nos ajudam a lembrar suas preferências e melhorar sua experiência no aplicativo.'),
      _LegalSection(heading: 'Cookies essenciais', text: 'Necessários para o funcionamento básico do app: manter sua sessão ativa, lembrar seu perfil (treinador ou aluno) e garantir a segurança do acesso. Não podem ser desativados.'),
      _LegalSection(heading: 'Cookies de desempenho', text: 'Coletam informações anônimas sobre como você usa o aplicativo (telas visitadas, tempo de sessão) para nos ajudar a melhorar a experiência. Podem ser desativados nas configurações do dispositivo.'),
      _LegalSection(heading: 'Cookies de publicidade', text: 'Usados para exibir anúncios relevantes (via Google AdSense e parceiros). Coletam dados como identificador de dispositivo e comportamento de navegação de forma agregada. Você pode optar por não participar em Configurações > Privacidade.'),
      _LegalSection(heading: 'Gerenciar preferências', text: 'Você pode limpar os dados de cache do aplicativo a qualquer momento pelas configurações do seu dispositivo. Para recusar cookies de publicidade, acesse Perfil > Preferências > Privacidade.'),
    ]),
  );
}

class _LegalBody extends StatelessWidget {
  final List<_LegalSection> sections;
  const _LegalBody({required this.sections});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: sections.map((s) => Padding(padding: const EdgeInsets.only(bottom: 20), child: s)).toList(),
  );
}

class _LegalSection extends StatelessWidget {
  final String heading;
  final String text;
  const _LegalSection({required this.heading, required this.text});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(heading, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PTColors.gray900)),
      const SizedBox(height: 4),
      Text(text, style: const TextStyle(fontSize: 13, color: PTColors.gray600, height: 1.55)),
    ],
  );
}
