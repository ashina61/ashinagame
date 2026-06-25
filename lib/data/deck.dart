import '../models/kagan_card.dart';
import '../models/metric.dart';

/// The dilemma deck. Each card trades a few pillars against each other so no
/// answer is free. Effects are tuned to roughly cancel over a long reign.
const deck = <KaganCard>[
  KaganCard(
    id: 'kitlik',
    speaker: 'Aksakal Tonga',
    title: 'Boyun Aksakalı',
    prompt:
        'Kağanım, kış uzadı, ambarlar boşaldı, çocuklar aç. Hazineyi açıp tahıl mı dağıtalım, yoksa halk kemerini mi sıksın?',
    left: Choice(
      label: 'Hazineyi aç',
      effects: {Metric.hazine: -12, Metric.halk: 12},
      outcome: 'Tahıl dağıtıldı; halk adını hayırla andı.',
    ),
    right: Choice(
      label: 'Halk dayansın',
      effects: {Metric.halk: -14, Metric.hazine: 7},
      outcome: 'Kazan doldu ama otağda homurtu arttı.',
    ),
  ),
  KaganCard(
    id: 'akin',
    speaker: 'Komutan Bayan',
    title: 'Sağ Kol Beyi',
    prompt:
        'Komşu boy sürülerimizi yağmaladı. Atlara binip karşılık mı verelim, yoksa kan dökmeden anlaşıp haraç mı ödeyelim?',
    left: Choice(
      label: 'Akına çık',
      effects: {Metric.ordu: 10, Metric.hazine: 6, Metric.halk: -8},
      outcome: 'Yağma geri alındı, birkaç yiğit toprağa düştü.',
    ),
    right: Choice(
      label: 'Haraç öde',
      effects: {Metric.hazine: -10, Metric.ordu: -8, Metric.tore: -4},
      outcome: 'Barış satın alındı; gençler bunu zayıflık saydı.',
    ),
  ),
  KaganCard(
    id: 'kurultay',
    speaker: 'Beyler Heyeti',
    title: 'Kurultay',
    prompt:
        'Beyler kurultayda söz hakkı istiyor; kararlara ortak olmak istiyorlar. Yetki verelim mi, yoksa son söz kağanda mı kalsın?',
    left: Choice(
      label: 'Söz hakkı ver',
      effects: {Metric.ordu: 10, Metric.halk: 6, Metric.tore: -10},
      outcome: 'Beyler memnun; eski töre biraz daha gevşedi.',
    ),
    right: Choice(
      label: 'Son söz benim',
      effects: {Metric.tore: 10, Metric.ordu: -10},
      outcome: 'Otorite korundu, beylerin yüzü asıldı.',
    ),
  ),
  KaganCard(
    id: 'evlilik',
    speaker: 'Elçi Yamtar',
    title: 'Komşu Boyun Elçisi',
    prompt:
        'Hanımız kızını sana vermek, kanımızı birleştirmek ister. İttifak kuralım mı, yoksa bağımsızlığımız mı esas?',
    left: Choice(
      label: 'İttifakı kabul et',
      effects: {Metric.ordu: 10, Metric.hazine: 8, Metric.tore: -6},
      outcome: 'Düğün kuruldu; iki boyun atlısı bir oldu.',
    ),
    right: Choice(
      label: 'Reddet',
      effects: {Metric.tore: 8, Metric.ordu: -8},
      outcome: 'Bağımsızlık korundu, komşu gücendi.',
    ),
  ),
  KaganCard(
    id: 'kuraklik',
    speaker: 'Kam Udun',
    title: 'Boyun Kamı',
    prompt:
        'Gök yağmurunu kesti, otlaklar sarardı. Gök Tengri için büyük bir kurban töreni mi yapalım, yoksa bunu boş inanç sayıp işe mi koyulalım?',
    left: Choice(
      label: 'Tören düzenle',
      effects: {Metric.tore: 12, Metric.halk: 6, Metric.hazine: -10},
      outcome: 'Ateşler yakıldı; halkın yüreğine umut düştü.',
    ),
    right: Choice(
      label: 'Boş inanç',
      effects: {Metric.tore: -12, Metric.halk: -6},
      outcome: 'Kam küstü, yaşlılar başını salladı.',
    ),
  ),
  KaganCard(
    id: 'kervan',
    speaker: 'Tüccar Maniak',
    title: 'Soğd Kervanbaşı',
    prompt:
        'İpek kervanım toprağından geçmek ister. Ağır geçiş vergisi mi alalım, yoksa serbest geçişle ticareti mi büyütelim?',
    left: Choice(
      label: 'Ağır vergi al',
      effects: {Metric.hazine: 12, Metric.halk: -6},
      outcome: 'Kese doldu; tüccarlar yolu değiştirmekten söz etti.',
    ),
    right: Choice(
      label: 'Serbest bırak',
      effects: {Metric.hazine: -4, Metric.halk: 8, Metric.tore: -2},
      outcome: 'Pazar canlandı, mallar boldu.',
    ),
  ),
  KaganCard(
    id: 'isyan',
    speaker: 'Genç Bey Böri',
    title: 'Asi Bey',
    prompt:
        'Bir bey vergisini kesti, otağına çağrına gelmiyor. Üzerine yürüyüp ezelim mi, yoksa konuşup gönlünü mü alalım?',
    left: Choice(
      label: 'Ez',
      effects: {Metric.ordu: 8, Metric.tore: 6, Metric.halk: -10},
      outcome: 'İsyan bastırıldı; korku obayı sardı.',
    ),
    right: Choice(
      label: 'Gönlünü al',
      effects: {Metric.hazine: -8, Metric.halk: 8, Metric.ordu: -4},
      outcome: 'Bey armağanla yatıştı, ama başkaları da cesaret aldı.',
    ),
  ),
  KaganCard(
    id: 'veba',
    speaker: 'Hekim Otacı',
    title: 'Otacı (Hekim)',
    prompt:
        'Obada bir hastalık kol geziyor. Hastaları çadırlarda ayrı mı tutalım, yoksa kamın okuyup üflemesine mi bırakalım?',
    left: Choice(
      label: 'Ayrı tut',
      effects: {Metric.halk: -6, Metric.hazine: -6, Metric.tore: -4},
      outcome: 'Salgın yavaşladı; ayrılan aileler kırgın.',
    ),
    right: Choice(
      label: 'Kama bırak',
      effects: {Metric.tore: 8, Metric.halk: -10},
      outcome: 'Dualar okundu; hastalık birkaç çadırı daha yuttu.',
    ),
  ),
  KaganCard(
    id: 'at_surusu',
    speaker: 'Yılkıcı Sübeg',
    title: 'Baş Yılkıcı',
    prompt:
        'Bozkırda sahipsiz bir yılkı bulduk. Atları orduya mı katalım, yoksa muhtaç ailelere mi dağıtalım?',
    left: Choice(
      label: 'Orduya kat',
      effects: {Metric.ordu: 12, Metric.halk: -6},
      outcome: 'Süvari bölükleri güçlendi.',
    ),
    right: Choice(
      label: 'Halka dağıt',
      effects: {Metric.halk: 12, Metric.ordu: -6},
      outcome: 'Çobanların yüzü güldü; beyler buruk.',
    ),
  ),
  KaganCard(
    id: 'cin_elcisi',
    speaker: 'Çin Elçisi Pei',
    title: 'Tang Sarayı Elçisi',
    prompt:
        'İmparator sana ipek, unvan ve altın yollar; karşılığında tabiiyet ister. Armağanları alıp baş eğelim mi, yoksa elçiyi geri mi gönderelim?',
    left: Choice(
      label: 'Armağanı al',
      effects: {Metric.hazine: 14, Metric.tore: -10, Metric.ordu: -6},
      outcome: 'Saray altına gömüldü; bozkır bunu utanç saydı.',
    ),
    right: Choice(
      label: 'Geri yolla',
      effects: {Metric.tore: 10, Metric.ordu: 6, Metric.hazine: -8},
      outcome: 'Elçi eli boş döndü; onurun bozkırda anlatıldı.',
    ),
  ),
  KaganCard(
    id: 'vergi',
    speaker: 'Defterdar Üge',
    title: 'Hazine Yazıcısı',
    prompt:
        'Kese inceldi kağanım. Boylardan alınan vergiyi artıralım mı, yoksa halkın yükünü mü hafifletelim?',
    left: Choice(
      label: 'Vergiyi artır',
      effects: {Metric.hazine: 12, Metric.halk: -10},
      outcome: 'Hazine doldu; köylerde mırıltı yükseldi.',
    ),
    right: Choice(
      label: 'Yükü hafiflet',
      effects: {Metric.hazine: -10, Metric.halk: 12},
      outcome: 'Halk rahatladı, defterler kızardı.',
    ),
  ),
  KaganCard(
    id: 'genc_savascilar',
    speaker: 'Yüzbaşı Alp Er',
    title: 'Genç Süvari',
    prompt:
        'Genç yiğitler şan için bir akın diler. İzin verip onları bozkıra mı salalım, yoksa dizginleri mi tutalım?',
    left: Choice(
      label: 'İzin ver',
      effects: {
        Metric.ordu: 8,
        Metric.hazine: 8,
        Metric.halk: -6,
        Metric.tore: -4
      },
      outcome: 'Ganimetle döndüler; birkaç ana evladını gömdü.',
    ),
    right: Choice(
      label: 'Dizginle',
      effects: {Metric.ordu: -8, Metric.tore: 6},
      outcome: 'Yiğitler söylendi ama oba huzura kavuştu.',
    ),
  ),
  KaganCard(
    id: 'kehanet',
    speaker: 'Kam Udun',
    title: 'Boyun Kamı',
    prompt:
        'Kürek kemiğinde kara bir alâmet gördüm. Tengri obayı bu otlaktan göçmeye çağırıyor. Göçelim mi, yoksa kalalım mı?',
    left: Choice(
      label: 'Göç et',
      effects: {Metric.tore: 8, Metric.hazine: -8, Metric.halk: -6},
      outcome: 'Çadırlar söküldü; yorgun ama itaatkâr bir göç.',
    ),
    right: Choice(
      label: 'Kal',
      effects: {Metric.tore: -8, Metric.halk: 4},
      outcome: 'Yerinde kaldık; kam uğursuzluktan dem vurdu.',
    ),
  ),
  KaganCard(
    id: 'esir',
    speaker: 'Komutan Bayan',
    title: 'Sağ Kol Beyi',
    prompt:
        'Savaştan tutsaklar getirdik. Onları köle edip işe mi koşalım, yoksa fidye karşılığı mı salalım?',
    left: Choice(
      label: 'İşe koş',
      effects: {Metric.hazine: 8, Metric.tore: -8},
      outcome: 'Eller işe koşuldu; yaşlılar bunu töreye aykırı buldu.',
    ),
    right: Choice(
      label: 'Fidyeyle sal',
      effects: {Metric.hazine: 10, Metric.ordu: -4, Metric.tore: 4},
      outcome: 'Keseler doldu; tutsaklar yurduna döndü.',
    ),
  ),
  KaganCard(
    id: 'dugun',
    speaker: 'Hatun',
    title: 'Baş Hatun',
    prompt:
        'Vârisimizin düğünü yaklaşıyor. Bütün boyları doyuran görkemli bir toy mu verelim, yoksa sade mi geçelim?',
    left: Choice(
      label: 'Görkemli toy',
      effects: {Metric.halk: 10, Metric.ordu: 6, Metric.hazine: -12},
      outcome: 'Kazanlar kaynadı; adın yedi boyda anıldı.',
    ),
    right: Choice(
      label: 'Sade düğün',
      effects: {Metric.hazine: 8, Metric.halk: -6},
      outcome: 'Hazine korundu; dedikodu da eksik olmadı.',
    ),
  ),
  KaganCard(
    id: 'su_kavgasi',
    speaker: 'İki Boy Beyi',
    title: 'Anlaşmazlık',
    prompt:
        'İki boy bir ırmağın suyu için bıçaklara davrandı. Güçlü boydan yana mı çıkalım, yoksa suyu adilce mi paylaştıralım?',
    left: Choice(
      label: 'Güçlüden yana',
      effects: {Metric.ordu: 8, Metric.halk: -6, Metric.tore: -6},
      outcome: 'Güçlü boy yanına çekildi; zayıf boy kin tuttu.',
    ),
    right: Choice(
      label: 'Adil paylaştır',
      effects: {Metric.tore: 10, Metric.ordu: -6},
      outcome: 'İki boy da pay aldı; adaletin konuşuldu.',
    ),
  ),
  KaganCard(
    id: 'demirci',
    speaker: 'Demirci Başı',
    title: 'Ergene Ustası',
    prompt:
        'Yeni bir su ocağı kurarsam kılıçlarımız daha keskin olur. Ocağı fonlayalım mı, yoksa keseyi mi koruyalım?',
    left: Choice(
      label: 'Ocağı fonla',
      effects: {Metric.ordu: 12, Metric.hazine: -10},
      outcome: 'Örsler döğüldü; ordu yeni çelikle donandı.',
    ),
    right: Choice(
      label: 'Keseyi koru',
      effects: {Metric.hazine: 6, Metric.ordu: -6},
      outcome: 'Usta küstü; eski kılıçlarla idare edildi.',
    ),
  ),
  KaganCard(
    id: 'yagma_payi',
    speaker: 'Beyler Heyeti',
    title: 'Ganimet Paylaşımı',
    prompt:
        'Zaferden sonra ganimet bölüşülecek. Aslan payını beylere mi verelim, yoksa halka mı dağıtalım?',
    left: Choice(
      label: 'Beylere ver',
      effects: {Metric.ordu: 10, Metric.halk: -8, Metric.hazine: -4},
      outcome: 'Beyler doydu; sıradan yiğitler söylendi.',
    ),
    right: Choice(
      label: 'Halka dağıt',
      effects: {Metric.halk: 12, Metric.ordu: -8},
      outcome: 'Çadırlar şenlendi; beylerin kaşı çatıldı.',
    ),
  ),
  KaganCard(
    id: 'casus',
    speaker: 'İç Oğuş Başı',
    title: 'Muhafız Beyi',
    prompt:
        'Bir casusu yakaladık kağanım. Halkın önünde mi cezalandıralım, yoksa para verip kendi adımıza mı çalıştıralım?',
    left: Choice(
      label: 'Halkın önünde cezalandır',
      effects: {Metric.tore: 8, Metric.ordu: 6, Metric.halk: -6},
      outcome: 'İbret oldu; korku da yayıldı.',
    ),
    right: Choice(
      label: 'Kendine çalıştır',
      effects: {Metric.ordu: 8, Metric.hazine: -6, Metric.tore: -6},
      outcome: 'Casus döndü; düşmanın sırrı artık bizde.',
    ),
  ),
  KaganCard(
    id: 'eski_tore',
    speaker: 'Aksakal Tonga',
    title: 'Boyun Aksakalı',
    prompt:
        'Atalarımızın katı töresi unutuluyor. Eski yasaları yeniden diriltelim mi, yoksa zamana mı uyalım?',
    left: Choice(
      label: 'Töreyi dirilt',
      effects: {Metric.tore: 12, Metric.halk: -8},
      outcome: 'Eski yasa geri geldi; gençler zoru yaşadı.',
    ),
    right: Choice(
      label: 'Zamana uy',
      effects: {Metric.tore: -10, Metric.halk: 8},
      outcome: 'Kurallar yumuşadı; aksakallar dertlendi.',
    ),
  ),
  KaganCard(
    id: 'kuzey_boylari',
    speaker: 'Yabancı Bey',
    title: 'Kuzeyli Sığınmacı',
    prompt:
        'Soğuktan kaçan kuzey boyları otağına sığınmak ister. Onları içeri mi alalım, yoksa kapıyı mı kapatalım?',
    left: Choice(
      label: 'İçeri al',
      effects: {Metric.halk: 8, Metric.ordu: 8, Metric.hazine: -10},
      outcome: 'Yeni yiğitler saflara katıldı; ağızlar da çoğaldı.',
    ),
    right: Choice(
      label: 'Geri çevir',
      effects: {Metric.hazine: 6, Metric.halk: -6, Metric.tore: -4},
      outcome: 'Kapı kapandı; bozkır soğuğunda donanlar oldu.',
    ),
  ),
  KaganCard(
    id: 'altin_madeni',
    speaker: 'Defterdar Üge',
    title: 'Hazine Yazıcısı',
    prompt:
        'Dağda altın damarı bulundu. Halkı zorla çalıştırıp hızla mı çıkaralım, yoksa ağır ama gönüllü mü işletelim?',
    left: Choice(
      label: 'Zorla çıkar',
      effects: {Metric.hazine: 14, Metric.halk: -12},
      outcome: 'Altın aktı; madende beller büküldü.',
    ),
    right: Choice(
      label: 'Gönüllü işlet',
      effects: {Metric.hazine: 6, Metric.halk: 4},
      outcome: 'Ağır ama huzurlu; kese yavaş doldu.',
    ),
  ),
  KaganCard(
    id: 'yabanci_din',
    speaker: 'Yabancı Vaiz',
    title: 'Gezgin Rahip',
    prompt:
        'Obada yeni bir inanç yayılıyor. Hoşgörüyle bırakalım mı, yoksa Gök Tengri töresi adına yasaklayalım mı?',
    left: Choice(
      label: 'Hoşgörü göster',
      effects: {Metric.tore: -10, Metric.hazine: 8, Metric.halk: 6},
      outcome: 'Tüccarlar ve mühtediler memnun; kamlar tedirgin.',
    ),
    right: Choice(
      label: 'Yasakla',
      effects: {Metric.tore: 10, Metric.halk: -8},
      outcome: 'Eski töre korundu; bazı çadırlar küstü.',
    ),
  ),
  KaganCard(
    id: 'ordugah',
    speaker: 'Komutan Bayan',
    title: 'Sağ Kol Beyi',
    prompt:
        'Askerin maaşı gecikti, çadırlarda söylenti var. Hazineyi açıp şimdi mi ödeyelim, yoksa zafere kadar mı erteleyelim?',
    left: Choice(
      label: 'Şimdi öde',
      effects: {Metric.hazine: -12, Metric.ordu: 12},
      outcome: 'Kese boşaldı; askerin gözü parladı.',
    ),
    right: Choice(
      label: 'Ertele',
      effects: {Metric.ordu: -12, Metric.hazine: 6},
      outcome: 'Hazine korundu; bazı bölükler hava kararınca dağıldı.',
    ),
  ),
  KaganCard(
    id: 'kiz_isteme',
    speaker: 'Güçlü Han Elçisi',
    title: 'Yabancı Han Elçisi',
    prompt:
        'Bozkırın en güçlü hanı kızını ister. Kızını verip ittifak mı kuralım, yoksa onu yanında mı tutalım?',
    left: Choice(
      label: 'Kızını ver',
      effects: {
        Metric.ordu: 10,
        Metric.hazine: 8,
        Metric.halk: -6,
        Metric.tore: -4
      },
      outcome: 'İki yurt akraba oldu; otağda bir ocak söndü.',
    ),
    right: Choice(
      label: 'Yanında tut',
      effects: {Metric.tore: 8, Metric.ordu: -8},
      outcome: 'Han reddi hakaret saydı; sınırda davullar çalındı.',
    ),
  ),
  KaganCard(
    id: 'yangin',
    speaker: 'Aksakal Tonga',
    title: 'Boyun Aksakalı',
    prompt:
        'Bir gece ateşi yarım obayı yaktı. Hazineden çadır ve sürü mü verelim, yoksa aileler kendi mi toparlasın?',
    left: Choice(
      label: 'Hazineden ver',
      effects: {Metric.hazine: -12, Metric.halk: 12},
      outcome: 'Yeni çadırlar kuruldu; halk minnettar.',
    ),
    right: Choice(
      label: 'Kendileri toparlasın',
      effects: {Metric.halk: -10, Metric.hazine: 6},
      outcome: 'Hazine korundu; küller arasında küskünlük kaldı.',
    ),
  ),
  KaganCard(
    id: 'bilge',
    speaker: 'İhtiyar Bilge',
    title: 'Gezgin Ozan',
    prompt:
        'Bir ozan, zaferlerinin seni kibre sürüklediğini söyler. Öğüdünü dinleyip alçakgönüllü mü olalım, yoksa lafını mı keselim?',
    left: Choice(
      label: 'Öğüdü dinle',
      effects: {Metric.tore: 10, Metric.halk: 6, Metric.ordu: -6},
      outcome: 'Tevazu bozkırda anlatıldı; beyler şaşırdı.',
    ),
    right: Choice(
      label: 'Lafını kes',
      effects: {Metric.tore: -8, Metric.ordu: 6},
      outcome: 'Ozan sustu; gururun pekişti.',
    ),
  ),
  KaganCard(
    id: 'ticaret_yolu',
    speaker: 'Tüccar Maniak',
    title: 'Soğd Kervanbaşı',
    prompt:
        'Bir geçit, kazançlı ipek yolunu denetliyor. Oraya muhafız dikip vergi mi alalım, yoksa serbest bırakıp halkı mı sevindirelim?',
    left: Choice(
      label: 'Muhafız dik',
      effects: {Metric.hazine: 12, Metric.ordu: -6},
      outcome: 'Geçit vergisi aktı; bölükler dağıldı.',
    ),
    right: Choice(
      label: 'Serbest bırak',
      effects: {Metric.hazine: -6, Metric.halk: 8},
      outcome: 'Yollar şenlendi, mallar ucuzladı.',
    ),
  ),
  KaganCard(
    id: 'kut',
    speaker: 'Kam Udun',
    title: 'Boyun Kamı',
    prompt:
        'Tengri sana "kut" verdi diye haykıralım mı, görkemli bir tören kuralım mı; yoksa kağan alçakgönüllü mü kalsın?',
    left: Choice(
      label: 'Kut\'u ilan et',
      effects: {
        Metric.tore: 10,
        Metric.halk: 8,
        Metric.ordu: 4,
        Metric.hazine: -10
      },
      outcome: 'Davullar gümbürdedi; kutun yedi iklime yayıldı.',
    ),
    right: Choice(
      label: 'Alçakgönüllü kal',
      effects: {Metric.tore: -6, Metric.hazine: 4},
      outcome: 'Tören olmadı; bazıları bunu zayıflık sandı.',
    ),
  ),
  KaganCard(
    id: 'salgin_hayvan',
    speaker: 'Yılkıcı Sübeg',
    title: 'Baş Yılkıcı',
    prompt:
        'Sürülere bir hastalık düştü. Hasta hayvanları telef edip yayılmayı mı durduralım, yoksa kamın duasına mı bırakalım?',
    left: Choice(
      label: 'Telef et',
      effects: {Metric.hazine: -8, Metric.halk: -6, Metric.tore: 2},
      outcome: 'Hastalık durdu; sürüler inceldi.',
    ),
    right: Choice(
      label: 'Duaya bırak',
      effects: {Metric.tore: 8, Metric.hazine: -10, Metric.halk: -4},
      outcome: 'Dualar okundu; hastalık komşu sürülere de atladı.',
    ),
  ),
  KaganCard(
    id: 'genc_varis',
    speaker: 'Hatun',
    title: 'Baş Hatun',
    prompt:
        'Vârisimiz delişmen, akına can atıyor. Onu sıkı bir terbiyeden mi geçirelim, yoksa başına buyruk bırakıp şanını mı arttırsın?',
    left: Choice(
      label: 'Sıkı terbiye',
      effects: {Metric.tore: 8, Metric.halk: 4, Metric.ordu: -4},
      outcome: 'Vâris dizginlendi; gözünde bir küskünlük belirdi.',
    ),
    right: Choice(
      label: 'Başına buyruk bırak',
      effects: {Metric.ordu: 8, Metric.tore: -8},
      outcome: 'Genç bir akına çıktı; şanı da çılgınlığı da arttı.',
    ),
  ),
  KaganCard(
    id: 'yabanci_usta',
    speaker: 'Yabancı Usta',
    title: 'Gezgin Zanaatkâr',
    prompt:
        'Yabancı ustalar obamıza yerleşmek, sanatlarını öğretmek ister. Kabul edip onları yerleştirelim mi, yoksa geri mi çevirelim?',
    left: Choice(
      label: 'Yerleştir',
      effects: {Metric.hazine: 10, Metric.halk: 6, Metric.tore: -8},
      outcome: 'Pazarda yeni mallar belirdi; eski usul sarsıldı.',
    ),
    right: Choice(
      label: 'Geri çevir',
      effects: {Metric.tore: 8, Metric.hazine: -6},
      outcome: 'Ustalar başka yurda gitti; töre korundu.',
    ),
  ),
  KaganCard(
    id: 'kar_firtinasi',
    speaker: 'Komutan Bayan',
    title: 'Sağ Kol Beyi',
    prompt:
        'Korkunç bir tipi yaklaşıyor. Sürüleri ve halkı obaya mı toplayalım, yoksa orduyu hareketli tutup düşmana mı hazır olalım?',
    left: Choice(
      label: 'Obaya topla',
      effects: {Metric.halk: 10, Metric.ordu: -6},
      outcome: 'Çadırlar doldu, sürüler kurtuldu; atlar tembelleşti.',
    ),
    right: Choice(
      label: 'Orduyu hazır tut',
      effects: {Metric.ordu: 10, Metric.halk: -8},
      outcome: 'Ordu tetikte kaldı; soğukta birkaç çoban kayboldu.',
    ),
  ),
  KaganCard(
    id: 'adalet',
    speaker: 'İç Oğuş Başı',
    title: 'Muhafız Beyi',
    prompt:
        'Bir bey, sıradan bir çobanı öldürdü. Töre uyarınca beyi mi cezalandıralım, yoksa kan bedeli alıp olayı mı kapatalım?',
    left: Choice(
      label: 'Beyi cezalandır',
      effects: {Metric.halk: 10, Metric.tore: 8, Metric.ordu: -8},
      outcome: 'Adaletin dilden dile dolaştı; beyler ürktü.',
    ),
    right: Choice(
      label: 'Kan bedeli al',
      effects: {Metric.hazine: 6, Metric.ordu: 4, Metric.halk: -10},
      outcome: 'Bey kurtuldu; çobanın anası göğe beddua etti.',
    ),
  ),
  KaganCard(
    id: 'buyuk_av',
    speaker: 'Beyler Heyeti',
    title: 'Sürek Avı',
    prompt:
        'Beyleri kaynaştıracak büyük bir sürek avı düzenleyelim mi, yoksa herkes işinin başına mı dönsün?',
    left: Choice(
      label: 'Avı düzenle',
      effects: {Metric.ordu: 8, Metric.halk: 6, Metric.hazine: -10},
      outcome: 'Beyler omuz omuza avlandı; bağlar tazelendi.',
    ),
    right: Choice(
      label: 'İşe dön',
      effects: {Metric.hazine: 6, Metric.ordu: -6},
      outcome: 'Av iptal oldu; beyler arasındaki soğukluk sürdü.',
    ),
  ),
  KaganCard(
    id: 'yas',
    speaker: 'Kam Udun',
    title: 'Boyun Kamı',
    prompt:
        'Önceki kağan göçtü. Uzun bir yas tutup töreyi yerine getirelim mi, yoksa kısa bir matemle işlerin başına mı dönelim?',
    left: Choice(
      label: 'Uzun yas tut',
      effects: {Metric.tore: 10, Metric.hazine: -8, Metric.ordu: -6},
      outcome: 'Yoğ töreni günlerce sürdü; töre yerini buldu.',
    ),
    right: Choice(
      label: 'Kısa mateme dön',
      effects: {Metric.tore: -8, Metric.hazine: 6, Metric.ordu: 4},
      outcome: 'Çabuk toparlanıldı; yaşlılar bunu saygısızlık saydı.',
    ),
  ),
];
