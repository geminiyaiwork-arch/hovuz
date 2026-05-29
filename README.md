# Hovuz

**Hovuz** — kripto tranzaksiya va kashelek tekshiruv dasturi.
Bitcoin, Ethereum, TRON va BNB Chain tarmoqlaridagi har qanday
TxID yoki manzilni qidirib, batafsil oqimni ko'rsatadi: kim kimga,
qancha o'tkazgan, qaysi birjaga tushgan, komissiya va vaqt.

Texnologiya: Flutter Desktop (Linux + Windows).

## Imkoniyatlar

- 🔍 Qidiruv: TxID yoki kashelek manzilini avtomatik aniqlash.
- 🌐 4 tarmoq: BTC, ETH/ERC20, TRX/TRC20, BNB/BEP20.
- 🏦 Birja yorliqlari: Binance, OKX, Bybit, KuCoin, Bitget, Coinbase,
  Kraken, HTX, MEXC, Gate.io, Bitfinex va boshqa mashhurlari.
- 📊 Chap panel — umumiy hisob: balans, jami tushgan, jami chiqqan.
- 📋 O'ng panel — to'liq oqim: barcha o'tkazmalar, manzillar, vaqt.
- 🔗 Tashqi explorer'ga havola (Blockstream, Etherscan, Tronscan, BscScan).
- 🌙 Qorong'i tema (dark mode).

## Loyiha tuzilmasi

```
lib/
├── main.dart                          ← kirish nuqtasi, oyna sozlash
├── theme.dart                         ← qorong'i tema
├── models/
│   ├── chain.dart                     ← Chain, InputKind, DetectionResult
│   └── transfer.dart                  ← Transfer, TransactionInfo, AddressSummary
├── services/
│   ├── api_keys.dart                  ← API kalitlar (override qilinadi)
│   ├── chain_detector.dart            ← Input formatini aniqlash
│   ├── exchange_addresses.dart        ← Mashhur birjalarning manzillari DB
│   └── blockchain_service.dart        ← Blockstream + Etherscan + TronGrid + BscScan
├── pages/
│   ├── home_page.dart                 ← Asosiy sahifa
│   └── about_page.dart                ← Dastur haqida + AFTOR (placeholder)
├── widgets/
│   ├── search_header.dart             ← Tepadagi qidiruv paneli
│   ├── summary_sidebar.dart           ← Chap tomondagi hisob paneli
│   └── details_panel.dart             ← O'ng tomondagi batafsil panel
└── utils/
    └── format.dart                    ← Raqam/vaqt/manzil formatlash

packaging/
├── deb/build_deb.sh                   ← Linux .deb yasash skripti
├── windows/build_windows.ps1          ← Windows build skripti
└── windows/hovuz_setup.iss            ← Inno Setup installer skripti
```

## Build qilish

### Tayyorgarlik

Flutter SDK 3.4+ kerak. Tarmoqlarni yoqib oling:

```bash
flutter config --enable-linux-desktop --enable-windows-desktop
flutter pub get
```

### Linux (.deb)

Faqat dpkg + Flutter kerak, qo'shimcha tool yo'q:

```bash
./packaging/deb/build_deb.sh 1.0.0
# Natija: dist/hovuz_1.0.0_amd64.deb
sudo dpkg -i dist/hovuz_1.0.0_amd64.deb
hovuz
```

Manual ishga tushirish (paket yasamay):

```bash
flutter build linux --release
./build/linux/x64/release/bundle/hovuz
```

### Windows (.exe)

Windows mashinada (Visual Studio 2022 Build Tools + Inno Setup 6 o'rnatilgan):

```powershell
.\packaging\windows\build_windows.ps1
# Natija: dist\HovuzSetup-1.0.0.exe
```

Yoki faqat portable bundle yasash:

```powershell
flutter build windows --release
# Natija: build\windows\x64\runner\Release\ (hovuz.exe + DLL'lar)
```

## API kalitlari (ixtiyoriy)

Etherscan/BscScan birmuncha rate-limit qo'yadi. Shaxsiy kalit
olish uchun:

- https://etherscan.io/myapikey
- https://bscscan.com/myapikey
- https://www.trongrid.io/ (TRON uchun yuqori limit kerak bo'lsa)

Kalitlarni `lib/services/api_keys.dart` da kiriting yoki dastur
ichidan `BlockchainService(etherscanKey: '...')` orqali bering.

## AFTOR bo'limi

`lib/pages/about_page.dart` faylida quyidagi maydonlar bor —
mazmunini bersangiz, to'ldirib qo'yiladi:

- `kAuthorName` — ism familiya
- `kAuthorTitle` — lavozim / tavsif
- `kAuthorBio` — biografiya
- `kAuthorContacts` — email, Telegram, GitHub, telefon
- `kAuthorAvatarAsset` — avatar (assets papkasiga rasm qo'yib yo'l ko'rsating)
- `kAppVersion` — versiya

## Test

```bash
flutter test
```

Asosiy `chain_detector` testlari `test/widget_test.dart` da.

## Ogohlantirish

Dastur faqat ochiq blokcheyn ma'lumotlarini ko'rsatadi.
Birja yorliqlari jamoatchilik tomonidan tanilgan manzillarga
asoslangan va 100% kafolatlanmaydi. Maxfiy moliyaviy maslahat emas.
