import 'package:flutter/material.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.blurb,
    required this.icon,
  });

  final String id;
  final String name;
  final String blurb;
  final IconData icon;
}

const achievements = <Achievement>[
  Achievement(
    id: 'ilk_olum',
    name: 'İlk Saltanat',
    blurb: 'İlk kez tahtını yitir.',
    icon: Icons.flag_rounded,
  ),
  Achievement(
    id: 'saltanat_15',
    name: 'Usta Kağan',
    blurb: 'Bir saltanatı 15 yıl sürdür.',
    icon: Icons.workspace_premium_rounded,
  ),
  Achievement(
    id: 'saltanat_30',
    name: 'Efsane Kağan',
    blurb: 'Bir saltanatı 30 yıl sürdür.',
    icon: Icons.military_tech_rounded,
  ),
  Achievement(
    id: 'hanedan_50',
    name: 'Köklü Hanedan',
    blurb: 'Hanedanı 50 yıl yaşat.',
    icon: Icons.account_balance_rounded,
  ),
  Achievement(
    id: 'hanedan_100',
    name: 'Ebedi Ashina',
    blurb: 'Hanedanı 100 yıl yaşat.',
    icon: Icons.auto_awesome_rounded,
  ),
  Achievement(
    id: 'cag_cokus',
    name: 'Çağları Gör',
    blurb: 'Çöküş çağına ulaş.',
    icon: Icons.hourglass_bottom_rounded,
  ),
  Achievement(
    id: 'denge',
    name: 'Denge Ustası',
    blurb: 'Dört dengeyi de aynı anda 45-55 arasında tut.',
    icon: Icons.balance_rounded,
  ),
  Achievement(
    id: 'besinci_kagan',
    name: 'Hanedan Sürüyor',
    blurb: 'Bir oyunda 5. kağana ulaş.',
    icon: Icons.groups_2_rounded,
  ),
  Achievement(
    id: 'tum_olumler',
    name: 'Sekiz Son',
    blurb: 'Sekiz ölüm türünü de gör.',
    icon: Icons.menu_book_rounded,
  ),
  Achievement(
    id: 'diplomat',
    name: 'Diplomat',
    blurb: 'Bir hanedanda hem komşuyla savaş hem ittifak gör.',
    icon: Icons.handshake_rounded,
  ),
];
