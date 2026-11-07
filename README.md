# Zakat Calculator (Flutter)

This app provides a Flutter Zakat workflow with:

- Three screens: Nisab, Assets, and Review
- Silver-based and Gold-based visual standard selector
- Manual PKR Nisab amount, valuation date, and optional source
- PKR asset and liability fields with two-decimal input validation
- Hijri-year checkbox state
- Review edit links, back navigation, finish acknowledgement, and reset
- Pure Dart calculation service for net zakatable wealth and Zakat due
- Shared emerald/ivory theme and reusable layout widgets
- A separate Dart/Shelf backend in `backend/` for authentication, PKR
  calculations, and the optional Gemini assistant proxy

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter test
```

## Main Files

- `lib/main.dart`: app entry point
- `lib/app_theme.dart`: centralized colors, spacing, icons, and Material theme
- `lib/app_widgets.dart`: shared header, step title, and action widgets
- `lib/zakat_calculator_screen.dart`: three-step workflow UI
- `test/widget_test.dart`: workflow and validation tests

The calculation domain is implemented in
`lib/zakat_calculation_service.dart`. It accepts the current PKR form values
and returns a typed result without requiring a network or database. The review
screen uses this service to display net wealth, nisab, eligibility, and Zakat
due.

Backend setup and API payloads are documented in
[`backend/README.md`](backend/README.md). The mobile UI remains usable offline;
the Gemini key must stay on the backend and must never be shipped in the app.
