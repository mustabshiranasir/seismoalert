# SeismoAlert

A Flutter application for real-time earthquake monitoring, built for Pakistan and surrounding regions using the USGS Earthquake Hazards API.

---

## Features

- **Live Feed** — Recent earthquakes fetched from USGS, filterable by magnitude, with pull-to-refresh
- **Interactive Map** — OpenStreetMap view with magnitude-scaled, color-coded markers and a quick-detail bottom sheet
- **Quake Detail** — Full earthquake info with automatic aftershock detection (7-day / 200 km window)
- **On This Day** — Historical earthquakes on today's date across the past 10 years, grouped by year
- **Emergency Contacts** — Save contacts with one-tap call and pre-filled SMS shortcuts; swipe to delete with undo
- **Push Notifications** — Local alert when a newly fetched quake meets or exceeds a configurable magnitude threshold
- **Settings** — Switch between 5 Pakistani city regions; adjust notification threshold (M2.5–M7.0); all settings persisted
- **Offline Mode** — Cached data loads automatically when offline; an offline banner is shown across all screens

---

## Tech Stack

| Package | Purpose |
|---|---|
| `provider` | State management (ChangeNotifier) |
| `hive` / `hive_flutter` | Local persistence & offline caching |
| `flutter_map` | Interactive map with OpenStreetMap tiles |
| `flutter_local_notifications` | Device push notifications |
| `connectivity_plus` | Online/offline detection |
| `url_launcher` | `tel:` and `sms:` deep links |
| `http` | USGS REST API calls |
| `intl` | Date/time formatting |

Data source: [USGS Earthquake Hazards Program](https://earthquake.usgs.gov/fdsnws/event/1/)

---

## Getting Started

```bash
git clone <repo-url>
cd seismoalert
flutter pub get
flutter run
```

To build a debug APK:
```bash
flutter build apk --debug
```

> Requires Flutter SDK ≥ 3.12 and a connected Android device or emulator.

---

## Project Structure

```
lib/
├── main.dart
├── models/          # Quake, EmergencyContact (with Hive adapters)
├── providers/       # QuakeProvider, AftershockProvider, HistoryProvider, ContactsProvider
├── screens/         # HomeFeed, Map, QuakeDetail, OnThisDay, Contacts, Settings
├── services/        # UsgsService, NotificationService
└── widgets/         # QuakeCard, MagnitudeBadge, OfflineBanner
```

---

## How Offline Caching Works

On every successful API call, fetched quakes are written to a Hive box (`quake_cache`). "On This Day" results are cached per calendar date. Settings (region, alert threshold) are also persisted in Hive. When connectivity is unavailable, all providers fall back to their cached data automatically.

---

## Known Limitations

- Notifications only fire while the app is open (no background fetch)
- OpenStreetMap tiles are not cached; the map background requires connectivity
- Results are capped at 50 earthquakes per query (no pagination)
