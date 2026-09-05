AGENTS.md
Instructions for agents working in this repo.

Stack
Flutter / Dart
BLoC (flutter_bloc) for state management
Drift for local persistence (tables, DAOs)
web3dart for EVM-compatible cryptographic signing
flutter_p2p_connection (v3+ API: FlutterP2pHost / FlutterP2pClient) for WiFi Direct sync
flutter_blue_plus / ble_peripheral for Bluetooth transport
Deep linking via the zplit:// custom scheme

Commands
flutter pub get
flutter run
flutter run -d <device-id>
dart format .
flutter analyze
flutter test
flutter build apk --release

Drift codegen (lib/data/):
dart run build_runner build --delete-conflicting-outputs

Layout
Path                        Role
lib/ui/                     Screens (onboarding, splash, home, friend detail)
lib/view_models/            BLoC/Cubit view models
lib/widgets/, lib/theme/    Shared UI, ThemeData-based theming
lib/domain/                 Abstract repository interfaces, domain layer
lib/data/                   Drift database, DAOs, repository implementations
lib/services/               BluetoothBloc/Bluetooth transport, deep link service, WiFi Direct sync
test/                       flutter_test

Folder pattern is ui / view_models / widgets. Do not add a lib/repositories/ layer outside lib/domain/.

HomeScreen / other screens
  → view_models (BLoC/Cubit)
  → domain repository interfaces
  → data (Drift) / services (Bluetooth, WiFi Direct, deep links)

Deep link flow: zplit://invite?d=... and transaction links → deep link service → Accept/Reject flow → signing (web3dart) → Drift.

Transport: scan-first, host-as-fallback heuristic (jitter + background re-scan glare correction), single active peer at a time. NFC is a handshake trigger only (via HCE) — it exchanges Bluetooth connection info, not raw NDEF payload transfer.

BLoC
Keep state management in BLoC/Cubit, not scattered setState calls.
Domain layer stays repository-interface based; do not let Drift or BLoC leak directly into domain.
Reuse the existing BluetoothBloc for all Bluetooth transport. Do not run host and client roles simultaneously in WiFi Direct.

Database
Drift is the schema source of truth — new schema = new table/DAO in lib/data/, not ad hoc SQL.
Use int64() for amount fields.
Keep foreign key pragmas and naming conventions consistent with existing tables.
Add unit tests for new DAOs alongside existing Drift test coverage.

Sync & Signing
Cryptographic signing goes through web3dart (EVM-compatible); ecRecover-based verification lives with the signing logic, not duplicated elsewhere.
QR code generation/scanning and deep links are the two invite/transaction entry points — keep parsing centralized rather than scattered across screens.
Do not route data transfer through NFC/NDEF.
Do not swap the P2P transport (flutter_p2p_connection) or signing library (web3dart) unless asked.

Tests
Only Drift DAO unit tests exist today.
flutter test
Add tests next to new logic.

Security
Never commit private keys, wallet secrets, or signing material
Never bypass signature verification (ecRecover) to ship a feature
Never hardcode peer addresses or transport secrets

Git
git checkout -b feature/<short-description>   # also fix/, docs/, refactor/
PRs target upstream/dev via cherry-pick.
Handle untracked .g.dart files with git stash -u before switching branches.
One feature per PR. Clear commit messages. Run flutter analyze and flutter test before opening.

Do not
Run WiFi Direct host and client roles simultaneously
Route data transfer through NFC/NDEF
Bypass the domain layer's repository interfaces
Hardcode theme colors/styles outside ThemeData
Commit generated .g.dart files without checking they're current
Refactor unrelated code in a scoped change