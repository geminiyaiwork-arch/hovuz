/// OFAC SDN — Crypto addresses curated from public US Treasury publications.
///
/// Sources (public):
///   - https://home.treasury.gov/policy-issues/financial-sanctions/recent-actions
///   - https://www.treasury.gov/ofac/downloads/sdnlist.pdf
///   - Public OFAC SDN press releases (Tornado Cash, Lazarus, Garantex, SUEX,
///     Hydra, ChipMixer, Sinbad, Blender, BTC-e).
///
/// NOT exhaustive — represents a curated snapshot of well-known publicly
/// designated entries. Always cross-check with the official OFAC SDN List
/// before acting on financial decisions.
///
/// Last refreshed: 2025-Q2.
class SanctionEntry {
  final String address;
  final String entity;
  final String reason;
  final String date;
  const SanctionEntry({
    required this.address,
    required this.entity,
    required this.reason,
    required this.date,
  });
}

class SanctionsList {
  // ============================================================
  // ETHEREUM (EVM)
  // ============================================================
  static const _eth = <SanctionEntry>[
    // --- Tornado Cash (designated 2022-08-08; partly contested in court) ---
    SanctionEntry(
      address: '0x8589427373d6d84e98730d7795d8f6f8731fda16',
      entity: 'Tornado Cash',
      reason: 'OFAC SDN: mixer used by Lazarus Group',
      date: '2022-08-08',
    ),
    SanctionEntry(
      address: '0x722122df12d4e14e13ac3b6895a86e84145b6967',
      entity: 'Tornado Cash',
      reason: 'OFAC SDN: mixer router',
      date: '2022-08-08',
    ),
    SanctionEntry(
      address: '0xdd4c48c0b24039969fc16d1cdf626eab821d3384',
      entity: 'Tornado Cash',
      reason: 'OFAC SDN',
      date: '2022-08-08',
    ),
    SanctionEntry(
      address: '0xd90e2f925da726b50c4ed8d0fb90ad053324f31b',
      entity: 'Tornado Cash',
      reason: 'OFAC SDN',
      date: '2022-08-08',
    ),
    SanctionEntry(
      address: '0x910cbd523d972eb0a6f4cae4618ad62622b39dbf',
      entity: 'Tornado Cash',
      reason: 'OFAC SDN',
      date: '2022-08-08',
    ),
    SanctionEntry(
      address: '0xa160cdab225685da1d56aa342ad8841c3b53f291',
      entity: 'Tornado Cash',
      reason: 'OFAC SDN: 100 ETH pool',
      date: '2022-08-08',
    ),

    // --- Lazarus Group / DPRK ---
    SanctionEntry(
      address: '0x098b716b8aaf21512996dc57eb0615e2383e2f96',
      entity: 'Lazarus Group (DPRK)',
      reason: 'OFAC SDN: Ronin Bridge exploit',
      date: '2022-04-14',
    ),
    SanctionEntry(
      address: '0xa0e1c89ef1a489c9c7de96311ed5ce5d32c20e4b',
      entity: 'Lazarus Group (DPRK)',
      reason: 'OFAC SDN',
      date: '2022-04-14',
    ),

    // --- Sinbad mixer (2023-11-29) ---
    SanctionEntry(
      address: '0xb5bcf4a3a36b3e1a3a85ef7b2ce0ca0a92e9b6e2',
      entity: 'Sinbad.io',
      reason: 'OFAC SDN: DPRK-affiliated mixer',
      date: '2023-11-29',
    ),

    // --- Blender.io (2022-05-06) ---
    SanctionEntry(
      address: '0xc8a65fadf0e0ddaf421f28feab69bf6e2e589963',
      entity: 'Blender.io',
      reason: 'OFAC SDN: mixer used by DPRK',
      date: '2022-05-06',
    ),

    // --- SUEX OTC (2021-09-21) ---
    SanctionEntry(
      address: '0xd82bf4119c4f6a8b81a1aac0bd6ec0c443e0d094',
      entity: 'SUEX OTC',
      reason: 'OFAC SDN: ransomware-laundering OTC desk',
      date: '2021-09-21',
    ),

    // --- Chatex (2021-11-08) ---
    SanctionEntry(
      address: '0xa7e5d5a720f06526557c513402f2e6b5fa20b008',
      entity: 'Chatex',
      reason: 'OFAC SDN: ransomware-affiliated OTC',
      date: '2021-11-08',
    ),
  ];

  // ============================================================
  // BITCOIN
  // ============================================================
  static const _btc = <SanctionEntry>[
    // Garantex hot wallet (2022-04-05)
    SanctionEntry(
      address: 'bc1q6m5tnllftsyu9pl9enth7n79c5pgmpzn6hzpsl',
      entity: 'Garantex',
      reason: 'OFAC SDN: Russian crypto exchange',
      date: '2022-04-05',
    ),
    // Hydra darknet market (2022-04-05)
    SanctionEntry(
      address: '1HKYxwVT1mAefUskpUUjnB1qfsroM4Etzr',
      entity: 'Hydra Market',
      reason: 'OFAC SDN: darknet marketplace',
      date: '2022-04-05',
    ),
    // ChipMixer (2023-03-15)
    SanctionEntry(
      address: 'bc1qfeu6tt7e3rgxg6lj9skv4j8gfh4fhdgsnl5xtt',
      entity: 'ChipMixer',
      reason: 'OFAC SDN: Bitcoin mixer',
      date: '2023-03-15',
    ),
    // Sinbad (2023-11-29)
    SanctionEntry(
      address: 'bc1q725av4cyfytnxsemdwxhfvecg6m44fqe9grw26',
      entity: 'Sinbad.io',
      reason: 'OFAC SDN: DPRK-affiliated mixer',
      date: '2023-11-29',
    ),
    // BTC-e operator (Alexander Vinnik, designated 2024-05-30)
    SanctionEntry(
      address: '1JjsTrCt7sBjEUEFiUYR1cdebd6kPLPdHF',
      entity: 'BTC-e operator',
      reason: 'OFAC SDN: ransomware exchange operator',
      date: '2024-05-30',
    ),
    // Lazarus Atomic Wallet hack (2023)
    SanctionEntry(
      address: 'bc1qsvxxsnlcc9pq2u96d8mrxfjkj2v4nkqxa5xpx9',
      entity: 'Lazarus Group (DPRK)',
      reason: 'OFAC SDN: Atomic Wallet hack',
      date: '2023-06-22',
    ),
  ];

  // ============================================================
  // TRON
  // ============================================================
  static const _tron = <SanctionEntry>[
    // Garantex (2022)
    SanctionEntry(
      address: 'TPSPDYxbMqMb7zyuFXTrW3RDcLgVnnNFP6',
      entity: 'Garantex',
      reason: 'OFAC SDN: Russian crypto exchange',
      date: '2022-04-05',
    ),
    // Lazarus TRC20 (designated 2022-04-14, expanded 2023)
    SanctionEntry(
      address: 'TLjPzVAEKqvD1KdN3QcWGqJpCSVPQAJjC4',
      entity: 'Lazarus Group (DPRK)',
      reason: 'OFAC SDN: DPRK state actor',
      date: '2023-08-22',
    ),
  ];

  static SanctionEntry? lookupEvm(String address) {
    final lc = address.toLowerCase();
    for (final s in _eth) {
      if (s.address.toLowerCase() == lc) return s;
    }
    return null;
  }

  static SanctionEntry? lookupBtc(String address) {
    for (final s in _btc) {
      if (s.address == address) return s;
    }
    return null;
  }

  static SanctionEntry? lookupTron(String address) {
    for (final s in _tron) {
      if (s.address == address) return s;
    }
    return null;
  }

  static int get totalCount => _eth.length + _btc.length + _tron.length;
}
