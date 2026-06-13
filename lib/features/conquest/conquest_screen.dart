import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/conquest_regions.dart';
import '../../game/models/conquest_region.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';

class ConquestScreen extends StatelessWidget {
  const ConquestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final conquered = state.conqueredRegions.length;
    final total = ConquestRegions.all.length;
    final unified = conquered >= total;

    return Scaffold(
      body: OrnateScaffold(
        backgroundAsset: GameAssets.bgMapParchment,
        child: Column(
          children: [
            const OrnateHeader(title: 'Fetih Haritası', showBack: true),
            OrnatePanel(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      unified
                          ? 'Bütün bozkır senin tamganın altında!'
                          : 'Diplomasiyle kazan ya da kılıçla al. Amaç: '
                              'bozkırı birleştirmek.',
                      style: AppTextStyles.body,
                    ),
                  ),
                  Column(
                    children: [
                      const Text('Fethedilen', style: AppTextStyles.meta),
                      Text('$conquered/$total',
                          style: AppTextStyles.value
                              .copyWith(color: AppColors.goldBright)),
                      Text('Güç ${controller.warStrength}',
                          style: AppTextStyles.meta),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  for (final region in ConquestRegions.all)
                    _RegionPanel(region: region),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionPanel extends StatelessWidget {
  const _RegionPanel({required this.region});

  final ConquestRegion region;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final conquered = state.regionConquered(region.id);
    final relation = controller.regionRelation(region);
    final canAnnex = controller.canAnnex(region);
    final hasAp = state.dailyActionPoints > 0;
    final chance = controller.warChanceFor(region);

    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(region.name,
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 16)),
              ),
              Text(
                conquered ? 'Senin' : 'Bağımsız',
                style: AppTextStyles.value.copyWith(
                  fontSize: 14,
                  color: conquered ? AppColors.success : AppColors.goldBright,
                ),
              ),
            ],
          ),
          Text('Bey: ${region.holder} • Garnizon ${region.power}',
              style: AppTextStyles.meta),
          if (!conquered) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(
                    width: 64,
                    child: Text('İlişki', style: AppTextStyles.meta)),
                Expanded(child: StatBar(fraction: relation / 100, height: 9)),
                const SizedBox(width: 8),
                Text('$relation/100', style: AppTextStyles.meta),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                SizedBox(
                  width: 104,
                  child: DarkButton(
                    label: 'Diplomasi',
                    height: 34,
                    onPressed: hasAp && state.resource(ResourceType.gold) >= 80
                        ? () => _act(
                            context,
                            controller.improveRegionRelation(region.id),
                            'İlişki geliştirildi.')
                        : null,
                  ),
                ),
                SizedBox(
                  width: 104,
                  child: DarkButton(
                    label: 'İlhak',
                    height: 34,
                    onPressed: canAnnex
                        ? () => _act(context, controller.annexRegion(region.id),
                            '${region.name} barışla alındı.')
                        : null,
                  ),
                ),
                SizedBox(
                  width: 132,
                  child: GoldButton(
                    label: 'SALDIR  %$chance',
                    height: 34,
                    onPressed: hasAp
                        ? () {
                            final won = controller.attackRegion(region.id);
                            AudioService.instance
                                .playSfx(won ? 'victory' : 'defeat');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(won
                                    ? '${region.name} fethedildi!'
                                    : 'Saldırı püskürtüldü; kayıp verdin.'),
                              ),
                            );
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _act(BuildContext context, bool ok, String okMsg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(ok ? okMsg : 'Koşullar uygun değil (aksiyon/altın/ilişki).'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
