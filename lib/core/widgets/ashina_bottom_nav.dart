import 'package:flutter/material.dart';

class AshinaBottomNav extends StatelessWidget {
  const AshinaBottomNav({
    required this.index,
    required this.onChanged,
    super.key,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onChanged,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_work_outlined),
          selectedIcon: Icon(Icons.home_work),
          label: 'Oba',
        ),
        NavigationDestination(
          icon: Icon(Icons.tent_outlined),
          selectedIcon: Icon(Icons.festival),
          label: 'Kamp',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Harita',
        ),
        NavigationDestination(
          icon: Icon(Icons.flag_outlined),
          selectedIcon: Icon(Icons.flag),
          label: 'Görevler',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Karakter',
        ),
      ],
    );
  }
}
