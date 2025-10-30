# Game Tracker (Flutter)

En simpel, offline-first Flutter app til at holde styr på dine spil.

## Krav
- Flutter 3.x
- iOS/Android emulator eller fysisk enhed

## Kom i gang
```bash
flutter pub get
flutter run
```

## Tech
- State management: flutter_riverpod
- Navigation: go_router
- DB: sqflite (SQLite) + path_provider

## Struktur
```
lib/
  app_router.dart
  main.dart
  data/
    db.dart
    game_dao.dart
  models/
    enums.dart
    game.dart
  providers.dart
  screens/
    home_screen.dart
    edit_game_screen.dart
  widgets/
    game_card.dart
```

## Næste skridt
- Eksport/Import (JSON)
- Statistikskærm (games pr. år, gennemsnitlig rating)
- Cover-billeder via IGDB/RAWG
- Platform-lister og tags (separeret tabel)
- Tests
```
