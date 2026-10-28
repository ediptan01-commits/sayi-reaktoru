# Sayı Reaktörü — Flutter MVP

10 bölümlük, Türkçe, çevrimdışı sayı zincirleme reaksiyon prototipi.

## Kurallar
1. Dolu kareye, sonra dikey/yatay komşu dolu kareye dokunun. İlk sayı ikincisine eklenir.
2. Değeri **8 veya üzeri** olan kare patlar ve boşalır.
3. Patlama, patlama anında dolu olan dört komşuya **+2** verir. Yeniden 8'e ulaşanlar yeni dalgada patlar.
4. Bölümde hedef patlama sayısına, hamleler tükenmeden ulaşın.

## Telefonda GitHub Actions ile APK
1. Bu ZIP'teki dosyaları yeni ve **ayrı** bir GitHub deposunun köküne yükleyin (`.github/workflows/android.yml` dahil).
2. Actions > Android APK > Run workflow (veya `main`'e push) çalıştırın.
3. İş bitince `Sayi-Reaktoru-debug-apk` artifact'ini indirin. İçindeki `app-debug.apk` test amaçlıdır.

Flutter bilgisayarda kuruluysa: `flutter create --platforms=android .`, `flutter pub get`, `flutter test`, `flutter run`.

## Mevcut kapsam ve sınırlamalar
- Bölüm ilerlemesi yalnızca uygulama açıkken saklanır; kalıcı kayıt henüz yok.
- Şu an animasyonlu patlama efektleri/sesler/puan liderlik tablosu yok.
- İlk 10 bulmaca taslak zorluk seviyeleridir; otomatik çözüm/denge testi henüz yok.
- Dağıtım için ayrıca release signing, uygun paket kimliği ve Play Store varlıkları gerekir.
