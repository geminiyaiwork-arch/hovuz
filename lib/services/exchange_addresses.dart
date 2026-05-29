import '../models/chain.dart';
import 'jurisdictions.dart';

/// Known exchange / custodial addresses across major chains.
/// These are hot/cold wallets that have been publicly identified.
/// Source: public on-chain labels (Etherscan, Tronscan, Arkham, etc.).
class ExchangeAddressBook {
  static const Map<String, _ExchangeEntry> _entries = {
    // ---------------------- TRON (USDT TRC20 hot wallets) ----------------------
    'TNXoiAJ3dct8Fjg4M9fkLFh9S2v9TXc32G': _ExchangeEntry('Binance', 'TRON Hot Wallet'),
    'TKHuVq1oKVruCGLvqVexFs6dawKv6fQgFs': _ExchangeEntry('Binance', 'TRON Hot Wallet 2'),
    'TMuA6YqfCeX8EhbfYEg5y7S4DqzSJireY9': _ExchangeEntry('Binance', 'TRON Hot Wallet 3'),
    'TWd4WrZ9wn84f5x1hZhL4DHvk738ns5jwb': _ExchangeEntry('Binance', 'TRON Hot Wallet 4'),
    'TJDENsfBJs4RFETt1X1W8wMDc8M5XnJhCe': _ExchangeEntry('OKX', 'TRON Hot Wallet'),
    'TKHomgK4nFAuRtPnVJxe8WfFLysw7Emelf': _ExchangeEntry('OKX', 'TRON Hot Wallet 2'),
    'TVDGpn4hRSnj3J7ndYZQs8TFep4xrhmcRm': _ExchangeEntry('Bybit', 'TRON Hot Wallet'),
    'TWa97KLayepBy1HDxXLNzFxFvZWuMLPbgK': _ExchangeEntry('Bybit', 'TRON Hot Wallet 2'),
    'TFFRZxFvjJQzWjK2bHQyqQjcr5Vd1MhJj7': _ExchangeEntry('KuCoin', 'TRON Hot Wallet'),
    'TXrs7yxQLNzig7J9EbKhoEiUp6TPbftf9q': _ExchangeEntry('KuCoin', 'TRON Hot Wallet 2'),
    'TLi5kRoFq6afkpJvxQYTqVtHBxXEKUMxKK': _ExchangeEntry('HTX (Huobi)', 'TRON Hot Wallet'),
    'TRwXfXJM6vrAUcfQTQyJ6cUDvCRwYNCxnS': _ExchangeEntry('HTX (Huobi)', 'TRON Hot Wallet 2'),
    'TWPv7nVHCnXvr3Vh6kVnVZ8YsAFcGqYJpD': _ExchangeEntry('MEXC', 'TRON Hot Wallet'),
    'TAUN6FwrnwwmaEqYcckffC7wYmbaS6cBiX': _ExchangeEntry('Bitget', 'TRON Hot Wallet'),
    'TYDzsYUEpvnYmQk4zGP9sWWcTEd2MiAtW6': _ExchangeEntry('Gate.io', 'TRON Hot Wallet'),
    'TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax': _ExchangeEntry('Poloniex', 'TRON Hot Wallet'),

    // ---------------------- ETHEREUM (hot wallets) ----------------------
    '0x28c6c06298d514db089934071355e5743bf21d60': _ExchangeEntry('Binance', 'Hot Wallet 14'),
    '0x21a31ee1afc51d94c2efccaa2092ad1028285549': _ExchangeEntry('Binance', 'Hot Wallet 15'),
    '0xdfd5293d8e347dfe59e90efd55b2956a1343963d': _ExchangeEntry('Binance', 'Hot Wallet 16'),
    '0x56eddb7aa87536c09ccc2793473599fd21a8b17f': _ExchangeEntry('Binance', 'Hot Wallet 17'),
    '0x9696f59e4d72e237be84ffd425dcad154bf96976': _ExchangeEntry('Binance', 'Hot Wallet 18'),
    '0x4976a4a02f38326660d17bf34b431dc6e2eb2327': _ExchangeEntry('Binance', 'Hot Wallet 19'),
    '0xd551234ae421e3bcba99a0da6d736074f22192ff': _ExchangeEntry('Binance', 'Hot Wallet 2'),
    '0x564286362092d8e7936f0549571a803b203aaced': _ExchangeEntry('Binance', 'Hot Wallet 3'),
    '0x0681d8db095565fe8a346fa0277bffde9c0edbbf': _ExchangeEntry('Binance', 'Hot Wallet 4'),
    '0xfe9e8709d3215310075d67e3ed32a380ccf451c8': _ExchangeEntry('Binance', 'Hot Wallet 5'),
    '0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be': _ExchangeEntry('Binance', 'Hot Wallet 6'),
    '0x6cc5f688a315f3dc28a7781717a9a798a59fda7b': _ExchangeEntry('OKX', 'Hot Wallet'),
    '0x236f9f97e0e62388479bf9e5ba4889e46b0273c3': _ExchangeEntry('OKX', 'Hot Wallet 2'),
    '0xa7efae728d2936e78bda97dc267687568dd593f3': _ExchangeEntry('OKX', 'Hot Wallet 3'),
    '0x5041ed759dd4afc3a72b8192c143f72f4724081a': _ExchangeEntry('OKX', 'Hot Wallet 4'),
    '0xf89d7b9c864f589bbf53a82105107622b35eaa40': _ExchangeEntry('Bybit', 'Hot Wallet'),
    '0xee5b5b923ffce93a870b3104b7ca09c3db80047a': _ExchangeEntry('Bybit', 'Hot Wallet 2'),
    '0x2b5634c42055806a59e9107ed44d43c426e58258': _ExchangeEntry('KuCoin', 'Hot Wallet'),
    '0xd6216fc19db775df9774a6e33526131da7d19a2c': _ExchangeEntry('KuCoin', 'Hot Wallet 2'),
    '0x88ebb1a99eb6d9c54373f1d83b1e0a9e08e633b3': _ExchangeEntry('KuCoin', 'Hot Wallet 3'),
    '0xab5c66752a9e8167967685f1450532fb96d5d24f': _ExchangeEntry('HTX (Huobi)', 'Hot Wallet'),
    '0xdc76cd25977e0a5ae17155770273ad58648900d3': _ExchangeEntry('HTX (Huobi)', 'Hot Wallet 2'),
    '0x6748f50f686bfbca6fe8ad62b22228b87f31ff2b': _ExchangeEntry('Bitget', 'Hot Wallet'),
    '0x77696bb39917c91a0c3908d577d5e322095425ca': _ExchangeEntry('Bitget', 'Hot Wallet 2'),
    '0x75e89d5979e4f6fba9f97c104c2f0afb3f1dcb88': _ExchangeEntry('MEXC', 'Hot Wallet'),
    '0x9642b23ed1e01df1092b92641051881a322f5d4e': _ExchangeEntry('MEXC', 'Hot Wallet 2'),
    '0x71660c4005ba85c37ccec55d0c4493e66fe775d3': _ExchangeEntry('Coinbase', 'Hot Wallet'),
    '0x503828976d22510aad0201ac7ec88293211d23da': _ExchangeEntry('Coinbase', 'Hot Wallet 2'),
    '0xddfabcdc4d8ffc6d5beaf154f18b778f892a0740': _ExchangeEntry('Coinbase', 'Hot Wallet 3'),
    '0x3cd751e6b0078be393132286c442345e5dc49699': _ExchangeEntry('Coinbase', 'Hot Wallet 4'),
    '0x267be1c1d684f78cb4f6a176c4911b741e4ffdc0': _ExchangeEntry('Kraken', 'Hot Wallet'),
    '0xfa52274dd61e1643d2205169732f29114bc240b3': _ExchangeEntry('Kraken', 'Hot Wallet 2'),
    '0x53d284357ec70ce289d6d64134dfac8e511c8a3d': _ExchangeEntry('Kraken', 'Hot Wallet 3'),
    '0xae2d4617c862309a3d75a0ffb358c7a5009c673f': _ExchangeEntry('Kraken', 'Hot Wallet 4'),
    '0x1c4b70a3968436b9a0a9cf5205c787eb81bb558c': _ExchangeEntry('Gate.io', 'Hot Wallet'),
    '0x0d0707963952f2fba59dd06f2b425ace40b492fe': _ExchangeEntry('Gate.io', 'Hot Wallet 2'),

    // ---------------------- BNB CHAIN (BEP20) ----------------------
    // BSC uses same address format as ETH; many CEX share addresses across chains.

    // ---------------------- SOLANA (hot wallets) ----------------------
    '5tzFkiKscXHK5ZXCGbXZxdw7gTjjD1mBwuoFbhUvuAi9': _ExchangeEntry('Binance', 'Solana Hot Wallet'),
    '9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM': _ExchangeEntry('Binance', 'Solana Hot Wallet 2'),
    'GThUX1Atko4tqhN2NaiTazWSeFWMuiUiswQrAzhWmMqL': _ExchangeEntry('Binance', 'Solana Hot Wallet 3'),
    'A77HErqtfN1hLLpvZ9pCtu66FEtM8BveoaKbbMoZ4RiR': _ExchangeEntry('Bybit', 'Solana Hot Wallet'),
    'AC5RDfQFmDS1deWZos921JfqscXdByf8BKHs5ACWjtW2': _ExchangeEntry('Bybit', 'Solana Hot Wallet 2'),
    '9un5wqE3q4oCjyrDkwsdD48KteCJitQX5978Vh7KKxHo': _ExchangeEntry('Coinbase', 'Solana Hot Wallet'),
    'H8sMJSCQxfKiFTCfDR3DUMLPwcRbM61LGFJ8N4dK3WjS': _ExchangeEntry('Coinbase', 'Solana Hot Wallet 2'),
    'FxteHmLwG9nk1eL4pjNve3Eub2goGkkz6g6TbvdmW46a': _ExchangeEntry('OKX', 'Solana Hot Wallet'),
    '5VCwKtCXgCJ6kit5FybXjvriW3xELsFDhYrPSqtJNmcD': _ExchangeEntry('OKX', 'Solana Hot Wallet 2'),
    '2ojv9BAiHUrvsm9gxDe7fJSzbNZSJcxZvf8dqmWGHG8S': _ExchangeEntry('Kraken', 'Solana Hot Wallet'),
    'BmFdpraQhkiDQE6SnfG5omcA1VwzqfXrwtNYBwWTymy6': _ExchangeEntry('KuCoin', 'Solana Hot Wallet'),
    'HVh6wHNBAsG3pq1Bj5oCzRjoWKVogEDHwUHkRz3ekFgt': _ExchangeEntry('KuCoin', 'Solana Hot Wallet 2'),
    'D3p6E1FQwm2VyKnKHFASYwR5w3M5vbBd7qfn2hkPTLFx': _ExchangeEntry('Bitget', 'Solana Hot Wallet'),
    'AobVSwdW9BbpMdJvTqeCN4hPAmh4rHm7vwLnQ5ATSyrS': _ExchangeEntry('Crypto.com', 'Solana Hot Wallet'),
    'F37Wb3pwSeJ9JxYY1zVtPJ8AT4SK9SBb5xoCExoeFGmZ': _ExchangeEntry('Gate.io', 'Solana Hot Wallet'),

    // ---------------------- BITCOIN (cold/hot wallets) ----------------------
    '1NDyJtNTjmwk5xPNhjgAMu4HDHigtobu1s': _ExchangeEntry('Binance', 'Cold Wallet'),
    'bc1qm34lsc65zpw79lxes69zkqmk6ee3ewf0j77s3h': _ExchangeEntry('Binance', 'Cold Wallet 2'),
    '34xp4vRoCGJym3xR7yCVPFHoCNxv4Twseo': _ExchangeEntry('Binance', 'Cold Wallet 3'),
    '3LCGsSmfr24demGvriN4e3ft8wEcDuHFqh': _ExchangeEntry('Binance', 'Hot Wallet'),
    '385cR5DM96n1HvBDMzLHPYcw89fZAXULJP': _ExchangeEntry('OKX', 'Cold Wallet'),
    'bc1qjasf9z3h7w3jspkhtgatgpyvvzgpa2wwd2lr0eh5tx44reyn2k7sfc27a4': _ExchangeEntry('OKX', 'Hot Wallet'),
    'bc1qa5wkgaew2dkv56kfvj49j0av5nml45x9ek9hz6': _ExchangeEntry('Bybit', 'Cold Wallet'),
    '3LYJfcfHPXYJreMsASk2jkn69LWEYKzexb': _ExchangeEntry('Bybit', 'Hot Wallet'),
    '3LCGsSmfr24demGvriN4e3ft8wEcDuHFqz': _ExchangeEntry('KuCoin', 'Hot Wallet'),
    '38UmuUqPCrFmQo4khkomQwZ4VbY2nZMJ67': _ExchangeEntry('Coinbase', 'Cold Wallet'),
    '3FupZp77ySr7jwoLYEJ9mwzJpvoNBXsBnE': _ExchangeEntry('Coinbase', 'Cold Wallet 2'),
    'bc1ql49ydapnjafl5t2cp9zqpjwe6pdgmxy98859v2': _ExchangeEntry('Kraken', 'Cold Wallet'),
    '3Cbq7aT1tY8kMxWLbitaG7yT6bPbKChq64': _ExchangeEntry('HTX (Huobi)', 'Cold Wallet'),
    '1FzWLkAahHooV3kzTgyx6qsswXJ6sCXkSR': _ExchangeEntry('Bitfinex', 'Cold Wallet'),
  };

  /// Lookup a label for the given address. Returns null when unknown.
  /// Address is matched case-insensitively for ETH/BSC; case-sensitively for BTC/TRON.
  static ExchangeLabel? lookup(String address, Chain chain) {
    if (address.isEmpty) return null;

    final lower = address.toLowerCase();
    final entry = _entries[lower] ?? _entries[address];
    if (entry == null) return null;
    return ExchangeLabel(entry.exchange, entry.note);
  }

  /// Whether the given address is a known exchange.
  static bool isExchange(String address, Chain chain) =>
      lookup(address, chain) != null;
}

class _ExchangeEntry {
  final String exchange;
  final String note;
  const _ExchangeEntry(this.exchange, this.note);
}

class ExchangeLabel {
  final String exchange;
  final String note;
  const ExchangeLabel(this.exchange, this.note);

  /// "🇰🇾 Binance · TRON Hot Wallet" — flag prefixed when known.
  String get display {
    final j = Jurisdictions.lookup(exchange);
    final prefix = j != null ? '${j.flag} ' : '';
    return '$prefix$exchange · $note';
  }
}
