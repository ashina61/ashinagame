import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/ashina_card.dart';
import '../../core/widgets/ashina_scaffold.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  static const items = [
    'Yay',
    'Kılıç',
    'Deri zırh',
    'Kurutulmuş et',
    'At koşumu',
    'Eski yazıt parçası',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AshinaScaffold(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Text('Envanter', style: AppTextStyles.title),
            const SizedBox(height: 8),
            for (final item in items)
              AshinaCard(
                child: ListTile(
                  leading: const Icon(Icons.circle_outlined),
                  title: Text(item),
                  subtitle: const Text('Placeholder eşya kaydı'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
