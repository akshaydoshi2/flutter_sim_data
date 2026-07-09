## 2.0.1-dev.1

- Bug fixes

## 2.0.0-dev.1

- **Breaking:** `sendSMS` now returns `true` on success and throws a `PlatformException` (with documented error codes) on cancel/timeout/failure; adds an iOS-only `timeoutSeconds`; fixes iOS present-self crash and hanging `Future`s on both platforms

## 1.0.5

- Fixed crash issue for Android 14. See [#1](https://github.com/akshaydoshi2/flutter_sim_data/issues/1)

## 1.0.4

- Fixed an issue with ios podspec

## 1.0.3

- Model changes

## 1.0.2

- Fixed an issue where accepting permissions crashed the app

## 1.0.1

- Formatting changes

## 1.0.0

- Initial release