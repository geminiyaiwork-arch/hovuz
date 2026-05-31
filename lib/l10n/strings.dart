import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// Locales
// ============================================================
enum AppLocale {
  uz('UZ', "O'zbekcha", '🇺🇿'),
  en('EN', 'English', '🇬🇧'),
  ru('RU', 'Русский', '🇷🇺');

  final String code;
  final String label;
  final String flag;
  const AppLocale(this.code, this.label, this.flag);
}

// ============================================================
// Error codes (so service is locale-free)
// ============================================================
enum LookupErrorCode {
  invalidFormat,
  timeout,
  unsupported,
  txNotFound,
  http,
  generic,
}

// ============================================================
// Abstract surface — every UI string is here
// ============================================================
abstract class S {
  // App
  String get appName;
  String get appTagline;
  String get appDescription;
  String get appLongDescription;

  // Header / search
  String get searchHint;
  String get pasteTooltip;
  String get checkButton;
  String get aboutTooltip;
  String get languageTooltip;
  String get autoDetect;
  String get forceNetwork;
  String get autoBadge;

  // Sidebar — general
  String get sectionGeneralBalance;
  String get sectionError;
  String get currentBalance;
  String get totalReceived;
  String get totalSent;
  String get totalReceivedMoney;
  String get totalSentMoney;
  String get transferVolume;
  String get networkWord;
  String get supportedHeading;

  // Mini block
  String get txCount;
  String get status;
  String get block;
  String get fee;
  String get time;
  String get transfersCount;

  // Loading / empty
  String get loadingBlockchain;
  String get requestFailed;

  // Transaction details
  String get transactionTitle;
  String get txId;
  String get sender;
  String get receiver;
  String get noValueTransferInTx;

  // Address details
  String get walletTitle;
  String get addressField;
  String get labelField;
  String get recentTransfers;
  String get noTransfersFound;
  String get transactionsField;

  // Transfer tile
  String get fromShort;
  String get toShort;

  // Header buttons
  String get explorerButton;

  // About page
  String get aboutPageTitle;
  String get sectionAuthor;
  String get sectionContact;
  String get emailLabel;
  String get telegramLabel;
  String get githubLabel;
  String get phoneLabel;
  String get phone1Label;
  String get phone2Label;
  String get versionPrefix;
  String get disclaimer;

  // Token contract
  String get contractAddress;

  // v2.0 — direction / navigation / watchlist / filter / pagination
  String get directionSent;
  String get directionReceived;
  String get directionSelfTransfer;
  String get currentLocation;
  String get backTooltip;
  String get forwardTooltip;
  String get watchlistTitle;
  String get watchlistTooltip;
  String get watchlistEmpty;
  String get addToWatchlist;
  String get removeFromWatchlist;
  String get alertReceivedTitle;
  String get alertSentTitle;
  String get alertChangedTitle;
  String get refreshWatchlist;
  String txCountWith(int n);
  String get filterByAddress;
  String get clearFilter;
  String get filteredBy;
  String get loadMore;
  String get noMore;
  String get openInNewView;

  // v2.1 — jurisdiction / sanctions / timezone / export
  String get jurisdictionLabel;
  String get sanctionsBadge;
  String get sanctionsHeader;
  String get sanctionsBody;
  String get sanctionsClean;
  String get sanctionsSheet;
  String get tzAnalysisTitle;
  String get tzPattern;
  String get tzConfidence;
  String get tzSamples;
  String get tzAlgorithmic;
  String get tzInsufficient;
  String get tzActiveHours;
  String get exportButton;
  String get exportInProgress;
  String exportSuccess(String path);
  String get exportFailed;

  // v2.2 — USD price
  String get priceUnavailable;
  String get pricesUpdatedAgo;

  // v2.2 — Notes
  String get noteTitle;
  String get noteAddTooltip;
  String get noteEditTooltip;
  String get noteHint;
  String get noteSave;
  String get noteRemove;
  String get noteEmpty;

  // v2.2 — Theme
  String get themeLight;
  String get themeDark;
  String get themeSystem;
  String get themeTooltip;

  // v2.3 — Multi-hop trace
  String get traceTitle;
  String get traceButton;
  String get traceInProgress;
  String get traceHopsLabel;
  String get traceTerminalExchange;
  String get traceTerminalSanctioned;
  String get traceTerminalCycle;
  String get traceTerminalDeadEnd;
  String get traceTerminalMaxHops;
  String get traceMixerWarning;

  // v2.3 — Risk score
  String get riskScoreTitle;
  String get riskLevelVeryLow;
  String get riskLevelLow;
  String get riskLevelMedium;
  String get riskLevelHigh;
  String get riskLevelCritical;
  String translateRiskFactor(String key);

  // v2.3 — Whale
  String get whaleBadge;
  String whaleAboveUsd(String usd);

  // v2.3 — PDF report
  String get pdfExportButton;

  // v3.0 — Flow diagram + portfolio
  String get flowDiagramTitle;
  String get portfolioTitle;
  String get newTabTooltip;

  // v3.1 — Donate
  String get donateTitle;
  String get donateDescription;
  String get donateNetworkUsdtTrc20;
  String get donateNetworkBtc;
  String donateMin(String formatted);
  String get donateWarningUsdt;
  String get donateWarningBtc;
  String get donateThanks;

  // Chain names
  String chainLong(String code);

  // Error translation
  String translateError(LookupErrorCode code, [String? extra]);

  // Helper
  static S of(BuildContext context) => LocaleScope.of(context).strings;
}

// ============================================================
// O'ZBEKCHA
// ============================================================
class UzS extends S {
  @override
  String get appName => 'Hovuz';
  @override
  String get appTagline => 'Crypto Transaction Inspector';
  @override
  String get appDescription =>
      'Kripto tranzaksiya va kashelek tekshiruv dasturi';
  @override
  String get appLongDescription =>
      'Tepadagi qidiruv maydoniga TxID yoki kashelek manzilini joylashtiring. Dastur tarmoqni avtomatik aniqlaydi va to\'liq oqimni — kim kimga, qancha, qaysi birjaga — ko\'rsatadi.';

  @override
  String get searchHint =>
      'TxID yoki kashelek manzilini kiriting (BTC / ETH / TRX / BNB)…';
  @override
  String get pasteTooltip => 'Yopishtirish';
  @override
  String get checkButton => 'Tekshirish';
  @override
  String get aboutTooltip => 'Dastur haqida';
  @override
  String get languageTooltip => 'Tilni tanlash';
  @override
  String get autoDetect => 'Avtomatik aniqlash';
  @override
  String get forceNetwork => 'Tarmoqni majburlash';
  @override
  String get autoBadge => 'AVTO';

  @override
  String get sectionGeneralBalance => 'UMUMIY HISOB';
  @override
  String get sectionError => 'XATOLIK';
  @override
  String get currentBalance => 'Joriy balans';
  @override
  String get totalReceived => 'Jami tushgan';
  @override
  String get totalSent => 'Jami chiqqan';
  @override
  String get totalReceivedMoney => 'Jami tushgan pul';
  @override
  String get totalSentMoney => 'Jami chiqqan pul';
  @override
  String get transferVolume => 'O\'tkazma hajmi';
  @override
  String get networkWord => 'tarmoq';
  @override
  String get supportedHeading => 'Qo\'llab-quvvatlanadi';

  @override
  String get txCount => 'Tranzaksiyalar';
  @override
  String get status => 'Holat';
  @override
  String get block => 'Blok';
  @override
  String get fee => 'Komissiya';
  @override
  String get time => 'Vaqt';
  @override
  String get transfersCount => 'O\'tkazmalar';

  @override
  String get loadingBlockchain => 'Blokcheyn so\'rovi yuborilmoqda…';
  @override
  String get requestFailed => 'So\'rov bajarilmadi';

  @override
  String get transactionTitle => 'Tranzaksiya ma\'lumotlari';
  @override
  String get txId => 'TxID';
  @override
  String get sender => 'Jo\'natuvchi';
  @override
  String get receiver => 'Qabul qiluvchi';
  @override
  String get noValueTransferInTx =>
      'Bu tranzaksiyada qiymat o\'tkazmasi topilmadi.';

  @override
  String get walletTitle => 'Kashelek ma\'lumotlari';
  @override
  String get addressField => 'Manzil';
  @override
  String get labelField => 'Yorliq';
  @override
  String get recentTransfers => 'So\'nggi o\'tkazmalar';
  @override
  String get noTransfersFound => 'Hech qanday o\'tkazma topilmadi.';
  @override
  String get transactionsField => 'Tranzaksiyalar';

  @override
  String get fromShort => 'Dan';
  @override
  String get toShort => 'Ga';

  @override
  String get explorerButton => 'Explorer';

  @override
  String get aboutPageTitle => 'Dastur haqida';
  @override
  String get sectionAuthor => 'AFTOR';
  @override
  String get sectionContact => 'ALOQA';
  @override
  String get emailLabel => 'Email';
  @override
  String get telegramLabel => 'Telegram';
  @override
  String get githubLabel => 'GitHub';
  @override
  String get phoneLabel => 'Telefon';
  @override
  String get phone1Label => 'Telefon 1';
  @override
  String get phone2Label => 'Telefon 2';
  @override
  String get versionPrefix => 'v';
  @override
  String get disclaimer =>
      'Dastur faqat ochiq blokcheyn ma\'lumotlarini ko\'rsatadi. Birja yorliqlari jamoatchilik tomonidan tanilgan manzillarga asoslangan va 100% kafolatlanmaydi.';
  @override
  String get contractAddress => 'Kontrakt manzili';

  @override
  String get directionSent => 'YUBORGAN';
  @override
  String get directionReceived => 'QABUL QILGAN';
  @override
  String get directionSelfTransfer => 'O\'ZIGA';
  @override
  String get currentLocation => 'Pul hozir';
  @override
  String get backTooltip => 'Orqaga';
  @override
  String get forwardTooltip => 'Oldinga';
  @override
  String get watchlistTitle => 'Kuzatish ro\'yxati';
  @override
  String get watchlistTooltip => 'Kuzatish ro\'yxati';
  @override
  String get watchlistEmpty =>
      'Hozircha kuzatuvga olingan manzillar yo\'q. Kashelek sahifasida ❤ tugmasini bosing.';
  @override
  String get addToWatchlist => 'Kuzatishga qo\'shish';
  @override
  String get removeFromWatchlist => 'Kuzatishdan olib tashlash';
  @override
  String get alertReceivedTitle => 'Manzilga pul tushdi';
  @override
  String get alertSentTitle => 'Manzildan pul chiqdi';
  @override
  String get alertChangedTitle => 'Balans o\'zgardi';
  @override
  String get refreshWatchlist => 'Yangilash';
  @override
  String txCountWith(int n) => '$n ta o\'tkazma';
  @override
  String get filterByAddress => 'Shu manzil bo\'yicha filtrlash';
  @override
  String get clearFilter => 'Filtrni tozalash';
  @override
  String get filteredBy => 'Filtr';
  @override
  String get loadMore => 'Yana yuklash';
  @override
  String get noMore => 'Boshqa o\'tkazma yo\'q';
  @override
  String get openInNewView => 'Manzilni ochish';

  @override
  String get jurisdictionLabel => 'Yurisdiksiya';
  @override
  String get sanctionsBadge => 'SANKSIYALANGAN';
  @override
  String get sanctionsHeader => 'OFAC sanksiya ro\'yxatida';
  @override
  String get sanctionsBody =>
      'Bu manzil AQSh xazinasi OFAC SDN ro\'yxatida ko\'rinadi. U bilan operatsiya qilish AQSh huquq tizimi bo\'yicha jinoiy javobgarlikka olib kelishi mumkin.';
  @override
  String get sanctionsClean =>
      'Sanksiyalangan manzillarga teginish topilmadi';
  @override
  String get sanctionsSheet => 'Sanksiya tekshiruvi';
  @override
  String get tzAnalysisTitle => 'Vaqt zona tahlili';
  @override
  String get tzPattern => 'Faollik namunasi';
  @override
  String get tzConfidence => 'Ishonchlilik';
  @override
  String get tzSamples => 'Tahlil qilingan tx soni';
  @override
  String get tzAlgorithmic =>
      'Algoritmik / 24-soat — birja yoki bot bo\'lishi mumkin';
  @override
  String get tzInsufficient =>
      'Yetarli ma\'lumot yo\'q (kamida 5 ta tx kerak)';
  @override
  String get tzActiveHours => 'Faol soatlar';
  @override
  String get exportButton => 'Excel\'ga eksport';
  @override
  String get exportInProgress => 'Eksport tayyorlanyapti…';
  @override
  String exportSuccess(String path) => 'Excel saqlandi: $path';
  @override
  String get exportFailed => 'Eksport amalga oshmadi';
  @override
  String get priceUnavailable => 'Narx mavjud emas';
  @override
  String get pricesUpdatedAgo => 'CoinGecko narxlari';
  @override
  String get noteTitle => 'Shaxsiy izoh';
  @override
  String get noteAddTooltip => 'Izoh qo\'shish';
  @override
  String get noteEditTooltip => 'Izohni tahrirlash';
  @override
  String get noteHint =>
      'Bu manzil haqida shaxsiy yozuvingiz (faqat sizning kompyuteringizda saqlanadi)…';
  @override
  String get noteSave => 'Saqlash';
  @override
  String get noteRemove => 'O\'chirish';
  @override
  String get noteEmpty => 'Izoh kiritilmagan';
  @override
  String get themeLight => 'Yorug\'';
  @override
  String get themeDark => 'Qorong\'i';
  @override
  String get themeSystem => 'Tizim';
  @override
  String get themeTooltip => 'Temani almashtirish';
  @override
  String get traceTitle => 'Pul izi (multi-hop)';
  @override
  String get traceButton => 'Pulni kuzatish';
  @override
  String get traceInProgress => 'Pul izi qidirilyapti…';
  @override
  String get traceHopsLabel => 'qadam';
  @override
  String get traceTerminalExchange => 'Birjaga keldi';
  @override
  String get traceTerminalSanctioned => 'Sanksiyalangan manzilga keldi!';
  @override
  String get traceTerminalCycle => 'Aylanma yo\'l (siklik)';
  @override
  String get traceTerminalDeadEnd => 'Boshqa o\'tkazma topilmadi';
  @override
  String get traceTerminalMaxHops => 'Maksimal qadam soni';
  @override
  String get traceMixerWarning => 'Mixer namunasi aniqlandi';
  @override
  String get riskScoreTitle => 'Xavf darajasi';
  @override
  String get riskLevelVeryLow => 'JUDA PAST';
  @override
  String get riskLevelLow => 'PAST';
  @override
  String get riskLevelMedium => 'O\'RTA';
  @override
  String get riskLevelHigh => 'YUQORI';
  @override
  String get riskLevelCritical => 'JIDDIY';
  @override
  String translateRiskFactor(String key) {
    switch (key) {
      case 'riskSelfSanctioned':
        return 'Manzilning o\'zi OFAC sanksiyasida';
      case 'riskCounterpartySanctioned':
        return 'Sanksiyalangan manzil bilan o\'tkazma';
      case 'riskKnownExchange':
        return 'Ma\'lum birja (xavfsizroq)';
      case 'riskAlgorithmic':
        return 'Algoritmik faollik (bot/birja, xavfsizroq)';
      case 'riskLowActivity':
        return 'Juda kam tranzaksiya';
      case 'riskOneWayFlow':
        return 'Bir tomonlama oqim (faqat tushgan)';
      case 'riskMixerPattern':
        return 'Mixer namunasi (bir xil miqdordagi tx\'lar)';
      default:
        return key;
    }
  }
  @override
  String get whaleBadge => 'KIT';
  @override
  String whaleAboveUsd(String usd) => 'Yirik o\'tkazma · $usd+';
  @override
  String get pdfExportButton => 'PDF hisobot';
  @override
  String get flowDiagramTitle => 'Pul oqimi diagrammasi';
  @override
  String get portfolioTitle => 'Token portfolio';
  @override
  String get newTabTooltip => 'Yangi tab';
  @override
  String get donateTitle => 'DONAT — DASTURNI QO\'LLAB-QUVVATLASH';
  @override
  String get donateDescription =>
      'Hovuz bepul va ochiq dastur. Agar foydali deb topgan bo\'lsangiz, kichik donat orqali keyingi yangiliklarga yordam bering. Rahmat!';
  @override
  String get donateNetworkUsdtTrc20 => 'TRON · TRC20';
  @override
  String get donateNetworkBtc => 'Bitcoin tarmog\'i';
  @override
  String donateMin(String formatted) => 'Eng kam summa: $formatted';
  @override
  String get donateWarningUsdt =>
      'Diqqat! Faqat USDT (TRC20) jo\'nating. Boshqa tarmoq (ERC20/BEP20) yo\'qoladi.';
  @override
  String get donateWarningBtc =>
      'Diqqat! Faqat Bitcoin (BTC) jo\'nating. BCH/LTC/wrapped BTC yo\'qoladi.';
  @override
  String get donateThanks =>
      'Har bir donat — Hovuz\'ning rivojiga sarmoya. Ko\'p rahmat!';

  @override
  String chainLong(String code) {
    switch (code) {
      case 'BTC':
        return 'Bitcoin';
      case 'ETH':
        return 'Ethereum (ERC20)';
      case 'TRX':
        return 'TRON (TRC20)';
      case 'BNB':
        return 'BNB Chain (BEP20)';
      case 'SOL':
        return 'Solana (SPL)';
      case 'POL':
        return 'Polygon';
      case 'ARB':
        return 'Arbitrum One';
      case 'OP':
        return 'Optimism';
      case 'BASE':
        return 'Base';
      default:
        return code;
    }
  }

  @override
  String translateError(LookupErrorCode code, [String? extra]) {
    switch (code) {
      case LookupErrorCode.invalidFormat:
        return 'Kiritilgan qiymat formati tanilmadi. TxID yoki manzil kiriting.';
      case LookupErrorCode.timeout:
        return 'Tarmoq vaqti tugadi.';
      case LookupErrorCode.unsupported:
        return 'Qo\'llab-quvvatlanmaydigan turi.';
      case LookupErrorCode.txNotFound:
        return 'Tranzaksiya topilmadi (API kaliti yo\'q yoki limit tugagan bo\'lishi mumkin).';
      case LookupErrorCode.http:
        return 'HTTP xato: ${extra ?? ''}';
      case LookupErrorCode.generic:
        return 'Xato: ${extra ?? ''}';
    }
  }
}

// ============================================================
// ENGLISH
// ============================================================
class EnS extends S {
  @override
  String get appName => 'Hovuz';
  @override
  String get appTagline => 'Crypto Transaction Inspector';
  @override
  String get appDescription =>
      'Crypto transaction and wallet inspector';
  @override
  String get appLongDescription =>
      'Paste a TxID or wallet address into the search bar above. Hovuz auto-detects the network and shows full flow — who sent how much to whom, and which exchange received it.';

  @override
  String get searchHint =>
      'Enter TxID or wallet address (BTC / ETH / TRX / BNB)…';
  @override
  String get pasteTooltip => 'Paste';
  @override
  String get checkButton => 'Inspect';
  @override
  String get aboutTooltip => 'About';
  @override
  String get languageTooltip => 'Language';
  @override
  String get autoDetect => 'Auto-detect';
  @override
  String get forceNetwork => 'Force network';
  @override
  String get autoBadge => 'AUTO';

  @override
  String get sectionGeneralBalance => 'SUMMARY';
  @override
  String get sectionError => 'ERROR';
  @override
  String get currentBalance => 'Current balance';
  @override
  String get totalReceived => 'Total received';
  @override
  String get totalSent => 'Total sent';
  @override
  String get totalReceivedMoney => 'Total received';
  @override
  String get totalSentMoney => 'Total sent';
  @override
  String get transferVolume => 'Transfer volume';
  @override
  String get networkWord => 'network';
  @override
  String get supportedHeading => 'Supported';

  @override
  String get txCount => 'Transactions';
  @override
  String get status => 'Status';
  @override
  String get block => 'Block';
  @override
  String get fee => 'Fee';
  @override
  String get time => 'Time';
  @override
  String get transfersCount => 'Transfers';

  @override
  String get loadingBlockchain => 'Querying the blockchain…';
  @override
  String get requestFailed => 'Request failed';

  @override
  String get transactionTitle => 'Transaction details';
  @override
  String get txId => 'TxID';
  @override
  String get sender => 'Sender';
  @override
  String get receiver => 'Receiver';
  @override
  String get noValueTransferInTx =>
      'No value transfers were found in this transaction.';

  @override
  String get walletTitle => 'Wallet details';
  @override
  String get addressField => 'Address';
  @override
  String get labelField => 'Label';
  @override
  String get recentTransfers => 'Recent transfers';
  @override
  String get noTransfersFound => 'No transfers found.';
  @override
  String get transactionsField => 'Transactions';

  @override
  String get fromShort => 'From';
  @override
  String get toShort => 'To';

  @override
  String get explorerButton => 'Explorer';

  @override
  String get aboutPageTitle => 'About';
  @override
  String get sectionAuthor => 'AUTHOR';
  @override
  String get sectionContact => 'CONTACT';
  @override
  String get emailLabel => 'Email';
  @override
  String get telegramLabel => 'Telegram';
  @override
  String get githubLabel => 'GitHub';
  @override
  String get phoneLabel => 'Phone';
  @override
  String get phone1Label => 'Phone 1';
  @override
  String get phone2Label => 'Phone 2';
  @override
  String get versionPrefix => 'v';
  @override
  String get disclaimer =>
      'Hovuz only displays public blockchain data. Exchange labels are based on community-known addresses and are not guaranteed to be 100% accurate.';
  @override
  String get contractAddress => 'Contract address';

  @override
  String get directionSent => 'SENT';
  @override
  String get directionReceived => 'RECEIVED';
  @override
  String get directionSelfTransfer => 'SELF';
  @override
  String get currentLocation => 'Currently at';
  @override
  String get backTooltip => 'Back';
  @override
  String get forwardTooltip => 'Forward';
  @override
  String get watchlistTitle => 'Watchlist';
  @override
  String get watchlistTooltip => 'Watchlist';
  @override
  String get watchlistEmpty =>
      'No watched addresses yet. Open a wallet and tap the ❤ button.';
  @override
  String get addToWatchlist => 'Add to watchlist';
  @override
  String get removeFromWatchlist => 'Remove from watchlist';
  @override
  String get alertReceivedTitle => 'Address received funds';
  @override
  String get alertSentTitle => 'Address sent funds';
  @override
  String get alertChangedTitle => 'Balance changed';
  @override
  String get refreshWatchlist => 'Refresh';
  @override
  String txCountWith(int n) => '$n transfers';
  @override
  String get filterByAddress => 'Filter by this address';
  @override
  String get clearFilter => 'Clear filter';
  @override
  String get filteredBy => 'Filtered by';
  @override
  String get loadMore => 'Load more';
  @override
  String get noMore => 'No more transfers';
  @override
  String get openInNewView => 'Open address';

  @override
  String get jurisdictionLabel => 'Jurisdiction';
  @override
  String get sanctionsBadge => 'SANCTIONED';
  @override
  String get sanctionsHeader => 'On the OFAC SDN list';
  @override
  String get sanctionsBody =>
      'This address appears on the US Treasury OFAC SDN list. Transacting with it may incur criminal liability under US law.';
  @override
  String get sanctionsClean =>
      'No sanctioned addresses found';
  @override
  String get sanctionsSheet => 'Sanctions check';
  @override
  String get tzAnalysisTitle => 'Timezone analysis';
  @override
  String get tzPattern => 'Activity pattern';
  @override
  String get tzConfidence => 'Confidence';
  @override
  String get tzSamples => 'Transactions analyzed';
  @override
  String get tzAlgorithmic =>
      'Algorithmic / 24-hour — likely an exchange or bot';
  @override
  String get tzInsufficient =>
      'Not enough data (need at least 5 transactions)';
  @override
  String get tzActiveHours => 'Active hours';
  @override
  String get exportButton => 'Export to Excel';
  @override
  String get exportInProgress => 'Preparing export…';
  @override
  String exportSuccess(String path) => 'Excel saved: $path';
  @override
  String get exportFailed => 'Export failed';
  @override
  String get priceUnavailable => 'Price unavailable';
  @override
  String get pricesUpdatedAgo => 'CoinGecko prices';
  @override
  String get noteTitle => 'Private note';
  @override
  String get noteAddTooltip => 'Add note';
  @override
  String get noteEditTooltip => 'Edit note';
  @override
  String get noteHint =>
      'Your private note about this address (stored locally on your computer)…';
  @override
  String get noteSave => 'Save';
  @override
  String get noteRemove => 'Remove';
  @override
  String get noteEmpty => 'No note';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get themeSystem => 'System';
  @override
  String get themeTooltip => 'Toggle theme';
  @override
  String get traceTitle => 'Fund trace (multi-hop)';
  @override
  String get traceButton => 'Trace the money';
  @override
  String get traceInProgress => 'Tracing fund flow…';
  @override
  String get traceHopsLabel => 'hop';
  @override
  String get traceTerminalExchange => 'Reached an exchange';
  @override
  String get traceTerminalSanctioned => 'Reached a sanctioned address!';
  @override
  String get traceTerminalCycle => 'Cyclic path';
  @override
  String get traceTerminalDeadEnd => 'No further outflow found';
  @override
  String get traceTerminalMaxHops => 'Max hops reached';
  @override
  String get traceMixerWarning => 'Mixer-like pattern detected';
  @override
  String get riskScoreTitle => 'Risk score';
  @override
  String get riskLevelVeryLow => 'VERY LOW';
  @override
  String get riskLevelLow => 'LOW';
  @override
  String get riskLevelMedium => 'MEDIUM';
  @override
  String get riskLevelHigh => 'HIGH';
  @override
  String get riskLevelCritical => 'CRITICAL';
  @override
  String translateRiskFactor(String key) {
    switch (key) {
      case 'riskSelfSanctioned':
        return 'This address is on the OFAC sanctions list';
      case 'riskCounterpartySanctioned':
        return 'Transacted with a sanctioned counterparty';
      case 'riskKnownExchange':
        return 'Known exchange (safer)';
      case 'riskAlgorithmic':
        return 'Algorithmic activity (bot/exchange, safer)';
      case 'riskLowActivity':
        return 'Very few transactions';
      case 'riskOneWayFlow':
        return 'One-way flow (incoming only)';
      case 'riskMixerPattern':
        return 'Mixer-like pattern (uniform tx sizes)';
      default:
        return key;
    }
  }
  @override
  String get whaleBadge => 'WHALE';
  @override
  String whaleAboveUsd(String usd) => 'Whale tx · $usd+';
  @override
  String get pdfExportButton => 'PDF report';
  @override
  String get flowDiagramTitle => 'Fund flow diagram';
  @override
  String get portfolioTitle => 'Token portfolio';
  @override
  String get newTabTooltip => 'New tab';
  @override
  String get donateTitle => 'DONATE — SUPPORT THE PROJECT';
  @override
  String get donateDescription =>
      'Hovuz is free and open source. If you find it useful, please consider a small donation to keep development going. Thank you!';
  @override
  String get donateNetworkUsdtTrc20 => 'TRON · TRC20';
  @override
  String get donateNetworkBtc => 'Bitcoin network';
  @override
  String donateMin(String formatted) => 'Minimum: $formatted';
  @override
  String get donateWarningUsdt =>
      'Warning! Send only USDT (TRC20). Funds sent via ERC20/BEP20 will be lost.';
  @override
  String get donateWarningBtc =>
      'Warning! Send only Bitcoin (BTC). BCH/LTC/wrapped BTC will be lost.';
  @override
  String get donateThanks =>
      'Every donation fuels Hovuz development. Thank you so much!';

  @override
  String chainLong(String code) {
    switch (code) {
      case 'BTC':
        return 'Bitcoin';
      case 'ETH':
        return 'Ethereum (ERC20)';
      case 'TRX':
        return 'TRON (TRC20)';
      case 'BNB':
        return 'BNB Chain (BEP20)';
      case 'SOL':
        return 'Solana (SPL)';
      case 'POL':
        return 'Polygon';
      case 'ARB':
        return 'Arbitrum One';
      case 'OP':
        return 'Optimism';
      case 'BASE':
        return 'Base';
      default:
        return code;
    }
  }

  @override
  String translateError(LookupErrorCode code, [String? extra]) {
    switch (code) {
      case LookupErrorCode.invalidFormat:
        return 'Could not recognize the input format. Enter a TxID or address.';
      case LookupErrorCode.timeout:
        return 'Network timed out.';
      case LookupErrorCode.unsupported:
        return 'Unsupported type.';
      case LookupErrorCode.txNotFound:
        return 'Transaction not found (API key missing or rate-limited).';
      case LookupErrorCode.http:
        return 'HTTP error: ${extra ?? ''}';
      case LookupErrorCode.generic:
        return 'Error: ${extra ?? ''}';
    }
  }
}

// ============================================================
// РУССКИЙ
// ============================================================
class RuS extends S {
  @override
  String get appName => 'Hovuz';
  @override
  String get appTagline => 'Инспектор крипто-транзакций';
  @override
  String get appDescription =>
      'Просмотр крипто-транзакций и кошельков';
  @override
  String get appLongDescription =>
      'Вставьте TxID или адрес кошелька в поле поиска выше. Hovuz автоматически определит сеть и покажет полный поток средств — кто, кому, сколько и на какую биржу.';

  @override
  String get searchHint =>
      'Введите TxID или адрес кошелька (BTC / ETH / TRX / BNB)…';
  @override
  String get pasteTooltip => 'Вставить';
  @override
  String get checkButton => 'Проверить';
  @override
  String get aboutTooltip => 'О программе';
  @override
  String get languageTooltip => 'Язык';
  @override
  String get autoDetect => 'Автоопределение';
  @override
  String get forceNetwork => 'Выбрать сеть';
  @override
  String get autoBadge => 'АВТО';

  @override
  String get sectionGeneralBalance => 'СВОДКА';
  @override
  String get sectionError => 'ОШИБКА';
  @override
  String get currentBalance => 'Текущий баланс';
  @override
  String get totalReceived => 'Всего получено';
  @override
  String get totalSent => 'Всего отправлено';
  @override
  String get totalReceivedMoney => 'Всего получено';
  @override
  String get totalSentMoney => 'Всего отправлено';
  @override
  String get transferVolume => 'Объём перевода';
  @override
  String get networkWord => 'сеть';
  @override
  String get supportedHeading => 'Поддерживается';

  @override
  String get txCount => 'Транзакции';
  @override
  String get status => 'Статус';
  @override
  String get block => 'Блок';
  @override
  String get fee => 'Комиссия';
  @override
  String get time => 'Время';
  @override
  String get transfersCount => 'Переводы';

  @override
  String get loadingBlockchain => 'Запрос к блокчейну…';
  @override
  String get requestFailed => 'Запрос не выполнен';

  @override
  String get transactionTitle => 'Детали транзакции';
  @override
  String get txId => 'TxID';
  @override
  String get sender => 'Отправитель';
  @override
  String get receiver => 'Получатель';
  @override
  String get noValueTransferInTx =>
      'В этой транзакции не найдено переводов средств.';

  @override
  String get walletTitle => 'Детали кошелька';
  @override
  String get addressField => 'Адрес';
  @override
  String get labelField => 'Метка';
  @override
  String get recentTransfers => 'Последние переводы';
  @override
  String get noTransfersFound => 'Переводы не найдены.';
  @override
  String get transactionsField => 'Транзакции';

  @override
  String get fromShort => 'От';
  @override
  String get toShort => 'К';

  @override
  String get explorerButton => 'Обозреватель';

  @override
  String get aboutPageTitle => 'О программе';
  @override
  String get sectionAuthor => 'АВТОР';
  @override
  String get sectionContact => 'КОНТАКТЫ';
  @override
  String get emailLabel => 'Email';
  @override
  String get telegramLabel => 'Telegram';
  @override
  String get githubLabel => 'GitHub';
  @override
  String get phoneLabel => 'Телефон';
  @override
  String get phone1Label => 'Телефон 1';
  @override
  String get phone2Label => 'Телефон 2';
  @override
  String get versionPrefix => 'v';
  @override
  String get disclaimer =>
      'Hovuz отображает только открытые данные блокчейна. Метки бирж основаны на общедоступных адресах и не гарантируют 100% точности.';
  @override
  String get contractAddress => 'Адрес контракта';

  @override
  String get directionSent => 'ОТПРАВЛЕНО';
  @override
  String get directionReceived => 'ПОЛУЧЕНО';
  @override
  String get directionSelfTransfer => 'СЕБЕ';
  @override
  String get currentLocation => 'Сейчас на';
  @override
  String get backTooltip => 'Назад';
  @override
  String get forwardTooltip => 'Вперёд';
  @override
  String get watchlistTitle => 'Список наблюдения';
  @override
  String get watchlistTooltip => 'Наблюдение';
  @override
  String get watchlistEmpty =>
      'Нет отслеживаемых адресов. Откройте кошелёк и нажмите ❤.';
  @override
  String get addToWatchlist => 'Добавить в наблюдение';
  @override
  String get removeFromWatchlist => 'Убрать из наблюдения';
  @override
  String get alertReceivedTitle => 'На адрес поступили средства';
  @override
  String get alertSentTitle => 'С адреса отправлены средства';
  @override
  String get alertChangedTitle => 'Баланс изменился';
  @override
  String get refreshWatchlist => 'Обновить';
  @override
  String txCountWith(int n) => '$n переводов';
  @override
  String get filterByAddress => 'Фильтр по адресу';
  @override
  String get clearFilter => 'Сбросить фильтр';
  @override
  String get filteredBy => 'Фильтр';
  @override
  String get loadMore => 'Показать ещё';
  @override
  String get noMore => 'Больше нет переводов';
  @override
  String get openInNewView => 'Открыть адрес';

  @override
  String get jurisdictionLabel => 'Юрисдикция';
  @override
  String get sanctionsBadge => 'ПОД САНКЦИЯМИ';
  @override
  String get sanctionsHeader => 'В списке OFAC SDN';
  @override
  String get sanctionsBody =>
      'Адрес значится в санкционном списке Минфина США (OFAC SDN). Операции с ним могут повлечь уголовную ответственность по законам США.';
  @override
  String get sanctionsClean =>
      'Связи с санкционными адресами не обнаружены';
  @override
  String get sanctionsSheet => 'Проверка санкций';
  @override
  String get tzAnalysisTitle => 'Анализ часового пояса';
  @override
  String get tzPattern => 'Паттерн активности';
  @override
  String get tzConfidence => 'Достоверность';
  @override
  String get tzSamples => 'Проанализировано транзакций';
  @override
  String get tzAlgorithmic =>
      'Круглосуточный / алгоритмический — вероятно биржа или бот';
  @override
  String get tzInsufficient =>
      'Недостаточно данных (нужно минимум 5 транзакций)';
  @override
  String get tzActiveHours => 'Активные часы';
  @override
  String get exportButton => 'Экспорт в Excel';
  @override
  String get exportInProgress => 'Подготовка экспорта…';
  @override
  String exportSuccess(String path) => 'Excel сохранён: $path';
  @override
  String get exportFailed => 'Экспорт не выполнен';
  @override
  String get priceUnavailable => 'Цена недоступна';
  @override
  String get pricesUpdatedAgo => 'Цены CoinGecko';
  @override
  String get noteTitle => 'Личная заметка';
  @override
  String get noteAddTooltip => 'Добавить заметку';
  @override
  String get noteEditTooltip => 'Редактировать заметку';
  @override
  String get noteHint =>
      'Ваша личная заметка об этом адресе (хранится только на вашем компьютере)…';
  @override
  String get noteSave => 'Сохранить';
  @override
  String get noteRemove => 'Удалить';
  @override
  String get noteEmpty => 'Заметка пуста';
  @override
  String get themeLight => 'Светлая';
  @override
  String get themeDark => 'Тёмная';
  @override
  String get themeSystem => 'Системная';
  @override
  String get themeTooltip => 'Переключить тему';
  @override
  String get traceTitle => 'Трассировка средств (multi-hop)';
  @override
  String get traceButton => 'Проследить деньги';
  @override
  String get traceInProgress => 'Трассировка потока…';
  @override
  String get traceHopsLabel => 'шаг';
  @override
  String get traceTerminalExchange => 'Достигли биржи';
  @override
  String get traceTerminalSanctioned => 'Санкционный адрес!';
  @override
  String get traceTerminalCycle => 'Циклический путь';
  @override
  String get traceTerminalDeadEnd => 'Дальнейших переводов нет';
  @override
  String get traceTerminalMaxHops => 'Достигнут максимум шагов';
  @override
  String get traceMixerWarning => 'Обнаружен паттерн миксера';
  @override
  String get riskScoreTitle => 'Уровень риска';
  @override
  String get riskLevelVeryLow => 'ОЧЕНЬ НИЗКИЙ';
  @override
  String get riskLevelLow => 'НИЗКИЙ';
  @override
  String get riskLevelMedium => 'СРЕДНИЙ';
  @override
  String get riskLevelHigh => 'ВЫСОКИЙ';
  @override
  String get riskLevelCritical => 'КРИТИЧЕСКИЙ';
  @override
  String translateRiskFactor(String key) {
    switch (key) {
      case 'riskSelfSanctioned':
        return 'Сам адрес под санкциями OFAC';
      case 'riskCounterpartySanctioned':
        return 'Транзакции с санкционным адресом';
      case 'riskKnownExchange':
        return 'Известная биржа (безопаснее)';
      case 'riskAlgorithmic':
        return 'Алгоритмическая активность (бот/биржа)';
      case 'riskLowActivity':
        return 'Очень мало транзакций';
      case 'riskOneWayFlow':
        return 'Односторонний поток (только входящий)';
      case 'riskMixerPattern':
        return 'Паттерн миксера (одинаковые суммы)';
      default:
        return key;
    }
  }
  @override
  String get whaleBadge => 'КИТ';
  @override
  String whaleAboveUsd(String usd) => 'Крупный перевод · $usd+';
  @override
  String get pdfExportButton => 'PDF отчёт';
  @override
  String get flowDiagramTitle => 'Диаграмма потока средств';
  @override
  String get portfolioTitle => 'Портфель токенов';
  @override
  String get newTabTooltip => 'Новая вкладка';
  @override
  String get donateTitle => 'ДОНАТ — ПОДДЕРЖАТЬ ПРОЕКТ';
  @override
  String get donateDescription =>
      'Hovuz — бесплатная и открытая программа. Если она вам полезна, поддержите развитие небольшим донатом. Спасибо!';
  @override
  String get donateNetworkUsdtTrc20 => 'TRON · TRC20';
  @override
  String get donateNetworkBtc => 'Сеть Bitcoin';
  @override
  String donateMin(String formatted) => 'Минимум: $formatted';
  @override
  String get donateWarningUsdt =>
      'Внимание! Отправляйте только USDT (TRC20). Средства через ERC20/BEP20 будут потеряны.';
  @override
  String get donateWarningBtc =>
      'Внимание! Отправляйте только Bitcoin (BTC). BCH/LTC/wrapped BTC будут потеряны.';
  @override
  String get donateThanks =>
      'Каждый донат — вклад в развитие Hovuz. Большое спасибо!';

  @override
  String chainLong(String code) {
    switch (code) {
      case 'BTC':
        return 'Bitcoin';
      case 'ETH':
        return 'Ethereum (ERC20)';
      case 'TRX':
        return 'TRON (TRC20)';
      case 'BNB':
        return 'BNB Chain (BEP20)';
      case 'SOL':
        return 'Solana (SPL)';
      case 'POL':
        return 'Polygon';
      case 'ARB':
        return 'Arbitrum One';
      case 'OP':
        return 'Optimism';
      case 'BASE':
        return 'Base';
      default:
        return code;
    }
  }

  @override
  String translateError(LookupErrorCode code, [String? extra]) {
    switch (code) {
      case LookupErrorCode.invalidFormat:
        return 'Формат не распознан. Введите TxID или адрес.';
      case LookupErrorCode.timeout:
        return 'Превышено время ожидания сети.';
      case LookupErrorCode.unsupported:
        return 'Неподдерживаемый тип.';
      case LookupErrorCode.txNotFound:
        return 'Транзакция не найдена (нет API-ключа или превышен лимит).';
      case LookupErrorCode.http:
        return 'HTTP-ошибка: ${extra ?? ''}';
      case LookupErrorCode.generic:
        return 'Ошибка: ${extra ?? ''}';
    }
  }
}

// ============================================================
// State controller + InheritedNotifier
// ============================================================
class LocaleController extends ChangeNotifier {
  LocaleController(this._locale);

  AppLocale _locale;
  AppLocale get locale => _locale;

  S get strings {
    switch (_locale) {
      case AppLocale.uz:
        return UzS();
      case AppLocale.en:
        return EnS();
      case AppLocale.ru:
        return RuS();
    }
  }

  Future<void> setLocale(AppLocale loc) async {
    if (_locale == loc) return;
    _locale = loc;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, loc.name);
    } catch (_) {
      // best-effort persistence
    }
  }

  static const _prefsKey = 'hovuz.locale';

  static Future<LocaleController> load() async {
    AppLocale initial = AppLocale.uz;
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(_prefsKey);
      if (v != null) {
        initial = AppLocale.values.firstWhere(
          (e) => e.name == v,
          orElse: () => AppLocale.uz,
        );
      }
    } catch (_) {}
    return LocaleController(initial);
  }
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null,
        'LocaleScope.of() called outside a LocaleScope ancestor.');
    return scope!.notifier!;
  }
}

extension LocaleContextX on BuildContext {
  /// Shorthand: `context.s.checkButton`.
  S get s => LocaleScope.of(this).strings;
}
