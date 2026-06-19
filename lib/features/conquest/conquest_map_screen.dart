import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/assets/game_art.dart';
import '../../core/assets/game_assets.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/nations.dart';
import '../../game/models/nation.dart';
import '../../game/models/resource.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';
import '../army/army_screen.dart';
import '../atelier/atelier_screen.dart';
import '../expeditions/expeditions_screen.dart';
import '../scene/floating_text.dart';

/// The conquest map: every castle is a pin on the parchment, flying its power
/// like a challenge. Your army's strength rides at the top, and tapping a
/// castle weighs that strength against its garrison — strong enough and you
/// march; too weak and the screen points you at the ways to grow. This is the
/// heart of the game's loop: a world of targets gated behind your own power.
class ConquestMapScreen extends StatefulWidget {
  const ConquestMapScreen({super.key});

  @override
  State<ConquestMapScreen> createState() => _ConquestMapScreenState();
}

class _ConquestMapScreenState extends State<ConquestMapScreen> {
  String? _selected;

  /// Fractional map positions, clustered by nation across the steppe.
  static const _pos = <String, Offset>{
    // Dokuz Oğuz — kuzeydoğu
    'otuken': Offset(0.60, 0.17),
    'orhun': Offset(0.80, 0.19),
    'selenge': Offset(0.87, 0.33),
    'tola': Offset(0.64, 0.35),
    'oguz_ordasi': Offset(0.74, 0.26),
    // Türgiş — orta-batı
    'altay': Offset(0.18, 0.26),
    'cu': Offset(0.37, 0.24),
    'talas': Offset(0.41, 0.43),
    'yedisu': Offset(0.18, 0.45),
    'turgis_baligi': Offset(0.29, 0.35),
    // Karluk — güney
    'idil': Offset(0.41, 0.61),
    'isikgol': Offset(0.64, 0.59),
    'balasagun': Offset(0.69, 0.78),
    'kasgar': Offset(0.43, 0.80),
    'karluk_ordu': Offset(0.56, 0.70),
  };

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final selectedCastle =
        _selected == null ? null : Nations.castleById(_selected!);

    return Scaffold(
      backgroundColor: AppColors.leatherDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            GameArt.conquestMapBg,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              GameArt.worldMapParchment,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: AppColors.leatherDeep),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC0E0A06),
                  Color(0x22000000),
                  Color(0x990E0A06)
                ],
                stops: [0.0, 0.3, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _MapHeader(controller: controller),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Home base marker.
                          Positioned(
                            left: 0.12 * c.maxWidth - 22,
                            top: 0.88 * c.maxHeight - 22,
                            child: const _HomePin(),
                          ),
                          for (final castle in Nations.allCastles)
                            if (_pos[castle.id] != null)
                              Positioned(
                                left: _pos[castle.id]!.dx * c.maxWidth - 26,
                                top: _pos[castle.id]!.dy * c.maxHeight - 26,
                                child: _CastlePin(
                                  castle: castle,
                                  controller: controller,
                                  selected: _selected == castle.id,
                                  onTap: () => setState(
                                    () => _selected = _selected == castle.id
                                        ? null
                                        : castle.id,
                                  ),
                                ),
                              ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (selectedCastle != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: _CastlePanel(
                castle: selectedCastle,
                controller: controller,
                onClose: () => setState(() => _selected = null),
                onChanged: () => setState(() {}),
              ),
            ),
        ],
      ),
    );
  }
}

/// Top strip: a back medallion, your army's strength as the headline number,
/// and quick gold / muster readouts.
class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final taken =
        state.conqueredRegions.where((id) => Nations.castleById(id) != null);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Row(
        children: [
          _MapChip(
            icon: Icons.shield_moon,
            label: 'GÜCÜN',
            value: '${controller.warStrength}',
            highlight: true,
          ),
          const SizedBox(width: 6),
          _MapChip(
            icon: Icons.savings,
            label: 'Altın',
            value: '${state.resource(ResourceType.gold)}',
          ),
          const SizedBox(width: 6),
          _MapChip(
            icon: Icons.castle,
            label: 'Fetih',
            value: '${taken.length}/${Nations.allCastles.length}',
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => const ExpeditionsScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.goldDim.withValues(alpha: 0.6)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.backpack, size: 16, color: AppColors.sand),
                  SizedBox(width: 4),
                  Text('Hazırlık',
                      style: TextStyle(color: AppColors.sand, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: highlight ? 0.85 : 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? AppColors.gold
              : AppColors.goldDim.withValues(alpha: 0.6),
          width: highlight ? 1.6 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: highlight ? 20 : 16,
              color: highlight ? AppColors.goldBright : AppColors.sand),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.meta.copyWith(fontSize: 9),
              ),
              Text(
                value,
                style: AppTextStyles.value.copyWith(
                  fontSize: highlight ? 18 : 14,
                  color: highlight ? AppColors.goldBright : AppColors.sand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomePin extends StatelessWidget {
  const _HomePin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ink.withValues(alpha: 0.7),
            border: Border.all(color: AppColors.goldBright, width: 2),
          ),
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            GameAssets.iconYurtMedallion,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.home, color: AppColors.goldBright),
          ),
        ),
        const SizedBox(height: 2),
        const _PinLabel('Oban', AppColors.goldBright),
      ],
    );
  }
}

/// A castle on the map, coloured by your odds against it: green when you are
/// the stronger, amber when it is a gamble, red when you are outmatched, and a
/// muted lock for a sealed capital. Conquered castles fly a check.
class _CastlePin extends StatelessWidget {
  const _CastlePin({
    required this.castle,
    required this.controller,
    required this.selected,
    required this.onTap,
  });

  final Castle castle;
  final GameController controller;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final conquered = controller.state.regionConquered(castle.id);
    final locked = controller.centerLocked(castle);
    final chance = controller.warChanceFor(castle);

    final Color color;
    final IconData icon;
    if (conquered) {
      color = AppColors.success;
      icon = Icons.verified;
    } else if (locked) {
      color = AppColors.stone;
      icon = Icons.lock;
    } else if (chance >= 60) {
      color = AppColors.success;
      icon = Icons.castle;
    } else if (chance >= 35) {
      color = AppColors.goldBright;
      icon = Icons.castle;
    } else {
      color = AppColors.danger;
      icon = Icons.castle;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.ink.withValues(alpha: 0.72),
                  border: Border.all(
                    color: color,
                    width: selected ? 3 : 1.8,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: color.withValues(alpha: 0.7),
                              blurRadius: 14)
                        ]
                      : null,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              if (!conquered)
                Positioned(
                  bottom: -6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield,
                            size: 9, color: AppColors.sand),
                        const SizedBox(width: 2),
                        Text(
                          '${castle.power}',
                          style: AppTextStyles.value.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _PinLabel(
            castle.name,
            conquered ? AppColors.success : AppColors.sand,
          ),
        ],
      ),
    );
  }
}

class _PinLabel extends StatelessWidget {
  const _PinLabel(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.meta.copyWith(fontSize: 10, color: color),
      ),
    );
  }
}

/// The bottom sheet for a tapped castle: your strength against its garrison,
/// a verdict, and the right call to action — march if you can, or grow if you
/// can't.
class _CastlePanel extends StatelessWidget {
  const _CastlePanel({
    required this.castle,
    required this.controller,
    required this.onClose,
    required this.onChanged,
  });

  final Castle castle;
  final GameController controller;
  final VoidCallback onClose;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final conquered = state.regionConquered(castle.id);
    final locked = controller.centerLocked(castle);
    final chance = controller.warChanceFor(castle);
    final mine = controller.warStrength;
    final nation = Nations.nationOf(castle.id);
    final marching = state.marching;

    final maxScale = (mine > castle.power ? mine : castle.power).toDouble();

    final (String verdict, Color vColor) = conquered
        ? ('Bu kale senin.', AppColors.success)
        : locked
            ? ('Başkenti almak için önce dış kaleleri fethet.', AppColors.stone)
            : chance >= 60
                ? ('Gücün üstün — fethe hazırsın.', AppColors.success)
                : chance >= 35
                    ? ('Riskli bir kuşatma olur.', AppColors.goldBright)
                    : (
                        'Zayıfsın — bu kale seni ezer. Önce güçlen.',
                        AppColors.danger
                      );

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.leatherDeep.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                conquered ? Icons.verified : Icons.castle,
                color: conquered ? AppColors.success : AppColors.goldBright,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(castle.name, style: AppTextStyles.title),
                    if (nation != null)
                      Text(
                        '${nation.name} • ${nation.ruler}',
                        style: AppTextStyles.meta,
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, color: AppColors.sand),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _PowerRow(
            label: 'Senin Gücün',
            value: mine,
            scale: maxScale,
            color: AppColors.goldBright,
          ),
          const SizedBox(height: 5),
          _PowerRow(
            label: 'Kale Gücü',
            value: castle.power,
            scale: maxScale,
            color: AppColors.danger,
          ),
          const SizedBox(height: 8),
          Text(verdict, style: AppTextStyles.body.copyWith(color: vColor)),
          if (!conquered && !locked) ...[
            const SizedBox(height: 4),
            Text(
              'Zafer şansı: %$chance • Ödül: ${castle.rewardGold} altın, '
              '${castle.rewardReputation} itibar',
              style: AppTextStyles.meta,
            ),
          ],
          const SizedBox(height: 10),
          if (conquered)
            const SizedBox.shrink()
          else if (locked)
            const SizedBox.shrink()
          else if (chance < 35)
            _GrowRow(onChanged: onChanged)
          else
            Row(
              children: [
                Expanded(
                  child: GoldButton(
                    label: marching ? 'ORDU SEFERDE' : 'SALDIR',
                    height: 44,
                    onPressed: marching
                        ? null
                        : () {
                            final before = controller.state;
                            final won = controller.attackRegion(castle.id);
                            showStateDelta(
                              context,
                              before,
                              controller.state,
                              fallback: won
                                  ? '${castle.name} düştü!'
                                  : '${castle.name} önünde bozguna uğradın.',
                            );
                            onChanged();
                          },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DarkButton(
                    label: 'SEFER BAŞLAT',
                    height: 44,
                    onPressed: marching
                        ? null
                        : () {
                            final ok = controller.startMarch(castle.id);
                            showFloatingNote(
                              context,
                              ok
                                  ? 'Ordu ${castle.name} yolunda.'
                                  : 'Sefer başlatılamadı.',
                              good: ok,
                            );
                            onChanged();
                          },
                  ),
                ),
              ],
            ),
          if (!conquered && chance < 35) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  final before = controller.state;
                  final won = controller.attackRegion(castle.id);
                  showStateDelta(
                    context,
                    before,
                    controller.state,
                    fallback: won
                        ? '${castle.name} düştü!'
                        : '${castle.name} önünde bozguna uğradın.',
                  );
                  onChanged();
                },
                child: Text(
                  marching ? '' : 'Yine de saldır (riskli)',
                  style: AppTextStyles.meta.copyWith(
                    color: AppColors.danger,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// When the player is too weak, point them at the ways to grow rather than a
/// dead end.
class _GrowRow extends StatelessWidget {
  const _GrowRow({required this.onChanged});

  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DarkButton(
            label: 'ASKER TOPLA',
            height: 42,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ArmyScreen()),
              );
              onChanged();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DarkButton(
            label: 'SİLAH YAP',
            height: 42,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AtelierScreen()),
              );
              onChanged();
            },
          ),
        ),
      ],
    );
  }
}

class _PowerRow extends StatelessWidget {
  const _PowerRow({
    required this.label,
    required this.value,
    required this.scale,
    required this.color,
  });

  final String label;
  final int value;
  final double scale;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(label, style: AppTextStyles.meta),
        ),
        Expanded(
          child: StatBar(
            fraction: scale <= 0 ? 0 : (value / scale).clamp(0.0, 1.0),
            height: 12,
            fill: color,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: AppTextStyles.value.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
