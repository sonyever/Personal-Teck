import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';

class StudentShell extends StatelessWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  int _tabIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/student/progress')) return 1;
    if (loc.startsWith('/student/chat')) return 2;
    if (loc.startsWith('/student/community')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _tabIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: PTColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          selectedItemColor: PTColors.teal400,
          onTap: (i) {
            switch (i) {
              case 0: context.go('/student/workout');
              case 1: context.go('/student/progress');
              case 2: context.go('/student/chat');
              case 3: context.go('/student/community');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: 'Treino'),
            BottomNavigationBarItem(icon: Icon(Icons.trending_up_outlined), activeIcon: Icon(Icons.trending_up), label: 'Evolução'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Feed'),
          ],
        ),
      ),
    );
  }
}
