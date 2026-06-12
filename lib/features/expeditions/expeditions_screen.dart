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
    (1, 'Sınır Karakolu', 'Tamamlandı', NodeState.done),
    (2, 'Bozkır Geçidi', 'Mevcut', NodeState.available),
    (3, 'Yeşit Kalesi', 'Tehlikeli', NodeState.dangerous),
    (4, 'Cin Hududu', 'Kilitli', NodeState.locked),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Seferler', showBack: true),
            OrnateTabs(
              tabs: const ['Harita', 'Sefer Listesi'],
              index: _tab,
              onChanged: (value) => setState(() => _tab = value),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    children: [
                      for (final (number, name, status, state) in _nodes)
                        _MapNode(
                          number: number,
                          name: name,
                          status: status,
                          state: state,
                        ),
                    ],
                  ),
                  Positioned(
                    left: 14,
                    bottom: 10,
                    child: Opacity(
                      opacity: 0.85,
                      child: Image.asset(GameAssets.uiCompassRose, width: 64),
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
    required this.number,
    required this.name,
    required this.status,
    required this.state,
  });

  final int number;
  final String name;
  final String status;
  final NodeState state;

  Color get _statusColor => switch (state) {
        NodeState.done => AppColors.success,
        NodeState.available => AppColors.info,
        NodeState.dangerous => AppColors.danger,
        NodeState.locked => AppColors.lockedGrey,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
      child: Row(
        children: [
          Column(
            children: [
              SizedBox(
                width: 46,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      GameAssets.uiBadgeShieldBlue,
                      fit: BoxFit.contain,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        '$number',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 19,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (number != 4)
                Container(
                  width: 2,
                  height: 26,
                  color: AppColors.gold.withValues(alpha: 0.5),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: OrnatePanel(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
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
                    state == NodeState.locked ? '$status  🔒' : status,
                    style: AppTextStyles.meta.copyWith(color: _statusColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
