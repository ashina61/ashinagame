# Ashina — Görsel & Ses Varlık Kılavuzu

Tüm dosyalar **opsiyonel ve drop-in**: doğru ada sahip dosyayı doğru klasöre
atınca otomatik görünür/çalar; yoksa uygulama çizili görsele / sessizliğe
düşer. Dosya adlarını **birebir** koru.

---

## 1) Portreler — `assets/images/portraits/`

**Format:** kare **1:1**, 1024×1024 PNG. Kart üzerinde dairesel maskelenir, o
yüzden yüz ortalı olsun. Arka plan koyu olsun (daire içine oturur).

**Ortak stil (her promptun başına ekle):**

> Painterly semi-realistic character portrait, 6th–8th century Göktürk /
> Central Asian steppe culture, head and shoulders, centered, slight 3/4 view,
> dramatic warm rim light from one side, dark muted background (deep brown to
> black), earthy palette with gold accents, weathered realistic skin, detailed
> fur and fabric, cinematic, highly detailed, no text, no border, square 1:1.

Sonra karaktere özel kısmı ekle:

| Dosya | Karakter | Prompt eki (karaktere özel) |
|---|---|---|
| `aksakal_tonga.png` | Boyun Aksakalı | very old tribal elder, long white beard, deep wrinkles, fur-trimmed felt hat, wise stern eyes, worn leather robe |
| `komutan_bayan.png` | Sağ Kol Beyi (komutan) | battle-hardened general, lamellar armor, plumed helmet, facial scar, hand on sword hilt, grim |
| `beyler_heyeti.png` | Beyler / Kurultay | senior council bey representing the assembly, ornate fur hat, gold torc, embroidered heavy coat, authoritative |
| `elci_yamtar.png` | Komşu Boyun Elçisi | diplomat in his 30s, neat beard, embroidered travel coat, holding a sealed message, confident |
| `kam_udun.png` | Boyun Kamı (şaman) | steppe shaman, antler-and-feather headdress, bone and bead ornaments, holding a frame drum, painted face, trance gaze, mystical |
| `tuccar_maniak.png` | Soğd Kervanbaşı | Sogdian merchant, fine patterned silk robe, jeweled rings, exotic cap, shrewd friendly smile, holding silk cloth |
| `genc_bey_bori.png` | Asi Bey | young arrogant warrior, wolf-pelt over one shoulder, cheek scar, defiant smirk, leather armor |
| `hekim_otaci.png` | Otacı (hekim) | calm older healer, herb pouches and amulets, plain robe, holding a medicine bowl |
| `yilkici_subeg.png` | Baş Yılkıcı | rugged horse-herder, coiled rope/lasso, weathered face, simple clothes, faint horse silhouette behind |
| `cin_elcisi_pei.png` | Tang Sarayı Elçisi | refined Tang dynasty Chinese official, silk court robe, futou official hat, composed, holding an imperial decree scroll |
| `defterdar_uge.png` | Hazine Yazıcısı | middle-aged scribe, narrow shrewd face, ink-stained fingers, plain dark robe and cap, holding a ledger scroll |
| `yuzbasi_alp_er.png` | Genç Süvari | eager young cavalry captain, light armor, bow over shoulder, wind-blown hair, bold grin |
| `hatun.png` | Baş Hatun | noble steppe queen, tall ornate headdress, gold jewelry, embroidered silk, dignified and strong, beautiful |
| `iki_boy_beyi.png` | Anlaşmazlık | two stern rival clan chieftains side by side, tension between them, furs and leather |
| `demirci_basi.png` | Ergene Ustası (demirci) | muscular blacksmith, soot-streaked face, leather apron, holding tongs, glowing forge light on one side |
| `ic_ogus_basi.png` | Muhafız Beyi | vigilant inner-guard captain, dark armor, watchful eyes, hand resting on a dagger |
| `yabanci_bey.png` | Kuzeyli Sığınmacı | weathered northern chieftain, heavy furs, frost in his beard, tired but proud |
| `yabanci_vaiz.png` | Gezgin Rahip | foreign wandering preacher, pale Manichaean-style robe, serene, holding a small religious symbol |
| `han_elcisi.png` | Yabancı Han Elçisi | imposing envoy of a powerful khan, rich silk-trimmed coat, gold ornaments, feathered fur hat, proud |
| `yabanci_usta.png` | Gezgin Zanaatkâr | foreign master artisan, apron and tools, focused, holding a finely crafted ornament |
| `ihtiyar_bilge.png` | Gezgin Ozan | old wandering bard, holding a kopuz (lute), kind eyes, white hair, simple travel clothes |

---

## 2) Arka plan — `assets/images/bg/steppe.png`

**Format:** dikey **9:16**, ör. 1080×1920 PNG.

> Vast Central Asian steppe at dusk, rolling golden grasslands, distant
> mountains, moody dramatic sky, a few yurts (otağ) and a faint campfire glow
> far away, cinematic painterly style, desaturated earthy tones, edges darker
> for UI legibility, no text, vertical 9:16 composition.

(Üstüne otomatik bir karartma uygulanır, metin okunur kalır.)

---

## 3) Ses — `assets/audio/`

| Dosya | Tür | İstenen |
|---|---|---|
| `sfx/swipe.wav` | SFX | kısa kâğıt/whoosh + yumuşak davul vuruşu (~300 ms) |
| `sfx/death.wav` | SFX | hüzünlü tek büyük davul + alçak boru/gong tınısı (~1.5 sn) |
| `sfx/succeed.wav` | SFX | umutlu kısa yükseliş + küçük davul süslemesi (~1 sn) |
| `sfx/tap.wav` | SFX | yumuşak UI tık / deri dokunuşu (~150 ms) |
| `music/steppe.mp3` | Müzik (loop) | sakin ambiyans: alçak çerçeve-davul nabzı + kopuz/morin khuur drone + rüzgâr, ~1-2 dk döngü |

**Format:** SFX `.wav` (düşük gecikme), müzik `.mp3`. Adları birebir koru.

---

## 4) Uygulama ikonu (launcher) — `assets/icon/app_icon.png`

**Format:** kare **1024×1024** PNG, kenar boşluğu az, merkezde net amblem. Telefon
ana ekranındaki yuvarlak/köşeli ikona maskeleneceği için önemli detay ortada
olsun. (`dart run flutter_launcher_icons` ile tüm boyutlar üretilir.)

> App icon for a steppe-khanate game, a bold Göktürk-style wolf-head (Bozkurt)
> or a single tamga emblem, gold on a near-black background, clean flat
> vector-like emblem, centered, strong silhouette readable at small sizes,
> subtle metallic gold gradient, no text, square 1:1, 1024×1024.

## 5) Ana ekran logosu (opsiyonel) — `assets/images/ui/logo.png`

**Format:** yatay/şeffaf **PNG**, ~1200×400 (yükseklik ~120px gösterilir). Yoksa
"ASHINA" yazısına düşer.

> "ASHINA" wordmark logo for a steppe-khanate game, ornate engraved gold
> serif lettering with a small wolf-head or tamga emblem above or beside it,
> transparent background, weathered metallic gold, subtle depth, no extra
> text, horizontal lockup.
