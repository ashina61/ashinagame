import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/research_data.dart';
import '../../game/models/research.dart';
import '../../game/state/game_scope.dart';
import '../scene/floating_text.dart';
import '../scene/scene_hud_overlay.dart';

/// The academy's research tree. Points accrue each day from the academy; the
/// player spends them here to unlock economy and infrastructure techs. Locked
/// techs show their prerequisite, available ones an "Araştır" button —
/// İkariam's lab, told in the oba's voice.
class ResearchScreen extends StatelessWidget {
  const ResearchScreen({super.key});

  static const _categories = ['Ekonomi', 'Altyapı', 'Bilim', 'Askerî'];

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final hasAcademy = state.building('academy') != null;

    return Scaffold(
      body: OrnateScaffold(
        backgroundAsset: GameAssets.bgSceneCampNight,
        scrim: true,
        child: Column(
          children: [
            const OrnateHeader(title: 'Akademi • Araştırma'),
            const ResourceStrip(),
            OrnatePanel(
              child: Row(
                children: [
                  const Icon(Icons.menu_book,
                      color: AppColors.goldBright, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.researchPoints} araştırma puanı',
                          style: AppTextStyles.title,
                        ),
                        Text(
                          hasAcademy
                              ? 'Günde +${controller.researchPerDay} puan '
                                  '(akademi seviyesiyle artar).'
                              : 'Akademi yok; bilginler henüz toplanmadı.',
                          style: AppTextStyles.meta,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  for (final category in _categories) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
                      child: Text(
                        category.toUpperCase(),
                        style: AppTextStyles.meta.copyWith(
                          color: AppColors.goldBright,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    // Each lane is a left-to-right progression track of compact
                    // tiles — prerequisites sit before what they unlock, so it
                    // reads as a tech tree rather than a stack of cards.
                    SizedBox(
                      height: 124,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          for (final tech in ResearchData.techs)
                            if (tech.category == category)
                              _TechTile(tech: tech),
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

/// One node in a research lane: a compact, tappable tile whose border and
/// glyph encode its state (done / available / locked / too costly). Tapping
/// researches it when possible, or floats why it can't be researched yet.
class _TechTile extends StatelessWidget {
  const _TechTile({required this.tech});

  final ResearchTech tech;

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final researched = state.researchedTechs.contains(tech.id);
    final unmet = tech.requires
        .where((r) => !state.researchedTechs.contains(r))
        .map((r) => ResearchData.byId(r)?.name ?? r)
        .toList();
    final locked = unmet.isNotEmpty;
    final canResearch = controller.canResearch(tech.id);

    final Color accent;
    if (researched) {
      accent = AppColors.success;
    } else if (locked) {
      accent = AppColors.lockedGrey;
    } else if (canResearch) {
      accent = AppColors.goldBright;
    } else {
      accent = AppColors.stone;
    }

    return GestureDetector(
      onTap: () {
        if (researched) {
          showFloatingNote(context, '${tech.name} zaten araştırıldı.');
          return;
        }
        if (locked) {
          AudioService.instance.playSfx('denied');
          showFloatingNote(context, 'Önce gerekli: ${unmet.join(", ")}',
              good: false);
          return;
        }
        final ok = controller.research(tech.id);
        if (ok) {
          AudioService.instance.playSfx('craft');
          showFloatingGain(context, '${tech.name} açıldı',
              color: AppColors.goldBright);
        } else {
          AudioService.instance.playSfx('denied');
          showFloatingNote(context, '${tech.cost} araştırma puanı gerekli.',
              good: false);
        }
      },
      child: Container(
        width: 152,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: researched
                ? [const Color(0xFF1C2A1C), const Color(0xFF14200F)]
                : [const Color(0xFF1A140C), const Color(0xFF241B10)],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.85), width: 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  researched
                      ? Icons.check_circle
                      : locked
                          ? Icons.lock
                          : Icons.science,
                  color: accent,
                  size: 18,
                ),
                const Spacer(),
                if (!researched)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book, size: 12, color: accent),
                      const SizedBox(width: 2),
                      Text(
                        '${tech.cost}',
                        style: AppTextStyles.meta.copyWith(color: accent),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tech.name,
              style: AppTextStyles.bodyStrong.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                tech.effectDescription,
                style: AppTextStyles.meta.copyWith(fontSize: 11),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              researched
                  ? 'Araştırıldı ✓'
                  : locked
                      ? 'Kilitli'
                      : canResearch
                          ? 'Dokun → Araştır'
                          : 'Puan yetersiz',
              style: AppTextStyles.meta.copyWith(
                color: accent,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
