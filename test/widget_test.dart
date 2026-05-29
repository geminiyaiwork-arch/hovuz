import 'package:flutter_test/flutter_test.dart';

import 'package:hovuz/l10n/strings.dart';
import 'package:hovuz/models/chain.dart';
import 'package:hovuz/services/chain_detector.dart';
import 'package:hovuz/services/jurisdictions.dart';
import 'package:hovuz/services/name_resolver.dart';
import 'package:hovuz/services/sanctions_list.dart';
import 'package:hovuz/services/timezone_analyzer.dart';

void main() {
  group('ChainDetector', () {
    final d = ChainDetector();

    test('TRON address', () {
      final r = d.detect('TNXoiAJ3dct8Fjg4M9fkLFh9S2v9TXc32G');
      expect(r.chain, Chain.tron);
      expect(r.kind, InputKind.address);
    });

    test('ETH address', () {
      final r = d.detect('0x28C6c06298d514Db089934071355E5743bf21d60');
      expect(r.chain, Chain.ethereum);
      expect(r.kind, InputKind.address);
    });

    test('BTC bech32 address', () {
      final r = d.detect('bc1qm34lsc65zpw79lxes69zkqmk6ee3ewf0j77s3h');
      expect(r.chain, Chain.bitcoin);
      expect(r.kind, InputKind.address);
    });

    test('ETH tx hash with 0x prefix', () {
      final r = d.detect(
          '0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef');
      expect(r.chain, Chain.ethereum);
      expect(r.kind, InputKind.txHash);
    });

    test('Empty input returns unknown', () {
      final r = d.detect('   ');
      expect(r.ok, isFalse);
    });

    test('Solana address (base58, 44 chars)', () {
      // Real USDC SPL mint
      final r = d.detect('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
      expect(r.chain, Chain.solana);
      expect(r.kind, InputKind.address);
    });

    test('Solana signature (base58, 87+ chars)', () {
      final r = d.detect(
          '5j7s4ZuZWE8s8rg4XKEbiJsLgL6kkvWcqJL5hKp9TfH3bWzVx9rTd2vQqRzKjT9gTPmkM4nDfvSqB6JcFEd2DqzM');
      expect(r.chain, Chain.solana);
      expect(r.kind, InputKind.txHash);
    });

    test('TRON still wins over Solana for T-prefixed addr', () {
      final r = d.detect('TNXoiAJ3dct8Fjg4M9fkLFh9S2v9TXc32G');
      expect(r.chain, Chain.tron);
    });

    test('BTC legacy still wins over Solana for 1/3-prefixed addr', () {
      final r = d.detect('1NDyJtNTjmwk5xPNhjgAMu4HDHigtobu1s');
      expect(r.chain, Chain.bitcoin);
    });
  });

  group('Localization completeness', () {
    final variants = <S>[UzS(), EnS(), RuS()];

    test('all getters non-empty across UZ/EN/RU', () {
      for (final s in variants) {
        expect(s.appName, isNotEmpty);
        expect(s.appTagline, isNotEmpty);
        expect(s.appDescription, isNotEmpty);
        expect(s.appLongDescription, isNotEmpty);
        expect(s.searchHint, isNotEmpty);
        expect(s.pasteTooltip, isNotEmpty);
        expect(s.checkButton, isNotEmpty);
        expect(s.aboutTooltip, isNotEmpty);
        expect(s.languageTooltip, isNotEmpty);
        expect(s.autoDetect, isNotEmpty);
        expect(s.forceNetwork, isNotEmpty);
        expect(s.autoBadge, isNotEmpty);
        expect(s.sectionGeneralBalance, isNotEmpty);
        expect(s.sectionError, isNotEmpty);
        expect(s.currentBalance, isNotEmpty);
        expect(s.totalReceived, isNotEmpty);
        expect(s.totalSent, isNotEmpty);
        expect(s.totalReceivedMoney, isNotEmpty);
        expect(s.totalSentMoney, isNotEmpty);
        expect(s.transferVolume, isNotEmpty);
        expect(s.networkWord, isNotEmpty);
        expect(s.supportedHeading, isNotEmpty);
        expect(s.txCount, isNotEmpty);
        expect(s.status, isNotEmpty);
        expect(s.block, isNotEmpty);
        expect(s.fee, isNotEmpty);
        expect(s.time, isNotEmpty);
        expect(s.transfersCount, isNotEmpty);
        expect(s.loadingBlockchain, isNotEmpty);
        expect(s.requestFailed, isNotEmpty);
        expect(s.transactionTitle, isNotEmpty);
        expect(s.txId, isNotEmpty);
        expect(s.sender, isNotEmpty);
        expect(s.receiver, isNotEmpty);
        expect(s.noValueTransferInTx, isNotEmpty);
        expect(s.walletTitle, isNotEmpty);
        expect(s.addressField, isNotEmpty);
        expect(s.labelField, isNotEmpty);
        expect(s.recentTransfers, isNotEmpty);
        expect(s.noTransfersFound, isNotEmpty);
        expect(s.transactionsField, isNotEmpty);
        expect(s.fromShort, isNotEmpty);
        expect(s.toShort, isNotEmpty);
        expect(s.explorerButton, isNotEmpty);
        expect(s.aboutPageTitle, isNotEmpty);
        expect(s.sectionAuthor, isNotEmpty);
        expect(s.sectionContact, isNotEmpty);
        expect(s.emailLabel, isNotEmpty);
        expect(s.telegramLabel, isNotEmpty);
        expect(s.githubLabel, isNotEmpty);
        expect(s.phoneLabel, isNotEmpty);
        expect(s.versionPrefix, isNotEmpty);
        expect(s.disclaimer, isNotEmpty);
        expect(s.phone1Label, isNotEmpty);
        expect(s.phone2Label, isNotEmpty);
        expect(s.contractAddress, isNotEmpty);
        expect(s.directionSent, isNotEmpty);
        expect(s.directionReceived, isNotEmpty);
        expect(s.directionSelfTransfer, isNotEmpty);
        expect(s.currentLocation, isNotEmpty);
        expect(s.backTooltip, isNotEmpty);
        expect(s.forwardTooltip, isNotEmpty);
        expect(s.watchlistTitle, isNotEmpty);
        expect(s.watchlistTooltip, isNotEmpty);
        expect(s.watchlistEmpty, isNotEmpty);
        expect(s.addToWatchlist, isNotEmpty);
        expect(s.removeFromWatchlist, isNotEmpty);
        expect(s.alertReceivedTitle, isNotEmpty);
        expect(s.alertSentTitle, isNotEmpty);
        expect(s.alertChangedTitle, isNotEmpty);
        expect(s.refreshWatchlist, isNotEmpty);
        expect(s.txCountWith(5), contains('5'));
        expect(s.filterByAddress, isNotEmpty);
        expect(s.clearFilter, isNotEmpty);
        expect(s.filteredBy, isNotEmpty);
        expect(s.loadMore, isNotEmpty);
        expect(s.noMore, isNotEmpty);
        expect(s.openInNewView, isNotEmpty);
        expect(s.jurisdictionLabel, isNotEmpty);
        expect(s.sanctionsBadge, isNotEmpty);
        expect(s.sanctionsHeader, isNotEmpty);
        expect(s.sanctionsBody, isNotEmpty);
        expect(s.sanctionsClean, isNotEmpty);
        expect(s.sanctionsSheet, isNotEmpty);
        expect(s.tzAnalysisTitle, isNotEmpty);
        expect(s.tzPattern, isNotEmpty);
        expect(s.tzConfidence, isNotEmpty);
        expect(s.tzSamples, isNotEmpty);
        expect(s.tzAlgorithmic, isNotEmpty);
        expect(s.tzInsufficient, isNotEmpty);
        expect(s.tzActiveHours, isNotEmpty);
        expect(s.exportButton, isNotEmpty);
        expect(s.exportInProgress, isNotEmpty);
        expect(s.exportSuccess('/tmp/test.xlsx'),
            contains('/tmp/test.xlsx'));
        expect(s.exportFailed, isNotEmpty);
        expect(s.priceUnavailable, isNotEmpty);
        expect(s.pricesUpdatedAgo, isNotEmpty);
        expect(s.noteTitle, isNotEmpty);
        expect(s.noteAddTooltip, isNotEmpty);
        expect(s.noteEditTooltip, isNotEmpty);
        expect(s.noteHint, isNotEmpty);
        expect(s.noteSave, isNotEmpty);
        expect(s.noteRemove, isNotEmpty);
        expect(s.noteEmpty, isNotEmpty);
        expect(s.themeLight, isNotEmpty);
        expect(s.themeDark, isNotEmpty);
        expect(s.themeSystem, isNotEmpty);
        expect(s.themeTooltip, isNotEmpty);
        for (final code in ['BTC', 'ETH', 'TRX', 'BNB', 'SOL']) {
          expect(s.chainLong(code), isNotEmpty);
        }
        for (final code in LookupErrorCode.values) {
          expect(s.translateError(code, '42'), isNotEmpty);
        }
      }
    });

    test('translations differ across locales (not stub-equal)', () {
      expect(UzS().checkButton, isNot(equals(EnS().checkButton)));
      expect(EnS().checkButton, isNot(equals(RuS().checkButton)));
      expect(UzS().sender, isNot(equals(EnS().sender)));
      expect(UzS().status, isNot(equals(RuS().status)));
      expect(UzS().sanctionsBadge, isNot(equals(EnS().sanctionsBadge)));
      expect(UzS().exportButton, isNot(equals(RuS().exportButton)));
    });
  });

  group('Jurisdictions', () {
    test('Binance → Cayman Islands', () {
      final j = Jurisdictions.lookup('Binance');
      expect(j, isNotNull);
      expect(j!.countryIso, 'KY');
      expect(j.flag, '🇰🇾');
    });

    test('Coinbase → USA', () {
      expect(Jurisdictions.lookup('Coinbase')?.countryIso, 'US');
    });

    test('HTX (Huobi) matches prefix form', () {
      final j = Jurisdictions.lookup('HTX (Huobi)');
      expect(j?.countryIso, 'SC');
    });

    test('Unknown exchange → null', () {
      expect(Jurisdictions.lookup('NotAnExchange'), isNull);
    });
  });

  group('Sanctions list', () {
    test('Known Tornado Cash ETH address is flagged', () {
      final hit = SanctionsList.lookupEvm(
          '0x8589427373d6d84e98730d7795d8f6f8731fda16');
      expect(hit, isNotNull);
      expect(hit!.entity, contains('Tornado'));
    });

    test('Hydra Market BTC address is flagged', () {
      final hit =
          SanctionsList.lookupBtc('1HKYxwVT1mAefUskpUUjnB1qfsroM4Etzr');
      expect(hit, isNotNull);
      expect(hit!.entity, contains('Hydra'));
    });

    test('Random address is NOT flagged', () {
      expect(
          SanctionsList.lookupEvm(
              '0x0000000000000000000000000000000000000000'),
          isNull);
    });

    test('Total list > 0 entries', () {
      expect(SanctionsList.totalCount, greaterThan(10));
    });
  });

  group('Timezone analyzer', () {
    test('Under 5 samples → undetermined', () {
      final r = TimezoneAnalyzer.analyzeTimes(
          [DateTime.utc(2026, 5, 29, 10, 0)]);
      expect(r.offsetHours, isNull);
      expect(r.sampleSize, 1);
    });

    test('UTC+5 wallet (active 03:00-17:00 UTC) is detected', () {
      // simulate 20 txs spread across active hours 03..17 UTC
      // representing 08..22 local time at UTC+5.
      final times = <DateTime>[
        for (var h = 3; h < 17; h++) DateTime.utc(2026, 5, 1, h),
        for (var h = 4; h < 16; h++) DateTime.utc(2026, 5, 2, h),
      ];
      final r = TimezoneAnalyzer.analyzeTimes(times);
      expect(r.sampleSize, equals(times.length));
      expect(r.offsetHours, isNotNull);
      expect((r.offsetHours! - 5).abs(), lessThanOrEqualTo(2));
    });

    test('NameResolver detects ENS pattern', () {
      expect(NameResolver.looksLikeEns('vitalik.eth'), isTrue);
      expect(NameResolver.looksLikeEns('foo.sol'), isFalse);
      expect(NameResolver.looksLikeEns('0xabc'), isFalse);
    });

    test('NameResolver detects SNS pattern', () {
      expect(NameResolver.looksLikeSns('toly.sol'), isTrue);
      expect(NameResolver.looksLikeSns('vitalik.eth'), isFalse);
    });

    test('Uniform 24h activity → algorithmic', () {
      final times = <DateTime>[
        for (var d = 0; d < 5; d++)
          for (var h = 0; h < 24; h++) DateTime.utc(2026, 5, d + 1, h),
      ];
      final r = TimezoneAnalyzer.analyzeTimes(times);
      expect(r.algorithmic, isTrue);
    });
  });
}
