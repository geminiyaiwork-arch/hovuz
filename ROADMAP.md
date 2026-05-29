# Hovuz — Yo'l xaritasi (Roadmap)

Har bitta vazifa bajarilgan zahoti ✅ qo'yiladi. Hech narsa unutmaslik uchun
markdown jadval — tepada ko'rinib turadi.

**Joriy versiya:** v2.1.0
**Maqsad versiya:** v3.0.0 (vau effekti)

## Status kalit
- ✅ Bajarildi
- 🛠️ Hozir bajarilyapti
- ⏳ Navbatda
- 📦 Build qilingan va `/v/` da

---

## Phase 0 — Infrastruktura

| # | Vazifa | Status |
|---|---|---|
| 0.1 | `/v/` papka yaratish | ✅ |
| 0.2 | `v/index.html` yuklab olish sahifasi | ✅ |
| 0.3 | GitHub Actions workflow `.exe` build uchun | ✅ |
| 0.4 | `ROADMAP.md` (shu fayl) — kuzatuv | ✅ |
| 0.5 | Barcha eski versiyalarni `/v/vX.Y.Z/` ga arxivlash | ✅ |

---

## v2.2.0 — UX yaxshilash (5 ta xususiyat)

| # | Xususiyat | Kod | i18n UZ | i18n EN | i18n RU | Test | `.deb` | `.exe` (CI) | `/v/` |
|---|---|---|---|---|---|---|---|---|---|
| 2.2.1 | 💵 USD qiymat (CoinGecko) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |
| 2.2.2 | 📝 Shaxsiy izohlar | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |
| 2.2.3 | 🔤 ENS / SNS nom hal qilish | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |
| 2.2.4 | 🌗 Yorug'/Qorong'i tema | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |
| 2.2.5 | ⌨️ Klaviatura yorliqlari | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |

**v2.2.0 RELEASE** — barcha 5 ta birgalikda → 📦 ✅

---

## v2.3.0 — Professional forensika (4 ta xususiyat)

| # | Xususiyat | Kod | i18n UZ | i18n EN | i18n RU | Test | `.deb` | `.exe` (CI) | `/v/` |
|---|---|---|---|---|---|---|---|---|---|
| 2.3.1 | 🔬 Multi-hop tracing + mixer detect | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |
| 2.3.2 | 📊 Risk score (0-100) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |
| 2.3.3 | 🐋 Whale belgisi + filter | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |
| 2.3.4 | 📑 PDF compliance hisobot | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |

**v2.3.0 RELEASE** → 📦 ✅

---

## v3.0.0 — Vau effekti (4 ta xususiyat)

| # | Xususiyat | Kod | i18n UZ | i18n EN | i18n RU | Test | `.deb` | `.exe` (CI) | `/v/` |
|---|---|---|---|---|---|---|---|---|---|
| 3.0.1 | 🗺️ Sankey / graf diagrammasi | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |
| 3.0.2 | 📋 Qidiruv tarixi (multi-tab alt) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |
| 3.0.3 | 💼 Token portfolio | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |
| 3.0.4 | ➕ Polygon + Arbitrum + Base + Optimism | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⏳ CI | ✅ |

**v3.0.0 RELEASE** → 📦 ✅

---

## Tugallangan versiyalar

| Versiya | Sana | `.deb` | `.exe` | Tavsif |
|---|---|---|---|---|
| v1.0.0 | 2026-05-29 | ✅ | — | Birinchi skelet |
| v1.0.1 | 2026-05-29 | ✅ | — | Dizayn kripto-iliq |
| v1.0.2 | 2026-05-29 | ✅ | — | i18n UZ/EN/RU |
| v1.0.3 | 2026-05-29 | ✅ | — | Logo + Solana + kontrakt manzili + Qodirov Elyorbek aftor |
| v1.0.4 | 2026-05-29 | ✅ | — | Ikonka o'rnatish + maximize |
| v1.0.5 | 2026-05-29 | ✅ | — | Sidebar top alignment |
| v2.0.0 | 2026-05-29 | ✅ | — | Drill-down + back/forward + grouping + watchlist + pagination + CoinLogo |
| v2.1.0 | 2026-05-29 | ✅ | — | Yurisdiksiya + OFAC SDN + vaqt zona tahlili + Excel eksport |
| v2.2.0 | 2026-05-29 | ✅ | ⏳ CI | UX: USD narx + izohlar + ENS/SNS + tema + klaviatura yorliqlari |
| v2.3.0 | 2026-05-29 | ✅ | ⏳ CI | Forensika: multi-hop trace + risk score + whale + PDF |
| v3.0.0 | 2026-05-29 | ✅ | ⏳ CI | **VAU**: Sankey + portfolio + tarix + Polygon/Arbitrum/Optimism/Base |
