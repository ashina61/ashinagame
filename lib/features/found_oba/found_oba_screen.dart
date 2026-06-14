import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_assets.dart';
import '../../core/audio/audio_service.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/tamgas.dart';
import '../../game/models/npc.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';

/// The founding of an oba is a rite, not a form. The player walks four steps —
/// name, tamga, ground, first roles — and then raises the oba to a short
/// result card that announces the new settlement and the screens it opens.
class FoundObaScreen extends StatefulWidget {
  const FoundObaScreen({super.key});

  @override
  State<FoundObaScreen> createState() => _FoundObaScreenState();
}

class _FoundObaScreenState extends State<FoundObaScreen> {
  final _name = TextEditingController();
  String _tamga = Tamgas.all.first.id;
  int _land = 0;
  int _step = 0;
  final Map<String, String> _roles = {};

  static const _lands = <(String, String)>[
    ('Irmak Kıyısı', 'Suyu bol, otlağı yeşil. Sürüler ve ekin için verimli.'),
    ('Otlak Düzü', 'Geniş, açık düzlük. At sürüleri ve talim için ideal.'),
    ('Tepe Eteği', 'Korunaklı, rüzgârdan kuytu. Savunması güçlü bir yurt.'),
  ];

  static const _roleOptions = [
    'Savaş Başı',
    'Ocak Anası',
    'Sürü Başı',
    'Gözcü',
  ];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final followers = [
      for (final e in state.npcRelations.entries)
        if (e.value >= 75) e.key,
    ];
    final isLast = _step == 3;

    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Oba Kuruluş Töreni', showBack: true),
            _StepDots(step: _step, count: 4),
            Expanded(
              child: switch (_step) {
                0 => _NameStep(controller: _name),
                1 => _TamgaStep(
                    selected: _tamga,
                    onSelect: (id) => setState(() => _tamga = id),
                  ),
                2 => _LandStep(
                    lands: _lands,
                    selected: _land,
                    onSelect: (i) => setState(() => _land = i),
                  ),
                _ => _RolesStep(
                    followers: followers,
                    roleOptions: _roleOptions,
                    roles: _roles,
                    onAssign: (id, role) => setState(() => _roles[id] = role),
                  ),
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: DarkButton(
                        label: 'GERİ',
                        onPressed: () => setState(() => _step -= 1),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 10),
                  Expanded(
                    child: GoldButton(
                      label: isLast ? 'OBANI KUR' : 'İLERİ',
                      onPressed: () {
                        if (!isLast) {
                          setState(() => _step += 1);
                          return;
                        }
                        _found(context, controller);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _found(BuildContext context, GameController controller) {
    if (!controller.canFoundNewOba) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oba kurma şartları henüz tamam değil.')),
      );
      return;
    }
    final popBefore = controller.state.resource(ResourceType.population);
    controller.foundNewOba(_name.text, _tamga);
    AudioService.instance.playSfx('reward');
    final after = controller.state;
    final gained = after.resource(ResourceType.population) - popBefore;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ResultCard(
        obaName: after.clan.name,
        tamga: _tamga,
        land: _lands[_land].$1,
        population: gained,
        onClose: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step, required this.count});
  final int step;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= step ? AppColors.goldBright : AppColors.stone,
              ),
            ),
        ],
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionPlaque('1 • OBA ADI'),
        const OrnatePanel(
          child: Text(
            'Tek çadırla başladığın yol, bir ocağın doğuşuyla taçlanıyor. '
            'Obana bir ad ver — bu ad bozkırda anılacak.',
            style: AppTextStyles.body,
          ),
        ),
        OrnatePanel(
          child: TextField(
            controller: controller,
            maxLength: 20,
            style: AppTextStyles.bodyStrong,
            cursorColor: AppColors.gold,
            decoration: const InputDecoration(
              hintText: 'Örn. Gökböri Obası',
              hintStyle: AppTextStyles.meta,
              counterStyle: AppTextStyles.meta,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.goldDim),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.gold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TamgaStep extends StatelessWidget {
  const _TamgaStep({required this.selected, required this.onSelect});
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionPlaque('2 • TAMGA SEÇ'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
            children: [
              for (final tamga in Tamgas.all)
                GestureDetector(
                  onTap: () => onSelect(tamga.id),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.leatherDeep.withValues(alpha: 0.6),
                      border: Border.all(
                        color: selected == tamga.id
                            ? AppColors.goldBright
                            : AppColors.goldDim.withValues(alpha: 0.4),
                        width: selected == tamga.id ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(tamga.asset, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 4),
                        Text(tamga.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.meta),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LandStep extends StatelessWidget {
  const _LandStep({
    required this.lands,
    required this.selected,
    required this.onSelect,
  });
  final List<(String, String)> lands;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionPlaque('3 • UYGUN TOPRAK'),
        for (var i = 0; i < lands.length; i++)
          GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              foregroundDecoration: selected == i
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.goldBright, width: 1.6),
                    )
                  : null,
              child: OrnatePanel(
                child: Row(
                  children: [
                    Icon(
                      selected == i
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: selected == i
                          ? AppColors.goldBright
                          : AppColors.stone,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lands[i].$1, style: AppTextStyles.bodyStrong),
                          Text(lands[i].$2, style: AppTextStyles.meta),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RolesStep extends StatelessWidget {
  const _RolesStep({
    required this.followers,
    required this.roleOptions,
    required this.roles,
    required this.onAssign,
  });
  final List<String> followers;
  final List<String> roleOptions;
  final Map<String, String> roles;
  final void Function(String id, String role) onAssign;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionPlaque('4 • İLK YANDAŞ ROLLERİ'),
        const OrnatePanel(
          child: Text(
            'Yanına aldığın yandaşlara obanda birer görev ver. Roller obanın '
            'ilk düzenini kurar.',
            style: AppTextStyles.body,
          ),
        ),
        for (final id in followers)
          OrnatePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(NpcCharacters.byId(id)?.name ?? id,
                    style: AppTextStyles.bodyStrong),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final role in roleOptions)
                      GestureDetector(
                        onTap: () => onAssign(id, role),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: roles[id] == role
                                ? AppColors.gold.withValues(alpha: 0.25)
                                : AppColors.leatherDeep.withValues(alpha: 0.8),
                            border: Border.all(
                              color: roles[id] == role
                                  ? AppColors.goldBright
                                  : AppColors.goldDim.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(role,
                              style: AppTextStyles.meta.copyWith(
                                color: roles[id] == role
                                    ? AppColors.goldBright
                                    : AppColors.sand,
                              )),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        if (followers.isEmpty)
          const OrnatePanel(
            child: Text('Henüz yandaşın yok — yine de obanı kurabilirsin.',
                style: AppTextStyles.meta),
          ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.obaName,
    required this.tamga,
    required this.land,
    required this.population,
    required this.onClose,
  });

  final String obaName;
  final String tamga;
  final String land;
  final int population;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: OrnatePanel(
        margin: EdgeInsets.zero,
        backgroundAsset: GameAssets.bgSceneCampNight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(Tamgas.byId(tamga).asset,
                width: 72,
                height: 72,
                errorBuilder: (_, __, ___) => const SizedBox(height: 72)),
            const SizedBox(height: 8),
            Text('$obaName kuruldu!',
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.title.copyWith(color: AppColors.goldBright)),
            const SizedBox(height: 8),
            _ResultRow(Icons.terrain, 'Toprak: $land'),
            _ResultRow(Icons.groups, 'Nüfus +$population (ilk haneler)'),
            const _ResultRow(Icons.favorite, 'Moral yükseldi'),
            const _ResultRow(Icons.lock_open, 'Oba, Boylar ve Seferler açıldı'),
            const SizedBox(height: 12),
            GoldButton(label: 'OBANA GİR', onPressed: onClose),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.goldBright),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
