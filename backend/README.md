# Zakat Calculator API

This is the Dart/Shelf backend for the Flutter mobile app. It provides:

- `POST /api/auth/register` and `POST /api/auth/login` with bcrypt passwords and JWTs
- `GET /api/me` for validating a logged-in session
- `POST /api/calculate` for PKR Zakat calculation
- `POST /api/assistant` as a server-side Gemini proxy
- `GET /health` for deployment checks

## Local setup

1. Create a PostgreSQL database named `zakat`.
2. Run `schema.sql` against that database.
3. Copy `.env.example` to `.env` and set `DATABASE_URL` and a long `JWT_SECRET`.
4. Run:

```bash
dart pub get
dart run bin/server.dart
```

The Gemini endpoint is optional. Set `GEMINI_API_KEY` only in `.env`; never put
the key in the mobile app. All money values are PKR. The client must send the user's Zakat rate as
`zakatRate` (a percentage, for example `2.5`) when the net amount reaches the
entered Nisab; Nisab itself remains a PKR threshold based on the selected
Silver or Gold standard.

Example calculation payload:

```json
{
  "nisabAmount": 500000,
  "standard": "silver",
  "valuationDate": "2026-10-31",
  "cash": 100000,
  "bankBalance": 450000,
  "otherAssets": 0,
  "liabilities": 50000,
  "oneHijriYear": true
}
```
