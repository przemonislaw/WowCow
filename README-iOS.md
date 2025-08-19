# FunFacts iOS — pełny starter (SwiftUI)

## Jak uruchomić
1. Otwórz Xcode → **File > New > Project > App** (SwiftUI/Swift). Nazwa np. `FunFacts`, Bundle ID np. `com.your.FunFacts`.
2. Dodaj do projektu WSZYSTKIE pliki z tego folderu (`FunFactsApp.swift`, `AppDelegate.swift`, `Config.swift`, `Models/*`, `Services/*`, `Views/*`, `Persistence/*`).
3. W `Signing & Capabilities` wybierz **Personal Team** (Twoje darmowe Apple ID).
4. Uruchom na iPhonie lub Simulatorze.
5. Na ekranie głównym kliknij **„Wyślij testową notyfikację za 10 s”** i zminimalizuj appkę – powinna przyjść notyfikacja.

## Tryby
- `AppConfig.transport = .local` – lokalne notyfikacje (działa od razu).
- `AppConfig.transport = .remote` – prawdziwe push (po włączeniu APNs i backendzie AWS).

## Symulacja APNs w Simulatorze
Utwórz `sample.apns`:
```json
{
  "aps": { "alert": { "title": "Ciekawostka", "body": "Ośmiornice mają trzy serca." }, "sound": "default" },
  "factId": "demo-1"
}
```
Wyślij:
```
xcrun simctl push booted com.your.FunFacts sample.apns
```