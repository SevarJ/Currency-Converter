# Currency Converter

[![CI](https://github.com/SevarJ/Currency-Converter/actions/workflows/ci.yml/badge.svg)](https://github.com/SevarJ/Currency-Converter/actions/workflows/ci.yml)

A SwiftUI currency converter powered by the [Frankfurter v2 API](https://frankfurter.dev) — live rates for 200+ currencies sourced from 84 central banks. No API key required.


## Features

- **Live conversion** — result updates as you type; no convert button
- **Rates list** — all rates for a chosen base currency, with per-rate dates
- **Historical charts** — interactive rate history with touch scrubbing,
  quick presets (1M/3M/1Y), and a custom date range; resolution (daily,
  weekly, monthly) adapts automatically to the range length
- **200+ currencies** including AZN, sourced from 84 central banks
- **Searchable currency picker** with symbols and full names
- **Instant swap** — inverts the cached rate locally, no extra network call
- **Home screen widget** — latest rate at a glance, refreshed every few
  hours via a WidgetKit timeline (with a faster retry when offline)
- **Offline-friendly** — currency list is cached on disk (30-day TTL)
- Decimal-accurate money math (no floating-point drift)

## Architecture

Clean Architecture with a strict one-way dependency flow:

```
Presentation            Domain                 Data
────────────            ──────                 ────
ConverterView/VM   ┌─ Currency, Rate ─┐   ConverterRepository
RatesListView/VM ─▶│ RepositoryProto  │◀─ NetworkService ── Frankfurter v2
CurrencyPicker     └─ NetworkError ───┘   CurrenciesDataStore (disk cache)
Components (row,                          DTOs (network + storage)
 currency button)

Widget extension: reuses the network layer to fetch a single rate
on a WidgetKit timeline (separate process, no shared state with the app).
```

- **Domain** knows nothing about the API or storage — pure Swift types.
- **Data** owns all external concerns: JSON decoding (network DTOs), disk
  persistence (storage DTOs), URL building. Mapping to domain entities
  happens at the boundary (`toDomain()`).
- **Presentation** is MVVM: `@Observable` view models talk to the domain
  protocol, never to the network directly. One view model per screen;
  shared UI (currency row, currency button) lives in reusable components.

Key decisions:

- `Decimal` everywhere money is involved; rates are converted from `Double`
  via string round-trip to avoid binary floating-point artifacts.
- Rate fetching and conversion are decoupled: the rate is fetched once per
  currency pair, keystrokes recompute locally.
- Every dependency is injected via protocols (`URLSession` → service →
  repository → view model), which makes each layer testable in isolation.
- The whole dependency graph is built once in a single composition root
  (`AppDependencies`) and distributed through the SwiftUI environment;
  screens construct their view models via constructor injection.

## API

[Frankfurter v2](https://frankfurter.dev) endpoints used:

| Endpoint | Purpose |
|---|---|
| `GET /v2/currencies` | Currency list (code, name, symbol) |
| `GET /v2/rate/{base}/{quote}` | Single pair rate for the converter |
| `GET /v2/rates?base=X&quotes=A,B` | Multi-currency rates |
| `GET /v2/rates?from=...&to=...&group=...` | Time series for history charts |

## Requirements

- iOS 17.0+
- Xcode 26+

## Getting Started

```bash
git clone https://github.com/SevarJ/Currency-Converter.git
open Currency-Converter/CurrencyConverter/CurrencyConverter.xcodeproj
```

Run with ⌘R. No API keys, no configuration.

## Testing

Unit tests (Swift Testing) cover the decision points of the codebase:

- **Endpoint URLs** — correct paths/queries, including the empty-quotes case
- **DTO → domain mapping** — date parsing and `Decimal` precision
  (guards against reintroducing float-based conversion)
- **Disk cache** — save/load round-trip, TTL expiry, and the
  `ignoringTTL` escape hatch (isolated via injected file URLs)
- **Repository policies** — cache-first reads, stale-while-error fallback,
  and automatic chart resolution, proven with a mock network service

Run locally with ⌘U. CI runs the full suite on every push and pull request
(GitHub Actions, macOS runner).
