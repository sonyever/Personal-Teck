import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';

class NutritionistShell extends StatelessWidget {
  final Widget child;
  const NutritionistShell({super.key, required this.child});

  int _tabIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/nutritionist/patients')) return 1;
    if (loc.startsWith('/nutritionist/chat')) return 2;
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
          onTap: (i) {
            switch (i) {
              case 0: context.go('/nutritionist/dashboard');
              case 1: context.go('/nutritionist/patients');
              case 2: context.go('/nutritionist/chat');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined),  activeIcon: Icon(Icons.dashboard),      label: 'Início'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline),       activeIcon: Icon(Icons.people),         label: 'Pacientes'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline),  activeIcon: Icon(Icons.chat_bubble),    label: 'Chat'),
          ],
        ),
      ),
    );
  }
}
