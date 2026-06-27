import '../models/era.dart';
import '../models/kagan_card.dart';
import '../models/metric.dart';

/// The dilemma deck. Each card trades a few pillars against each other so no
/// answer is free. Effects are tuned to roughly cancel over a long reign.
/// Not `const` because some cards carry [condition] closures.
final deck = <KaganCard>[
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
      enqueue: 'bori_geri_doner',
      enqueueAfter: 4,
    ),
  ),
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
    id: 'cin_elcisi',
    speaker: 'Çin Elçisi Pei',
    title: 'Tang Sarayı Elçisi',
    prompt:
        'İmparator sana ipek, unvan ve altın yollar; karşılığında tabiiyet ister. Armağanları alıp baş eğelim mi, yoksa elçiyi geri mi gönderelim?',
    left: Choice(
      label: 'Armağanı al',
      effects: {Metric.hazine: 14, Metric.tore: -10, Metric.ordu: -6},
      outcome: 'Saray altına gömüldü; bozkır bunu utanç saydı.',
      enqueue: 'cin_baski',
      enqueueAfter: 3,
    ),
    right: Choice(
      label: 'Geri yolla',
      effects: {Metric.tore: 10, Metric.ordu: 6, Metric.hazine: -8},
      outcome: 'Elçi eli boş döndü; onurun bozkırda anlatıldı.',
    ),
  ),
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
      enqueue: 'casus_ifsa',
      enqueueAfter: 3,
    ),
  ),
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
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
  const KaganCard(
    id: 'kan_davasi',
    speaker: 'Aksakal Tonga',
    title: 'Boyun Aksakalı',
    prompt:
        'İki aile arasında kan davası büyüyor. Araya girip barıştıralım mı, yoksa töre gereği kanı kanla mı ödetelim?',
    left: Choice(
      label: 'Barıştır',
      effects: {Metric.halk: 10, Metric.tore: -6},
      outcome: 'Eller sıkıldı; bazıları öcün alınmadığına yandı.',
    ),
    right: Choice(
      label: 'Töreyi uygula',
      effects: {Metric.tore: 10, Metric.halk: -8},
      outcome: 'Kan kanla ödendi; töre yerini buldu, oba sustu.',
    ),
  ),
  const KaganCard(
    id: 'kusatma',
    speaker: 'Komutan Bayan',
    title: 'Sağ Kol Beyi',
    prompt:
        'Düşman kalesini kuşattık. Hemen hücum mu edelim, yoksa açlığa terk edip teslim mi bekleyelim?',
    left: Choice(
      label: 'Hücum et',
      effects: {Metric.ordu: 6, Metric.hazine: 8, Metric.halk: -10},
      outcome: 'Kale düştü; surların önü yiğit cesetleriyle doldu.',
    ),
    right: Choice(
      label: 'Açlığa terk et',
      effects: {Metric.hazine: -8, Metric.ordu: -4, Metric.tore: 4},
      outcome: 'Kale aylar sonra teslim oldu; sabır pahalıya patladı.',
    ),
  ),
  const KaganCard(
    id: 'ay_tutulmasi',
    speaker: 'Kam Udun',
    title: 'Boyun Kamı',
    prompt:
        'Ay kana boyandı, gök bir uyarı verdi. Büyük bir kurbanla Tengri\'yi yatıştıralım mı, yoksa korkuya boyun eğmeyelim mi?',
    left: Choice(
      label: 'Kurban sun',
      effects: {Metric.tore: 10, Metric.hazine: -8, Metric.halk: 4},
      outcome: 'Kurbanlar kesildi; korkan halk biraz yatıştı.',
    ),
    right: Choice(
      label: 'Boyun eğme',
      effects: {Metric.tore: -10, Metric.ordu: 6},
      outcome: 'Kağan göğe meydan okudu; kimi cesaret, kimi dehşet duydu.',
    ),
  ),
  const KaganCard(
    id: 'kole_pazari',
    speaker: 'Tüccar Maniak',
    title: 'Soğd Kervanbaşı',
    prompt:
        'Savaş tutsaklarını köle pazarımda iyi paraya satabilirim. Satalım mı, yoksa bu işe bulaşmayalım mı?',
    left: Choice(
      label: 'Sat',
      effects: {Metric.hazine: 12, Metric.tore: -8},
      outcome: 'Keseler doldu; aksakallar bu kazancı kirli buldu.',
    ),
    right: Choice(
      label: 'Bulaşma',
      effects: {Metric.tore: 8, Metric.hazine: -4},
      outcome: 'Tutsaklar pazara çıkmadı; tüccar omuz silkti.',
    ),
  ),
  const KaganCard(
    id: 'sahte_para',
    speaker: 'Defterdar Üge',
    title: 'Hazine Yazıcısı',
    prompt:
        'Sikkenin altınını azaltıp daha çok para basabiliriz kağanım. Hazineyi böyle mi şişirelim, yoksa paranın ayarı mı korunsun?',
    left: Choice(
      label: 'Ayarı düşür',
      effects: {Metric.hazine: 12, Metric.halk: -8, Metric.tore: -4},
      outcome: 'Kese doldu; pazarda fiyatlar fırladı, güven sarsıldı.',
    ),
    right: Choice(
      label: 'Ayarı koru',
      effects: {Metric.hazine: -6, Metric.halk: 8},
      outcome: 'Para itibarlı kaldı; tüccarlar obaya akın etti.',
    ),
  ),
  const KaganCard(
    id: 'ikinci_hatun',
    speaker: 'Hatun',
    title: 'Baş Hatun',
    prompt:
        'Bir bey, ittifak için kızını sana hatun vermek ister. İkinci bir hatun alıp bağı mı güçlendirelim, yoksa ocağına mı sadık kalalım?',
    left: Choice(
      label: 'Hatun al',
      effects: {Metric.ordu: 10, Metric.hazine: 6, Metric.halk: -8},
      outcome: 'İttifak mühürlendi; otağda bir gönül kırıldı.',
    ),
    right: Choice(
      label: 'Sadık kal',
      effects: {Metric.halk: 8, Metric.tore: 4, Metric.ordu: -8},
      outcome: 'Vefan konuşuldu; bey teklifini geri çekti.',
    ),
  ),
  const KaganCard(
    id: 'sinir_komutasi',
    speaker: 'Genç Bey Böri',
    title: 'Hırslı Bey',
    prompt:
        'Böri artık sadık ama hırslı. Sınır boyunun komutasını ona mı verelim, yoksa gözümüzün önünde mi tutalım?',
    left: Choice(
      label: 'Sınırı ver',
      effects: {Metric.ordu: 12, Metric.tore: -6},
      outcome: 'Sınır sağlama alındı; Böri uzakta güçleniyor.',
    ),
    right: Choice(
      label: 'Yanında tut',
      effects: {Metric.ordu: -6, Metric.tore: 6, Metric.halk: 4},
      outcome: 'Böri otağda kaldı; sınır biraz daha zayıf.',
    ),
  ),
  const KaganCard(
    id: 'duello',
    speaker: 'Yüzbaşı Alp Er',
    title: 'Genç Süvari',
    prompt:
        'Düşman, iki ordu yerine er meydanında tek bir yiğitle işi çözmeyi öneriyor. Alp Er\'i meydana mı sürelim, yoksa reddedip savaşa mı tutuşalım?',
    left: Choice(
      label: 'Meydana sür',
      effects: {Metric.halk: 10, Metric.ordu: 6, Metric.hazine: 4},
      outcome: 'Alp Er er meydanında galip geldi; oba bir hafta şenlendi.',
    ),
    right: Choice(
      label: 'Reddet',
      effects: {Metric.ordu: -8, Metric.halk: -6},
      outcome: 'Meydan okuma geri çevrildi; düşman korkaklıkla suçladı.',
    ),
  ),
  const KaganCard(
    id: 'yaralilar',
    speaker: 'Hekim Otacı',
    title: 'Otacı (Hekim)',
    prompt:
        'Savaştan dönen yaralılar inliyor. Hazineyi açıp hepsini tedavi mi ettirelim, yoksa kaderlerine mi bırakalım?',
    left: Choice(
      label: 'Tedavi ettir',
      effects: {Metric.hazine: -8, Metric.ordu: 8, Metric.halk: 6},
      outcome: 'Yiğitler ayağa kalktı; ordu kağanına minnettar.',
    ),
    right: Choice(
      label: 'Kadere bırak',
      effects: {Metric.hazine: 6, Metric.ordu: -10, Metric.halk: -6},
      outcome: 'Hazine korundu; çadırlardan iniltiler yükseldi.',
    ),
  ),
  const KaganCard(
    id: 'damizlik_at',
    speaker: 'Yılkıcı Sübeg',
    title: 'Baş Yılkıcı',
    prompt:
        'Komşu han, en iyi damızlık aygırlarımıza ağır altın veriyor. Satalım mı, yoksa kan hattını kendimize mi saklayalım?',
    left: Choice(
      label: 'Sat',
      effects: {Metric.hazine: 12, Metric.ordu: -8},
      outcome: 'Altın aktı; en iyi kan rakibin ahırına girdi.',
    ),
    right: Choice(
      label: 'Sakla',
      effects: {Metric.ordu: 8, Metric.hazine: -4},
      outcome: 'Soy bizde kaldı; süvarimiz bozkırın en hızlısı.',
    ),
  ),
  const KaganCard(
    id: 'tang_prensesi',
    speaker: 'Çin Elçisi Pei',
    title: 'Tang Sarayı Elçisi',
    prompt:
        'İmparator, barış için bir prensesi ve büyük bir çeyizi sana vermeyi öneriyor. Kabul edip akraba mı olalım, yoksa bozkır onurunu mu koruyalım?',
    left: Choice(
      label: 'Kabul et',
      effects: {Metric.hazine: 12, Metric.ordu: 6, Metric.tore: -10},
      outcome: 'Saray ihtişama büründü; bozkır Çin\'e yanaşıldı diye söylendi.',
    ),
    right: Choice(
      label: 'Onuru koru',
      effects: {Metric.tore: 10, Metric.hazine: -6},
      outcome: 'Teklif reddedildi; bağımsızlık türkülere kondu.',
    ),
  ),
  const KaganCard(
    id: 'kut_sorgusu',
    speaker: 'Beyler Heyeti',
    title: 'Kurultay',
    prompt:
        'Bir yenilgiden sonra beyler kutunu sorguluyor. Kurultay toplayıp seçimini yenileyelim mi, yoksa muhalefeti ezip otoriteyi mi gösterelim?',
    left: Choice(
      label: 'Kurultay topla',
      effects: {Metric.tore: 8, Metric.ordu: 6, Metric.hazine: -6},
      outcome: 'Beyler yeniden biat etti; meşruiyetin tazelendi.',
    ),
    right: Choice(
      label: 'Muhalefeti ez',
      effects: {Metric.ordu: 8, Metric.halk: -8, Metric.tore: -6},
      outcome: 'Sesler kısıldı; korku itaati getirdi, sevgiyi değil.',
    ),
  ),
  const KaganCard(
    id: 'esir_takasi',
    speaker: 'Elçi Yamtar',
    title: 'Komşu Boyun Elçisi',
    prompt:
        'Tutsak düşen beyini geri istiyorlar. Asker takasıyla mı geri alalım, yoksa ağır bir fidyeye mi bağlayalım?',
    left: Choice(
      label: 'Takas yap',
      effects: {Metric.ordu: 8, Metric.hazine: -6},
      outcome: 'Beyimiz yurda döndü; saflar tazelendi.',
    ),
    right: Choice(
      label: 'Fidye iste',
      effects: {Metric.hazine: 12, Metric.ordu: -6, Metric.halk: -4},
      outcome: 'Kese doldu; tutsak beyin ailesi kırgın kaldı.',
    ),
  ),
  const KaganCard(
    id: 'suikast_plani',
    speaker: 'İç Oğuş Başı',
    title: 'Muhafız Beyi',
    prompt:
        'Muhafızlar arasında bir suikast planı sezdik kağanım. Bütün muhafızı eleyip yenileyelim mi, yoksa sessizce elebaşını mı kaldıralım?',
    left: Choice(
      label: 'Muhafızı ele',
      effects: {Metric.tore: 6, Metric.ordu: -8, Metric.halk: -4},
      outcome: 'Saray temizlendi; ama güvenlik bir süre aksadı.',
    ),
    right: Choice(
      label: 'Elebaşını kaldır',
      effects: {Metric.ordu: 6, Metric.tore: -6},
      outcome: 'Tehlike sessizce yok edildi; dedikodu fısıltıyla yayıldı.',
    ),
  ),
  const KaganCard(
    id: 'zirh_mi_kilic_mi',
    speaker: 'Demirci Başı',
    title: 'Ergene Ustası',
    prompt:
        'Sınırlı demirimiz var. Halkı koruyacak zırh mı dövelim, yoksa düşmanı biçecek kılıç mı?',
    left: Choice(
      label: 'Zırh döv',
      effects: {Metric.halk: 8, Metric.ordu: 4, Metric.hazine: -8},
      outcome: 'Yiğitler zırha büründü; halk kendini güvende hissetti.',
    ),
    right: Choice(
      label: 'Kılıç döv',
      effects: {Metric.ordu: 10, Metric.hazine: -8, Metric.halk: -2},
      outcome: 'Keskin kılıçlar kuşanıldı; saldırı gücü arttı.',
    ),
  ),
  const KaganCard(
    id: 'tapinak',
    speaker: 'Yabancı Vaiz',
    title: 'Gezgin Rahip',
    prompt:
        'İnananlar bir ibadethane yapmak için izin ve yardım ister. Tapınağı fonlayalım mı, yoksa Gök Tengri töresi adına reddedelim mi?',
    left: Choice(
      label: 'Tapınağı fonla',
      effects: {Metric.hazine: -8, Metric.halk: 8, Metric.tore: -8},
      outcome: 'Tapınak yükseldi; tüccarlar memnun, kamlar küskün.',
    ),
    right: Choice(
      label: 'Reddet',
      effects: {Metric.tore: 8, Metric.halk: -6},
      outcome: 'Eski töre korundu; bir cemaat sessizce küstü.',
    ),
  ),
  const KaganCard(
    id: 'destan',
    speaker: 'İhtiyar Bilge',
    title: 'Gezgin Ozan',
    prompt:
        'Zaferlerini ölümsüz kılacak bir destan düzmek isterim kağanım. Beni ağırlayıp destanı yazdıralım mı, yoksa böbürlenmeye gerek var mı?',
    left: Choice(
      label: 'Destanı yazdır',
      effects: {Metric.halk: 8, Metric.tore: 6, Metric.hazine: -6},
      outcome: 'Adın kopuz tellerinde yedi boya yayıldı.',
    ),
    right: Choice(
      label: 'Gerek yok',
      effects: {Metric.tore: -4, Metric.hazine: 4},
      outcome: 'Ozan başka kapı çaldı; namın dilden dile kalmadı.',
    ),
  ),
  const KaganCard(
    id: 'su_kanali',
    speaker: 'Yabancı Usta',
    title: 'Gezgin Zanaatkâr',
    prompt:
        'Irmaktan su kanalı çekersem otlakların yeşerir, tarla biçersiniz. Yerleşik düzene mi geçelim, yoksa göçer töresine mi sadık kalalım?',
    left: Choice(
      label: 'Kanalı kazdır',
      effects: {Metric.halk: 10, Metric.hazine: -8, Metric.tore: -6},
      outcome: 'Tarlalar yeşerdi; kimi yaşlı göçer hayatına ağladı.',
    ),
    right: Choice(
      label: 'Göçer kal',
      effects: {Metric.tore: 8, Metric.halk: -4},
      outcome: 'Oklar yine bozkıra sürüldü; töre korundu.',
    ),
  ),
  const KaganCard(
    id: 'firariler',
    speaker: 'Yüzbaşı Alp Er',
    title: 'Genç Süvari',
    prompt:
        'Savaştan kaçan birkaç asker yakalandı. Disiplin için onları idam mı edelim, yoksa bağışlayıp orduya mı katalım?',
    left: Choice(
      label: 'İdam et',
      effects: {Metric.ordu: 8, Metric.tore: 6, Metric.halk: -8},
      outcome: 'Saflar hizaya geldi; çadırlara korku çöktü.',
    ),
    right: Choice(
      label: 'Bağışla',
      effects: {Metric.halk: 8, Metric.ordu: -6, Metric.tore: -4},
      outcome: 'Merhametin konuşuldu; kimi bunu gevşeklik saydı.',
    ),
  ),
  const KaganCard(
    id: 'varis_hasta',
    speaker: 'Hatun',
    title: 'Baş Hatun',
    prompt:
        'Veliahtımız ateşler içinde yatıyor. Yabancı bir hekim mi getirtelim, yoksa kamın ellerine mi bırakalım?',
    left: Choice(
      label: 'Hekim getirt',
      effects: {Metric.hazine: -8, Metric.tore: -6, Metric.halk: 6},
      outcome: 'Yabancı ilaçlar vârisi kurtardı; kamlar gücendi.',
    ),
    right: Choice(
      label: 'Kama bırak',
      effects: {Metric.tore: 8, Metric.halk: -4},
      outcome: 'Kam günlerce okudu; vâris termiş gibi atlattı, töre güçlendi.',
    ),
  ),

  // --- Olay zinciri takip kartları (yalnızca tetiklenince çıkar) ---
  const KaganCard(
    id: 'bori_geri_doner',
    speaker: 'Genç Bey Böri',
    title: 'Eski Borç',
    scheduledOnly: true,
    prompt:
        'Bir zamanlar gönlünü aldığın Böri, borcunu ödemeye geldi: emrine bir süvari bölüğü sunuyor. Kabul edip yanına mı alalım, yoksa onurla geri mi çevirelim?',
    left: Choice(
      label: 'Kabul et',
      effects: {Metric.ordu: 12, Metric.halk: 4},
      outcome: 'Böri sözünü tuttu; bölüğü sancağına katıldı.',
    ),
    right: Choice(
      label: 'Geri çevir',
      effects: {Metric.tore: 8, Metric.hazine: 4},
      outcome: 'Borcu bağışladın; mertliğin dilden dile dolaştı.',
    ),
  ),
  const KaganCard(
    id: 'cin_baski',
    speaker: 'Çin Elçisi Pei',
    title: 'Artan İştah',
    scheduledOnly: true,
    prompt:
        'İmparator, verdiği armağanları bahane edip artık vergi ve itaat istiyor. Boyun eğip ödeyelim mi, yoksa zinciri kırıp karşı mı çıkalım?',
    left: Choice(
      label: 'Boyun eğ',
      effects: {Metric.hazine: -12, Metric.tore: -8, Metric.halk: -4},
      outcome: 'Vergi yollandı; bozkır başını öne eğdi.',
    ),
    right: Choice(
      label: 'Karşı çık',
      effects: {Metric.tore: 12, Metric.ordu: 6, Metric.hazine: -6},
      outcome: 'Zincir kırıldı; sınırda davullar yeniden çaldı.',
    ),
  ),
  const KaganCard(
    id: 'casus_ifsa',
    speaker: 'İç Oğuş Başı',
    title: 'İfşa',
    scheduledOnly: true,
    prompt:
        'Kendine çalıştırdığın casus deşifre oldu; düşman ikili oyununu öğrendi. Onu feda mı edelim, yoksa kaçırıp koruyalım mı?',
    left: Choice(
      label: 'Feda et',
      effects: {Metric.ordu: 6, Metric.tore: -6},
      outcome: 'Casus gözden çıkarıldı; iz sürenler yanıldı.',
    ),
    right: Choice(
      label: 'Kaçır ve koru',
      effects: {Metric.hazine: -8, Metric.halk: 4},
      outcome: 'Adamını korudun; sadakatin altın değerinde.',
    ),
  ),

  // --- Koşullu uç kartları (bir denge tehlikeye girince çıkar) ---
  KaganCard(
    id: 'darbe_riski',
    speaker: 'İç Oğuş Başı',
    title: 'Kıpırdanma',
    condition: _ordu(82),
    weight: 2,
    prompt:
        'Ordu öyle güçlendi ki bazı komutanlar fısıldaşmaya başladı. Önde gelenleri rütbeyle mi yatıştıralım, yoksa orduyu küçültüp dağıtalım mı?',
    left: const Choice(
      label: 'Rütbeyle yatıştır',
      effects: {Metric.hazine: -10, Metric.ordu: -6, Metric.halk: 4},
      outcome: 'Mevki dağıtıldı; hırslar şimdilik dindi.',
    ),
    right: const Choice(
      label: 'Orduyu küçült',
      effects: {Metric.ordu: -14, Metric.halk: 6},
      outcome: 'Bölükler dağıtıldı; tehlike azaldı, güç de.',
    ),
  ),
  KaganCard(
    id: 'kibir_tehlikesi',
    speaker: 'Hatun',
    title: 'Aşırı Sevgi',
    condition: _halk(82),
    weight: 2,
    prompt:
        'Halk seni o kadar sevdi ki beyler kıskanıyor, "kağan halka fazla yaslandı" diyorlar. Beylere de pay verip mi gönül alalım, yoksa halkın sevgisine mi güvenelim?',
    left: const Choice(
      label: 'Beylere pay ver',
      effects: {Metric.halk: -8, Metric.ordu: 8, Metric.hazine: -4},
      outcome: 'Beyler hediyelerle yatıştı; halk biraz darıldı.',
    ),
    right: const Choice(
      label: 'Halka güven',
      effects: {Metric.halk: 4, Metric.ordu: -8},
      outcome: 'Halkın sevgisine sığındın; beylerin kaşı çatık.',
    ),
  ),
  KaganCard(
    id: 'iflas_riski',
    speaker: 'Defterdar Üge',
    title: 'Boş Kese',
    condition: _hazine(18),
    weight: 2,
    prompt:
        'Hazine dibe vurdu kağanım. Acil bir baskın vergisi mi koyalım, yoksa saray eşyalarını eritip mi idare edelim?',
    left: const Choice(
      label: 'Baskın vergisi',
      effects: {Metric.hazine: 14, Metric.halk: -10},
      outcome: 'Kese biraz doldu; halk dişini sıktı.',
    ),
    right: const Choice(
      label: 'Sarayı erit',
      effects: {Metric.hazine: 10, Metric.tore: -6},
      outcome: 'Altın eşya eritildi; itibar pahasına nakit bulundu.',
    ),
  ),
  KaganCard(
    id: 'tore_catlagi',
    speaker: 'Kam Udun',
    title: 'Çatlayan Töre',
    condition: _tore(18),
    weight: 2,
    prompt:
        'Töre çiğnene çiğnene kamlar ve aksakallar isyan eşiğine geldi. Büyük bir tören ve af ile mi yatıştıralım, yoksa dik durup töreyi mi savunalım?',
    left: const Choice(
      label: 'Tören ve af',
      effects: {Metric.tore: 14, Metric.hazine: -8},
      outcome: 'Ateşler yakıldı; kamlar öfkesini yatıştırdı.',
    ),
    right: const Choice(
      label: 'Dik dur',
      effects: {Metric.tore: 10, Metric.halk: -8},
      outcome: 'Sertçe bastırıldı; töre korundu ama korkuyla.',
    ),
  ),
  KaganCard(
    id: 'altin_kibri',
    speaker: 'Defterdar Üge',
    title: 'Altına Boğulmak',
    condition: _hazineHigh(82),
    weight: 2,
    prompt:
        'Hazine altınla taştı; saray sefahate kayıyor, halk homurdanıyor. Altını halka ve sefere mi açalım, yoksa kasada mı tutalım?',
    left: const Choice(
      label: 'Altını aç',
      effects: {Metric.hazine: -14, Metric.halk: 8, Metric.ordu: 6},
      outcome: 'Kese açıldı; çadırlar ve saflar şenlendi.',
    ),
    right: const Choice(
      label: 'Kasada tut',
      effects: {Metric.hazine: 4, Metric.halk: -10, Metric.tore: -4},
      outcome: 'Altın istiflendi; sefahat ve dedikodu büyüdü.',
    ),
  ),

  // --- Çağ kartları ---
  const KaganCard(
    id: 'ilk_oba_yeri',
    speaker: 'Aksakal Tonga',
    title: 'Kuruluş',
    eras: {Era.kurulus},
    prompt:
        'Genç hanedanımıza kalıcı bir oba yeri seçmeliyiz. Verimli ama açık ovaya mı kuralım, yoksa korunaklı ama dar vadiye mi?',
    left: Choice(
      label: 'Açık ova',
      effects: {Metric.halk: 10, Metric.hazine: 6, Metric.ordu: -6},
      outcome: 'Sürüler bollaştı; ama oba saldırıya açık kaldı.',
    ),
    right: Choice(
      label: 'Korunaklı vadi',
      effects: {Metric.ordu: 10, Metric.halk: -6},
      outcome: 'Vadi savunmaya elverişli; topraksa cimri.',
    ),
  ),
  const KaganCard(
    id: 'eyalet_isyani',
    speaker: 'Komutan Bayan',
    title: 'Çöküş',
    eras: {Era.cokus},
    weight: 2,
    prompt:
        'Hanedan yaşlandı; uzak eyaletler vergi vermeyi kesti, bağımsızlık ilan ediyorlar. Kanlı bir seferle mi geri alalım, yoksa özerklik verip bağı mı koruyalım?',
    left: Choice(
      label: 'Sefere çık',
      effects: {Metric.ordu: 8, Metric.hazine: -12, Metric.halk: -6},
      outcome: 'İsyan bastırıldı; ama hazine ve canlar eridi.',
    ),
    right: Choice(
      label: 'Özerklik ver',
      effects: {Metric.tore: -8, Metric.hazine: 6, Metric.halk: 4},
      outcome: 'Eyaletler gevşek bağla kaldı; merkez zayıfladı.',
    ),
  ),
];

// Condition helpers for the conditional cards above.
CardCondition _ordu(int min) => (c) => c.m(Metric.ordu) >= min;
CardCondition _halk(int min) => (c) => c.m(Metric.halk) >= min;
CardCondition _hazine(int max) => (c) => c.m(Metric.hazine) <= max;
CardCondition _hazineHigh(int min) => (c) => c.m(Metric.hazine) >= min;
CardCondition _tore(int max) => (c) => c.m(Metric.tore) <= max;
