/// Maps each speaker to an optional portrait asset. Drop a matching PNG into
/// `assets/images/portraits/` and it shows automatically; until then the card
/// falls back to a stylized monogram. Keep the filenames exactly as below.
const portraitBySpeaker = <String, String>{
  'Aksakal Tonga': 'assets/images/portraits/aksakal_tonga.png',
  'Beyler Heyeti': 'assets/images/portraits/beyler_heyeti.png',
  'Defterdar Üge': 'assets/images/portraits/defterdar_uge.png',
  'Demirci Başı': 'assets/images/portraits/demirci_basi.png',
  'Elçi Yamtar': 'assets/images/portraits/elci_yamtar.png',
  'Genç Bey Böri': 'assets/images/portraits/genc_bey_bori.png',
  'Güçlü Han Elçisi': 'assets/images/portraits/han_elcisi.png',
  'Hatun': 'assets/images/portraits/hatun.png',
  'Hekim Otacı': 'assets/images/portraits/hekim_otaci.png',
  'Kam Udun': 'assets/images/portraits/kam_udun.png',
  'Komutan Bayan': 'assets/images/portraits/komutan_bayan.png',
  'Tüccar Maniak': 'assets/images/portraits/tuccar_maniak.png',
  'Yabancı Bey': 'assets/images/portraits/yabanci_bey.png',
  'Yabancı Usta': 'assets/images/portraits/yabanci_usta.png',
  'Yabancı Vaiz': 'assets/images/portraits/yabanci_vaiz.png',
  'Yüzbaşı Alp Er': 'assets/images/portraits/yuzbasi_alp_er.png',
  'Yılkıcı Sübeg': 'assets/images/portraits/yilkici_subeg.png',
  'Çin Elçisi Pei': 'assets/images/portraits/cin_elcisi_pei.png',
  'İhtiyar Bilge': 'assets/images/portraits/ihtiyar_bilge.png',
  'İki Boy Beyi': 'assets/images/portraits/iki_boy_beyi.png',
  'İç Oğuş Başı': 'assets/images/portraits/ic_ogus_basi.png',
};

String? portraitFor(String speaker) => portraitBySpeaker[speaker];
