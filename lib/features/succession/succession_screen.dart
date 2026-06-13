import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';

/// Shown when the leader dies of old age; the realm passes to an heir
/// instead of ending, carrying the clan into the next generation.
class SuccessionScreen extends StatelessWidget {
  const SuccessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final late = state.profile;

    return OrnateScaffold(
      backgroundAsset: GameAssets.bgSceneCampNight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                GameAssets.uiBannerWolfTall,
                width: 96,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 10),
            Text('MİRAS', style: AppTextStyles.display.copyWith(fontSize: 36)),
            Text(
              '${state.generation}. NESİL SONA ERDİ',
              style: AppTextStyles.section.copyWith(letterSpacing: 3),
            ),
            const SizedBox(height: 14),
            OrnatePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${late.name} göçtü.',
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${late.title} olarak ${late.age} yıl yaşadı ve '
                    '${state.clan.name} obasını bozkırın bir gücü hâline '
                    'getirdi. Şimdi soyu ocağı devralacak.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 12),
                  _LegacyRow('Yaşanan Gün', '${state.day.day}'),
                  _LegacyRow('İtibar', '${late.reputation}'),
                  _LegacyRow(
                    'Halk',
                    '${state.resource(ResourceType.population)}',
                  ),
                  _LegacyRow(
                    'Hazine',
                    '${state.resource(ResourceType.gold)} altın',
                  ),
                ],
              ),
            ),
            const OrnatePanel(
              child: Text(
                'Mirasçı, atalarının ustalığının bir kısmını miras alır; '
                'cenaze töreni hazineden bir pay götürür ve liderlik boşluğu '
                'morali sarsar.',
                style: AppTextStyles.meta,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 8, 48, 0),
              child: GoldButton(
                label: 'MİRASI DEVRAL',
                onPressed: () {
                  controller.succeedWithHeir();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${controller.state.profile.name} obanın başına geçti.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegacyRow extends StatelessWidget {
  const _LegacyRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(
            value,
            style: AppTextStyles.value.copyWith(color: AppColors.goldBright),
          ),
        ],
      ),
    );
  }
}
