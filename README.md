# SeismoAlert 🌍

**SeismoAlert** is a Flutter mobile application for real-time earthquake monitoring, built as a complete end-to-end project covering live feed, interactive map, offline caching, historical data, emergency contacts, and local push notifications.

---

## 📱 Features

| Module | Description |
|---|---|
| **Live Feed** | Fetches recent earthquakes near a selected region from the USGS API, with magnitude filter (All / M2.5+ / M4.0+ / M5.5+ / M7.0+) and pull-to-refresh |
| **Interactive Map** | flutter_map powered OpenStreetMap view with magnitude-scaled, color-coded markers; tap a marker for a quick summary sheet |
| **Quake Detail** | Full detail page per earthquake (magnitude, depth, location, time, USGS link) with automatic aftershock detection in a 7-day / 200 km window |
| **On This Day** | Historical lookup showing earthquakes that occurred on today's calendar date in each of the past 10 years, grouped by year in collapsible tiles |
| **Emergency Contacts** | Save/edit/delete contacts with name, phone, and relation; one-tap call (`tel:`) and pre-filled SMS (`sms:`) shortcuts; swipe-to-delete with undo |
| **Local Notifications** | `flutter_local_notifications` fires a device alert for any **newly fetched** quake whose magnitude meets or exceeds a configurable threshold |
| **Settings** | Region selection (Islamabad, Karachi, Lahore, Peshawar, Quetta), notification magnitude threshold slider (M2.5–M7.0), all persisted via Hive |
| **Offline Mode** | All fetched quakes are cached in Hive; the app loads cached data automatically when offline and shows an OfflineBanner across all relevant screens |

---

## 🛠 Tech Stack

| Technology | Role |
|---|---|
| **Flutter** | Cross-platform UI framework |
| **Provider** | State management (ChangeNotifier pattern) |
| **USGS Earthquake Hazards API** | Live seismic data source (GeoJSON, free & open) |
| **Hive / hive_flutter** | Fast local key-value persistence for offline caching & settings |
| **flutter_map** | Interactive map widget powered by OpenStreetMap tiles |
| **flutter_local_notifications** | Trigger device-level push notifications for significant quakes |
| **connectivity_plus** | Detect online/offline state at runtime |
| **url_launcher** | Launch `tel:` and `sms:` URIs for emergency contact actions |
| **intl** | Date/time formatting |

---

## ⚙️ How Offline Caching Works

1. On each successful USGS API call, `QuakeProvider` clears and re-writes the `quake_cache` Hive box with the latest list of `Quake` objects (serialised via `QuakeAdapter`).
2. Emergency contacts are stored in the `emergency_contacts` Hive box (keyed by contact ID).
3. "On This Day" results are cached in the `history_cache` box under the key `yyyy-MM-dd` (today's date), preventing redundant API calls within the same day.
4. Settings (alert threshold, selected region lat/lon) are also persisted in `history_cache` under fixed keys so they survive app restarts.
5. If `connectivity_plus` reports no connection, all providers fall back to their Hive boxes and the OfflineBanner is displayed.

---

## 🚀 How to Run

### Prerequisites
- Flutter SDK ≥ 3.12 (`flutter --version`)
- A connected Android device or emulator

### Steps

```bash
# 1. Clone the repo
git clone <repo-url>
cd seismoalert

# 2. Fetch dependencies
flutter pub get

# 3. Run on a connected device / emulator
flutter run

# 4. (Optional) Build a debug APK
flutter build apk --debug
```

> **Note:** The app fetches live data from `https://earthquake.usgs.gov`. Ensure the device has internet access on first launch to populate the cache.

---

## 📂 Project Structure

```
lib/
├── main.dart                      # Entry point, Hive init, Provider setup
├── models/
│   ├── quake.dart                 # Quake model + Hive adapter
│   └── emergency_contact.dart     # EmergencyContact model + Hive adapter
├── providers/
│   ├── quake_provider.dart        # Live feed, filtering, notifications
│   ├── aftershock_provider.dart   # Aftershock detection
│   ├── history_provider.dart      # On This Day historical lookup
│   └── contacts_provider.dart     # Emergency contacts CRUD
├── screens/
│   ├── main_navigation_screen.dart
│   ├── home_feed_screen.dart
│   ├── map_screen.dart
│   ├── quake_detail_screen.dart
│   ├── on_this_day_screen.dart
│   ├── contacts_screen.dart       # EmergencyContactsScreen
│   └── settings_screen.dart
├── services/
│   ├── usgs_service.dart          # HTTP calls to USGS FDSNWS API
│   └── notification_service.dart  # Local push notification wrapper
└── widgets/
    ├── quake_card.dart
    ├── magnitude_badge.dart
    └── offline_banner.dart
```

---

## ⚠️ Known Limitations & TODOs

- **No background fetch**: Notifications only fire when the app is open and `QuakeProvider.fetchQuakes()` is called (pull-to-refresh or region change). Background periodic polling would require a platform plugin (e.g., `workmanager`).
- **iOS notification permissions**: On iOS the user must explicitly grant notification permissions; the app handles this via `DarwinInitializationSettings` but does not proactively prompt at startup.
- **Map tiles offline**: OpenStreetMap tiles are not cached locally; the map background will not render when offline (markers from cached data will still plot correctly once tiles are fetched at least once).
- **Hive box for settings reuses `history_cache`**: In a future version this should be separated into a dedicated `settings` box for clarity.
- **No pagination**: The USGS query is capped at 50 results (`limit=50`). Infinite scroll / pagination is a future enhancement.
