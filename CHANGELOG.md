## Unreleased

### Breaking changes

- Replace the Dart HTTP transport with the OpenPanel Kotlin and Swift SDKs.
  Only Android and iOS are supported; Windows, macOS and Linux support is removed.
- Require Dart 3.13 or newer and Flutter 3.47 or newer.

### Added

- Add `track`, `identify`, `alias`, `flush` and `ready` APIs. Keep `event` and
  `updateProfile` as compatibility aliases.
- Add `disabled`, `automaticTracking` and `waitForProfile` options. Add `apiUrl`
  as the preferred name for the deprecated `url` option.
- Persist whether a profile was explicitly identified. With `waitForProfile`,
  anonymous events wait for `identify`, `setProfileId` or `ready`. Older saved
  states without identification metadata are treated as anonymous.
- Include the native SDK sources, licenses and revision notes in the package,
  with SwiftPM integration on iOS. Git installations require no submodule setup.
- Add Android and iOS integration tests that verify requests against a local
  HTTP server.

### Fixed

- Preserve profile state, global properties and lifecycle subscriptions when
  toggling event collection.
- Forward `flush` and `ready` to the Kotlin SDK so queued events can be sent.
- Preserve boolean values, including nested properties, when encoding iOS
  events and profiles.
- Fix Swift SDK identification requests containing profile and global properties.
- Restore iOS app version, build number and device properties, including after
  clearing the current profile.
- Update the Android build configuration and CI Flutter version to match the
  minimum supported toolchain.

## 0.3.0
- **Breaking**: Migrate to new OpenPanel tracking API
  - All API calls now use the unified `/track` endpoint
  - Event tracking uses `type: "track"`
  - User identification uses `type: "identify"`
  - Increment/decrement use `type: "increment"` and `type: "decrement"`
- Add desktop platform support (Windows, macOS, Linux)
  - Referrer tracking is gracefully disabled on non-mobile platforms
- See [API documentation](https://openpanel.dev/docs/api/track) for details

## 0.2.1
- Update documentation
- Upgrade dependencies

## 0.2.0
- Update package version
- Add sdk name to headers

## 0.0.6
- Add back referrer tracking

## 0.0.5
- Replace User Agent lib with another one that supports all platforms
- Remove lifecycle events tracking (for now)
- Update README

## 0.0.4
Add:
- Referrer url for Android & iOS
- User agent headers are now properly sent
- App lifecycle events are automatically handled now

## 0.0.3
- Remove mason_logger

## 0.0.2
- Update readme

## 0.0.1

Initial version:
- Client initialisation
- Events logging
