import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/ashina_button.dart';
import '../../core/widgets/ashina_card.dart';
import '../../core/widgets/ashina_scaffold.dart';
import '../../game/state/game_scope.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool sound = true;
  bool notifications = false;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    return Scaffold(
      body: AshinaScaffold(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('Ayarlar', style: AppTextStyles.title),
            const SizedBox(height: 8),
            AshinaCard(
              child: Column(
                children: [
                  SwitchListTile(
                    value: sound,
                    onChanged: (value) => setState(() => sound = value),
                    title: const Text('Ses açık'),
                    subtitle: const Text('Ses sistemi için placeholder.'),
                  ),
                  SwitchListTile(
                    value: notifications,
                    onChanged: (value) => setState(() => notifications = value),
                    title: const Text('Bildirimler'),
                    subtitle: const Text('İleride yerel bildirimlere bağlanacak.'),
                  ),
                ],
              ),
            ),
            AshinaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hakkında', style: AppTextStyles.section),
                  Text('Ashina: Bozkırda Bir Ömür playable foundation. Binary asset içermez.', style: AppTextStyles.body),
                  const SizedBox(height: 12),
                  AshinaButton(
                    label: 'Oyunu sıfırla',
                    icon: Icons.restart_alt_rounded,
                    onPressed: controller.resetGame,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
