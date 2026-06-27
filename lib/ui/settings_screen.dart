import 'package:flutter/material.dart';

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
              const _Header(title: 'AYARLAR'),
              Expanded(
                child: ListenableBuilder(
                  listenable: _settings,
                  builder: (context, _) => ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _slider(
                        'Müzik',
                        Icons.music_note_rounded,
                        _settings.musicVolume,
                        (v) async {
                          await _settings.setMusicVolume(v);
                          await AudioService.instance.applyVolumes();
                        },
                      ),
                      _slider(
                        'Efektler',
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
                        label: 'Titreşim',
                        trailing: Switch(
                          value: _settings.haptics,
                          activeThumbColor: AppColors.gold,
                          onChanged: (v) => _settings.setHaptics(v),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SettingTile(
                        icon: Icons.delete_outline_rounded,
                        label: 'İstatistikleri sıfırla',
                        trailing: TextButton(
                          onPressed: _confirmReset,
                          child: Text('SIFIRLA',
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

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.leather,
        title: const Text('Emin misin?', style: AppTextStyles.header),
        content: const Text(
          'En uzun saltanat, hanedan, başarımlar ve ölüm güncesi silinecek.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('VAZGEÇ', style: AppTextStyles.buttonDark),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('SİL',
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
          const SnackBar(content: Text('İstatistikler sıfırlandı.')),
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
