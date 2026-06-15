import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/info_sheet.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/game_info.dart';
import '../../game/logic/phase_logic.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../expeditions/expeditions_screen.dart';
import '../scene/floating_text.dart';
import '../scene/scene_background.dart';
import '../scene/scene_detail_panel.dart';
import '../scene/scene_hotspot.dart';

/// "Yolculuk" — a small parchment map of the near country. Tapping a place
/// scouts it for a little reward and reveals ground to settle on. The great
/// campaign map stays locked until the player has an oba and the strength to
/// ride far.
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({this.showBack = true, super.key});

  final bool showBack;

  static final _rng = Random();

  static const _sites = <_Site>[
    _Site('river', 'Irmak Kıyısı', 0.22, 0.3, 'Düşük'),
    _Site('forest', 'Ormanlık', 0.5, 0.24, 'Düşük'),
    _Site('hunt', 'Avlak', 0.74, 0.32, 'Orta'),
    _Site('market', 'Pazar Yolu', 0.3, 0.62, 'Düşük'),
    _Site('inscription', 'Eski Yazıt', 0.58, 0.66, 'Orta'),
    _Site('pass', 'Tepelik Geçit', 0.82, 0.62, 'Yüksek'),
  ];

  /// Each place can play out a few different ways — a small mini-event with its
  /// own flavour, reward and sometimes a wound. One is rolled on each scout.
  static const _outcomes = <String, List<_Outcome>>{
    'river': [
      _Outcome(
          'Temiz su buldun; içtin, kaplarını doldurdun.',
          {
            ResourceType.food: 8,
            ResourceType.wood: 4,
          },
          4),
      _Outcome('Kıyıda balık tuttun.', {ResourceType.food: 14}, 0),
    ],
    'forest': [
      _Outcome('Bol odun kestin.', {ResourceType.wood: 14}, 0),
      _Outcome(
          'Kurt izi gördün; temkinli avlandın.',
          {
            ResourceType.leather: 4,
            ResourceType.food: 6,
          },
          -2),
    ],
    'hunt': [
      _Outcome(
          'İyi bir av vurdun.',
          {
            ResourceType.food: 16,
            ResourceType.leather: 3,
          },
          0),
      _Outcome(
          'Avlanırken yaralandın ama eli boş dönmedin.',
          {
            ResourceType.leather: 4,
            ResourceType.food: 8,
          },
          -8),
    ],
    'market': [
      _Outcome(
          'Tüccara yol gösterdin; bahşiş aldın.',
          {
            ResourceType.gold: 12,
            ResourceType.reputation: 1,
          },
          0),
      _Outcome('Küçük bir takas yaptın.', {ResourceType.gold: 8}, 0),
    ],
    'inscription': [
      _Outcome(
          'Ataların izini okudun; içine huzur doldu.',
          {
            ResourceType.reputation: 2,
            ResourceType.morale: 2,
          },
          0),
      _Outcome(
          'Eski bir töre öğrendin.',
          {
            ResourceType.reputation: 1,
            ResourceType.morale: 1,
          },
          0),
    ],
    'pass': [
      _Outcome(
          'Geçidi aştın; adın biraz daha duyuldu.',
          {
            ResourceType.reputation: 3,
          },
          -3),
      _Outcome(
          'Sis seni yordu ama vazgeçmedin.',
          {
            ResourceType.reputation: 2,
          },
          -5),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final hotspots = [
      for (final s in _sites)
        SceneHotspot(
          id: s.id,
          title: s.name,
          x: s.x,
          y: s.y,
          iconData: Icons.place,
          onTap: () => _openSite(context, controller, s),
        ),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SceneBackground(asset: GameAssets.bgMapParchment, scrim: false),
          SafeArea(
            child: Column(
              children: [
                OrnateHeader(
                  title: 'Yolculuk',
                  showBack: showBack,
                  onInfo: () => showHelpSheet(context, HelpId.journey),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (final hot in hotspots)
                          Positioned(
                            left: hot.x * c.maxWidth - 28,
                            top: hot.y * c.maxHeight - 28,
                            child: SceneHotspotWidget(hotspot: hot),
                          ),
                      ],
                    ),
                  ),
                ),
                const _DistantLandsPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSite(BuildContext context, GameController controller, _Site site) {
    final hasAp = controller.state.dailyActionPoints > 0;
    showSceneDetail(
      context,
      title: site.name,
      description: 'Risk: ${site.risk}. Ne çıkacağı belli olmaz — keşfet, '
          'toprağı tanı. Bazen ödül, bazen yara.',
      actions: [
        SceneAction(
          label: 'Keşfet',
          primary: true,
          enabled: hasAp,
          subtitle: hasAp ? null : 'Aksiyon hakkın kalmadı.',
          onTap: () {
            final pool = _outcomes[site.id] ?? const [];
            final outcome =
                pool.isEmpty ? null : pool[_rng.nextInt(pool.length)];
            final effects = outcome?.effects ?? const {ResourceType.wood: 6};
            final ok = controller.exploreRegion(
              site.name,
              effects,
              healthEffect: outcome?.health ?? 0,
              note: '${site.name}: ${outcome?.note ?? 'Keşif tamamlandı.'}',
            );
            if (ok) {
              showFloatingGain(context, Formatters.resourceDelta(effects));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(outcome?.note ?? 'Keşif tamamlandı.'),
                  duration: const Duration(seconds: 3),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Keşif için aksiyon gerekiyor.')),
              );
            }
          },
        ),
      ],
    );
  }
}

/// A possible result of scouting a place: a flavour note, resource effects,
/// and an optional health change (a wound or a restful gain).
class _Outcome {
  const _Outcome(this.note, this.effects, this.health);

  final String note;
  final Map<ResourceType, int> effects;
  final int health;
}

class _DistantLandsPanel extends StatelessWidget {
  const _DistantLandsPanel();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final open = PhaseLogic.campaignScene(state);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: OrnatePanel(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  open ? Icons.explore : Icons.lock,
                  size: 18,
                  color: AppColors.goldBright,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Uzak Diyarlar', style: AppTextStyles.bodyStrong),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              open
                  ? 'Adın ve gücün yettikçe sınır ötesine sefere çıkabilirsin.'
                  : 'Daha uzak diyarlara açılmak için önce kendi obanı kurmalı '
                      've güçlenmelisin.',
              style: AppTextStyles.meta,
            ),
            if (open) ...[
              const SizedBox(height: 8),
              GoldButton(
                label: 'SEFER HARİTASI',
                height: 40,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ExpeditionsScreen(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Site {
  const _Site(this.id, this.name, this.x, this.y, this.risk);

  final String id;
  final String name;
  final double x;
  final double y;
  final String risk;
}
