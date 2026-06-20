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

/// The academy's research tree. Points accrue each day from the academy; the
/// player spends them here to unlock economy and infrastructure techs. Locked
/// techs show their prerequisite, available ones an "Araştır" button —
/// İkariam's lab, told in the oba's voice.
class ResearchScreen extends StatelessWidget {
  const ResearchScreen({super.key});

  static const _categories = ['Ekonomi', 'Altyapı', 'Bilim'];

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
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 2),
                      child: Text(
                        category.toUpperCase(),
                        style: AppTextStyles.meta.copyWith(
                          color: AppColors.goldBright,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    for (final tech in ResearchData.techs)
                      if (tech.category == category) _TechCard(tech: tech),
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

class _TechCard extends StatelessWidget {
  const _TechCard({required this.tech});

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

    return OrnatePanel(
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(tech.name, style: AppTextStyles.section),
              ),
              if (!researched)
                Text(
                  '${tech.cost} puan',
                  style: AppTextStyles.meta.copyWith(color: accent),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(tech.description, style: AppTextStyles.body),
          const SizedBox(height: 2),
          Text(
            '⚙ ${tech.effectDescription}',
            style: AppTextStyles.meta.copyWith(color: AppColors.success),
          ),
          if (locked)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Önce gerekli: ${unmet.join(", ")}',
                style: AppTextStyles.meta.copyWith(color: AppColors.danger),
              ),
            ),
          if (researched)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Araştırıldı ✓',
                style: AppTextStyles.meta.copyWith(color: AppColors.success),
              ),
            )
          else if (!locked)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GoldButton(
                label: canResearch ? 'Araştır' : 'Puan yetersiz (${tech.cost})',
                height: 44,
                onPressed: canResearch
                    ? () {
                        final ok = controller.research(tech.id);
                        if (ok) {
                          AudioService.instance.playSfx('craft');
                          showFloatingGain(
                            context,
                            '${tech.name} açıldı',
                            color: AppColors.goldBright,
                          );
                        } else {
                          AudioService.instance.playSfx('denied');
                          showFloatingNote(context, 'Araştırma yapılamadı.',
                              good: false);
                        }
                      }
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
