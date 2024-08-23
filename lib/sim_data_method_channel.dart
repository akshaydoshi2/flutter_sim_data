import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sim_data_platform_interface.dart';

/// An implementation of [SimDataPlatform] that uses method channels.
class MethodChannelSimData extends SimDataPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sim_data');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> getSimData() async {
    final version = await methodChannel.invokeMethod<String>('get_sim_data');
    return version;
  }

  @override
  Future<bool?> sendSMS(
      {required String phoneNumber,
      required String message,
      required int subId}) async {
    return await methodChannel.invokeMethod<bool?>(
        'send_sms', <String, dynamic>{
      "phone": phoneNumber,
      "msg": message,
      "subId": subId
    });
  }
}
