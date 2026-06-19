import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_art.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/game_image.dart';
import '../../core/widgets/info_sheet.dart';
import '../../core/widgets/ornate.dart';
import '../../core/widgets/portrait_frame.dart';
import '../../core/widgets/skinned_button.dart';
import '../../core/widgets/skinned_panel.dart';
import '../../game/data/game_info.dart';
import '../../game/logic/life_logic.dart';
import '../../game/models/marriage_candidate.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../equipment/equipment_screen.dart';
import '../inventory/inventory_screen.dart';
import '../scene/floating_text.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({this.showBack = false, super.key});

  /// True when pushed as its own route; false when shown as a bottom tab.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final profile = state.profile;
    final nextAgeGate = profile.age < 16
        ? '16: Yoldaşlık, pazar yolu, at eğitimi'
        : profile.age < 18
            ? '18: Oba kurma hazırlıkları'
            : profile.age < 21
                ? '21: Boy / sefer / kağanlık yolu'
                : 'Geç oyun: antlaşma, sefer ve kağanlık';
    return Scaffold(
      body: OrnateScaffold(
        backgroundAsset: GameAssets.bgSceneCampNight,
        scrim: true,
        child: Column(
          children: [
            OrnateHeader(
              title: 'Karakter',
              showBack: showBack,
              onInfo: () => showHelpSheet(context, HelpId.character),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  OrnatePanel(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PortraitFrame(
                          asset: profile.portrait ?? GameAssets.characterLeader,
                          onTap: () => _showPortraitPicker(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${profile.name}, ${profile.age}',
                                style: AppTextStyles.title,
                              ),
                              Text(profile.title, style: AppTextStyles.meta),
                              Text(
                                'Yıl ${LifeLogic.yearOf(state.day.day)} • '
                                'Hayat evresi: ${profile.title}',
                                style: AppTextStyles.meta,
                              ),
                              Text(
                                'Sıradaki eşik: $nextAgeGate',
                                style: AppTextStyles.meta,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Seviye ${profile.level} • XP ${profile.xp}/${profile.xpToNextLevel}',
                                style: AppTextStyles.value,
                              ),
                              const SizedBox(height: 6),
                              StatBar(
                                fraction: profile.xp / profile.xpToNextLevel,
                                height: 9,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Beceri Puanı: ${profile.skillPoints}',
                                style: AppTextStyles.bodyStrong.copyWith(
                                  color: AppColors.goldBright,
                                ),
                              ),
                              Text(
                                'İtibar ${state.resource(ResourceType.reputation)} • ${profile.marriageStatus}',
                                style: AppTextStyles.meta,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SectionPlaque('DURUM'),
                  const _VitalsPanel(),
                  const SectionPlaque('BECERİ GELİŞİMİ'),
                  OrnatePanel(
                    child: Column(
                      children: [
                        _SkillBar('Cesaret', 'courage', profile.courage),
                        _SkillBar('Bilgelik', 'wisdom', profile.wisdom),
                        _SkillBar('Liderlik', 'leadership', profile.leadership),
                        _SkillBar(
                          'Dayanıklılık',
                          'endurance',
                          profile.endurance,
                        ),
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
                        Text(
                          'Eş: ${state.household.spouseName ?? 'Yok'}',
                          style: AppTextStyles.bodyStrong,
                        ),
                        Text(
                          'Bonus: ${state.household.spouseBonus}',
                          style: AppTextStyles.body,
                        ),
                        Text(
                          'Hane morali ${state.household.householdMorale}/100 • Çocuk ${state.household.childrenCount} • Aile itibarı ${state.household.familyPrestige}',
                          style: AppTextStyles.meta,
                        ),
                      ],
                    ),
                  ),
                  const SectionPlaque('EVLİLİK ADAYLARI'),
                  if (state.profile.age < GameController.marriageMinAge)
                    const OrnatePanel(
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_clock,
                            size: 18,
                            color: AppColors.stone,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Henüz çok gençsin. Evlilik ancak '
                              '${GameController.marriageMinAge} yaşından sonra '
                              'açılır — büyümek zaman ister.',
                              style: AppTextStyles.meta,
                            ),
                          ),
                        ],
                      ),
                    ),
                  for (final candidate in state.marriageCandidates)
                    _CandidateCard(candidate: candidate),
                  const SectionPlaque('OBA SÖZÜ'),
                  OrnatePanel(
                    backgroundAsset: GameAssets.bgSceneCampNight,
                    child: Text(
                      state.clan.motto,
                      style: AppTextStyles.bodyStrong.copyWith(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DarkButton(
                            label: 'KUŞAM',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const EquipmentScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DarkButton(
                            label: 'ENVANTER',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const InventoryScreen(),
                              ),
                            ),
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
      ),
    );
  }
}

/// The tappable leader portrait with a small "change" badge.
class _PortraitFrame extends StatelessWidget {
  const _PortraitFrame({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 170,
      child: Stack(
        children: [
          WolfPortraitFrame(
            asset: asset,
            width: 120,
            height: 170,
            onTap: onTap,
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold),
              ),
              child: const Icon(
                Icons.edit,
                size: 14,
                color: AppColors.goldBright,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slides up the portrait gallery so the player can change their leader's face.
void _showPortraitPicker(BuildContext context) {
  final controller = GameScope.of(context);
  final current =
      controller.state.profile.portrait ?? GameAssets.characterLeader;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SkinnedPanel(
          backgroundAsset: GameArt.dialogPanel,
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Portre Seç',
                style: AppTextStyles.title.copyWith(
                  fontSize: 18,
                  color: AppColors.goldBright,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 112,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: GameArt.playerPortraits.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final asset = GameArt.playerPortraits[i];
                    final selected = asset == current;
                    return GestureDetector(
                      onTap: () {
                        controller.setPortrait(asset);
                        AudioService.instance.playSfx('tap');
                        Navigator.of(sheetContext).maybePop();
                      },
                      child: WolfPortraitFrame(
                        asset: asset,
                        width: 80,
                        height: 112,
                        selected: selected,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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
          Text(
            'Kut ${faith.kut}/100 • Töre ${faith.tore}/100',
            style: AppTextStyles.bodyStrong,
          ),
          const SizedBox(height: 4),
          Text(
            'İnanç ${faith.faith}/100 • Atalara Saygı ${faith.ancestorHonor}/100',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 6),
          const Text(
            'Kut diplomasi ve evlilik görüşmelerine küçük güven etkisi verir; töre oba düzenini korur.',
            style: AppTextStyles.meta,
          ),
          if (faith.activeBlessings.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Kutsamalar: ${faith.activeBlessings.join(', ')}',
              style: AppTextStyles.meta.copyWith(color: AppColors.goldBright),
            ),
          ],
          if (faith.activeWarnings.isNotEmpty)
            Text(
              'Uyarılar: ${faith.activeWarnings.join(', ')}',
              style: AppTextStyles.meta.copyWith(color: AppColors.danger),
            ),
        ],
      ),
    );
  }
}

/// Produced emblem for each skill (falls back to an atlas emblem). The row
/// reads as a glyph + bar, not a plain stat line.
String _skillIcon(String stat) => GameArt.hasSkillIcon(stat)
    ? GameArt.skillIcon(stat)
    : _legacySkillIcon(stat);

String _legacySkillIcon(String stat) => switch (stat) {
      'courage' => GameAssets.iconDaggersCrossed,
      'wisdom' => GameAssets.iconScrollMedallion,
      'leadership' => GameAssets.iconPeopleGroupGold,
      'endurance' => GameAssets.iconHeartMedallion,
      'trade' => GameAssets.iconCoinsMedallion,
      'craft' => GameAssets.iconGearEmblem,
      'archery' => GameAssets.iconItemBow,
      'warfare' => GameAssets.iconArmyEmblem,
      _ => GameAssets.iconStarMedallion,
    };

/// The leader's vital signs as a compact dashboard of mini-bars instead of two
/// dense lines of "Sağlık 80/100 • Enerji …" text. "Bad" vitals (fatigue,
/// hunger, thirst) read healthier as they fall, so their colour is inverted.
class _VitalsPanel extends StatelessWidget {
  const _VitalsPanel();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final p = state.profile;
    final s = state.survival;
    return OrnatePanel(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _VitalBar(
                  label: 'Sağlık',
                  icon: Icons.favorite,
                  value: p.health,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _VitalBar(
                  label: 'Enerji',
                  icon: Icons.bolt,
                  value: p.energy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _VitalBar(
                  label: 'Yorgunluk',
                  icon: Icons.bedtime,
                  value: p.fatigue,
                  bad: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _VitalBar(
                  label: 'Açlık',
                  icon: Icons.restaurant,
                  value: s.hunger,
                  bad: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _VitalBar(
                  label: 'Susuzluk',
                  icon: Icons.water_drop,
                  value: s.thirst,
                  bad: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _VitalBar(
                  label: 'Sıcaklık',
                  icon: Icons.local_fire_department,
                  value: s.warmth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VitalBar extends StatelessWidget {
  const _VitalBar({
    required this.label,
    required this.icon,
    required this.value,
    this.bad = false,
  });

  final String label;
  final IconData icon;
  final int value;

  /// When true a high value is unhealthy (fatigue/hunger/thirst), so the bar
  /// turns to danger as it fills rather than as it empties.
  final bool bad;

  @override
  Widget build(BuildContext context) {
    final health = bad ? 100 - value : value;
    final fill = health < 30
        ? AppColors.danger
        : health < 60
            ? AppColors.gold
            : AppColors.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.goldBright),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.meta.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('$value', style: AppTextStyles.value.copyWith(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 3),
        StatBar(
          fraction: (value / 100).clamp(0.0, 1.0),
          height: 8,
          fill: fill,
        ),
      ],
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
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showSkillInfoSheet(context, stat, value),
              child: Row(
                children: [
                  Image.asset(
                    _skillIcon(stat),
                    width: 22,
                    height: 22,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.star,
                      size: 18,
                      color: AppColors.goldDim,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 84,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: AppTextStyles.bodyStrong,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.info_outline,
                          size: 12,
                          color: AppColors.goldDim,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: StatBar(fraction: value / 20, height: 11)),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '$value',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.value,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    // The proposal is offered whenever this candidate is still open and the
    // leader is unwed; whether it succeeds is decided on tap, with a clear
    // reason if something is missing — never a silent, dead button.
    final offerable = !state.household.isMarried && candidate.isAvailable;
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 78,
                  child: GameImage(
                    primary: GameArt.marriageCandidate(candidate.id),
                    fallback: GameAssets.characterLeader,
                    placeholderIcon: Icons.person,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${candidate.name}, ${candidate.age}',
                            style: AppTextStyles.bodyStrong.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          candidate.isMarriedToPlayer
                              ? 'EŞ'
                              : candidate.isAvailable
                                  ? 'Uygun'
                                  : 'Kapalı',
                          style: AppTextStyles.meta.copyWith(
                            color: candidate.isAvailable
                                ? AppColors.success
                                : AppColors.stone,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${candidate.tribeName} • ${candidate.personality} • '
                      'Bonus: ${candidate.bonusType}',
                      style: AppTextStyles.body,
                    ),
                    Text(
                      'Uyum ${candidate.compatibility}/100 • İlişki '
                      '${candidate.relation}/100 • Diplomatik değer '
                      '${candidate.diplomaticValue}',
                      style: AppTextStyles.meta,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SkinnedButton(
                  label: 'GÖRÜŞ',
                  variant: SkinnedButtonVariant.secondary,
                  height: 34,
                  onPressed:
                      state.dailyActionPoints > 0 && candidate.isAvailable
                          ? () {
                              controller.meetCandidate(candidate.id);
                              AudioService.instance.playSfx('tap');
                            }
                          : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SkinnedButton(
                  label: 'HEDİYE',
                  variant: SkinnedButtonVariant.secondary,
                  height: 34,
                  onPressed: state.resource(ResourceType.gold) >= 50 &&
                          state.dailyActionPoints > 0 &&
                          candidate.isAvailable
                      ? () {
                          controller.giftCandidate(candidate.id);
                          AudioService.instance.playSfx('coin');
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SkinnedButton(
                  label: candidate.isMarriedToPlayer ? 'EŞİN' : 'TEKLİF',
                  height: 34,
                  onPressed:
                      offerable ? () => _propose(context, controller) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _propose(BuildContext context, controller) {
    final reason = controller.marriageBlockReason(candidate.id);
    if (reason != null) {
      AudioService.instance.playSfx('denied');
      showFloatingNote(context, reason, good: false);
      return;
    }
    controller.proposeMarriage(candidate.id);
    AudioService.instance.playSfx('reward');
    final h = controller.state.household;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: SkinnedPanel(
          backgroundAsset: GameArt.dialogPanel,
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${candidate.name} ile evlendin!',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.goldBright,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Eş: ${h.spouseName ?? candidate.name}',
                style: AppTextStyles.body,
              ),
              Text('Bonus: ${candidate.bonusType}', style: AppTextStyles.body),
              Text(
                'Hane morali yükseldi (${h.householdMorale}/100).',
                style: AppTextStyles.body,
              ),
              Text(
                '${candidate.tribeName} ile bağ güçlendi.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 6),
              const Text(
                'Oba kurma yolunda güçlü bağ tamamlandı.',
                style: AppTextStyles.meta,
              ),
              const SizedBox(height: 12),
              SkinnedButton(
                label: 'DEVAM',
                onPressed: () => Navigator.of(dialogContext).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
