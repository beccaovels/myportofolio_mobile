/// Base URL of the Django REST Framework backend (no trailing slash).
///
/// Defaults to `http://10.0.2.2:8000`, which is the host PC as seen from
/// inside the Android emulator. Override it per target with `--dart-define`:
///
/// - Chrome / Flutter Web: `--dart-define=API_BASE_URL=http://localhost:8000`
/// - Deployed backend:
///   `--dart-define=API_BASE_URL=https://rebecca-love-myportofolio.pws.cs.ui.ac.id`
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
