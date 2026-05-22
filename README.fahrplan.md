# Fahrplanauskunft App

Eine moderne Flutter-App zur Abfrage von Zugverbindungen und Echtzeit-Abfahrten im öffentlichen Nahverkehr — powered by der kostenlosen [DB REST API](https://v6.db.transport.rest).

---

## Features

- **Verbindungssuche** — Start und Ziel eingeben, Datum/Uhrzeit wählen, Verbindungen anzeigen
- **Abfahrtstafel** — Echtzeit-Abfahrten für beliebige Haltestellen mit Verspätungsanzeige
- **Haltestellensuche** — Live-Suche mit Autocomplete und Fallback bei fehlender Verbindung
- **Verbindungsdetails** — Einzelne Abschnitte mit Linie, Gleis, Umstieg und Verspätung
- **Start/Ziel tauschen** — Per Knopfdruck umkehren
- **Abfahrt / Ankunft** — Umschalten zwischen Abfahrts- und Ankunftszeit
- **Verspätungsanzeige** — Farbkodiert (grün / gelb / orange / rot)
- **Ausfälle** — Gestrichene Verbindungen werden markiert
- **Offline-Fallback** — Bekannte Haltestellen bei fehlender Internetverbindung

---

## Tech Stack

| Technologie | Verwendung |
|---|---|
| Flutter / Dart | Cross-Platform Framework (iOS & Android) |
| flutter_bloc | State Management (BLoC Pattern) |
| http | REST API Anfragen |
| intl | Datums- und Zeitformatierung (Deutsch) |
| flutter_animate | Animationen |
| DB REST API v6 | Fahrplandaten der Deutschen Bahn |

---

## Architektur

Die App verwendet das **BLoC Pattern** (Business Logic Component) für eine saubere Trennung von UI und Logik.

```
lib/
├── blocs/
│   ├── departure/          # Abfahrtstafel (laden, aktualisieren)
│   │   ├── departure_bloc.dart
│   │   ├── departure_event.dart
│   │   └── departure_state.dart
│   ├── journey/            # Verbindungssuche (suchen, tauschen, zurücksetzen)
│   │   ├── journey_bloc.dart
│   │   ├── journey_event.dart
│   │   └── journey_state.dart
│   └── station_search/     # Haltestellensuche (live, mit Fallback)
│       ├── station_search_bloc.dart
│       ├── station_search_event.dart
│       └── station_search_state.dart
├── models/
│   └── transit_models.dart  # Station, Departure, Journey, JourneyLeg, TransitLine
├── screens/
│   ├── home_screen.dart            # Tab-Navigation (Verbindung / Abfahrten)
│   ├── departures_screen.dart      # Abfahrtstafel mit Haltestellen-Picker
│   ├── station_search_screen.dart  # Haltestellensuche
│   └── journey_detail_screen.dart  # Verbindungsdetails
├── services/
│   └── transit_service.dart  # API-Schicht (DB REST API)
├── widgets/
│   ├── departure_tile.dart   # Einzelne Abfahrt
│   ├── journey_card.dart     # Verbindungskarte
│   └── line_badge.dart       # Linien-Badge (S, U, Tram, Bus, Regional)
└── main.dart
```

---

## Lokale Entwicklung

### Voraussetzungen
- Flutter SDK 3.x
- Dart SDK 3.0+
- Android Studio oder VS Code mit Flutter-Extension

### Installation

```bash
# Repository klonen
git clone https://github.com/alper42/FahrplanAuskunftVS.git
cd FahrplanAuskunftVS

# Dependencies installieren
flutter pub get

# App starten (Emulator oder echtes Gerät)
flutter run
```

### Build

```bash
# Android APK
flutter build apk

# iOS (nur auf macOS)
flutter build ios
```

---

## API

Die App nutzt die offene [DB REST API v6](https://v6.db.transport.rest) — keine Registrierung oder API-Key erforderlich.

| Endpoint | Verwendung |
|---|---|
| `GET /locations` | Haltestellensuche |
| `GET /journeys` | Verbindungssuche |
| `GET /stops/:id/departures` | Echtzeit-Abfahrten |

---

## Linien & Farben

| Typ | Farbe |
|---|---|
| S-Bahn | Grün `#00A650` |
| U-Bahn | Blau `#0057B8` (linienspezifisch) |
| Tram | Rot `#E2001A` |
| Bus | Orange `#FF6B00` |
| Regional | Grau `#6D6E70` |

---

## Autor

**Alper Caliskan**
- GitHub: [@alper42](https://github.com/alper42)
- Website: [alper42.github.io/portfolio](https://alper42.github.io/portfolio)
