import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The four pillars a khan must balance. Each runs 0..100; hitting either
/// extreme ends the reign.
enum Metric { halk, ordu, hazine, tore }

extension MetricInfo on Metric {
  String get label {
    switch (this) {
      case Metric.halk:
        return 'Halk';
      case Metric.ordu:
        return 'Ordu';
      case Metric.hazine:
        return 'Hazine';
      case Metric.tore:
        return 'Töre';
    }
  }

  IconData get icon {
    switch (this) {
      case Metric.halk:
        return Icons.groups_rounded;
      case Metric.ordu:
        return Icons.shield_rounded;
      case Metric.hazine:
        return Icons.savings_rounded;
      case Metric.tore:
        return Icons.brightness_3_rounded;
    }
  }

  Color get color {
    switch (this) {
      case Metric.halk:
        return AppColors.success;
      case Metric.ordu:
        return AppColors.danger;
      case Metric.hazine:
        return AppColors.gold;
      case Metric.tore:
        return AppColors.info;
    }
  }

  /// Why the reign ended when this pillar reached [tooHigh] ? 100 : 0.
  String deathCause(bool tooHigh) {
    switch (this) {
      case Metric.halk:
        return tooHigh
            ? 'Halk seni öyle sevdi ki gücünden korkan beyler bir gece otağında seni boğdurdu.'
            : 'Aç ve ezilen halk ayaklandı; otağın ateşe verildi, hanedanın yıkıldı.';
      case Metric.ordu:
        return tooHigh
            ? 'Şişen ordu kendi gücüne güvendi; komutanların seni indirip kendi kağanını seçti.'
            : 'Ordusuz kalan obayı komşu boylar bir şafak baskınıyla yerle bir etti.';
      case Metric.hazine:
        return tooHigh
            ? 'Altına boğulan sarayında sefahate daldın; bıkkın halk vergi isyanıyla seni devirdi.'
            : 'Hazine kurudu; maaşsız kalan askerin ve beylerin seni terk etti.';
      case Metric.tore:
        return tooHigh
            ? 'Katı töreye boğulan boylar nefes alamadı; bir ıslahatçı bey seni alaşağı etti.'
            : 'Töreyi çiğnedin; kamlar ve aksakallılar lanet okuyup boyları sana karşı ayaklandırdı.';
    }
  }
}
