# Yayın (Google Play) Hazırlığı

## Uygulama kimliği
- **applicationId:** `com.ashina.bozkirda_bir_omur` (android/app/build.gradle)
- **Görünen ad:** Ashina (android:label)
- **Sürüm:** pubspec.yaml `version:` alanından (ör. `0.2.0+2` → versionName 0.2.0, versionCode 2)

## 1) İmza anahtarı oluştur (bir kez)
```bash
keytool -genkey -v -keystore ashina-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias ashina
```
`ashina-release.jks` dosyasını repoya **koyma** (.gitignore'da). Güvenli sakla.

## 2) key.properties
`android/key.properties.example`'ı `android/key.properties` olarak kopyalayıp
doldur (bu dosya da .gitignore'da).

## 3) build.gradle imza yapılandırması
`android/app/build.gradle` içinde `android { }` bloğuna ekle:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release { signingConfig signingConfigs.release }
    }
}
```
> Not: CI'daki `build-apk` iş akışı her koşuda `flutter create` çalıştırıp
> android/ dosyalarını yenileyebilir. Mağaza derlemesini **yerelde** ya da
> `flutter create` adımı olmayan ayrı bir release iş akışında yap.

## 4) Yayın paketi (AAB) üret
```bash
flutter build appbundle --release
# çıktı: build/app/outputs/bundle/release/app-release.aab
```
Play Console'a bu `.aab` yüklenir.

## Mağaza metinleri (taslak)
- **Başlık:** Ashina: Bozkırda Kağanlık
- **Kısa açıklama:** Kaydır, karar ver, hanedanını yaşat. Bir bozkır kağanlığı
  hayatta kalma oyunu.
- **Uzun açıklama:**
  Ashina hanedanının kağanı sensin. Otağına gelen beyler, kamlar, elçiler ve
  düşmanlar bir ikilem sunar; kartı **sağa ya da sola kaydırarak** karar
  verirsin. Her seçim dört dengeyi etkiler: **Halk, Ordu, Hazine, Töre.** Biri
  tükenir ya da taşarsa tahtını yitirirsin — ama vârisin tahta çıkar ve hanedan
  sürer. Olay zincirleri, çağlar, varis huyları ve sürpriz sonlarla her oyun
  farklı. Ne kadar uzun hüküm sürebilirsin?
- **Kategori:** Oyun / Strateji (veya Simülasyon)
- **İçerik derecesi:** Herkes / 7+ (savaş teması, grafik şiddet yok)

## Görsel materyaller (Play Console ister)
- Uygulama ikonu 512×512 (assets/icon/app_icon.png'den üretilebilir)
- Öne çıkan görsel (feature graphic) 1024×500
- En az 2 telefon ekran görüntüsü (oyun ekranı, menü)
