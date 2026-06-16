import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/settings/app_settings.dart';
import '../../core/widgets/info_sheet.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/game_info.dart';
import '../../game/state/game_scope.dart';
import '../found_oba/found_oba_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _music = AudioService.instance.musicOn;
  bool _sfx = AudioService.instance.sfxOn;
  bool _haptics = AppSettings.instance.haptics;

  @override
  Widget build(BuildContext context) {
    return OrnateScaffold(
      child: Column(
        children: [
          OrnateHeader(
            title: 'Ayarlar',
            showBack: true,
            onInfo: () => showHelpSheet(context, HelpId.settings),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              children: [
                const SectionPlaque('OBA & LİDER'),
                Builder(
                  builder: (context) {
                    final state = GameScope.of(context).state;
                    return OrnatePanel(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Oba: ${state.clan.name}',
                                  style: AppTextStyles.bodyStrong,
                                ),
                                Text(
                                  'Lider: ${state.profile.name}',
                                  style: AppTextStyles.meta,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          DarkButton(
                            label: 'İSİM DEĞİŞTİR',
                            onPressed: () => _renameDialog(context),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SectionPlaque('OYUN'),
                OrnatePanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      _Toggle(
                        label: 'Müzik',
                        value: _music,
                        onChanged: (v) {
                          setState(() => _music = v);
                          AudioService.instance.setMusicOn(v);
                        },
                      ),
                      _Toggle(
                        label: 'Ses Efektleri',
                        value: _sfx,
                        onChanged: (v) {
                          setState(() => _sfx = v);
                          AudioService.instance.setSfxOn(v);
                        },
                      ),
                      _Toggle(
                        label: 'Sarsıntı (Titreşim)',
                        value: _haptics,
                        onChanged: (v) {
                          setState(() => _haptics = v);
                          AppSettings.instance.setHaptics(v);
                        },
                      ),
                    ],
                  ),
                ),
                const SectionPlaque('OYUN VERİSİ'),
                OrnatePanel(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Kendi tamga ve adınla kağanlığa bağlı yeni bir '
                              'oba kur.',
                              style: AppTextStyles.body,
                            ),
                          ),
                          const SizedBox(width: 10),
                          DarkButton(
                            label: 'YENİ OBA KUR',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const FoundObaScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Obayı baştan kur. Tüm ilerleme silinir.',
                              style: AppTextStyles.body,
                            ),
                          ),
                          const SizedBox(width: 10),
                          DarkButton(
                            label: 'OYUNU SIFIRLA',
                            onPressed: () => _confirmReset(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SectionPlaque('OYUN BİLGİSİ'),
                const OrnatePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoLine('Oyun', 'Ashina: Bozkırda Bir Ömür'),
                      _InfoLine('Sürüm', '0.1.0'),
                      _InfoLine('Tür', 'Çevrimdışı, tek oyunculu'),
                      SizedBox(height: 6),
                      Text(
                        'Tamamen çevrimdışı oynanır; hesap, sunucu ya da '
                        'çevrimiçi bağlantı gerektirmez. İlerlemen bu cihazda '
                        'saklanır.',
                        style: AppTextStyles.meta,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _renameDialog(BuildContext context) {
    final controller = GameScope.of(context);
    final obaCtrl = TextEditingController(text: controller.state.clan.name);
    final leaderCtrl = TextEditingController(
      text: controller.state.profile.name,
    );
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.leatherDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
        ),
        title: const Text('İsim Değiştir', style: AppTextStyles.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: obaCtrl,
              maxLength: 20,
              style: AppTextStyles.bodyStrong,
              cursorColor: AppColors.gold,
              decoration: const InputDecoration(
                labelText: 'Oba adı',
                labelStyle: AppTextStyles.meta,
              ),
            ),
            TextField(
              controller: leaderCtrl,
              maxLength: 16,
              style: AppTextStyles.bodyStrong,
              cursorColor: AppColors.gold,
              decoration: const InputDecoration(
                labelText: 'Lider adı',
                labelStyle: AppTextStyles.meta,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Vazgeç', style: AppTextStyles.bodyStrong),
          ),
          TextButton(
            onPressed: () {
              controller.rename(
                obaName: obaCtrl.text,
                leaderName: leaderCtrl.text,
              );
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Kaydet',
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.goldBright,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    final controller = GameScope.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.leatherDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
        ),
        title: const Text('Oyunu Sıfırla', style: AppTextStyles.title),
        content: const Text(
          'Oba ateşi söndürülüp yeni bir ömür başlatılacak. Emin misin?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Vazgeç', style: AppTextStyles.bodyStrong),
          ),
          TextButton(
            onPressed: () {
              controller.resetGame();
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Oba ateşi yeniden yakıldı. Yeni ömür başladı.',
                  ),
                ),
              );
            },
            child: Text(
              'Sıfırla',
              style: AppTextStyles.bodyStrong.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.bodyStrong.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyStrong)),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Image.asset(
              value ? GameAssets.uiToggleOn : GameAssets.uiToggleOff,
              width: 58,
            ),
          ),
        ],
      ),
    );
  }
}
