# flutter_sim_data

This Flutter plugin provides an API to
- **Android**: fetch SIM data (dual-SIM and eSIM aware) and send an SMS silently in the background from a chosen SIM.
- **iOS**: send an SMS via `MFMessageComposeViewController`, which lets the user review and send the message.

### SDK Compatibility
- Dart `>=3.4.4 <4.0.0`
- Flutter `>=3.3.0`
- Android >=22
- iOS >=12.0
- Android `compileSDK` 34

## Sending SMS: return value and error handling

`sendSMS` resolves with `true` when the send is committed, and throws a `PlatformException` with a documented `code` on cancellation, timeout, or failure. The contract is the same on both platforms; each reports what it is able to detect.

What `true` means differs by platform:
- **Android** — the message was handed to the telephony stack without throwing. This is *not* a delivery confirmation; the actual sent/delivered signal arrives asynchronously (see Roadmap).
- **iOS** — the user tapped **Send** in the compose sheet.

| Code | Platform | Meaning |
|------|----------|---------|
| returns `true` | both | Android: dispatched to telephony stack · iOS: user sent |
| `CANCELLED` | iOS | User dismissed the composer without sending |
| `TIMEOUT` | iOS | User did not send within `timeoutSeconds` |
| `SEND_FAILED` | both | The underlying send call failed |
| `UNAVAILABLE` | iOS | Device cannot send SMS (e.g. the iOS Simulator) |
| `IN_PROGRESS` | iOS | A compose sheet is already open |
| `INVALID_ARGS` | iOS | `phone` or `msg` was missing or not a string |
| `NO_VC` | iOS | No view controller was available to present from |
| `PERMISSION_DENIED` | Android | The `SEND_SMS` runtime permission was denied |

### Android

The plugin adds the `READ_PHONE_NUMBERS` and `READ_PHONE_STATE` permissions, and checks and requests them at runtime. Sending SMS is not something every app needs, so the `SEND_SMS` permission is **not** added to the manifest by the plugin — add it yourself if your app sends SMS:

```xml
<uses-permission android:name="android.permission.SEND_SMS" />
```

The SMS is sent silently in the background from the SIM identified by `subId`. The plugin also shows toast messages when the message is sent and delivered.

```dart
import 'package:flutter_sim_data/sim_data.dart';
import 'package:flutter_sim_data/sim_data_model.dart';

final _simData = SimData();
final List<SimDataModel> simData = await _simData.getSimData();

await _simData.sendSMS(
  phoneNumber: "+11234567890",
  message: "test message",
  subId: simData.first.subscriptionId,
);
```

### iOS

iOS does not allow apps to send SMS in the background, so the plugin presents `MFMessageComposeViewController` for the user to review and send the message. `sendSMS` can be called directly; `subId` is ignored on iOS, so any int works.

`timeoutSeconds` (iOS only) automatically closes the compose sheet and throws `TIMEOUT` if the user has not sent within that many seconds. Pass `0` (the default) to disable the timeout. Android ignores this parameter.

```dart
import 'package:flutter_sim_data/sim_data.dart';

await _simData.sendSMS(
  phoneNumber: "+11234567890",
  message: "test message",
  subId: 0,             // ignored on iOS
  timeoutSeconds: 30,   // optional; 0 disables the timeout
);
```

> On the iOS Simulator `canSendText()` is always `false`, so the call throws `UNAVAILABLE`. Test SMS sending on a real device.

### Handling the result

Because a failed, cancelled, or timed-out send throws rather than returning `false`, wrap the call in a `try`/`catch` and branch on `e.code`:

```dart
import 'package:flutter/services.dart';
import 'package:flutter_sim_data/sim_data.dart';

try {
  final ok = await SimData().sendSMS(
    phoneNumber: "+11234567890",
    message: "test message",
    subId: 0,
    timeoutSeconds: 30,
  );
  if (ok == true) {
    // Android: dispatched to telephony stack · iOS: user tapped Send
  }
} on PlatformException catch (e) {
  switch (e.code) {
    case 'CANCELLED':         // iOS: user dismissed the composer
    case 'TIMEOUT':           // iOS: no send within timeoutSeconds
    case 'SEND_FAILED':       // both: underlying send failed
    case 'UNAVAILABLE':       // iOS: device can't send (incl. simulator)
    case 'IN_PROGRESS':       // iOS: a composer is already open
    case 'INVALID_ARGS':      // iOS: bad phone/msg arguments
    case 'NO_VC':             // iOS: no presenter view controller
    case 'PERMISSION_DENIED': // Android: SEND_SMS permission denied
      // handle as needed
      break;
  }
}
```

See `example/lib/main.dart` for a runnable version that surfaces each outcome as a `SnackBar`.

### Roadmap
1. Implement an event channel to surface Android sent/delivered status from the broadcast receivers, so callers can await true delivery rather than just dispatch.