import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
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
          const OrnateHeader(
            title: 'Boy',
            subtitle: 'Boy Üyeleri ve Diplomasi',
            showBack: true,
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
                            Text(state.clan.name.toUpperCase(),
                                style: AppTextStyles.title),
                            Text('Tamga: ${Tamgas.byId(state.tamga).name}',
                                style: AppTextStyles.meta),
                            const SizedBox(height: 8),
                            _InfoRow('Nüfus',
                                '${state.resource(ResourceType.population)}'),
                            _InfoRow('İtibar',
                                '${state.resource(ResourceType.reputation)}'),
                            _InfoRow('Halk',
                                '${state.peopleApproval}/100 hoşnutluk'),
                            _InfoRow('Kurultay',
                                '${state.councilApproval}/100 hoşnutluk'),
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
    final affordable =
        source.cost.entries.every((e) => state.resource(e.key) >= e.value);
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
                child: Text(source.name,
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 16)),
              ),
              Text('+${source.basePeople + bonus} kişi',
                  style: AppTextStyles.value
                      .copyWith(fontSize: 14, color: AppColors.goldBright)),
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
                              content: Text(ok
                                  ? '${source.name} obana katıldı.'
                                  : 'Aksiyon ya da kaynak yetersiz.'),
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

class _TribePanel extends StatelessWidget {
  const _TribePanel({required this.tribe});
  final TribeRelation tribe;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final hasAp = state.dailyActionPoints > 0;
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(tribe.name,
                      style: AppTextStyles.bodyStrong.copyWith(fontSize: 16))),
              Text(tribe.status,
                  style: AppTextStyles.value.copyWith(
                      fontSize: 14, color: _statusColor(tribe.status))),
            ],
          ),
          const SizedBox(height: 4),
          Text(
              'Lider ${tribe.leader} • Güç ${tribe.power} • Nüfus ${tribe.population}',
              style: AppTextStyles.body),
          Text(
              'İlişki ${tribe.relation}/100 • Savaş riski %${tribe.warRisk} • Ticaret ${tribe.tradeOpen ? 'Açık' : 'Kapalı'} • Evlilik bağı ${tribe.marriageTie ? 'Var' : 'Yok'}',
              style: AppTextStyles.meta),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Action(
                  label: 'Hediye',
                  enabled: hasAp && state.resource(ResourceType.gold) >= 100,
                  onTap: () => controller.performDiplomacy(tribe.id, 'gift')),
              _Action(
                  label: 'Ticaret',
                  enabled: hasAp && state.resource(ResourceType.gold) >= 60,
                  onTap: () => controller.performDiplomacy(tribe.id, 'trade')),
              _Action(
                  label: 'Elçi',
                  enabled: hasAp,
                  onTap: () => controller.performDiplomacy(tribe.id, 'envoy')),
              _Action(
                  label: 'Yardım',
                  enabled: hasAp && state.resource(ResourceType.food) >= 20,
                  onTap: () => controller.performDiplomacy(tribe.id, 'aid')),
              _Action(
                  label: 'Savaş Haz.',
                  enabled: hasAp && state.resource(ResourceType.gold) >= 40,
                  onTap: () => controller.performDiplomacy(tribe.id, 'war')),
              _Action(
                  label: 'Evlilik Bağı',
                  enabled: hasAp && state.resource(ResourceType.gold) >= 80,
                  onTap: () =>
                      controller.performDiplomacy(tribe.id, 'marriage')),
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

class _Action extends StatelessWidget {
  const _Action(
      {required this.label, required this.enabled, required this.onTap});
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 106,
      child: DarkButton(
        label: label,
        height: 32,
        onPressed: enabled
            ? () {
                final ok = onTap;
                ok();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('$label diplomasi aksiyonu işlendi.')));
              }
            : null,
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
              width: 70, child: Text('$label:', style: AppTextStyles.meta)),
          Expanded(child: Text(value, style: AppTextStyles.bodyStrong)),
        ],
      ),
    );
  }
}
