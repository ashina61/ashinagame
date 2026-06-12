import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import 'expedition_result_screen.dart';

enum NodeState { done, available, dangerous, locked }

class ExpeditionsScreen extends StatefulWidget {
  const ExpeditionsScreen({super.key});

  @override
  State<ExpeditionsScreen> createState() => _ExpeditionsScreenState();
}

class _ExpeditionsScreenState extends State<ExpeditionsScreen> {
  int _tab = 0;

  static const _nodes = [
    (
      GameAssets.uiBadgeBanner1,
      GameAssets.iconFortOutpost,
      'Sınır Karakolu',
      'Tamamlandı',
      NodeState.done,
    ),
    (
      GameAssets.uiBadgeBanner2,
      GameAssets.iconFortStone,
      'Bozkır Geçidi',
      'Mevcut',
      NodeState.available,
    ),
    (
      GameAssets.uiBadgeBanner3,
      GameAssets.iconFortRed,
      'Yeşit Kalesi',
      'Tehlikeli',
      NodeState.dangerous,
    ),
    (
      GameAssets.uiBadgeBanner4,
      GameAssets.iconFortDark,
      'Cin Hududu',
      'Kilitli',
      NodeState.locked,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Seferler', showBack: true),
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
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    children: [
                      for (var i = 0; i < _nodes.length; i++)
                        _MapNode(
                          badge: _nodes[i].$1,
                          fort: _nodes[i].$2,
                          name: _nodes[i].$3,
                          status: _nodes[i].$4,
                          state: _nodes[i].$5,
                          showRoute: i < _nodes.length - 1,
                        ),
                    ],
                  ),
                  Positioned(
                    left: 14,
                    bottom: 10,
                    child: Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        GameAssets.uiCompassRoseNsew,
                        width: 70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 4, 40, 12),
              child: ImageButton(
                asset: GameAssets.uiButtonSefereCik,
                height: 56,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const ExpeditionResultScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.badge,
    required this.fort,
    required this.name,
    required this.status,
    required this.state,
    this.showRoute = false,
  }) : numberOverlay = null;

  final String badge;
  final String fort;
  final String name;
  final String status;
  final NodeState state;
  final String? numberOverlay;
  final bool showRoute;

  Color get _statusColor => switch (state) {
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
          Row(
            children: [
              SizedBox(
                width: 52,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(badge, fit: BoxFit.contain),
                    if (numberOverlay != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          numberOverlay!,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 20,
                            color: AppColors.parchment,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OrnatePanel(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Image.asset(fort, height: 54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.toUpperCase(),
                              style: AppTextStyles.section.copyWith(
                                color: AppColors.parchment,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              status,
                              style: AppTextStyles.meta.copyWith(
                                color: _statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
