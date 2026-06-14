import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/nations.dart';
import '../../game/models/nation.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import 'battle_report_dialog.dart';

class ConquestScreen extends StatefulWidget {
  const ConquestScreen({super.key});

  @override
  State<ConquestScreen> createState() => _ConquestScreenState();
}

class _ConquestScreenState extends State<ConquestScreen> {
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
            const _RaidThreatBanner(),
            const _MarchBanner(),
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

/// A small pulsing red dot marking a province on the brink of revolt.
class _RebellionPulse extends StatefulWidget {
  const _RebellionPulse();

  @override
  State<_RebellionPulse> createState() => _RebellionPulseState();
}

class _RebellionPulseState extends State<_RebellionPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.danger,
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withValues(alpha: 0.3 + _c.value * 0.5),
              blurRadius: 4 + _c.value * 8,
            ),
          ],
        ),
      ),
    );
  }
}

/// A banner naming the strongest still-free nation as a looming raid threat,
/// so the map feels watched rather than inert.
class _RaidThreatBanner extends StatelessWidget {
  const _RaidThreatBanner();

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;

    // An active, counting-down raid takes priority over the idle threat line,
    // and offers the player a real choice: brace, parley, strike or pull back.
    if (state.raidLooming) {
      final nation = Nations.byId(state.raidFrom);
      return _banner(
        '${nation?.name ?? 'Düşman'} akını ${state.raidCountdown} gün sonra '
        'geliyor! Ne yapacaksın?',
        strong: true,
        actions: [
          _RaidChoice('Savun', 'defend', controller),
          _RaidChoice('Elçi', 'envoy', controller),
          _RaidChoice('Baskın', 'preempt', controller),
          _RaidChoice('Tahliye', 'evacuate', controller),
        ],
      );
    }

    Nation? threat;
    var best = -1;
    for (final n in Nations.all) {
      if (state.nationConquered(n.id)) continue;
      if (n.center.power > best) {
        best = n.center.power;
        threat = n;
      }
    }
    if (threat == null) return const SizedBox.shrink();
    return _banner(
      'Sınırda hareket var: ${threat.name} (${threat.ruler}) akına '
      'hazırlanıyor.',
    );
  }

  Widget _banner(String text, {bool strong = false, List<Widget>? actions}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.leatherDeep.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: strong ? 0.9 : 0.6),
          width: strong ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _RebellionPulse(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.meta
                      .copyWith(color: strong ? AppColors.danger : null),
                ),
              ),
            ],
          ),
          if (actions != null) ...[
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: actions),
          ],
        ],
      ),
    );
  }
}

/// One response chip for a looming raid.
class _RaidChoice extends StatelessWidget {
  const _RaidChoice(this.label, this.action, this.controller);

  final String label;
  final String action;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: DarkButton(
        label: label,
        height: 32,
        onPressed: controller.state.dailyActionPoints > 0
            ? () {
                final ok = controller.respondToRaid(action);
                AudioService.instance.playSfx(ok ? 'tap' : 'denied');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Karar verildi: $label.'
                        : 'Bu karar için aksiyon/kaynak yetersiz.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            : null,
      ),
    );
  }
}

/// A banner showing the army on campaign and how far it has to go.
class _MarchBanner extends StatelessWidget {
  const _MarchBanner();

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final castle = controller.marchCastle;
    if (castle == null) return const SizedBox.shrink();
    final left = controller.state.marchDaysLeft;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.leatherDeep.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldBright.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, size: 16, color: AppColors.goldBright),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              left > 0
                  ? 'Ordu ${castle.name} yolunda — ${controller.marchStatus}, '
                      '$left gün kaldı.'
                  : 'Ordu ${castle.name} önünde — kuşatma başlıyor.',
              style: AppTextStyles.meta.copyWith(color: AppColors.goldBright),
            ),
          ),
        ],
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

    final held = policy != null && policy != NationPolicy.yik;
    final loyalty = state.loyaltyOf(nation.id);

    return Column(
      children: [
        SectionPlaque('${nation.name} • ${nation.ruler}'),
        if (policy != null)
          OrnatePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                        policy == NationPolicy.yik
                            ? Icons.local_fire_department
                            : Icons.flag,
                        color: AppColors.success,
                        size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Bu il senin: ${policy.label}',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.success)),
                    ),
                  ],
                ),
                if (held) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(
                          width: 64,
                          child: Text('Sadakat', style: AppTextStyles.meta)),
                      Expanded(
                        child: StatBar(
                          fraction: loyalty / 100,
                          height: 9,
                          fill: loyalty >= 50
                              ? AppColors.success
                              : loyalty >= 25
                                  ? AppColors.amber
                                  : AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$loyalty/100', style: AppTextStyles.meta),
                    ],
                  ),
                  if (loyalty < 50)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          if (loyalty < 25) ...[
                            const _RebellionPulse(),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              loyalty < 25
                                  ? 'İSYAN EŞİĞİNDE! Sadakati tazele.'
                                  : 'Huzursuzluk artıyor.',
                              style: AppTextStyles.meta
                                  .copyWith(color: AppColors.danger),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 160,
                    child: DarkButton(
                      label: 'SADAKAT TAZELE',
                      height: 34,
                      onPressed: state.dailyActionPoints > 0 &&
                              state.resource(ResourceType.gold) >= 60
                          ? () {
                              final ok =
                                  controller.reinforceProvince(nation.id);
                              AudioService.instance
                                  .playSfx(ok ? 'coin' : 'denied');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? '${nation.name} sadakati arttı (60 altın).'
                                      : 'Aksiyon ya da altın yetersiz.'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                  if (loyalty < 50) ...[
                    const SizedBox(height: 8),
                    const Text('İsyana karşı kararlar:',
                        style: AppTextStyles.meta),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final (label, action) in const [
                          ('Vergiyi Düşür', 'lower_tax'),
                          ('Garnizon', 'garrison'),
                          ('Sert Bastır', 'suppress'),
                          ('Erzak Yardımı', 'gift'),
                          ('Vali Değiştir', 'replace'),
                        ])
                          SizedBox(
                            width: 116,
                            child: DarkButton(
                              label: label,
                              height: 30,
                              onPressed: state.dailyActionPoints > 0
                                  ? () {
                                      final ok = controller.manageProvince(
                                          nation.id, action);
                                      AudioService.instance
                                          .playSfx(ok ? 'tap' : 'denied');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(ok
                                            ? '$label uygulandı.'
                                            : 'Aksiyon/kaynak yetersiz.'),
                                        duration: const Duration(seconds: 2),
                                      ));
                                    }
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
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
                            final report = controller.lastBattle;
                            if (report != null) {
                              showDialog<void>(
                                context: context,
                                builder: (_) => BattleReportDialog(report),
                              );
                            }
                          }
                        : null,
                  ),
                ),
                SizedBox(
                  width: 132,
                  child: DarkButton(
                    label: state.marchTarget == castle.id
                        ? '${controller.marchStatus} ${state.marchDaysLeft}g'
                        : 'SEFER ${controller.marchDaysTo(castle)}g',
                    height: 34,
                    onPressed: !state.marching &&
                            hasAp &&
                            state.resource(ResourceType.food) >=
                                controller.marchFoodCost(castle)
                        ? () => _act(context, controller.startMarch(castle.id),
                            'Ordu ${castle.name} üzerine yürüyüşe geçti.')
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
    if (!ok) AudioService.instance.playSfx('denied');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(ok ? okMsg : 'Koşullar uygun değil (aksiyon/altın/ilişki).'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
