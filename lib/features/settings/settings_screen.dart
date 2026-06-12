import 'package:flutter/material.dart';

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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Hesap Bağla',
                              style: AppTextStyles.bodyStrong,
                            ),
                          ),
                          DarkButton(
                            label: 'GOOGLE PLAY',
                            height: 32,
                            onPressed: () => _soon(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const _InfoRow('Kullanıcı ID', '#ASINA-4587'),
                      const _InfoRow('Sunucu', 'TR-1'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      for (final asset in const [
                        GameAssets.uiButtonDestek,
                        GameAssets.uiButtonHediyeKodu,
                        GameAssets.uiButtonGizlilik,
                        GameAssets.uiButtonHizmetSartlari,
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ImageButton(
                            asset: asset,
                            height: 46,
                            onPressed: () => _soon(context),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.meta),
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
