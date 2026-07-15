# Currency Converter

[![CI](https://github.com/SevarJ/Currency-Converter/actions/workflows/ci.yml/badge.svg)](https://github.com/SevarJ/Currency-Converter/actions/workflows/ci.yml)

A SwiftUI currency converter powered by the [Frankfurter v2 API](https://frankfurter.dev) — live rates for 200+ currencies sourced from 84 central banks. No API key required.


## Features

- **Live conversion** — result updates as you type; no convert button
- **200+ currencies** including AZN, sourced from 84 central banks
- **Searchable currency picker** with symbols and full names
- **Instant swap** — inverts the cached rate locally, no extra network call
- **Offline-friendly** — currency list is cached on disk (30-day TTL)
- Decimal-accurate money math (no floating-point drift)

## Architecture

Clean Architecture with a strict one-way dependency flow:

```
Presentation          Domain                 Data
────────────          ──────                 ────
ConverterView    ┌─ Currency, Rate ─┐   ConverterRepository
ConverterVM ───▶ │ RepositoryProto  │ ◀─ NetworkService ── Frankfurter v2
CurrencyPicker   └─ NetworkError ───┘   CurrenciesDataStore (disk cache)
                                        DTOs (network + storage)
```

- **Domain** knows nothing about the API or storage — pure Swift types.
- **Data** owns all external concerns: JSON decoding (network DTOs), disk
  persistence (storage DTOs), URL building. Mapping to domain entities
  happens at the boundary (`toDomain()`).
- **Presentation** is MVVM: `@Observable` view models talk to the domain
  protocol, never to the network directly.

Key decisions:

- `Decimal` everywhere money is involved; rates are converted from `Double`
  via string round-trip to avoid binary floating-point artifacts.
- Rate fetching and conversion are decoupled: the rate is fetched once per
  currency pair, keystrokes recompute locally.
- Every dependency is injected via protocols (`URLSession` → service →
  repository → view model), which makes each layer testable in isolation.

## API

[Frankfurter v2](https://frankfurter.dev) endpoints used:

| Endpoint | Purpose |
|---|---|
| `GET /v2/currencies` | Currency list (code, name, symbol) |
| `GET /v2/rate/{base}/{quote}` | Single pair rate for the converter |
| `GET /v2/rates?base=X&quotes=A,B` | Multi-currency rates |

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

Run locally with ⌘U. CI runs the full suite on every push and pull request
(GitHub Actions, macOS runner).
