import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';

import '../models/chain.dart';
import '../models/transfer.dart';
import '../l10n/strings.dart';
import 'sanctions_list.dart';
import 'timezone_analyzer.dart';

class ExportResult {
  final String path;
  final int rowCount;
  const ExportResult({required this.path, required this.rowCount});
}

class ExportService {
  /// Build a workbook for an address lookup and save via OS file dialog.
  /// Returns null if the user cancels.
  static Future<ExportResult?> exportAddress(
    AddressSummary a, {
    required S s,
    TimezoneEstimate? tz,
  }) async {
    final book = Excel.createExcel();
    book.delete('Sheet1');

    _writeAddressSummary(book, a, s, tz: tz);
    _writeTransfers(book, a.recentTransfers, s,
        chain: a.chain, owner: a.address);
    _writeSanctionsSheet(book, _scanSanctions(a.recentTransfers), s);

    final bytes = book.save();
    if (bytes == null) return null;

    final filename = _safeFilename('hovuz_${a.chain.code}_${a.address}');
    return _save(bytes, '$filename.xlsx');
  }

  /// Build a workbook for a transaction lookup and save via OS file dialog.
  static Future<ExportResult?> exportTransaction(
    TransactionInfo t, {
    required S s,
  }) async {
    final book = Excel.createExcel();
    book.delete('Sheet1');

    _writeTxSummary(book, t, s);
    _writeTransfers(book, t.transfers, s,
        chain: t.chain, owner: t.rawSender);
    _writeSanctionsSheet(book, _scanSanctions(t.transfers), s);

    final bytes = book.save();
    if (bytes == null) return null;

    final filename = _safeFilename('hovuz_${t.chain.code}_tx_${t.hash}');
    return _save(bytes, '$filename.xlsx');
  }

  // ============================================================
  // Sheet writers
  // ============================================================

  static void _writeAddressSummary(
    Excel book,
    AddressSummary a,
    S s, {
    TimezoneEstimate? tz,
  }) {
    final sym = a.chain.nativeSymbol;
    final sh = book['Summary'];
    _h(sh, 'A1', 'Hovuz Export', 16);
    _row(sh, 2, [s.walletTitle, a.chain.label]);
    _row(sh, 3, [s.addressField, a.address]);
    if (a.label != null) _row(sh, 4, [s.labelField, a.label!]);
    _row(sh, 5, [s.currentBalance, '${a.balanceNative} $sym']);
    _row(sh, 6, [s.totalReceived, '${a.totalReceivedNative} $sym']);
    _row(sh, 7, [s.totalSent, '${a.totalSentNative} $sym']);
    _row(sh, 8, [s.transactionsField, '${a.txCount}']);

    if (tz != null) {
      _row(sh, 10, ['—', '—']);
      _h(sh, 'A11', s.tzAnalysisTitle, 13);
      _row(sh, 12, [s.tzSamples, '${tz.sampleSize}']);
      if (tz.algorithmic) {
        _row(sh, 13, [s.tzPattern, s.tzAlgorithmic]);
      } else if (tz.offsetHours != null) {
        final off = tz.offsetHours!;
        _row(sh, 13, [
          s.tzPattern,
          'UTC${off >= 0 ? '+' : ''}$off · ${tz.regionHint ?? ''}'
        ]);
        _row(sh, 14, [
          s.tzConfidence,
          '${(tz.confidence * 100).toStringAsFixed(0)}%'
        ]);
      } else {
        _row(sh, 13, [s.tzPattern, s.tzInsufficient]);
      }
    }
  }

  static void _writeTxSummary(
      Excel book, TransactionInfo t, S s) {
    final sh = book['Summary'];
    _h(sh, 'A1', 'Hovuz Export', 16);
    _row(sh, 2, [s.transactionTitle, t.chain.label]);
    _row(sh, 3, [s.txId, t.hash]);
    _row(sh, 4, [s.status, t.status ?? '—']);
    _row(sh, 5, [s.block, '${t.blockHeight ?? '—'}']);
    _row(sh, 6, [s.time, _fmtTime(t.time)]);
    if (t.feeNative != null) {
      _row(sh, 7, [s.fee, '${t.feeNative} ${t.chain.nativeSymbol}']);
    }
    if (t.rawSender != null) _row(sh, 8, [s.sender, t.rawSender!]);
    if (t.rawReceiver != null) _row(sh, 9, [s.receiver, t.rawReceiver!]);
  }

  static void _writeTransfers(
    Excel book,
    List<Transfer> transfers,
    S s, {
    required Chain chain,
    String? owner,
  }) {
    final sh = book[s.transfersCount];
    final headers = [
      '#',
      s.time,
      s.transferVolume,
      'Symbol',
      'Direction',
      'From',
      'From label',
      'To',
      'To label',
      s.contractAddress,
      s.txId,
    ];
    _headerRow(sh, headers);

    for (var i = 0; i < transfers.length; i++) {
      final t = transfers[i];
      final dir = owner == null
          ? '—'
          : _dirLabel(t.directionFor(owner), s);
      _row(sh, i + 2, [
        '${i + 1}',
        _fmtTime(t.time),
        '${t.amount}',
        t.symbol,
        dir,
        t.from,
        t.fromLabel ?? '',
        t.to,
        t.toLabel ?? '',
        t.contractAddress ?? '',
        t.txHash ?? '',
      ]);
    }
  }

  static void _writeSanctionsSheet(
    Excel book,
    List<_SanctionHit> hits,
    S s,
  ) {
    final sh = book[s.sanctionsSheet];
    _headerRow(sh,
        ['#', 'Address', 'Entity', 'Reason', 'Date', 'Direction']);
    if (hits.isEmpty) {
      _row(sh, 2, ['—', s.sanctionsClean, '', '', '', '']);
      return;
    }
    for (var i = 0; i < hits.length; i++) {
      final h = hits[i];
      _row(sh, i + 2, [
        '${i + 1}',
        h.address,
        h.entry.entity,
        h.entry.reason,
        h.entry.date,
        h.direction,
      ]);
    }
  }

  // ============================================================
  // Cell helpers
  // ============================================================

  static void _h(Sheet sh, String cell, String text, double size) {
    final c = sh.cell(CellIndex.indexByString(cell));
    c.value = TextCellValue(text);
    c.cellStyle = CellStyle(
      bold: true,
      fontSize: size.toInt(),
      fontColorHex: ExcelColor.fromHexString('FF154AAB'),
    );
  }

  static void _row(Sheet sh, int rowOneBased, List<String> values) {
    for (var i = 0; i < values.length; i++) {
      final c = sh.cell(CellIndex.indexByColumnRow(
          columnIndex: i, rowIndex: rowOneBased - 1));
      c.value = TextCellValue(values[i]);
    }
  }

  static void _headerRow(Sheet sh, List<String> headers) {
    for (var i = 0; i < headers.length; i++) {
      final c = sh.cell(CellIndex.indexByColumnRow(
          columnIndex: i, rowIndex: 0));
      c.value = TextCellValue(headers[i]);
      c.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('FFEEF4FD'),
        fontColorHex: ExcelColor.fromHexString('FF154AAB'),
      );
    }
  }

  static String _fmtTime(DateTime? t) {
    if (t == null) return '—';
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(t.toLocal());
  }

  static String _dirLabel(TransferDirection d, S s) {
    switch (d) {
      case TransferDirection.sent:
        return s.directionSent;
      case TransferDirection.received:
        return s.directionReceived;
      case TransferDirection.selfTransfer:
        return s.directionSelfTransfer;
      case TransferDirection.unrelated:
        return '—';
    }
  }

  // ============================================================
  // Sanctions scan
  // ============================================================

  static List<_SanctionHit> _scanSanctions(List<Transfer> transfers) {
    final out = <_SanctionHit>[];
    for (final t in transfers) {
      _checkAddr(t.from, 'FROM', out, transfers);
      _checkAddr(t.to, 'TO', out, transfers);
    }
    return out;
  }

  static void _checkAddr(String addr, String dir, List<_SanctionHit> out,
      List<Transfer> _) {
    if (addr.isEmpty || addr == '—') return;
    SanctionEntry? hit;
    if (addr.startsWith('0x')) {
      hit = SanctionsList.lookupEvm(addr);
    } else if (addr.startsWith('T') && addr.length == 34) {
      hit = SanctionsList.lookupTron(addr);
    } else {
      hit = SanctionsList.lookupBtc(addr);
    }
    if (hit != null) {
      out.add(_SanctionHit(address: addr, entry: hit, direction: dir));
    }
  }

  // ============================================================
  // Save dialog
  // ============================================================

  static Future<ExportResult?> _save(List<int> bytes, String filename) async {
    try {
      final location = await getSaveLocation(
        suggestedName: filename,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Excel', extensions: ['xlsx']),
        ],
      );
      if (location == null) return null;
      final file = File(location.path);
      await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
      return ExportResult(path: location.path, rowCount: bytes.length);
    } catch (e) {
      // Fallback: write to home directory if dialog fails on a barebones DE.
      final home = Platform.environment['HOME'] ?? '/tmp';
      final fallback = File('$home/$filename');
      await fallback.writeAsBytes(Uint8List.fromList(bytes), flush: true);
      return ExportResult(path: fallback.path, rowCount: bytes.length);
    }
  }

  static String _safeFilename(String s) =>
      s.replaceAll(RegExp(r'[^A-Za-z0-9_.\-]'), '_').substring(
            0,
            s.length.clamp(0, 80),
          );
}

class _SanctionHit {
  final String address;
  final SanctionEntry entry;
  final String direction;
  const _SanctionHit({
    required this.address,
    required this.entry,
    required this.direction,
  });
}
