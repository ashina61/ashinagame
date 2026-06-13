import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/ornate.dart';
import '../../game/data/tamgas.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_scope.dart';

class FoundObaScreen extends StatefulWidget {
  const FoundObaScreen({super.key});

  @override
  State<FoundObaScreen> createState() => _FoundObaScreenState();
}

class _FoundObaScreenState extends State<FoundObaScreen> {
  final _name = TextEditingController();
  String _tamga = Tamgas.all.first.id;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final canFound = controller.canFoundNewOba;
    return Scaffold(
      body: OrnateScaffold(
        child: Column(
          children: [
            const OrnateHeader(title: 'Yeni Oba Kur', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                children: [
                  const OrnatePanel(
                    child: Text(
                      'Soyun bir kenara çekilip kendi obanı kuruyorsun. '
                      'Obana bir ad ve bir tamga seç; kağanlığa bağlı yeni '
                      'bir ocak yakılacak.',
                      style: AppTextStyles.body,
                    ),
                  ),
                  if (!canFound)
                    OrnatePanel(
                      child: Text(
                        'Kendi obanı kurmak için önce ana çadırını '
                        '${GameController.foundObaTentLevel}. seviyeye '
                        'yükselt ve itibarını '
                        '${GameController.foundObaReputation}’a çıkar. '
                        '(Şu an çadır '
                        '${controller.state.building('main_tent')?.level ?? 1}, '
                        'itibar ${controller.state.profile.reputation}.)',
                        style: AppTextStyles.meta.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  const SectionPlaque('OBA ADI'),
                  OrnatePanel(
                    child: TextField(
                      controller: _name,
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
                  const SectionPlaque('TAMGA SEÇ'),
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
                            onTap: () => setState(() => _tamga = tamga.id),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.leatherDeep
                                    .withValues(alpha: 0.6),
                                border: Border.all(
                                  color: _tamga == tamga.id
                                      ? AppColors.goldBright
                                      : AppColors.goldDim
                                          .withValues(alpha: 0.4),
                                  width: _tamga == tamga.id ? 2 : 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      tamga.asset,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tamga.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.meta,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 12, 40, 0),
                    child: GoldButton(
                      label: 'OBANI KUR',
                      onPressed: canFound
                          ? () {
                              controller.foundNewOba(_name.text, _tamga);
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${controller.state.clan.name} kuruldu. '
                                    'Yeni bir ömür başladı.',
                                  ),
                                ),
                              );
                            }
                          : null,
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
}
