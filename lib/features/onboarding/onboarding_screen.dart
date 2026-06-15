import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/state/game_scope.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _leader = TextEditingController(text: 'Bumin');
  String _portrait = GameAssets.playerPortraits.first;

  @override
  void dispose() {
    _leader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    return OrnateScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
        child: Column(
          children: [
            // Opening flourish: the title swells out of the dark.
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: 1),
              builder: (context, t, child) => Opacity(
                opacity: t.clamp(0, 1),
                child: Transform.scale(scale: 0.7 + 0.3 * t, child: child),
              ),
              child: Column(
                children: [
                  const Text('ASHINA', style: AppTextStyles.display),
                  Text(
                    'BOZKIRDA BİR ÖMÜR',
                    style: AppTextStyles.section.copyWith(letterSpacing: 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const OrnatePanel(
              child: Text(
                'Gök sonsuz, bozkır geniş. 14 yaşında, tek bir çadır ve bir '
                'atla yola çıkıyorsun. Çalış, güçlen, ad yap, yandaş topla, '
                'evlen; sonra kendi obanı kur, kağana bağlan ya da kendi '
                'tahtını kovala.\n\nÖnce kendine bir ad ver.',
                style: AppTextStyles.body,
              ),
            ),
            const SectionPlaque('ADIN'),
            _Field(controller: _leader, hint: 'Örn. Bumin', maxLen: 16),
            const SectionPlaque('YÜZÜN'),
            _PortraitPicker(
              selected: _portrait,
              onSelect: (p) => setState(() => _portrait = p),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: GoldButton(
                label: 'OCAĞI YAK',
                onPressed: () {
                  AudioService.instance.playSfx('reward');
                  // No oba yet — only the traveller is named here. The oba name
                  // is chosen later, when one is founded.
                  controller.completeOnboarding(
                    obaName: '',
                    leaderName: _leader.text,
                    portrait: _portrait,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A horizontal row of selectable leader portraits. The chosen one gets a gold
/// frame; the rest dim. This is the player's first act of identity — the face
/// they will carry through the whole life.
class _PortraitPicker extends StatelessWidget {
  const _PortraitPicker({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Genç bir yolcunun yüzünü seç.',
            style: AppTextStyles.meta,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: GameAssets.playerPortraits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final asset = GameAssets.playerPortraits[i];
                final isSelected = asset == selected;
                return GestureDetector(
                  onTap: () {
                    AudioService.instance.playSfx('tap');
                    onSelect(asset);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.goldBright
                            : AppColors.goldDim.withValues(alpha: 0.5),
                        width: isSelected ? 2.4 : 1,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x80EEC36A),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: ColorFiltered(
                        colorFilter: isSelected
                            ? const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              )
                            : const ColorFilter.mode(
                                Color(0x66000000),
                                BlendMode.darken,
                              ),
                        child: Image.asset(
                          asset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: AppColors.leatherDeep,
                            child: Icon(Icons.person, color: AppColors.gold),
                          ),
                        ),
                      ),
                    ),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.maxLen,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLen;

  @override
  Widget build(BuildContext context) {
    return OrnatePanel(
      child: TextField(
        controller: controller,
        maxLength: maxLen,
        style: AppTextStyles.bodyStrong,
        cursorColor: AppColors.gold,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.meta,
          counterStyle: AppTextStyles.meta,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.goldDim),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.gold),
          ),
        ),
      ),
    );
  }
}
