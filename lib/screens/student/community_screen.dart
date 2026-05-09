import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/pt_card.dart';
import '../../widgets/avatar_circle.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<_Post> _posts = [
    _Post('Rafael Alves', 'Finalizei o Treino B hoje! PR no supino: 90kg 🎉', '5 min', 12, true),
    _Post('Marina Costa', 'Primeira semana completa sem faltar nenhum treino. Muito orgulhosa!', '1h', 8, false),
    _Post('Carlos Ferreira', '📢 Lembrete: semana que vem teremos avaliação física. Se preparem!', '2h', 15, false, isAnnouncement: true),
    _Post('Thiago Silva', 'Dica rápida: foco na técnica > carga. Vale mais 40kg certo que 60kg errado.', '3h', 22, true),
    _Post('Julia Santos', 'Alguém tem dica para dor muscular nas coxas depois do leg press?', '5h', 6, false),
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
            child: Row(children: [
              Text('Feed', style: t.headlineMedium),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showNewPost(context),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Publicar'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
              ),
            ]),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _posts.length,
              itemBuilder: (_, i) => _PostCard(
                post: _posts[i],
                onLike: () => setState(() => _posts[i] = _posts[i].toggleLike()),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _showNewPost(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PTColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nova publicação', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Compartilhe algo com a turma...'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: PTColors.teal400),
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  setState(() => _posts.insert(0, _Post('Você', ctrl.text.trim(), 'Agora', 0, false)));
                  Navigator.pop(context);
                }
              },
              child: const Text('Publicar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final _Post post;
  final VoidCallback onLike;

  const _PostCard({required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PTCard(
      margin: const EdgeInsets.only(bottom: 10),
      color: post.isAnnouncement ? PTColors.primary50 : PTColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          AvatarCircle(
            name: post.author,
            size: 36,
            bgColor: post.isAnnouncement ? PTColors.primary100 : null,
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(post.author, style: t.titleSmall),
              if (post.isAnnouncement) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: PTColors.primary600, borderRadius: BorderRadius.circular(99)),
                  child: const Text('Treinador', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
            Text(post.time, style: t.bodySmall),
          ])),
        ]),
        const SizedBox(height: 10),
        Text(post.content, style: t.bodyMedium?.copyWith(color: PTColors.gray900)),
        const SizedBox(height: 10),
        Row(children: [
          GestureDetector(
            onTap: onLike,
            child: Row(children: [
              Icon(post.liked ? Icons.favorite : Icons.favorite_border,
                  size: 18, color: post.liked ? PTColors.red400 : PTColors.gray400),
              const SizedBox(width: 4),
              Text('${post.likes}', style: const TextStyle(fontSize: 13, color: PTColors.gray400)),
            ]),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.chat_bubble_outline, size: 16, color: PTColors.gray400),
          const SizedBox(width: 4),
          const Text('Responder', style: TextStyle(fontSize: 13, color: PTColors.gray400)),
        ]),
      ]),
    );
  }
}

class _Post {
  final String author, content, time;
  final int likes;
  final bool liked;
  final bool isAnnouncement;

  const _Post(this.author, this.content, this.time, this.likes, this.liked, {this.isAnnouncement = false});

  _Post toggleLike() => _Post(author, content, time, liked ? likes - 1 : likes + 1, !liked, isAnnouncement: isAnnouncement);
}
