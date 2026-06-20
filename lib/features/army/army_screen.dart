import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/resource.dart';
import '../../game/models/unit_type.dart';
import '../../game/state/game_scope.dart';

class ArmyScreen extends StatefulWidget {
  const ArmyScreen({super.key});

  @override
  State<ArmyScreen> createState() => _ArmyScreenState();
}

class _ArmyScreenState extends State<ArmyScreen> {
  @override
  void initState() {
    super.initState();
    AudioService.instance.playMusic('battle');
  }

  @override
  void dispose() {
    AudioService.instance.playMusic('theme');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;

    return Scaffold(
      body: OrnateScaffold(
        backgroundAsset: GameAssets.sceneBattlefieldDusk,
        scrim: true,
        child: Column(
          children: [
            const OrnateHeader(title: 'Ordu', showBack: true),
            OrnatePanel(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asker: ${state.totalSoldiers} / '
                          '${controller.armyCapacity}',
                          style: AppTextStyles.bodyStrong,
                        ),
                        Text(
                          'Yaralı: ${state.totalWounded} • Kışla ve Tımar '
                          'düzeni kapasiteyi büyütür',
                          style: AppTextStyles.meta,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Text('Ordu Gücü', style: AppTextStyles.meta),
                      Text(
                        '${controller.armyStrength}',
                        style: AppTextStyles.value.copyWith(
                          color: AppColors.goldBright,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (controller.armyUpkeep.isNotEmpty)
              OrnatePanel(
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_dining,
                      size: 16,
                      color: AppColors.ember,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Günlük bakım: '
                        '${-(controller.armyUpkeep[ResourceType.gold] ?? 0)} altın, '
                        '${-(controller.armyUpkeep[ResourceType.food] ?? 0)} erzak. '
                        'Büyük ordu hazineyi ve kileri yer — gücünü ihtiyacına göre tut.',
                        style: AppTextStyles.meta,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  const SectionPlaque('BİRLİK TOPLA'),
                  for (final unit in UnitTypes.all) _UnitPanel(unit: unit),
                  if (state.totalWounded > 0) ...[
                    const SectionPlaque('YARALILAR (TEDAVİDE)'),
                    OrnatePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final entry in state.wounded.entries)
                            if (entry.value > 0)
                              Text(
                                '${UnitTypes.byId(entry.key)?.name ?? entry.key}'
                                ': ${entry.value}',
                                style: AppTextStyles.body,
                              ),
                          const SizedBox(height: 4),
                          const Text(
                            'Yaralılar her gün şifacı çadırında iyileşip '
                            'orduya döner; çadırı yükselt, daha hızlı iyileşir.',
                            style: AppTextStyles.meta,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitPanel extends StatelessWidget {
  const _UnitPanel({required this.unit});

  final UnitType unit;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final cost = UnitTypes.recruitCost(unit, 1);
    final affordable = cost.entries.every(
      (e) => state.resource(e.key) >= e.value,
    );
    final hasAp = state.dailyActionPoints > 0;
    final hasRoom = controller.armyHeadroom > 0;
    final costText =
        cost.entries.map((e) => '${e.value} ${e.key.label}').join(', ');

    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  unit.name,
                  style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
                ),
              ),
              Text(
                'x${state.unitCount(unit.id)}',
                style: AppTextStyles.value.copyWith(fontSize: 14),
              ),
            ],
          ),
          Text(
            'Saldırı ${unit.attack} • Savunma ${unit.defense}'
            '${unit.requiresHorse ? ' • Atlı' : ''}',
            style: AppTextStyles.meta,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasRoom ? 'Bedel: $costText' : 'Ordu kapasitesi dolu',
                  style: AppTextStyles.meta.copyWith(
                    color: hasRoom ? null : AppColors.danger,
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: DarkButton(
                  label: 'TOPLA',
                  height: 34,
                  onPressed: hasAp && affordable && hasRoom
                      ? () {
                          final ok = controller.recruitUnit(unit.id, 1);
                          AudioService.instance.playSfx(ok ? 'coin' : 'denied');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? '${unit.name} orduya katıldı.'
                                    : 'Aksiyon, kaynak ya da kapasite yetersiz.',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
