import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../../game/state/game_state.dart';
import 'expedition_result_screen.dart';

enum NodeState { done, available, dangerous, locked }

class _ExpeditionNode {
  const _ExpeditionNode({
    required this.badge,
    required this.fort,
    required this.name,
    required this.status,
    required this.state,
    this.effects = const {},
  });

  final String badge;
  final String fort;
  final String name;
  final String status;
  final NodeState state;
  final Map<ResourceType, int> effects;

  bool get explorable =>
      state == NodeState.available || state == NodeState.dangerous;
}

class _Region {
  const _Region(this.name, this.risk, this.reward, this.effects);

  final String name;
  final String risk;
  final String reward;
  final Map<ResourceType, int> effects;
}

class ExpeditionsScreen extends StatefulWidget {
  const ExpeditionsScreen({super.key});

  @override
  State<ExpeditionsScreen> createState() => _ExpeditionsScreenState();
}

class _ExpeditionsScreenState extends State<ExpeditionsScreen> {
  int _tab = 0;
  int _selected = 1;

  static const _nodes = [
    _ExpeditionNode(
      badge: GameAssets.uiBadgeBanner1,
      fort: GameAssets.iconFortOutpost,
      name: 'Sınır Karakolu',
      status: 'Tamamlandı',
      state: NodeState.done,
    ),
    _ExpeditionNode(
      badge: GameAssets.uiBadgeBanner2,
      fort: GameAssets.iconFortStone,
      name: 'Bozkır Geçidi',
      status: 'Mevcut',
      state: NodeState.available,
      effects: {
        ResourceType.gold: 25,
        ResourceType.reputation: 2,
        ResourceType.food: -6,
      },
    ),
    _ExpeditionNode(
      badge: GameAssets.uiBadgeBanner3,
      fort: GameAssets.iconFortRed,
      name: 'Yeşit Kalesi',
      status: 'Tehlikeli',
      state: NodeState.dangerous,
      effects: {
        ResourceType.gold: 60,
        ResourceType.reputation: 4,
        ResourceType.food: -14,
        ResourceType.morale: -3,
      },
    ),
    _ExpeditionNode(
      badge: GameAssets.uiBadgeBanner4,
      fort: GameAssets.iconFortDark,
      name: 'Çin Hududu',
      status: 'Kilitli',
      state: NodeState.locked,
    ),
  ];

  // Scouting runs preserved from the old map screen; each applies its
  // resource effects through the controller.
  static const _regions = [
    _Region('Irmak Kıyısı', 'Orta', 'Odun / Moral', {
      ResourceType.wood: 6,
      ResourceType.morale: 1,
    }),
    _Region('Avlak', 'Orta', 'Erzak / Deri', {
      ResourceType.food: 12,
      ResourceType.leather: 2,
    }),
    _Region('Ormanlık Alan', 'Orta', 'Odun', {
      ResourceType.wood: 14,
      ResourceType.food: -2,
    }),
    _Region('Dağ Geçidi', 'Yüksek', 'İtibar', {
      ResourceType.reputation: 2,
      ResourceType.food: -4,
    }),
    _Region('Eski Yazıt', 'Düşük', 'Moral / İtibar', {
      ResourceType.reputation: 1,
      ResourceType.morale: 2,
    }),
    _Region('Ticaret Yolu', 'Orta', 'Takas', {
      ResourceType.food: 8,
      ResourceType.leather: -2,
    }),
  ];

  @override
  Widget build(BuildContext context) {
    final energy = GameScope.of(context).state.energy;
    return OrnateScaffold(
      child: Column(
        children: [
          const OrnateHeader(title: 'Seferler'),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
            child: Row(
              children: [
                Image.asset(GameAssets.iconEnergyBolt, width: 16, height: 16),
                const SizedBox(width: 4),
                Text(
                  'Enerji $energy/${GameState.maxEnergy}  •  '
                  'Keşif ${GameController.exploreCost}  •  '
                  'Sefer ${GameController.expeditionCost}',
                  style: AppTextStyles.meta.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Row(
              children: [
                for (final (i, asset) in const [
                  (0, GameAssets.uiTabHarita),
                  (1, GameAssets.uiTabSeferListesi),
                ])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                        decoration: _tab == i
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x66EEC36A),
                                    blurRadius: 12,
                                  ),
                                ],
                              )
                            : null,
                        child: Opacity(
                          opacity: _tab == i ? 1 : 0.7,
                          child: Image.asset(asset, height: 36),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _tab == 0 ? _buildMap() : _buildList()),
          if (_tab == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 4, 40, 12),
              child: ImageButton(
                asset: GameAssets.uiButtonSefereCik,
                height: 56,
                onPressed: () => _embark(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                GameAssets.bgMapParchment,
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.35),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        ListView(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          children: [
            for (var i = 0; i < _nodes.length; i++)
              _MapNode(
                node: _nodes[i],
                selected: i == _selected,
                showRoute: i < _nodes.length - 1,
                onTap: _nodes[i].explorable
                    ? () => setState(() => _selected = i)
                    : null,
              ),
          ],
        ),
        Positioned(
          left: 14,
          bottom: 10,
          child: Opacity(
            opacity: 0.9,
            child: Image.asset(GameAssets.uiCompassRoseNsew, width: 70),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    final controller = GameScope.of(context);
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        for (final region in _regions)
          OrnatePanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(region.name, style: AppTextStyles.bodyStrong),
                      Text(
                        'Risk: ${region.risk} • Ödül: ${region.reward}',
                        style: AppTextStyles.meta,
                      ),
                      Text(
                        Formatters.resourceDelta(region.effects),
                        style: AppTextStyles.meta.copyWith(
                          color: AppColors.goldBright,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                DarkButton(
                  label: 'KEŞFET',
                  onPressed: () {
                    final done =
                        controller.exploreRegion(region.name, region.effects);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          done
                              ? '${region.name} keşfi: '
                                  '${Formatters.resourceDelta(region.effects)}'
                              : 'Enerji tükendi. Günü bitirerek dinlen.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _embark(BuildContext context) {
    final node = _nodes[_selected];
    if (!node.explorable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu hedef şu an sefere kapalı.')),
      );
      return;
    }
    final done = GameScope.of(context).embarkExpedition(
      node.name,
      node.effects,
    );
    if (!done) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sefer için enerji yetmiyor. Günü bitirerek dinlen.'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ExpeditionResultScreen(
          title: node.name,
          effects: node.effects,
        ),
      ),
    );
  }
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.node,
    required this.selected,
    this.showRoute = false,
    this.onTap,
  });

  final _ExpeditionNode node;
  final bool selected;
  final bool showRoute;
  final VoidCallback? onTap;

  Color get _statusColor => switch (node.state) {
        NodeState.done => AppColors.success,
        NodeState.available => AppColors.info,
        NodeState.dangerous => AppColors.danger,
        NodeState.locked => AppColors.lockedGrey,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  height: 76,
                  child: Image.asset(node.badge, fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    foregroundDecoration: selected
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.goldBright,
                              width: 1.6,
                            ),
                          )
                        : null,
                    child: OrnatePanel(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Image.asset(node.fort, height: 54),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  node.name.toUpperCase(),
                                  style: AppTextStyles.section.copyWith(
                                    color: AppColors.parchment,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  node.status,
                                  style: AppTextStyles.meta.copyWith(
                                    color: _statusColor,
                                  ),
                                ),
                                if (node.effects.isNotEmpty)
                                  Text(
                                    Formatters.resourceDelta(node.effects),
                                    style: AppTextStyles.meta.copyWith(
                                      color: AppColors.goldBright,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showRoute)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Image.asset(
                GameAssets.uiMapRoute,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}
