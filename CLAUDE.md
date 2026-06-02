# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Code generation — run after adding new @JsonSerializable annotations or changing DI
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
flutter pub run build_runner watch --delete-conflicting-outputs

# Build for Android
flutter build apk --release

# Analyze code
flutter analyze
```

## Architecture

Clean Architecture with feature-based organization. Each feature lives under `lib/features/` with three layers:

- **Domain**: Entities, abstract repositories, use cases (pure Dart — no Flutter or Firebase imports)
- **Data**: Models (extend domain entities, add Firestore/JSON parsing), datasource implementations, repository implementations
- **Presentation**: BLoC (event/state/bloc files), pages, widgets

### Feature list

`auth`, `auctions`, `admin`, `bidding`, `my_auctions`, `tickets`, `notifications`, `payment`, `profile`, `search`, `scratch_card`

### Shared code

`lib/core/` contains:
- `network/` — `WebSocketClient` (placeholder URL; live bidding actually goes through Firestore transactions)
- `errors/` — `AppException` hierarchy (`ServerException`, `NetworkException`, `CacheException`, `DatabaseException`, `AuthException`, `BidException`, `PaymentException`, `ValidationException`) and `Failure` types used with `dartz` Either
- `usecases/` — Base `UseCase<Type, Params>` abstract class
- `constants/`, `utils/`, `widgets/` — App-wide shared resources

### Data models

Models extend their domain entities directly (no separate mapping). They add `fromFirestore(DocumentSnapshot)` and `fromJson`/`toJson`. Do **not** add `@JsonSerializable` to domain entities — keep serialization in the data layer only.

### Dependency Injection

Manual `get_it` registration in `lib/injection_container.dart` (the `sl` variable). Despite `injectable` being in `pubspec.yaml`, **no `@injectable` annotations are used** — all registrations are written by hand in `init()`. Rules:
- Singletons (`registerLazySingleton`) for repositories, datasources, use cases, and `AuthBloc`
- Factories (`registerFactory`) for all other BLoCs that need a fresh instance per page
- Admin BLoCs are **not registered in `sl`** — they are provided locally via the `AdminProviders` widget

### State Management

Flutter BLoC pattern throughout. All BLoC states extend `Equatable`. `AuthBloc` is a lazySingleton so both the router and the widget tree share the same instance.

### Routing

`go_router` in `lib/app/app_router.dart`. Key points:
- **Web build** (`kIsWeb`) is admin-only — all non-`/admin` paths redirect to `/admin/login`
- **Mobile build** is user-facing with bottom-nav shell (`ShellScaffold`)
- Admin routes are wrapped in a `ShellRoute` that provides `AdminProviders`; user routes that overlay the bottom nav use `parentNavigatorKey: _rootNavigatorKey`
- Admin role is checked against the `admins/{uid}` Firestore collection (not `users/{uid}.role`) — users cannot self-escalate. Results are cached for 5 minutes and cleared on auth state change.
- Route constants and path helpers are in `lib/app/app_routes.dart`. Use `AppRoutes.*Path(id)` for parameterized routes (e.g., `AppRoutes.auctionDetailPath(id)`), never string interpolation.
- `paymentSuccess` must appear before `payment` in the route list — `'success'` would otherwise be captured as `:orderId`

### Error Handling Pattern

Datasources throw typed `AppException` subclasses. Repositories catch them and return `Either<Failure, T>` (dartz). BLoCs call use cases, fold the Either, and emit error states on Left.

### Backend & Real-time

- **Firebase Auth** — authentication
- **Firestore** — auction/bid data with real-time streams. Requires two composite indexes: `auctions(status ASC, endsAt ASC)` and `auctions(status ASC, category ASC, endsAt ASC)` for pagination to work.
- **Firebase Storage** — images
- **FCM** — push notifications via `NotificationService`
- **Mollie** — payment via WebView (`webview_flutter`). Stripe (`flutter_stripe`) is present but not yet active.
- **WebSocket** — `WebSocketClient` exists but the URL is a placeholder; current bid submission goes through a Firestore transaction in `AuctionRemoteDatasourceImpl.placeBid`

### Firestore collections

| Collection | Purpose |
|---|---|
| `auctions/{id}` | Auction docs; sub-collection `bids/` |
| `users/{uid}` | User profiles; `watchlist` and `alarms` arrays |
| `admins/{uid}` | Admin role docs (`role: 'admin' \| 'super_admin'`); write-protected to super_admin |

Pagination uses a cursor map keyed by `"category_query"` inside `AuctionRemoteDatasourceImpl`; page size is 20. Client-side text filtering is applied after Firestore results because Firestore doesn't support full-text search.

### Admin panel

`AdminProviders` widget (defined in `lib/features/admin/admin_routes.dart`) provides all admin datasources and `AdminAuthBloc` via `MultiRepositoryProvider`/`MultiBlocProvider`. It wraps every admin route in the router. Admin datasources directly call Firestore without going through the domain layer — they live in `lib/features/admin/data/datasources/`.

### Internationalization

Dutch (`nl`), English (`en`), Arabic (`ar`, RTL). Locale managed by `LocaleBloc` stored in `SharedPreferences`. Arabic triggers `TextDirection.rtl` via a `Directionality` wrapper in `app.dart`. Text scale is clamped to `[0.85, 1.15]` globally.
