import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import '../found_oba/found_oba_screen.dart';
import '../result/result_scaffold.dart';

/// Shown when the leader dies of old age; the realm passes to an heir
/// instead of ending, carrying the clan into the next generation.
class SuccessionScreen extends StatelessWidget {
  const SuccessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final late = state.profile;

    return ResultScaffold(
      backgroundAsset: GameAssets.bgSceneCampNight,
      bannerWidth: 96,
      title: 'MİRAS',
      subtitle: '${state.generation}. NESİL SONA ERDİ',
      body: [
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
              ResultRow('Yaşanan Gün', '${state.day.day}'),
              ResultRow('İtibar', '${late.reputation}'),
              ResultRow('Halk', '${state.resource(ResourceType.population)}'),
              ResultRow(
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
      ],
      actions: [
        GoldButton(
          label: 'SOYUNLA DEVAM ET',
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
        DarkButton(
          label: 'YENİ OBA KUR',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const FoundObaScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
