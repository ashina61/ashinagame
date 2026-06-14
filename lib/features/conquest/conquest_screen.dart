import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/nations.dart';
import '../../game/models/nation.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';

class ConquestScreen extends StatelessWidget {
  const ConquestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final castles = Nations.allCastles.length;
    final taken = state.conqueredRegions
        .where((id) => Nations.castleById(id) != null)
        .length;
    final pending = controller.pendingNation;

    return Scaffold(
      body: OrnateScaffold(
        backgroundAsset: GameAssets.bgMapParchment,
        child: Column(
          children: [
            const OrnateHeader(title: 'Fetih Haritası', showBack: true),
            OrnatePanel(
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Her elin dört kalesini al, sonra başkentini kuşat. '
                      'Başkent düşünce ilin kaderine sen karar verirsin.',
                      style: AppTextStyles.body,
                    ),
                  ),
                  Column(
                    children: [
                      const Text('Kaleler', style: AppTextStyles.meta),
                      Text('$taken/$castles',
                          style: AppTextStyles.value
                              .copyWith(color: AppColors.goldBright)),
                      Text(
                          'İl ${controller.conqueredNations}/'
                          '${Nations.all.length}',
                          style: AppTextStyles.meta),
                      Text('Güç ${controller.warStrength}',
                          style: AppTextStyles.meta),
                    ],
                  ),
                ],
              ),
            ),
            if (pending != null) _GovernancePanel(nation: pending),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  for (final nation in Nations.all)
                    _NationBlock(nation: nation),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where the verdict for a freshly fallen capital is rendered.
class _GovernancePanel extends StatelessWidget {
  const _GovernancePanel({required this.nation});

  final Nation nation;

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${nation.name} dize geldi',
              style: AppTextStyles.bodyStrong
                  .copyWith(color: AppColors.goldBright, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('İlin kaderini belirle:', style: AppTextStyles.meta),
          const SizedBox(height: 8),
          for (final policy in NationPolicy.values) ...[
            _PolicyButton(nation: nation, policy: policy),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PolicyButton extends StatelessWidget {
  const _PolicyButton({required this.nation, required this.policy});

  final Nation nation;
  final NationPolicy policy;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    return GestureDetector(
      onTap: () {
        final ok = controller.decideNationPolicy(nation.id, policy);
        if (ok) AudioService.instance.playSfx('victory');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                ok ? '${nation.name}: ${policy.label}.' : 'Karar verilemedi.'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.leatherDeep.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(policy.label,
                style: AppTextStyles.bodyStrong
                    .copyWith(color: AppColors.goldBright)),
            const SizedBox(height: 2),
            Text(policy.blurb, style: AppTextStyles.meta),
          ],
        ),
      ),
    );
  }
}

class _NationBlock extends StatelessWidget {
  const _NationBlock({required this.nation});

  final Nation nation;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final policyId = state.nationPolicies[nation.id];
    final policy = policyId == null ? null : NationPolicyInfo.byId(policyId);

    return Column(
      children: [
        SectionPlaque('${nation.name} • ${nation.ruler}'),
        if (policy != null)
          OrnatePanel(
            child: Row(
              children: [
                const Icon(Icons.flag, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Bu il senin: ${policy.label}',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.success)),
                ),
              ],
            ),
          ),
        for (final castle in nation.castles) _CastlePanel(castle: castle),
      ],
    );
  }
}

class _CastlePanel extends StatelessWidget {
  const _CastlePanel({required this.castle});

  final Castle castle;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final conquered = state.regionConquered(castle.id);
    final locked = controller.centerLocked(castle);
    final relation = controller.regionRelation(castle);
    final canAnnex = controller.canAnnex(castle);
    final hasAp = state.dailyActionPoints > 0;
    final chance = controller.warChanceFor(castle);

    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (castle.isCenter)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child:
                      Icon(Icons.castle, color: AppColors.goldBright, size: 18),
                ),
              Expanded(
                child: Text(
                  castle.isCenter ? '${castle.name} (Başkent)' : castle.name,
                  style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
                ),
              ),
              Text(
                conquered
                    ? 'Senin'
                    : locked
                        ? 'Kilitli'
                        : 'Bağımsız',
                style: AppTextStyles.value.copyWith(
                  fontSize: 14,
                  color: conquered
                      ? AppColors.success
                      : locked
                          ? AppColors.stone
                          : AppColors.goldBright,
                ),
              ),
            ],
          ),
          Text('Garnizon ${castle.power}', style: AppTextStyles.meta),
          if (!conquered && locked)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Önce ilin dört kalesini al.',
                  style: AppTextStyles.meta),
            ),
          if (!conquered && !locked) ...[
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
                            controller.improveRegionRelation(castle.id),
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
                        ? () => _act(context, controller.annexRegion(castle.id),
                            '${castle.name} barışla alındı.')
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
                            final won = controller.attackRegion(castle.id);
                            AudioService.instance
                                .playSfx(won ? 'victory' : 'defeat');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(won
                                    ? '${castle.name} fethedildi!'
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
