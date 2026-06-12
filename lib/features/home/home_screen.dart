import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import '../inventory/inventory_screen.dart';
import '../market/market_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrnateScaffold(
      child: Column(
        children: [
          const SizedBox(height: 4),
          const _LogoHeader(),
          const ResourceBar(
            entries: [
              (GameAssets.iconCoinGold, '7.101'),
              (GameAssets.iconFood, '5.740'),
              (GameAssets.iconSunEmblem, '120'),
              (GameAssets.iconIronOre, '11.040'),
              (GameAssets.iconCoinsMedallion, '813'),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 6, bottom: 16),
              children: [
                const _CharacterCard(),
                const Row(
                  children: [
                    Expanded(child: _DailyGoalCard()),
                    Expanded(child: _SuggestedMoveCard()),
                  ],
                ),
                const SectionPlaque('GÜNLÜK İŞLER'),
                const _DailyJobsRow(),
                const SectionPlaque('HANE ÖZETİ'),
                const _HouseholdPanel(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DarkButton(
                          label: 'ENVANTER',
                          onPressed: () =>
                              _push(context, const InventoryScreen()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DarkButton(
                          label: 'PAZAR',
                          onPressed: () => _push(context, const MarketScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => screen));
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('ASHINA', style: AppTextStyles.display),
        Text(
          'BOZKIRDA BİR ÖMÜR',
          style: AppTextStyles.section.copyWith(letterSpacing: 4),
        ),
      ],
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard();

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            height: 158,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                GameAssets.characterLeader,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.leatherDeep,
                  alignment: Alignment.center,
                  child: Image.asset(
                    GameAssets.iconPopulationMedallion,
                    width: 64,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Ashina, 16', style: AppTextStyles.title),
                    ),
                    Text(
                      'Atança',
                      style: AppTextStyles.meta.copyWith(color: AppColors.gold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const _StatRow('Sağlık', 82, 100),
                const _StatRow('Enerji', 70, 100),
                const _StatRow('Yorgunluk', 35, 100),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Seviye 1',
                      style: AppTextStyles.bodyStrong.copyWith(fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      'XP 62/180',
                      style: AppTextStyles.meta.copyWith(
                        color: AppColors.goldBright,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: StatBar(fraction: 62 / 180, height: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value, this.max);

  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child:
                Text(label, style: AppTextStyles.body.copyWith(fontSize: 13)),
          ),
          Expanded(child: StatBar(fraction: value / max, height: 9)),
          SizedBox(
            width: 52,
            child: Text(
              '$value/$max',
              textAlign: TextAlign.right,
              style: AppTextStyles.meta.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard();

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      margin: const EdgeInsets.fromLTRB(12, 0, 4, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GÜNLÜK HEDEFLER',
            style: AppTextStyles.section.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            'Tüccarlarla bir anlaşma yap. 0/1',
            style: AppTextStyles.body.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Ödül:', style: AppTextStyles.meta),
              const SizedBox(width: 6),
              Image.asset(GameAssets.iconCoinGold, width: 16, height: 16),
              const SizedBox(width: 2),
              Text('200', style: AppTextStyles.value.copyWith(fontSize: 13)),
              const SizedBox(width: 8),
              Image.asset(GameAssets.iconSunEmblem, width: 16, height: 16),
              const SizedBox(width: 2),
              Text('50', style: AppTextStyles.value.copyWith(fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestedMoveCard extends StatelessWidget {
  const _SuggestedMoveCard();

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      margin: const EdgeInsets.fromLTRB(4, 0, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÖNERİLEN HAMLE',
            style: AppTextStyles.section.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Image.asset(GameAssets.navAtelier, width: 40, height: 40),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Atölyede yeni bir eşya üret.',
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyJobsRow extends StatelessWidget {
  const _DailyJobsRow();

  static const _jobs = [
    (GameAssets.iconItemWood, 'Odun Kes'),
    (GameAssets.iconItemWheat, 'Tarlada Çalış'),
    (GameAssets.iconItemBow, 'Avlan'),
    (GameAssets.iconPopulationMedallion, 'Paralı Asker Topla'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _jobs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (asset, label) = _jobs[index];
          return Container(
            width: 104,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(GameAssets.uiCardTask),
                fit: BoxFit.fill,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            child: Column(
              children: [
                Expanded(child: Image.asset(asset, fit: BoxFit.contain)),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong.copyWith(fontSize: 11),
                ),
                Text(
                  '★ XP 24',
                  style: AppTextStyles.meta.copyWith(
                    color: AppColors.goldBright,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HouseholdPanel extends StatelessWidget {
  const _HouseholdPanel();

  @override
  Widget build(BuildContext context) {
    return const OrnatePanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _KeyValue('Nüfus', '47'),
                _KeyValue('Çiftlik', '3'),
                _KeyValue('Ordu', '128'),
                _KeyValue('Moral', '82/100'),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _KeyValue('Savaş', '4'),
                _KeyValue('Güç', '1'),
                _KeyValue('Ticaret', '1'),
                _KeyValue('Zanaat', '2'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.value),
        ],
      ),
    );
  }
}
