import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../l10n/strings.dart';
import '../models/transfer.dart';
import 'jurisdictions.dart';
import 'risk_score.dart';
import 'sanctions_list.dart';
import 'timezone_analyzer.dart';

class PdfReportResult {
  final String path;
  const PdfReportResult({required this.path});
}

class PdfReportService {
  /// Build a compliance/AML report for an address. Returns null on cancel.
  static Future<PdfReportResult?> exportAddress(
    AddressSummary a, {
    required S s,
  }) async {
    final doc = pw.Document(
      title: 'Hovuz Report ${a.chain.code} ${a.address}',
      author: 'Hovuz',
    );

    final risk = RiskAssessor.assess(a);
    final tz = TimezoneAnalyzer.analyze(a.recentTransfers);
    final jurisdiction = a.label != null
        ? Jurisdictions.lookup(a.label!.split('·').first.trim())
        : null;
    final sanctionHits = _collectSanctions(a);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => [
          _header(s, a.chain.label, a.address),
          pw.SizedBox(height: 16),
          _summaryTable(a, s, jurisdiction),
          pw.SizedBox(height: 18),
          _riskSection(risk, s),
          pw.SizedBox(height: 18),
          if (tz.sampleSize >= 5) _timezoneSection(tz, s),
          pw.SizedBox(height: 18),
          if (sanctionHits.isNotEmpty) _sanctionsSection(sanctionHits, s),
          pw.SizedBox(height: 18),
          _transfersSection(a.recentTransfers, s),
          pw.SizedBox(height: 24),
          _footer(s),
        ],
      ),
    );

    final bytes = await doc.save();
    return _save(bytes, _safeFilename('hovuz_report_${a.chain.code}_${a.address}.pdf'));
  }

  // ============================================================
  // Sections
  // ============================================================

  static pw.Widget _header(S s, String chainLabel, String addr) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Hovuz',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF1E62D8),
                )),
            pw.Text('Compliance Report',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromInt(0xFF5A6A85),
                )),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColor.fromInt(0xFF1E62D8)),
        pw.SizedBox(height: 8),
        pw.Text(s.walletTitle,
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('$chainLabel · $addr',
            style: pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromInt(0xFF5A6A85),
                fontWeight: pw.FontWeight.normal)),
        pw.Text(
            'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now().toLocal())}',
            style: pw.TextStyle(
                fontSize: 9, color: PdfColor.fromInt(0xFF5A6A85))),
      ],
    );
  }

  static pw.Widget _summaryTable(
      AddressSummary a, S s, Jurisdiction? j) {
    final sym = a.chain.nativeSymbol;
    final rows = <List<String>>[
      [s.currentBalance, '${a.balanceNative} $sym'],
      [s.totalReceived, '${a.totalReceivedNative} $sym'],
      [s.totalSent, '${a.totalSentNative} $sym'],
      [s.transactionsField, '${a.txCount}'],
      if (a.label != null) [s.labelField, a.label!],
      if (j != null)
        [s.jurisdictionLabel, '${j.flag} ${j.country}'],
    ];
    return _section(s.sectionGeneralBalance, _twoColTable(rows));
  }

  static pw.Widget _riskSection(RiskScore r, S s) {
    final level = switch (r.level) {
      RiskLevel.veryLow => s.riskLevelVeryLow,
      RiskLevel.low => s.riskLevelLow,
      RiskLevel.medium => s.riskLevelMedium,
      RiskLevel.high => s.riskLevelHigh,
      RiskLevel.critical => s.riskLevelCritical,
    };
    final color = switch (r.level) {
      RiskLevel.veryLow => PdfColor.fromInt(0xFF10A85B),
      RiskLevel.low => PdfColor.fromInt(0xFF7BB341),
      RiskLevel.medium => PdfColor.fromInt(0xFFCC8400),
      RiskLevel.high => PdfColor.fromInt(0xFFE6750E),
      RiskLevel.critical => PdfColor.fromInt(0xFFE0394A),
    };
    return _section(
      s.riskScoreTitle,
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(level,
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
              ),
              pw.SizedBox(width: 12),
              pw.Text('${r.score}/100',
                  style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: color)),
            ],
          ),
          pw.SizedBox(height: 10),
          for (final f in r.factors)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(
                children: [
                  pw.Text(f.isPositive ? '+ ' : '! ',
                      style: pw.TextStyle(
                          color: f.isPositive
                              ? PdfColor.fromInt(0xFF10A85B)
                              : PdfColor.fromInt(0xFFE0394A),
                          fontWeight: pw.FontWeight.bold)),
                  pw.Expanded(
                    child: pw.Text(s.translateRiskFactor(f.displayKey),
                        style: const pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Text(
                    '${f.isPositive ? '-' : '+'}${f.weight}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: f.isPositive
                          ? PdfColor.fromInt(0xFF10A85B)
                          : PdfColor.fromInt(0xFFE0394A),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _timezoneSection(TimezoneEstimate tz, S s) {
    String summary;
    if (tz.algorithmic) {
      summary = s.tzAlgorithmic;
    } else if (tz.offsetHours != null) {
      final off = tz.offsetHours!;
      summary =
          'UTC${off >= 0 ? '+' : ''}$off · ${tz.regionHint ?? ''}';
    } else {
      summary = s.tzInsufficient;
    }
    return _section(s.tzAnalysisTitle,
        _twoColTable([
          [s.tzSamples, '${tz.sampleSize}'],
          [s.tzPattern, summary],
          if (!tz.algorithmic && tz.offsetHours != null)
            [s.tzConfidence,
              '${(tz.confidence * 100).toStringAsFixed(0)}%'],
        ]));
  }

  static pw.Widget _sanctionsSection(
      List<_SanctionHit> hits, S s) {
    return _section(
      s.sanctionsHeader,
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final h in hits)
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 2),
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFFFE5E8),
                border: pw.Border.all(
                    color: PdfColor.fromInt(0xFFE0394A), width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${h.entry.entity} · ${h.entry.date}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFFE0394A),
                          fontSize: 10)),
                  pw.Text(h.address,
                      style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(h.entry.reason,
                      style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColor.fromInt(0xFF5A6A85))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _transfersSection(
      List<Transfer> transfers, S s) {
    return _section(
      s.recentTransfers,
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          fontSize: 9,
        ),
        headerDecoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFF1E62D8),
        ),
        cellStyle: const pw.TextStyle(fontSize: 8),
        cellAlignment: pw.Alignment.centerLeft,
        headers: [
          '#',
          s.time,
          'Amount',
          'Symbol',
          'From',
          'To',
        ],
        data: [
          for (var i = 0; i < transfers.length.clamp(0, 30); i++)
            [
              '${i + 1}',
              _fmtTime(transfers[i].time),
              transfers[i].amount.toString(),
              transfers[i].symbol,
              _short(transfers[i].from),
              _short(transfers[i].to),
            ]
        ],
      ),
    );
  }

  static pw.Widget _footer(S s) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColor.fromInt(0xFFE1E7F0)),
        pw.SizedBox(height: 6),
        pw.Text(
          s.disclaimer,
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColor.fromInt(0xFF5A6A85),
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Hovuz · VISIO EYE · Qodirov Elyorbek',
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColor.fromInt(0xFF1E62D8),
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Helpers
  // ============================================================

  static pw.Widget _section(String title, pw.Widget body) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title.toUpperCase(),
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF1E62D8),
                letterSpacing: 1)),
        pw.SizedBox(height: 6),
        body,
      ],
    );
  }

  static pw.Widget _twoColTable(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.symmetric(
        inside: pw.BorderSide(
            color: PdfColor.fromInt(0xFFE1E7F0), width: 0.5),
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(3),
      },
      children: [
        for (final r in rows)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 4, vertical: 4),
                child: pw.Text(r[0],
                    style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColor.fromInt(0xFF5A6A85))),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 4, vertical: 4),
                child: pw.Text(r[1],
                    style: const pw.TextStyle(fontSize: 9)),
              ),
            ],
          ),
      ],
    );
  }

  static String _short(String a) {
    if (a.isEmpty || a == '—') return '—';
    if (a.length < 16) return a;
    return '${a.substring(0, 8)}…${a.substring(a.length - 6)}';
  }

  static String _fmtTime(DateTime? t) {
    if (t == null) return '—';
    return DateFormat('MM-dd HH:mm').format(t.toLocal());
  }

  static List<_SanctionHit> _collectSanctions(AddressSummary a) {
    final out = <_SanctionHit>[];
    void check(String addr) {
      if (addr.isEmpty || addr == '—') return;
      SanctionEntry? hit;
      if (addr.startsWith('0x')) {
        hit = SanctionsList.lookupEvm(addr);
      } else if (addr.startsWith('T') && addr.length == 34) {
        hit = SanctionsList.lookupTron(addr);
      } else {
        hit = SanctionsList.lookupBtc(addr);
      }
      if (hit != null) out.add(_SanctionHit(address: addr, entry: hit));
    }

    check(a.address);
    for (final t in a.recentTransfers) {
      check(t.from);
      check(t.to);
    }
    return out;
  }

  static Future<PdfReportResult?> _save(
      Uint8List bytes, String filename) async {
    try {
      final location = await getSaveLocation(
        suggestedName: filename,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PDF', extensions: ['pdf']),
        ],
      );
      if (location == null) return null;
      final f = File(location.path);
      await f.writeAsBytes(bytes, flush: true);
      return PdfReportResult(path: location.path);
    } catch (_) {
      final home = Platform.environment['HOME'] ?? '/tmp';
      final fallback = File('$home/$filename');
      await fallback.writeAsBytes(bytes, flush: true);
      return PdfReportResult(path: fallback.path);
    }
  }

  static String _safeFilename(String s) =>
      s.replaceAll(RegExp(r'[^A-Za-z0-9_.\-]'), '_').substring(
            0,
            s.length.clamp(0, 100),
          );
}

class _SanctionHit {
  final String address;
  final SanctionEntry entry;
  const _SanctionHit({required this.address, required this.entry});
}
