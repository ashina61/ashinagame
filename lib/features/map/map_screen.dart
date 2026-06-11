import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ashina_button.dart';
import '../../core/widgets/ashina_card.dart';
import '../../core/widgets/ashina_scaffold.dart';
import '../../core/widgets/asset_placeholder.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    const regions = [
      _Region(
        'Oba',
        'Düşük',
        'Moral',
        'Ateşin ve çadırların güvenli merkezi.',
        {ResourceType.morale: 2},
      ),
      _Region(
        'Irmak kıyısı',
        'Orta',
        'Odun / Bilgi',
        'Su yolları yeni geçitler fısıldar.',
        {ResourceType.wood: 6, ResourceType.morale: 1},
      ),
      _Region(
        'Avlak',
        'Orta',
        'Erzak / Deri',
        'Otların arasında izler belirgin.',
        {ResourceType.food: 12, ResourceType.leather: 2},
      ),
      _Region(
        'Ormanlık alan',
        'Orta',
        'Odun',
        'Rüzgâr ağaçların arasından sert eser.',
        {ResourceType.wood: 14, ResourceType.food: -2},
      ),
      _Region(
        'Dağ geçidi',
        'Yüksek',
        'İtibar',
        'Geçit riskli ama stratejik.',
        {ResourceType.reputation: 2, ResourceType.food: -4},
      ),
      _Region(
        'Eski yazıt',
        'Düşük',
        'Bilgelik',
        'Taşa vurulmuş damgalar geçmişi taşır.',
        {ResourceType.reputation: 1, ResourceType.morale: 2},
      ),
      _Region(
        'Ticaret yolu',
        'Orta',
        'Takas',
        'Kervan izleri tozlu yolda kaybolur.',
        {ResourceType.food: 8, ResourceType.leather: -2},
      ),
    ];

    return AshinaScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const AssetPlaceholder(
            assetPath: GameAssets.locationRiver,
            label: 'Bozkır Haritası',
            icon: Icons.map_rounded,
          ),
          const SizedBox(height: 12),
          Text('Harita', style: AppTextStyles.title),
          const SizedBox(height: 8),
          for (final region in regions)
            AshinaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(region.name, style: AppTextStyles.section),
                  Text(region.description, style: AppTextStyles.body),
                  const SizedBox(height: 6),
                  Text(
                    'Risk: ${region.risk} • Ödül: ${region.reward} • '
                    '${Formatters.resourceDelta(region.effects)}',
                    style: AppTextStyles.meta,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AshinaButton(
                      label: 'Keşfet',
                      icon: Icons.explore_rounded,
                      onPressed: () => controller.exploreRegion(
                        region.name,
                        region.effects,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Region {
  const _Region(this.name, this.risk, this.reward, this.description, this.effects);
  final String name;
  final String risk;
  final String reward;
  final String description;
  final Map<ResourceType, int> effects;
}
