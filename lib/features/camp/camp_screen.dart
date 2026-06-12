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

class CampScreen extends StatelessWidget {
  const CampScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    const cards = [
      _CampItem(
        'Çadırlar',
        'Ailelerin barındığı keçe çadırlar.',
        'Düzenli',
        {ResourceType.morale: 2, ResourceType.wood: -2},
      ),
      _CampItem(
        'Sürü',
        'Atlar ve küçükbaş hayvanlar kontrol edilir.',
        'Sağlıklı',
        {ResourceType.food: 4, ResourceType.horse: 1},
      ),
      _CampItem(
        'Avcılar',
        'İz süren avcılar sefere hazırlanır.',
        'Hazır',
        {ResourceType.food: 10, ResourceType.leather: 2},
      ),
      _CampItem(
        'Zanaatkârlar',
        'Deri, ahşap ve koşum işleri yapılır.',
        'Seviye 1',
        {ResourceType.leather: -2, ResourceType.reputation: 1},
      ),
      _CampItem(
        'Savaşçılar',
        'Nöbet ve talim düzeni kurulur.',
        'Nöbette',
        {ResourceType.morale: 2, ResourceType.food: -3},
      ),
      _CampItem(
        'Yaşlılar Meclisi',
        'Kararlara kadim hafıza rehberlik eder.',
        'Toplandı',
        {ResourceType.reputation: 1, ResourceType.morale: 1},
      ),
      _CampItem(
        'Depo',
        'Erzak ve odun stokları gözden geçirilir.',
        'Kuru',
        {ResourceType.food: 6, ResourceType.wood: 4},
      ),
    ];

    return AshinaScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const AssetPlaceholder(
            assetPath: GameAssets.bgCamp,
            label: 'Kamp / Oba Yönetimi',
            icon: Icons.festival_rounded,
          ),
          const SizedBox(height: 12),
          const Text('Kamp / Oba Yönetimi', style: AppTextStyles.title),
          const SizedBox(height: 8),
          for (final item in cards)
            AshinaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.section),
                  Text(item.description, style: AppTextStyles.body),
                  const SizedBox(height: 6),
                  Text(
                    'Durum: ${item.status} • '
                    '${Formatters.resourceDelta(item.effects)}',
                    style: AppTextStyles.meta,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AshinaButton(
                      label: 'Aksiyon',
                      onPressed: () => controller.performCampAction(
                        item.title,
                        item.effects,
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

class _CampItem {
  const _CampItem(this.title, this.description, this.status, this.effects);
  final String title;
  final String description;
  final String status;
  final Map<ResourceType, int> effects;
}
