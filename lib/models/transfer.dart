import '../l10n/strings.dart';
import 'chain.dart';

enum TransferDirection { sent, received, selfTransfer, unrelated }

class Transfer {
  final String from;
  final String to;
  final double amount;
  final String symbol;
  final String? fromLabel;
  final String? toLabel;
  final DateTime? time;
  final String? txHash;

  /// Token contract address (for ERC20 / BEP20 / TRC20 / SPL tokens).
  /// Null for native currency transfers (BTC, ETH, BNB, TRX, SOL).
  final String? contractAddress;

  const Transfer({
    required this.from,
    required this.to,
    required this.amount,
    required this.symbol,
    this.fromLabel,
    this.toLabel,
    this.time,
    this.txHash,
    this.contractAddress,
  });

  /// Direction of this transfer relative to the given "owner" address.
  /// Addresses are compared case-insensitively.
  TransferDirection directionFor(String? owner) {
    if (owner == null || owner.isEmpty) return TransferDirection.unrelated;
    final o = owner.toLowerCase();
    final f = from.toLowerCase();
    final to_ = to.toLowerCase();
    if (f == o && to_ == o) return TransferDirection.selfTransfer;
    if (f == o) return TransferDirection.sent;
    if (to_ == o) return TransferDirection.received;
    return TransferDirection.unrelated;
  }

  /// The counterparty from the owner's perspective:
  /// - For "sent" → to
  /// - For "received" → from
  /// - For self/unrelated → null
  String? counterpartyFor(String? owner) {
    switch (directionFor(owner)) {
      case TransferDirection.sent:
        return to;
      case TransferDirection.received:
        return from;
      case TransferDirection.selfTransfer:
      case TransferDirection.unrelated:
        return null;
    }
  }
}

class TransactionInfo {
  final Chain chain;
  final String hash;
  final DateTime? time;
  final int? blockHeight;
  final int? confirmations;
  final String? status;
  final double? feeNative;
  final List<Transfer> transfers;
  final String? rawSender;
  final String? rawReceiver;

  const TransactionInfo({
    required this.chain,
    required this.hash,
    required this.transfers,
    this.time,
    this.blockHeight,
    this.confirmations,
    this.status,
    this.feeNative,
    this.rawSender,
    this.rawReceiver,
  });
}

class AddressSummary {
  final Chain chain;
  final String address;
  final double balanceNative;
  final double totalReceivedNative;
  final double totalSentNative;
  final int txCount;
  final String? label;
  final List<Transfer> recentTransfers;

  /// Per-symbol received totals (native + ERC20/BEP20 tokens).
  /// e.g. {'ETH': 0.42, 'USDT': 700.5, 'USDC': 12.0}
  final Map<String, double> totalReceivedBySymbol;
  final Map<String, double> totalSentBySymbol;

  const AddressSummary({
    required this.chain,
    required this.address,
    required this.balanceNative,
    required this.totalReceivedNative,
    required this.totalSentNative,
    required this.txCount,
    required this.recentTransfers,
    this.label,
    this.totalReceivedBySymbol = const {},
    this.totalSentBySymbol = const {},
  });

  /// Returns the symbol with the largest received total. Useful when the
  /// address has token activity but no native value moves — UI can then
  /// show 'USDT' totals instead of '0 ETH'.
  String get primarySymbol {
    if (totalReceivedBySymbol.isEmpty) return chain.nativeSymbol;
    var best = chain.nativeSymbol;
    var bestVal = totalReceivedBySymbol[best] ?? 0;
    totalReceivedBySymbol.forEach((sym, val) {
      if (val > bestVal) {
        bestVal = val;
        best = sym;
      }
    });
    return best;
  }

  double get primaryReceived =>
      totalReceivedBySymbol[primarySymbol] ?? totalReceivedNative;
  double get primarySent =>
      totalSentBySymbol[primarySymbol] ?? totalSentNative;
}

class LookupResult {
  final DetectionResult detection;
  final TransactionInfo? transaction;
  final AddressSummary? address;
  final LookupErrorCode? errorCode;
  final String? errorExtra;

  const LookupResult({
    required this.detection,
    this.transaction,
    this.address,
    this.errorCode,
    this.errorExtra,
  });

  bool get hasError => errorCode != null;
}
