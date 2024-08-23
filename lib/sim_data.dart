import 'dart:convert';

import 'package:flutter_sim_data/sim_data_model.dart';

import 'sim_data_platform_interface.dart';

/// SIM Data Plugin
/// Author: Akshay Doshi
class SimData {
  ///Boiler-plate code
  Future<String?> getPlatformVersion() {
    return SimDataPlatform.instance.getPlatformVersion();
  }

  ///Supported only for Android!
  ///Fetches the SIM data and returns [List<SimDataModel>]
  Future<List<SimDataModel>> getSimData() async {
    final res = await SimDataPlatform.instance.getSimData();
    if (res != null) {
      try {
        return jsonDecode(res).map<SimDataModel>((e) {
          return SimDataModel.fromJson(e);
        }).toList();
      } catch (e) {
        throw Exception(e);
      }
    } else {
      return <SimDataModel>[];
    }
  }

  ///Supported only for Android!
  ///Fetches the SIM data and returns raw unstructured JSON SIM data
  Future<String?> getRawSimData() async {
    return await SimDataPlatform.instance.getSimData();
  }

  ///Supported for both android and iOS
  ///This requires the SEND_SMS permissions for android.
  ///SMS is sent in the background for android and for iOS the plugin uses `MFMessageComposeViewController`
  Future<bool?> sendSMS(
      {required String phoneNumber,
      required String message,
      required int subId}) async {
    return await SimDataPlatform.instance
        .sendSMS(phoneNumber: phoneNumber, message: message, subId: subId);
  }
}
