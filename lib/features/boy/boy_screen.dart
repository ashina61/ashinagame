import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/info_sheet.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/game_info.dart';
import '../../game/data/recruitment.dart';
import '../../game/data/tamgas.dart';
import '../../game/logic/unlock_logic.dart';
import '../../game/models/resource.dart';
import '../../game/models/tribe_relation.dart';
import '../../game/state/game_scope.dart';
import '../khanate/khanate_screen.dart';

class BoyScreen extends StatelessWidget {
  const BoyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    return OrnateScaffold(
      child: Column(
        children: [
          OrnateHeader(
            title: 'Boylar',
            onInfo: () => showHelpSheet(context, HelpId.boy),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              children: [
                OrnatePanel(
                  backgroundAsset: GameAssets.bgSceneCampNight,
                  child: Row(
                    children: [
                      Image.asset(Tamgas.byId(state.tamga).asset, height: 110),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.clan.name.toUpperCase(),
                              style: AppTextStyles.title,
                            ),
                            Text(
                              'Tamga: ${Tamgas.byId(state.tamga).name}',
                              style: AppTextStyles.meta,
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              'Nüfus',
                              '${state.resource(ResourceType.population)}',
                            ),
                            _InfoRow(
                              'İtibar',
                              '${state.resource(ResourceType.reputation)}',
                            ),
                            _InfoRow(
                              'Halk',
                              '${state.peopleApproval}/100 hoşnutluk',
                            ),
                            _InfoRow(
                              'Kurultay',
                              '${state.councilApproval}/100 hoşnutluk',
                            ),
                            _InfoRow('Boy sayısı', '${state.tribes.length}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: GoldButton(
                    label: state.isKhan ? 'KAĞANLIK (KAĞANSIN)' : 'KAĞANLIK',
                    height: 46,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const KhanateScreen(),
                      ),
                    ),
                  ),
                ),
                const SectionPlaque('OBAYA İNSAN TOPLA'),
                if (!UnlockLogic.recruitment(state))
                  const OrnatePanel(
                    child: Text(
                      'Adam toplama henüz kapalı. İlk seferini tamamla; '
                      'adın duyulunca çevreden insanlar obana akmaya başlar.',
                      style: AppTextStyles.meta,
                    ),
                  )
                else ...[
                  OrnatePanel(
                    child: Text(
                      'Tek başına oba olmaz. Nüfus '
                      '${state.resource(ResourceType.population)} • Saygınlık '
                      'arttıkça her çağrıya daha çok kişi gelir.',
                      style: AppTextStyles.meta,
                    ),
                  ),
                  for (final source in Recruitment.sources)
                    _RecruitPanel(source: source),
                ],
                const SectionPlaque('BOY DURUMU / DİPLOMASİ'),
                for (final tribe in state.tribes) _TribePanel(tribe: tribe),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecruitPanel extends StatelessWidget {
  const _RecruitPanel({required this.source});

  final RecruitSource source;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final affordable = source.cost.entries.every(
      (e) => state.resource(e.key) >= e.value,
    );
    final hasAp = state.dailyActionPoints > 0;
    final costText =
        source.cost.entries.map((e) => '${e.value} ${e.key.label}').join(', ');
    final bonus = state.profile.reputation ~/ 20;
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  source.name,
                  style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
                ),
              ),
              Text(
                '+${source.basePeople + bonus} kişi',
                style: AppTextStyles.value.copyWith(
                  fontSize: 14,
                  color: AppColors.goldBright,
                ),
              ),
            ],
          ),
          Text(source.description, style: AppTextStyles.meta),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('Bedel: $costText', style: AppTextStyles.meta),
              ),
              SizedBox(
                width: 110,
                child: DarkButton(
                  label: 'TOPLA',
                  height: 34,
                  onPressed: hasAp && affordable
                      ? () {
                          final ok = controller.recruit(source.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? '${source.name} obana katıldı.'
                                    : 'Aksiyon ya da kaynak yetersiz.',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Banner and ruler portrait art for each NPC boy, by id.
const _boyArt = <String, (String banner, String portrait)>{
  'kara_kurtlar': (GameAssets.uiBadgeBanner1, GameAssets.portraitTogan),
  'demir_kartallar': (GameAssets.uiBadgeBanner2, GameAssets.portraitTugan),
  'gok_yeleler': (GameAssets.uiBadgeBanner3, GameAssets.portraitBori),
  'ak_sancak': (GameAssets.uiBadgeBanner4, GameAssets.portraitKaya),
  'yagiz_oba': (GameAssets.uiEmblemWarRound, GameAssets.portraitMerchant),
};

/// A boy rendered as a political power card: sancak, ruler portrait, the bars
/// that decide war and peace, the bonds that bind, and short icon actions.
/// Every boy here is NPC/AI — there are no online clans.
class _TribePanel extends StatelessWidget {
  const _TribePanel({required this.tribe});
  final TribeRelation tribe;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final hasAp = state.dailyActionPoints > 0;
    final art = _boyArt[tribe.id] ??
        (GameAssets.uiBadgeBanner1, GameAssets.portraitTogan);

    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                art.$1,
                width: 44,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(width: 44),
              ),
              const SizedBox(width: 8),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.6),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  art.$2,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.leatherDeep),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tribe.name,
                      style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
                    ),
                    Text(tribe.leader, style: AppTextStyles.meta),
                    Text(
                      tribe.status,
                      style: AppTextStyles.value.copyWith(
                        fontSize: 13,
                        color: _statusColor(tribe.status),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Bar('Güç', tribe.power / 120, '${tribe.power}', AppColors.gold),
          _Bar(
            'İlişki',
            (tribe.relation + 100) / 200,
            '${tribe.relation}',
            _statusColor(tribe.status),
          ),
          _Bar(
            'Savaş riski',
            tribe.warRisk / 100,
            '%${tribe.warRisk}',
            AppColors.danger,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Badge(
                icon: Icons.swap_horiz,
                label: tribe.tradeOpen ? 'Ticaret açık' : 'Ticaret kapalı',
                on: tribe.tradeOpen,
              ),
              _Badge(
                icon: Icons.favorite,
                label: tribe.marriageTie ? 'Evlilik bağı' : 'Bağ yok',
                on: tribe.marriageTie,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Action(
                icon: Icons.card_giftcard,
                label: 'Hediye',
                enabled: hasAp && state.resource(ResourceType.gold) >= 100,
                onTap: () => controller.performDiplomacy(tribe.id, 'gift'),
              ),
              _Action(
                icon: Icons.handshake,
                label: 'Ticaret',
                enabled: hasAp && state.resource(ResourceType.gold) >= 60,
                onTap: () => controller.performDiplomacy(tribe.id, 'trade'),
              ),
              _Action(
                icon: Icons.mail_outline,
                label: 'Elçi',
                enabled: hasAp,
                onTap: () => controller.performDiplomacy(tribe.id, 'envoy'),
              ),
              _Action(
                icon: Icons.volunteer_activism,
                label: 'Yardım',
                enabled: hasAp && state.resource(ResourceType.food) >= 20,
                onTap: () => controller.performDiplomacy(tribe.id, 'aid'),
              ),
              _Action(
                icon: Icons.local_fire_department,
                label: 'Savaş Haz.',
                enabled: hasAp && state.resource(ResourceType.gold) >= 40,
                onTap: () => controller.performDiplomacy(tribe.id, 'war'),
              ),
              _Action(
                icon: Icons.diversity_3,
                label: 'Evlilik',
                enabled: hasAp && state.resource(ResourceType.gold) >= 80,
                onTap: () => controller.performDiplomacy(tribe.id, 'marriage'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'Müttefik' || 'Dost' => AppColors.success,
        'Gergin' || 'Düşman' => AppColors.danger,
        _ => AppColors.goldBright,
      };
}

class _Bar extends StatelessWidget {
  const _Bar(this.label, this.fraction, this.value, this.fill);
  final String label;
  final double fraction;
  final String value;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: AppTextStyles.meta.copyWith(fontSize: 11),
            ),
          ),
          Expanded(
            child: StatBar(fraction: fraction, height: 8, fill: fill),
          ),
          SizedBox(
            width: 44,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.meta.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.on});
  final IconData icon;
  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final color = on ? AppColors.success : AppColors.stone;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.meta.copyWith(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () {
              onTap();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label: diplomasi işlendi.')),
              );
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.leatherDeep.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: AppColors.goldBright),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyles.buttonDark.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text('$label:', style: AppTextStyles.meta),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyStrong)),
        ],
      ),
    );
  }
}
