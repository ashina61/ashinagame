import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/asset_placeholder.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/equipment.dart';
import '../../game/models/marriage_candidate.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_scope.dart';
import '../atelier/atelier_screen.dart';
import '../equipment/equipment_screen.dart';
import '../inventory/inventory_screen.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({this.showBack = false, super.key});

  /// True when pushed as its own route; false when shown as a bottom tab.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final profile = state.profile;
    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            OrnateHeader(title: 'Karakter', showBack: showBack),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  const _CharacterHero(),
                  const SectionPlaque('EKİPMAN'),
                  const _EquipmentStrip(),
                  const _FamilyAndActions(),
                  const SectionPlaque('YETENEKLER'),
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
                  const SectionPlaque('EVLİLİK ADAYLARI'),
                  for (final candidate in state.marriageCandidates)
                    _CandidateCard(candidate: candidate),
                  const SectionPlaque('OBA SÖZÜ'),
                  OrnatePanel(
                    backgroundAsset: GameAssets.bgSceneCampNight,
                    child: Text(state.clan.motto,
                        style: AppTextStyles.bodyStrong.copyWith(fontSize: 16)),
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

/// Portrait hero with the leader's name, title and core attribute bars,
/// laid out like the KARAKTER mockup but fed by live profile data.
class _CharacterHero extends StatelessWidget {
  const _CharacterHero();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final profile = state.profile;
    final faith = state.faithState;
    return OrnatePanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 196,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  GameAssets.characterLeader,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) =>
                      const AssetPlaceholder(
                    assetPath: GameAssets.characterLeader,
                    label: 'Karakter',
                    height: 196,
                    icon: Icons.person_rounded,
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xE6000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.name}, ${profile.age}',
                        style: AppTextStyles.title.copyWith(
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 6),
                          ],
                        ),
                      ),
                      Text(
                        'Ünvan: ${profile.title}',
                        style: AppTextStyles.meta
                            .copyWith(color: AppColors.goldBright),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ÖZELLİKLER', style: AppTextStyles.section),
                const SizedBox(height: 8),
                _AttributeBar(GameAssets.iconScrollMedallion, 'Saygınlık',
                    profile.reputation, 100),
                _AttributeBar(GameAssets.iconPopulationEmblem, 'Liderlik',
                    profile.leadership, 20),
                _AttributeBar(GameAssets.iconSwordsCrossed, 'Cesaret',
                    profile.courage, 20),
                _AttributeBar(GameAssets.iconCoinsMedallion, 'Ticaret',
                    profile.trade, 20),
                _AttributeBar(
                    GameAssets.iconShieldSwords, 'Savaş', profile.warfare, 20),
                _AttributeBar(
                    GameAssets.iconSunEmblem, 'İnanç', faith.faith, 100),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: StatBar(
                        fraction: profile.xp / profile.xpToNextLevel,
                        height: 10,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Deneyim ${profile.xp}/${profile.xpToNextLevel}',
                      style: AppTextStyles.meta.copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Seviye ${profile.level}',
                      style: AppTextStyles.value.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributeBar extends StatelessWidget {
  const _AttributeBar(this.icon, this.label, this.value, this.max);

  final String icon;
  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 16,
            height: 16,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox(width: 16),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 78,
            child: Text(label, style: AppTextStyles.body.copyWith(fontSize: 13)),
          ),
          Expanded(child: StatBar(fraction: value / max, height: 10)),
          SizedBox(
            width: 48,
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

/// Five-slot equipment strip; tapping any slot opens the full Kuşam screen.
class _EquipmentStrip extends StatelessWidget {
  const _EquipmentStrip();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Row(
        children: [
          for (final slot in EquipmentData.slots)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _EquipSlotView(
                  name: slot.name,
                  equippedId: state.equippedIn(slot.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EquipSlotView extends StatelessWidget {
  const _EquipSlotView({required this.name, required this.equippedId});

  final String name;
  final String? equippedId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const EquipmentScreen()),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage(GameAssets.uiSlotItem),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: equippedId == null
                  ? Icon(
                      Icons.add,
                      color: AppColors.goldDim.withValues(alpha: 0.7),
                      size: 20,
                    )
                  : Image.asset(
                      craftIcon(equippedId!),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            name,
            style: AppTextStyles.navLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Family snapshot beside quick-access actions, mirroring the mockup's
/// bottom row (Aile Durumu + Yetenekler / Ekipman / Geçmiş buttons).
class _FamilyAndActions extends StatelessWidget {
  const _FamilyAndActions();

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context).state;
    final household = state.household;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: OrnatePanel(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AİLE DURUMU',
                    style: AppTextStyles.section.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  _FamilyRow('Eş', household.spouseName ?? '—'),
                  _FamilyRow('Çocuk', '${household.childrenCount}'),
                  _FamilyRow('Soy', state.clan.name),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: Column(
              children: [
                DarkButton(
                  label: 'EKİPMAN',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const EquipmentScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                DarkButton(
                  label: 'ENVANTER',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const InventoryScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                DarkButton(
                  label: 'GEÇMİŞ',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.leatherDark,
                      title: const Text('Geçmiş', style: AppTextStyles.section),
                      content: Text(
                        '${state.clan.name}\n${state.clan.motto}\n\n'
                        'Nesil: ${state.generation}\n'
                        'Geçen gün: ${state.day.day}',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyRow extends StatelessWidget {
  const _FamilyRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text('$label:', style: AppTextStyles.meta),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyStrong.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
          const Text(
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
