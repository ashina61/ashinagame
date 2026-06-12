import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';

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
          const OrnateHeader(title: 'Ayarlar'),
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
