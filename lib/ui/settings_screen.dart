import 'package:flutter/material.dart';

import '../l10n.dart';
import '../state/audio_service.dart';
import '../state/settings.dart';
import '../state/stats_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'widgets/steppe_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.stats});

  final StatsStore stats;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = Settings.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SteppeBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(title: tr2('AYARLAR', 'SETTINGS')),
              Expanded(
                child: ListenableBuilder(
                  listenable: _settings,
                  builder: (context, _) => ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _SettingTile(
                        icon: Icons.language_rounded,
                        label: tr2('Dil', 'Language'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _langButton('TR', Lang.tr),
                            const SizedBox(width: 6),
                            _langButton('EN', Lang.en),
                          ],
                        ),
                      ),
                      _difficultyTile(),
                      _slider(
                        tr2('Müzik', 'Music'),
                        Icons.music_note_rounded,
                        _settings.musicVolume,
                        (v) async {
                          await _settings.setMusicVolume(v);
                          await AudioService.instance.applyVolumes();
                        },
                      ),
                      _slider(
                        tr2('Efektler', 'Effects'),
                        Icons.graphic_eq_rounded,
                        _settings.sfxVolume,
                        (v) async {
                          await _settings.setSfxVolume(v);
                          await AudioService.instance.applyVolumes();
                        },
                      ),
                      const SizedBox(height: 8),
                      _SettingTile(
                        icon: Icons.vibration_rounded,
                        label: tr2('Titreşim', 'Haptics'),
                        trailing: Switch(
                          value: _settings.haptics,
                          activeThumbColor: AppColors.gold,
                          onChanged: (v) => _settings.setHaptics(v),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SettingTile(
                        icon: Icons.delete_outline_rounded,
                        label:
                            tr2('İstatistikleri sıfırla', 'Reset statistics'),
                        trailing: TextButton(
                          onPressed: _confirmReset,
                          child: Text(tr2('SIFIRLA', 'RESET'),
                              style: AppTextStyles.buttonDark
                                  .copyWith(color: AppColors.danger)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slider(String label, IconData icon, double value,
      ValueChanged<double> onChanged) {
    return _SettingTile(
      icon: icon,
      label: label,
      trailing: SizedBox(
        width: 160,
        child: Slider(
          value: value,
          activeColor: AppColors.gold,
          inactiveColor: AppColors.bronze,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _difficultyTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card,
        border: Border.all(color: AppColors.bronze),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 12),
              Text(tr2('Zorluk', 'Difficulty'),
                  style: AppTextStyles.bodyStrong),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final d in Difficulty.values) _diffButton(d),
            ],
          ),
        ],
      ),
    );
  }

  Widget _diffButton(Difficulty d) {
    final active = _settings.difficulty == d;
    return Expanded(
      child: GestureDetector(
        onTap: () => _settings.setDifficulty(d),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: active ? AppColors.gold : Colors.transparent,
            border:
                Border.all(color: active ? AppColors.gold : AppColors.bronze),
          ),
          child: Text(
            difficultyLabel(d),
            textAlign: TextAlign.center,
            style: AppTextStyles.buttonDark.copyWith(
              fontSize: 11,
              color: active ? const Color(0xFF2B1D08) : AppColors.sand,
            ),
          ),
        ),
      ),
    );
  }

  Widget _langButton(String label, Lang lang) {
    final active = _settings.lang == lang;
    return GestureDetector(
      onTap: () => _settings.setLang(lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: active ? AppColors.gold : Colors.transparent,
          border: Border.all(color: active ? AppColors.gold : AppColors.bronze),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonDark.copyWith(
            color: active ? const Color(0xFF2B1D08) : AppColors.sand,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.leather,
        title: Text(tr2('Emin misin?', 'Are you sure?'),
            style: AppTextStyles.header),
        content: Text(
          tr2(
            'En uzun saltanat, hanedan, başarımlar ve ölüm güncesi silinecek.',
            'Longest reign, dynasty, achievements and the book of deaths will '
                'be erased.',
          ),
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text(tr2('VAZGEÇ', 'CANCEL'), style: AppTextStyles.buttonDark),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr2('SİL', 'DELETE'),
                style:
                    AppTextStyles.buttonDark.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.stats.resetAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(tr2('İstatistikler sıfırlandı.', 'Statistics reset.'))),
        );
      }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.sand),
          ),
          const SizedBox(width: 4),
          Text(title, style: AppTextStyles.header),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.card,
        border: Border.all(color: AppColors.bronze),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.bodyStrong)),
          trailing,
        ],
      ),
    );
  }
}
