import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ornate.dart';
import '../../game/logic/phase_logic.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../expeditions/expeditions_screen.dart';
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

  static const _sites = <_Site>[
    _Site('river', 'Irmak Kıyısı', 0.22, 0.3, 'Düşük',
        {ResourceType.food: 8, ResourceType.wood: 4}),
    _Site('forest', 'Ormanlık', 0.5, 0.24, 'Düşük', {ResourceType.wood: 12}),
    _Site('hunt', 'Avlak', 0.74, 0.32, 'Orta',
        {ResourceType.food: 14, ResourceType.leather: 3}),
    _Site('market', 'Pazar Yolu', 0.3, 0.62, 'Düşük', {ResourceType.gold: 10}),
    _Site('inscription', 'Eski Yazıt', 0.58, 0.66, 'Orta',
        {ResourceType.reputation: 2, ResourceType.morale: 1}),
    _Site('pass', 'Tepelik Geçit', 0.82, 0.62, 'Yüksek',
        {ResourceType.reputation: 3}),
  ];

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
                OrnateHeader(title: 'Yolculuk', showBack: showBack),
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
      description: 'Risk: ${site.risk} • Ödül: '
          '${Formatters.resourceDelta(site.reward)}. Yakın çevreyi keşfetmek '
          'obana uygun toprağı tanımanı sağlar.',
      actions: [
        SceneAction(
          label: 'Keşfet',
          primary: true,
          enabled: hasAp,
          subtitle: hasAp ? null : 'Aksiyon hakkın kalmadı.',
          onTap: () {
            final ok = controller.exploreRegion(site.name, site.reward);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ok
                    ? '${site.name} keşfedildi: '
                        '${Formatters.resourceDelta(site.reward)}'
                    : 'Keşif için aksiyon gerekiyor.'),
              ),
            );
          },
        ),
      ],
    );
  }
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
                Icon(open ? Icons.explore : Icons.lock,
                    size: 18, color: AppColors.goldBright),
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
  const _Site(this.id, this.name, this.x, this.y, this.risk, this.reward);

  final String id;
  final String name;
  final double x;
  final double y;
  final String risk;
  final Map<ResourceType, int> reward;
}
