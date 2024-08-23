import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sim_data_method_channel.dart';

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getSimData() {
    throw UnimplementedError('getSimData() has not been implemented.');
  }

  Future<bool?> sendSMS(
      {required String phoneNumber,
      required String message,
      required int subId}) {
    throw UnimplementedError('sendSMS() has not been implemented.');
  }
}
