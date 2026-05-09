import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';
import '../../widgets/avatar_circle.dart';
import '../../widgets/pt_card.dart';

class TrainerChatScreen extends StatelessWidget {
  const TrainerChatScreen({super.key});

  final List<_ConvMock> _convs = const [
    _ConvMock('1', 'Rafael Alves', 'Posso aumentar a carga no supino?', '14:32', 2, false),
    _ConvMock('2', 'Marina Costa', 'Treino de amanhã confirmado!', '11:10', 0, false),
    _ConvMock('3', 'Thiago Silva', 'Senti dor no joelho hoje...', '09:45', 1, false),
    _ConvMock('4', 'Julia Santos', 'Obrigada pelo treino novo 🙏', '08:20', 0, true),
    _ConvMock('5', 'Carlos Mendes', 'Quando começa a fase 2?', 'Ontem', 0, false),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: PTColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mensagens', style: t.headlineMedium),
              Text('${_convs.where((c) => c.unread > 0).length} não lidas', style: t.bodySmall),
            ]),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _convs.length,
              itemBuilder: (_, i) => _ConvTile(conv: _convs[i], onTap: () => _openChat(context, _convs[i])),
            ),
          ),
        ]),
      ),
    );
  }

  void _openChat(BuildContext context, _ConvMock conv) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _ChatDetailScreen(studentId: conv.id, studentName: conv.name),
    ));
  }
}

class _ConvTile extends StatelessWidget {
  final _ConvMock conv;
  final VoidCallback onTap;

  const _ConvTile({required this.conv, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PTCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Stack(children: [
          AvatarCircle(name: conv.name, size: 46),
          if (conv.online)
            Positioned(bottom: 0, right: 0, child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: PTColors.teal400,
                shape: BoxShape.circle,
                border: Border.all(color: PTColors.surface, width: 2),
              ),
            )),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(conv.name, style: Theme.of(context).textTheme.titleSmall)),
            Text(conv.time, style: const TextStyle(fontSize: 11, color: PTColors.gray400)),
          ]),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(child: Text(
              conv.lastMessage,
              style: TextStyle(fontSize: 13, color: conv.unread > 0 ? PTColors.gray900 : PTColors.gray400,
                  fontWeight: conv.unread > 0 ? FontWeight.w500 : FontWeight.w400),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
            if (conv.unread > 0)
              Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(color: PTColors.primary600, shape: BoxShape.circle),
                child: Center(child: Text('${conv.unread}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600))),
              ),
          ]),
        ])),
      ]),
    );
  }
}

// Tela de chat individual
class _ChatDetailScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  const _ChatDetailScreen({required this.studentId, required this.studentName});

  @override
  State<_ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<_ChatDetailScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  final List<_MsgMock> _messages = [
    _MsgMock('Oi treinador! Posso aumentar a carga no supino hoje?', false, '14:30'),
    _MsgMock('Claro! Tente +5kg. Se a técnica falhar, volte ao peso anterior.', true, '14:32'),
    _MsgMock('Entendido! Vou tentar 85kg então', false, '14:33'),
  ];

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_MsgMock(text, true, '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'));
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PTColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          AvatarCircle(name: widget.studentName, size: 32),
          const SizedBox(width: 10),
          Text(widget.studentName, style: Theme.of(context).textTheme.titleMedium),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.fitness_center_outlined), onPressed: () => context.push('/trainer/students/${widget.studentId}')),
        ],
      ),
      body: Column(children: [
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
                decoration: const BoxDecoration(color: PTColors.primary600, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _MsgMock msg;
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
          color: msg.isMe ? PTColors.primary600 : PTColors.surface,
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

class _ConvMock {
  final String id, name, lastMessage, time;
  final int unread;
  final bool online;
  const _ConvMock(this.id, this.name, this.lastMessage, this.time, this.unread, this.online);
}

class _MsgMock {
  final String text, time;
  final bool isMe;
  const _MsgMock(this.text, this.isMe, this.time);
}
