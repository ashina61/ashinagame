import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/ornate.dart';
import '../../game/models/battle_report.dart';
import '../../game/models/unit_type.dart';

/// Recounts a battle's outcome unit by unit, so the player sees which kinds of
/// soldiers fell and which merely bled. Shared by conquest sieges and raids.
class BattleReportDialog extends StatelessWidget {
  const BattleReportDialog(this.report, {super.key});

  final BattleReport report;

  @override
  Widget build(BuildContext context) {
    final unitIds = {...report.lost.keys, ...report.wounded.keys}.toList();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: OrnatePanel(
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.won ? 'ZAFER' : 'BOZGUN',
              style: AppTextStyles.display.copyWith(
                fontSize: 26,
                color: report.won ? AppColors.success : AppColors.danger,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${report.castleName} • Galibiyet şansı %${report.chance}',
              style: AppTextStyles.meta,
            ),
            const SizedBox(height: 10),
            if (unitIds.isEmpty)
              const Text('Kayıp verilmedi.', style: AppTextStyles.body)
            else ...[
              Text(
                'Kayıp: ${report.totalLost} • Yaralı: ${report.totalWounded}',
                style: AppTextStyles.bodyStrong.copyWith(
                  color: AppColors.goldBright,
                ),
              ),
              const SizedBox(height: 6),
              for (final id in unitIds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${UnitTypes.byId(id)?.name ?? id}: '
                    '${(report.lost[id] ?? 0) > 0 ? '${report.lost[id]} şehit' : ''}'
                    '${(report.lost[id] ?? 0) > 0 && (report.wounded[id] ?? 0) > 0 ? ', ' : ''}'
                    '${(report.wounded[id] ?? 0) > 0 ? '${report.wounded[id]} yaralı' : ''}',
                    style: AppTextStyles.body,
                  ),
                ),
            ],
            const SizedBox(height: 12),
            GoldButton(
              label: 'KAPAT',
              height: 40,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
