import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import '../../game/state/game_scope.dart';
import '../found_oba/found_oba_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _music = true;
  bool _sfx = true;
  bool _notifications = true;
  bool _powerSave = false;

  @override
  Widget build(BuildContext context) {
    return OrnateScaffold(
      child: Column(
        children: [
          const OrnateHeader(title: 'Ayarlar', showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              children: [
                const SectionPlaque('HESAP'),
                OrnatePanel(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      _FieldRow(
                        label: 'Hesap Bağla',
                        value: 'Google Play  ✓',
                        valueColor: AppColors.success,
                        onTap: () => _soon(context),
                      ),
                      const _FieldRow(
                          label: 'Kullanıcı ID', value: 'ASHINA-4587'),
                      const _FieldRow(label: 'Sunucu', value: 'TR-1'),
                    ],
                  ),
                ),
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
                                Text('Oba: ${state.clan.name}',
                                    style: AppTextStyles.bodyStrong),
                                Text('Lider: ${state.profile.name}',
                                    style: AppTextStyles.meta),
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
                        onChanged: (v) => setState(() => _music = v),
                      ),
                      _Toggle(
                        label: 'Ses Efektleri',
                        value: _sfx,
                        onChanged: (v) => setState(() => _sfx = v),
                      ),
                      _Toggle(
                        label: 'Bildirimler',
                        value: _notifications,
                        onChanged: (v) => setState(() => _notifications = v),
                      ),
                      _Toggle(
                        label: 'Güç Tasarrufu Modu',
                        value: _powerSave,
                        onChanged: (v) => setState(() => _powerSave = v),
                      ),
                    ],
                  ),
                ),
                const SectionPlaque('DİL'),
                const OrnatePanel(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Dil', style: AppTextStyles.bodyStrong),
                      ),
                      Text('Türkçe  ▾', style: AppTextStyles.value),
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
                const SectionPlaque('DİĞER'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      for (final pair in const [
                        [
                          GameAssets.uiButtonDestek,
                          GameAssets.uiButtonHediyeKodu
                        ],
                        [
                          GameAssets.uiButtonGizlilik,
                          GameAssets.uiButtonHizmetSartlari,
                        ],
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              for (final asset in pair) ...[
                                if (asset != pair.first)
                                  const SizedBox(width: 8),
                                Expanded(
                                  child: ImageButton(
                                    asset: asset,
                                    height: 42,
                                    onPressed: () => _soon(context),
                                  ),
                                ),
                              ],
                            ],
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
    );
  }

  void _renameDialog(BuildContext context) {
    final controller = GameScope.of(context);
    final obaCtrl = TextEditingController(text: controller.state.clan.name);
    final leaderCtrl =
        TextEditingController(text: controller.state.profile.name);
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
            child: Text('Kaydet',
                style: AppTextStyles.bodyStrong
                    .copyWith(color: AppColors.goldBright)),
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
                  content:
                      Text('Oba ateşi yeniden yakıldı. Yeni ömür başladı.'),
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

  static void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu özellik yakında geliyor.')),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(GameAssets.uiPanelField),
            fit: BoxFit.fill,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.body)),
            Text(
              value,
              style: AppTextStyles.bodyStrong.copyWith(
                fontSize: 14,
                color: valueColor,
              ),
            ),
          ],
        ),
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
