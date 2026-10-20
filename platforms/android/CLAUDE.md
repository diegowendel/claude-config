@~/Workspace/claude-config/mobile/CLAUDE.md

# Android — rules for every app in `~/Workspace/android-projects`

> Source: `claude-config/platforms/android/CLAUDE.md` (symlinked here). App-specific details and deviations go in each repo's `CLAUDE.md`.

The baseline is the **calcly / koin setup**. Older apps (led-banner, unseen) deviate in places; their `CLAUDE.md` lists how.

## Repo layout

```
<app>/
├── mobile/        # Gradle root, :app module
├── firebase/      # Hosting (legal pages) and, if needed, functions/
├── tools/         # l10n generators, screenshot capture/compose, icon/feature graphic
└── docs/          # ASO.md, RELEASING.md, fastlane.md, plans
```

## Language and toolchain

- **Kotlin only** — no Java sources. Idiomatic Kotlin: extension functions, data/sealed classes, scope functions.
- Java 21 target. Kotlin code style `official`.
- **Versions come from `mobile/gradle/libs.versions.toml` and `gradle.properties` — never pin them in docs.** (For orientation: calcly/koin are on compile/target SDK 37, minSdk 24, AGP 9.4, Kotlin 2.4.)

## Architecture

- **MVVM with LiveData.** `MutableLiveData` private in the ViewModel, exposed as `LiveData`; `MediatorLiveData` to combine sources; `SingleLiveEvent` for one-time events (navigation, toasts).
- Fragments observe with `viewLifecycleOwner`.
- **Repository pattern** — ViewModels never touch data sources directly. Local (Room) and remote data sources sit behind the repository; mappers convert DTOs ↔ entities.
- **Offline-first** when the app has data: Room is the source of truth, UI observes local data, network refreshes the cache; track offline state in the ViewModel and refresh on reconnect.
- `Result<T>` for success/failure in repositories and data sources. `viewModelScope.launch` + `Dispatchers.IO` for background work.
- **No DI framework** — manual singletons (`companion object` + `getInstance()` with `@Volatile`/`synchronized`) and `ViewModelFactory` classes.
- Package by layer: `constants/`, `exception/`, `extensions/` (`<Type>Extensions.kt`), `integration/` (Firebase), `model/data/{local,mapper,network,repository}`, `utils/`, `view/{activity,adapter,dialog,fragment,component}`, `viewmodel/{activity,data,factory,fragment}`, `MainApplication.kt`.

## UI

- **XML layouts + ViewBinding** (`viewBinding = true`). No Data Binding, no Compose.
- Material Design 3. `ConstraintLayout` first; `LinearLayout` only for simple linear arrangements. Custom views in `view/component/`.
- Every image has a `contentDescription` from `strings.xml`. No hardcoded strings in layouts.
- Dark theme resources in `values-night/`.

## Navigation

- Jetpack Navigation + Safe Args, single `MainActivity` hosting a `NavHostFragment`.
- Navigate with `safeNavigate()` (androidcommons) to avoid double-tap crashes.
- Slide transitions: `slide_in_right`, `slide_out_left`, `slide_in_left`, `slide_out_right`.

## Build

- **Gradle Groovy DSL** (`.gradle`, never `.kts`). **Version catalog** for every dependency — no hardcoded versions.
- `gradle.properties` holds the custom keys: `androidApplicationId`, `androidMinimumSdkVersion`, `androidTargetSdkVersion`, `androidCompileSdkVersion`, `androidVersionCode`, `androidVersionName`, `keystorePropertiesFilename`.
- Repositories: `google()`, `mavenCentral()`, `mavenLocal()`, jitpack; `FAIL_ON_PROJECT_REPOS`. `android.nonTransitiveRClass=true`.
- Build types: `debug` (test ad IDs via `resValue`, analytics/crashlytics/perf collection off via manifest placeholders) and `release` (R8 minify + resource shrink, Crashlytics mapping upload).
- Signing via `mobile/keystore.properties` + keystore, both **outside git**.

## androidcommons (shared library)

- `com.appcraftlabs:androidcommons`, source in `~/Workspace/android-projects/android-commons`.
- Debug builds use `androidcommons-debug`, release builds `androidcommons`. Both must be in Maven Local: `cd android-commons && ./gradle-publish-local.sh`.
- Base classes: `BaseMainActivity`, `BaseViewModelFragment`, `BaseSimpleFragment`, `BaseDialog`, `BaseBottomSheetDialog`, `BasePreferences`. Firebase wrappers: `FirebaseViewModel`, `FirebaseRepository`, `FirebaseRemoteDataSource`, `FirebaseServerFunctions`. Utils: `ToastUtil`, `ShareUtil`, `VibrationUtil`, `BrowserUtil`, `PermissionUtil`, `AlertDialogUtil`, `InAppReview`.
- Preferences wrappers are Kotlin `object`s on `BasePreferences`.

## Firebase

- Firebase BoM. Analytics, Crashlytics, Performance in every app; Functions/Messaging only where used.
- Implement the androidcommons `FirebaseAnalyticsIntegration` / `FirebaseCrashlyticsIntegration` / `FirebaseMessagingIntegration`, accessed via `MainApplication.analytics` / `.crashlytics` / `.messaging`.
- Analytics event names in `constants/AnalyticsEvents.kt`.
- Privacy policy URL in the string `app_privacy_policy_url` (`https://<project>.web.app`).

## Room

- KSP compiler. Export schemas to `app/schemas/`.
- Explicit `Migration` objects — **never** `fallbackToDestructiveMigration`. Migration tests with Room Testing.
- Gson for JSON (DTOs, `@TypeConverter`s).

## Localization (Android specifics)

- `res/values*/strings.xml` for all 15 locales (folder names in `~/.claude/rules/localization.md`; Indonesian is `values-in`).
- `translatable="false"` for non-translatable strings. `res/resources.properties` + `generateLocaleConfig`.
- Lint treats `MissingTranslation`, `ExtraTranslation`, `StringFormatMatches` as errors; `StringResourcesTest` guards formats.

## Testing

- JUnit 4 unit tests in `src/test/java/`, Espresso in `src/androidTest/java/`, Room Testing for migrations.
- **Kover** coverage gate (task name per app, see its `CLAUDE.md`).
- Before saying done: `./gradlew testDebugUnitTest lintDebug` (from `mobile/`), plus the app's coverage task when logic changed.

## Release

- **Local fastlane only — no CI by design.** `cd mobile && bundle exec fastlane deploy` (preflight → tests → version → signed bundle → upload → archive → `release: vX.Y.Z (code)` commit + tag).
- Play service-account key at `~/.config/playstore/<app>.json`, exported as `PLAY_STORE_JSON_KEY_PATH`.
- Other lanes: `promote`, `rollout`, `metadata`, `validate`, `screenshots`, `release_log`. See the app's `docs/RELEASING.md`.

## Don't

- Jetpack Compose, Hilt/Dagger/Koin (DI), Retrofit, Kotlin DSL Gradle files.
- Hardcoded dependency versions, `fallbackToDestructiveMigration`.
- Java source files.
