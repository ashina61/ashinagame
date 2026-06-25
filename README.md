# Ashina — Bozkırda Kağanlık

Kaydır-karar ver tarzı (Reigns benzeri) bir hayatta kalma oyunu. Ashina
hanedanının kağanı olarak otağına gelen kartlardaki ikilemleri **sağa ya da
sola kaydırarak** çözersin. Her karar dört dengeyi etkiler:

- 🧑‍🤝‍🧑 **Halk** · ⚔️ **Ordu** · 💰 **Hazine** · ☾ **Töre**

Bir denge **0'a düşer ya da 100'e taşarsa** tahtını yitirirsin; vârisin tahta
çıkar ve hanedan sürer. Amaç: en uzun saltanat ve en uzun hanedan.

## Çalıştırma

```bash
flutter pub get
flutter run
```

Test:

```bash
flutter test
```

## Yapı

```
lib/
  models/   metric.dart, kagan_card.dart        # veri tipleri
  data/     deck.dart, rulers.dart              # kart destesi + kağan adları
  state/    game_state.dart, stats_store.dart   # oyun mantığı + kayıt
  ui/       home / game / stats ekranları + widgets/
  theme/    renk, tipografi, tema
```

Görseller koddan üretilir (degrade/painter); yalnızca Cinzel & Alegreya
fontları ve launcher ikonu asset olarak tutulur. Yeni kart eklemek için
`lib/data/deck.dart` içine bir `KaganCard` eklemen yeterli.
