# Field Log Mobile Application

Flutter mobile prototype for wildlife rangers who record sightings in low-connectivity field conditions, with a small Node.js API for end-of-shift sync.

## What is included

- Offline-first field log queue in the Flutter app.
- Sighting form for species, GPS coordinates, animal count, photo file names, and notes.
- Pending, synced, and retry states for each log.
- Online/offline toggle to simulate unreliable connectivity.
- Sync action that posts pending logs to a Node.js API.
- Dependency-free Node.js API with health, list, and sync endpoints.

## Run the API

```bash
cd api
npm start
```

The API runs at `http://localhost:3000`.

Available endpoints:

- `GET /health`
- `GET /api/logs`
- `POST /api/logs/sync`

## Run the Flutter app

```bash
flutter pub get
flutter run
```

For Android emulator builds, the app posts to `10.0.2.2:3000`. For desktop and iOS simulator builds, it posts to `localhost:3000`.

## Test

```bash
flutter test
```

## Notes

The current build keeps logs in memory to demonstrate the assessment workflow without extra dependencies. A production pass would add durable local storage, real GPS capture, image picker integration, authentication, and retry/backoff sync.
