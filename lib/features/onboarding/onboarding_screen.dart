import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/state/game_scope.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _oba = TextEditingController(text: 'Ashina Obası');
  final _leader = TextEditingController(text: 'Bumin');

  @override
  void dispose() {
    _oba.dispose();
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
                'Gök sonsuz, bozkır geniş. Tek bir çadır, bir avuç insanla '
                'başlıyorsun. Çalış, güçlen, evlen, soyunu büyüt; obanı kur, '
                'kağana bağlan ya da kendi tahtını kovala.\n\n'
                'Önce bir ad ver ocağına.',
                style: AppTextStyles.body,
              ),
            ),
            const SectionPlaque('OBA ADI'),
            _Field(controller: _oba, hint: 'Örn. Ashina Obası', maxLen: 20),
            const SectionPlaque('LİDER ADI'),
            _Field(controller: _leader, hint: 'Örn. Bumin', maxLen: 16),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: GoldButton(
                label: 'OCAĞI YAK',
                onPressed: () {
                  AudioService.instance.playSfx('reward');
                  controller.completeOnboarding(
                    obaName: _oba.text,
                    leaderName: _leader.text,
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
