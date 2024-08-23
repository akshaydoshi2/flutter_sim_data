import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sim_data/sim_data.dart';
import 'package:flutter_sim_data/sim_data_platform_interface.dart';
import 'package:flutter_sim_data/sim_data_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSimDataPlatform
    with MockPlatformInterfaceMixin
    implements SimDataPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> getSimData() {
    // TODO: implement getSimData
    throw UnimplementedError();
  }

  @override
  Future<bool?> sendSMS(
      {required String phoneNumber,
      required String message,
      required int subId}) {
    // TODO: implement sendSMS
    throw UnimplementedError();
  }
}

void main() {
  final SimDataPlatform initialPlatform = SimDataPlatform.instance;

  test('$MethodChannelSimData is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSimData>());
  });

  test('getPlatformVersion', () async {
    SimData simDataPlugin = SimData();
    MockSimDataPlatform fakePlatform = MockSimDataPlatform();
    SimDataPlatform.instance = fakePlatform;

    expect(await simDataPlugin.getPlatformVersion(), '42');
  });
}
