import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/avatar_circle.dart';

class StudentChatScreen extends StatefulWidget {
  const StudentChatScreen({super.key});

  @override
  State<StudentChatScreen> createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  final List<_Msg> _messages = [
    _Msg('Oi! Seu novo treino está pronto. Confira na aba Treino.', false, '09:00'),
    _Msg('Ótimo! Posso substituir a remada por puxada?', true, '09:15'),
    _Msg('Sim, pode! Puxada frontal é boa substituição. Use agarre médio.', false, '09:17'),
    _Msg('Entendido, obrigado! 💪', true, '09:18'),
  ];

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text, true, _now()));
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  String _now() => '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PTColors.background,
      body: SafeArea(
        child: Column(children: [
          // Header do treinador
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: const BoxDecoration(
              color: PTColors.surface,
              border: Border(bottom: BorderSide(color: PTColors.border, width: 0.5)),
            ),
            child: Row(children: [
              Stack(children: [
                const AvatarCircle(name: 'Carlos Ferreira', size: 44, bgColor: PTColors.primary100),
                Positioned(bottom: 0, right: 0, child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: PTColors.teal400, shape: BoxShape.circle, border: Border.all(color: PTColors.surface, width: 2)),
                )),
              ]),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Carlos Ferreira', style: t.titleSmall),
                const Text('Seu treinador · online', style: TextStyle(fontSize: 12, color: PTColors.teal400)),
              ]),
            ]),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _Bubble(msg: _messages[i]),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: const BoxDecoration(
              color: PTColors.surface,
              border: Border(top: BorderSide(color: PTColors.border, width: 0.5)),
            ),
            child: Row(children: [
              Expanded(child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(hintText: 'Mensagem...'),
                onSubmitted: (_) => _send(),
              )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(color: PTColors.teal400, shape: BoxShape.circle),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Msg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: msg.isMe ? PTColors.teal400 : PTColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: msg.isMe ? null : Border.all(color: PTColors.border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          Text(msg.text, style: TextStyle(fontSize: 14, color: msg.isMe ? Colors.white : PTColors.gray900)),
          const SizedBox(height: 2),
          Text(msg.time, style: TextStyle(fontSize: 10, color: msg.isMe ? Colors.white54 : PTColors.gray400)),
        ]),
      ),
    );
  }
}

class _Msg {
  final String text, time;
  final bool isMe;
  const _Msg(this.text, this.isMe, this.time);
}
