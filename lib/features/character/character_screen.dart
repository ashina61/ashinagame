import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/asset_placeholder.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/marriage_candidate.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import '../inventory/inventory_screen.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final profile = state.profile;
    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Karakter', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  OrnatePanel(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 170,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              GameAssets.characterLeader,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const AssetPlaceholder(
                                assetPath: GameAssets.characterLeader,
                                label: 'Karakter',
                                height: 170,
                                icon: Icons.person_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${profile.name}, ${profile.age}',
                                  style: AppTextStyles.title),
                              Text(profile.title, style: AppTextStyles.meta),
                              const SizedBox(height: 6),
                              Text(
                                  'Seviye ${profile.level} • XP ${profile.xp}/${profile.xpToNextLevel}',
                                  style: AppTextStyles.value),
                              const SizedBox(height: 6),
                              StatBar(
                                  fraction: profile.xp / profile.xpToNextLevel,
                                  height: 9),
                              const SizedBox(height: 8),
                              Text('Beceri Puanı: ${profile.skillPoints}',
                                  style: AppTextStyles.bodyStrong
                                      .copyWith(color: AppColors.goldBright)),
                              Text(
                                  'Sağlık ${profile.health}/100 • Enerji ${profile.energy}/100 • Yorgunluk ${profile.fatigue}/100',
                                  style: AppTextStyles.meta),
                              Text(
                                  'İtibar ${state.resource(ResourceType.reputation)} • ${profile.marriageStatus}',
                                  style: AppTextStyles.meta),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SectionPlaque('BECERİ GELİŞİMİ'),
                  OrnatePanel(
                    child: Column(
                      children: [
                        _SkillBar('Cesaret', 'courage', profile.courage),
                        _SkillBar('Bilgelik', 'wisdom', profile.wisdom),
                        _SkillBar('Liderlik', 'leadership', profile.leadership),
                        _SkillBar(
                            'Dayanıklılık', 'endurance', profile.endurance),
                        _SkillBar('Ticaret', 'trade', profile.trade),
                        _SkillBar('Zanaat', 'craft', profile.craft),
                        _SkillBar('Okçuluk', 'archery', profile.archery),
                        _SkillBar('Savaş', 'warfare', profile.warfare),
                      ],
                    ),
                  ),
                  const SectionPlaque('KUT / TÖRE'),
                  const _SpiritualCharacterPanel(),
                  const SectionPlaque('SOY / HANE'),
                  OrnatePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Eş: ${state.household.spouseName ?? 'Yok'}',
                            style: AppTextStyles.bodyStrong),
                        Text('Bonus: ${state.household.spouseBonus}',
                            style: AppTextStyles.body),
                        Text(
                            'Hane morali ${state.household.householdMorale}/100 • Çocuk ${state.household.childrenCount} • Aile itibarı ${state.household.familyPrestige}',
                            style: AppTextStyles.meta),
                      ],
                    ),
                  ),
                  const SectionPlaque('EVLİLİK ADAYLARI'),
                  for (final candidate in state.marriageCandidates)
                    _CandidateCard(candidate: candidate),
                  const SectionPlaque('OBA SÖZÜ'),
                  OrnatePanel(
                    backgroundAsset: GameAssets.bgSceneCampNight,
                    child: Text(state.clan.motto,
                        style: AppTextStyles.bodyStrong.copyWith(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: DarkButton(
                      label: 'ENVANTER',
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (_) => const InventoryScreen())),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpiritualCharacterPanel extends StatelessWidget {
  const _SpiritualCharacterPanel();

  @override
  Widget build(BuildContext context) {
    final faith = GameScope.of(context).state.faithState;
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kut ${faith.kut}/100 • Töre ${faith.tore}/100',
              style: AppTextStyles.bodyStrong),
          const SizedBox(height: 4),
          Text(
              'İnanç ${faith.faith}/100 • Atalara Saygı ${faith.ancestorHonor}/100',
              style: AppTextStyles.body),
          const SizedBox(height: 6),
          Text(
              'Kut diplomasi ve evlilik görüşmelerine küçük güven etkisi verir; töre oba düzenini korur.',
              style: AppTextStyles.meta),
          if (faith.activeBlessings.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Kutsamalar: ${faith.activeBlessings.join(', ')}',
                style:
                    AppTextStyles.meta.copyWith(color: AppColors.goldBright)),
          ],
          if (faith.activeWarnings.isNotEmpty)
            Text('Uyarılar: ${faith.activeWarnings.join(', ')}',
                style: AppTextStyles.meta.copyWith(color: AppColors.danger)),
        ],
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar(this.label, this.stat, this.value);
  final String label;
  final String stat;
  final int value;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final canSpend = controller.state.profile.skillPoints > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 98, child: Text(label, style: AppTextStyles.bodyStrong)),
          Expanded(child: StatBar(fraction: value / 20, height: 11)),
          SizedBox(
              width: 32,
              child: Text('$value',
                  textAlign: TextAlign.right, style: AppTextStyles.value)),
          const SizedBox(width: 8),
          SizedBox(
            width: 34,
            child: GoldButton(
              label: '+',
              height: 30,
              onPressed:
                  canSpend ? () => controller.spendSkillPoint(stat) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.candidate});
  final MarriageCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final tribe = state.tribeByName(candidate.tribeName);
    final canPropose = !state.household.isMarried &&
        candidate.isAvailable &&
        state.resource(ResourceType.reputation) >= 20 &&
        state.resource(ResourceType.gold) >= 300 &&
        (tribe?.relation ?? -100) >= 10 &&
        state.dailyActionPoints > 0;
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('${candidate.name}, ${candidate.age}',
                      style: AppTextStyles.bodyStrong.copyWith(fontSize: 16))),
              Text(
                  candidate.isMarriedToPlayer
                      ? 'EŞ'
                      : candidate.isAvailable
                          ? 'Uygun'
                          : 'Kapalı',
                  style: AppTextStyles.meta.copyWith(
                      color: candidate.isAvailable
                          ? AppColors.success
                          : AppColors.stone)),
            ],
          ),
          Text(
              '${candidate.tribeName} • ${candidate.personality} • Bonus: ${candidate.bonusType}',
              style: AppTextStyles.body),
          Text(
              'Uyum ${candidate.compatibility}/100 • İlişki ${candidate.relation}/100 • Diplomatik değer ${candidate.diplomaticValue}',
              style: AppTextStyles.meta),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: DarkButton(
                      label: 'GÖRÜŞ',
                      height: 34,
                      onPressed:
                          state.dailyActionPoints > 0 && candidate.isAvailable
                              ? () => controller.meetCandidate(candidate.id)
                              : null)),
              const SizedBox(width: 8),
              Expanded(
                  child: DarkButton(
                      label: 'HEDİYE',
                      height: 34,
                      onPressed: state.resource(ResourceType.gold) >= 50 &&
                              candidate.isAvailable
                          ? () => controller.meetCandidate(candidate.id)
                          : null)),
              const SizedBox(width: 8),
              Expanded(
                  child: GoldButton(
                      label: 'TEKLİF',
                      height: 34,
                      onPressed: canPropose
                          ? () => controller.proposeMarriage(candidate.id)
                          : null)),
            ],
          ),
        ],
      ),
    );
  }
}
