import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/nations.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../boy/boy_screen.dart';
import '../conquest/conquest_screen.dart';

class KhanateScreen extends StatelessWidget {
  const KhanateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final standing = state.khanateStanding;
    final power = controller.khanatePower;
    final canRebel = controller.canRebel;

    final order = state.isKhan
        ? 'Bozkırın kağanı sensin; obalar buyruğunu bekler, sözün töredir.'
        : standing >= 60
            ? 'Kağan sadakatinden hoşnut. Obanı güçlendir, sırası gelince '
                'sefere çağrılacaksın.'
            : 'Kağan haraç ve asker bekliyor. Bağlılığını göstermezsen '
                'gözden düşersin.';

    return Scaffold(
      body: OrnateScaffold(
        backgroundAsset: GameAssets.bgSceneFortressNight,
        child: Column(
          children: [
            const OrnateHeader(
              title: 'Kağanlık',
              subtitle: 'Kağan ve Boylar Arasındaki Gücü Yönet',
              showBack: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  // Kağanın Buyruğu
                  OrnatePanel(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          GameAssets.uiEmblemWarRound,
                          width: 48,
                          height: 48,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(width: 48),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KAĞANIN BUYRUĞU',
                                style: AppTextStyles.section
                                    .copyWith(fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(order, style: AppTextStyles.body),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            const Text('Bağlılık', style: AppTextStyles.meta),
                            Text(
                              '$standing/100',
                              style: AppTextStyles.value,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // İtaat / Başkaldırı dengesi
                  OrnatePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'İtaat $standing',
                              style: AppTextStyles.value
                                  .copyWith(fontSize: 13),
                            ),
                            const Spacer(),
                            Text(
                              'Başkaldırı ${100 - standing}',
                              style: AppTextStyles.value.copyWith(
                                fontSize: 13,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        StatBar(fraction: standing / 100, height: 12),
                        const SizedBox(height: 6),
                        Text(
                          'Güç $power / ${GameController.rebellionPowerThreshold}'
                          ' • Bağlı oba: ${state.vassalObas}',
                          style: AppTextStyles.meta,
                        ),
                      ],
                    ),
                  ),
                  // Bağlı Boylar + Valiler
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _LoyaltyColumn(
                              title: 'BAĞLI BOYLAR',
                              rows: [
                                for (final tribe in state.tribes.take(4))
                                  _LoyaltyRow(
                                    name: tribe.name,
                                    fraction:
                                        ((tribe.relation + 100) / 200)
                                            .clamp(0.0, 1.0),
                                    value: 'Sadakat: ${tribe.relation}',
                                  ),
                              ],
                              buttonLabel: 'Boy Ayrıntıları',
                              onButton: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const BoyScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _LoyaltyColumn(
                              title: 'VALİLER',
                              rows: [
                                for (final entry
                                    in state.nationLoyalty.entries.take(5))
                                  _LoyaltyRow(
                                    name: Nations.byId(entry.key)?.name ??
                                        entry.key,
                                    fraction:
                                        (entry.value / 100).clamp(0.0, 1.0),
                                    value: 'Sadakat: ${entry.value}',
                                  ),
                                if (state.nationLoyalty.isEmpty)
                                  const _LoyaltyRow(
                                    name: 'Vali yok',
                                    fraction: 0,
                                    value: 'Henüz toprak tutulmadı',
                                  ),
                              ],
                              buttonLabel: 'Vali Yönetimi',
                              onButton: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ConquestScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SectionPlaque('KARAR'),
                  if (state.isKhan)
                    const OrnatePanel(
                      backgroundAsset: GameAssets.bgSceneFortressNight,
                      child: Text(
                        'Artık bozkırın kağanısın. Obalar sana haraç verir, '
                        'sözün töredir.',
                        style: AppTextStyles.bodyStrong,
                      ),
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _DecisionTile(
                                  icon: GameAssets.iconSwordsCrossedGold,
                                  label: 'Sefere Katıl',
                                  detail: '−1 aksiyon, −20 erzak • +itibar',
                                  onTap: controller.joinKhanCampaign,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _DecisionTile(
                                  icon: GameAssets.iconCoinGold,
                                  label: 'Haraç Öde',
                                  detail: '−120 altın • +10 bağlılık',
                                  onTap: controller.payTribute,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _DecisionTile(
                                  icon: GameAssets.iconScrollMedallion,
                                  label: 'Divana Katıl',
                                  detail: '−1 aksiyon • +bağlılık, bilgelik',
                                  onTap: controller.attendDivan,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _DecisionTile(
                                  icon: GameAssets.iconArmyEmblem,
                                  label: 'Beyleri Topla',
                                  detail: '−200 altın (itibar ≥ 25) • +güç',
                                  onTap: controller.rallyObas,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    OrnatePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bağımsızlık / İsyan',
                            style: AppTextStyles.bodyStrong
                                .copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            canRebel
                                ? 'Gücün yeter. İsyan risklidir ama tahtı '
                                    'alabilirsin.'
                                : 'İsyan için güç ≥ '
                                    '${GameController.rebellionPowerThreshold} '
                                    've bağlılık ≥ 50 gerekir.',
                            style: AppTextStyles.meta,
                          ),
                          const SizedBox(height: 8),
                          GoldButton(
                            label: 'İSYAN ET',
                            height: 44,
                            onPressed: canRebel
                                ? () {
                                    final won = controller.attemptRebellion();
                                    AudioService.instance
                                        .playSfx(won ? 'victory' : 'defeat');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(won
                                            ? 'Zafer! Tahta sen geçtin.'
                                            : 'İsyan bastırıldı; ağır kayıp.'),
                                      ),
                                    );
                                  }
                                : null,
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

/// A titled column of loyalty rows with a footer button, used for both the
/// "Bağlı Boylar" and "Valiler" panels of the Kağanlık mockup.
class _LoyaltyColumn extends StatelessWidget {
  const _LoyaltyColumn({
    required this.title,
    required this.rows,
    required this.buttonLabel,
    required this.onButton,
  });

  final String title;
  final List<Widget> rows;
  final String buttonLabel;
  final VoidCallback onButton;

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.section.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          ...rows,
          const SizedBox(height: 6),
          DarkButton(label: buttonLabel, height: 30, onPressed: onButton),
        ],
      ),
    );
  }
}

class _LoyaltyRow extends StatelessWidget {
  const _LoyaltyRow({
    required this.name,
    required this.fraction,
    required this.value,
  });

  final String name;
  final double fraction;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyles.bodyStrong.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          StatBar(fraction: fraction, height: 7),
          Text(
            value,
            style: AppTextStyles.meta.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// One tappable governance choice in the "Karar" grid.
class _DecisionTile extends StatelessWidget {
  const _DecisionTile({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  final String icon;
  final String label;
  final String detail;
  final bool Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final ok = onTap();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? '$label yapıldı.' : 'Koşullar uygun değil.'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: OrnatePanel(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  icon,
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(width: 24),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: AppTextStyles.meta.copyWith(fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
