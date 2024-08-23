# flutter_sim_data

This Flutter plugin provides API to 
- Android: Fetch SIM data to send SMS with dual sim and eSIM support.
- iOS: Send SMS using `MFMessageComposeViewController` for iOS

### SDK Compatibility
- Dart '>=3.4.4 <4.0.0'
- Flutter '>=3.3.0'
- Android >=22
- iOS >=12.0
- Android `compileSDK` 34

### Android
The plugin adds the `READ_PHONE_NUMBERS` and `READ_PHONE_STATE` permissions and checks and requests those permissions.
Since sending SMS is not what every app might need, the `SEND_SMS` permission is not added to the manifest file by the plugin.

Make sure to add the `SEND_SMS` permission to the manifest file if the app need to send SMS.

The plugin notifies when the SMS is sent and delivered respectively via toast messages.
```dart
import 'package:sim_data/sim_data.dart';
import 'package:sim_data/sim_data_model.dart';

final _simData = SimData();
final List<SimDataModel> simData = await _simData.getSimData()

_simDataPlugin.sendSMS(
    phoneNumber: "+11234567890",
    message: "test message",
    subId: simData.first.subscriptionId
);
```

### iOS
Since iOS does not support sending a SMS in the background without user interaction, the plugin uses `MFMessageComposeViewController` to lets the user compose and send SMS.
The `sendSMS` method can be called directly and since `subId` parameter is not used for iOS, it can be any int.

```dart
import 'package:sim_data/sim_data.dart';

_simDataPlugin.sendSMS(
    phoneNumber: "+11234567890",
    message: "test message",
    subId: 0
);
```

