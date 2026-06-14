import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/audio/audio_service.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';

class KhanateScreen extends StatelessWidget {
  const KhanateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final power = controller.khanatePower;
    final canRebel = controller.canRebel;

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
                  OrnatePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isKhan
                              ? '${state.profile.name} — Kağan'
                              : '${state.clan.name} • Kağanlığa bağlı',
                          style:
                              AppTextStyles.bodyStrong.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        _Bar('Bağlılık', state.khanateStanding, 100),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Güç $power / ${GameController.rebellionPowerThreshold}',
                                style: AppTextStyles.value,
                              ),
                            ),
                            Text('Bağlı oba: ${state.vassalObas}',
                                style: AppTextStyles.meta),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                    const SectionPlaque('KAĞANLIK GÖREVLERİ'),
                    _DutyTile(
                      label: 'Haraç Öde',
                      detail: '−120 altın • +10 bağlılık',
                      onTap: controller.payTribute,
                    ),
                    _DutyTile(
                      label: 'Sefere Katıl',
                      detail: '−1 aksiyon, −20 erzak • +itibar, ganimet',
                      onTap: controller.joinKhanCampaign,
                    ),
                    _DutyTile(
                      label: 'Divana Katıl',
                      detail: '−1 aksiyon • +bağlılık, bilgelik',
                      onTap: controller.attendDivan,
                    ),
                    const SectionPlaque('YÜKSELİŞ'),
                    _DutyTile(
                      label: 'Obaları Topla',
                      detail: '−200 altın (itibar ≥ 25) • +güç',
                      onTap: controller.rallyObas,
                    ),
                    OrnatePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kağanı Devir',
                              style: AppTextStyles.bodyStrong
                                  .copyWith(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            canRebel
                                ? 'Gücün yeter. İsyan riskli ama tahtı '
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

class _DutyTile extends StatelessWidget {
  const _DutyTile({
    required this.label,
    required this.detail,
    required this.onTap,
  });

  final String label;
  final String detail;
  final bool Function() onTap;

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodyStrong),
                Text(detail, style: AppTextStyles.meta),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: DarkButton(
              label: 'YAP',
              height: 34,
              onPressed: () {
                final ok = onTap();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(ok ? '$label yapıldı.' : 'Koşullar uygun değil.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(this.label, this.value, this.max);

  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: AppTextStyles.body)),
        Expanded(child: StatBar(fraction: value / max, height: 10)),
        const SizedBox(width: 8),
        Text('$value/$max', style: AppTextStyles.meta),
      ],
    );
  }
}
