import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sim_data_method_channel.dart';

/// SIM Data Plugin
/// Author: Akshay Doshi
abstract class SimDataPlatform extends PlatformInterface {
  /// Constructs a SimDataPlatform.
  SimDataPlatform() : super(token: _token);

  static final Object _token = Object();

  static SimDataPlatform _instance = MethodChannelSimData();

  /// The default instance of [SimDataPlatform] to use.
  ///
  /// Defaults to [MethodChannelSimData].
  static SimDataPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SimDataPlatform] when
  /// they register themselves.
  static set instance(SimDataPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Boiler-plate code
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  ///Supported only for Android!
  ///Fetches the SIM data and returns [List<SimDataModel>]
  Future<String?> getSimData() {
    throw UnimplementedError('getSimData() has not been implemented.');
  }

  ///Supported for both android and iOS
  ///This requires the SEND_SMS permissions for android.
  ///SMS is sent in the background for android and for iOS the plugin uses `MFMessageComposeViewController`
  Future<bool?> sendSMS(
      {required String phoneNumber,
      required String message,
      required int subId}) {
    throw UnimplementedError('sendSMS() has not been implemented.');
  }
}
