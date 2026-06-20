import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/resource.dart';
import '../../game/models/unit_type.dart';
import '../../game/state/game_scope.dart';
import '../scene/scene_hud_overlay.dart';

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
            const ResourceStrip(),
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
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                    children: [
                      for (final unit in UnitTypes.all) _UnitTile(unit: unit),
                    ],
                  ),
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

/// A compact recruit tile in the army grid: the unit, its count, attack /
/// defence, the per-soldier cost and a TOPLA button that respects gold, the
/// action point and the army-capacity ceiling.
class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.unit});

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

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A140C), Color(0xFF241B10)],
        ),
        border: Border.all(color: AppColors.goldDim, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  unit.name,
                  style: AppTextStyles.bodyStrong.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'x${state.unitCount(unit.id)}',
                style: AppTextStyles.value
                    .copyWith(fontSize: 13, color: AppColors.goldBright),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.colorize, size: 12, color: AppColors.ember),
              Text(' ${unit.attack}', style: AppTextStyles.meta),
              const SizedBox(width: 8),
              const Icon(Icons.shield, size: 12, color: AppColors.info),
              Text(' ${unit.defense}', style: AppTextStyles.meta),
              if (unit.requiresHorse) ...[
                const SizedBox(width: 6),
                const Icon(Icons.bedtime, size: 12, color: AppColors.stone),
              ],
            ],
          ),
          const Spacer(),
          Text(
            hasRoom ? costText : 'Kapasite dolu',
            style: AppTextStyles.meta.copyWith(
              fontSize: 11,
              color: hasRoom ? AppColors.stone : AppColors.danger,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: DarkButton(
              label: 'TOPLA',
              height: 32,
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
    );
  }
}
