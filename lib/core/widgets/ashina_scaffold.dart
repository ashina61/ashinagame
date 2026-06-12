import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'ashina_top_bar.dart';

class AshinaScaffold extends StatelessWidget {
  const AshinaScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.night, AppColors.deepNight],
        ),
      ),
      child: Column(
        children: [
          const AshinaTopBar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
