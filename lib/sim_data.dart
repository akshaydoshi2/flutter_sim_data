
import 'dart:convert';

import 'package:sim_data/sim_data_model.dart';

import 'sim_data_platform_interface.dart';

class SimData {
  Future<String?> getPlatformVersion() {
    return SimDataPlatform.instance.getPlatformVersion();
  }

  Future<List<SimDataModel>> getSimData() async{
    final res = await SimDataPlatform.instance.getSimData();
    if(res != null){
      try{
        return jsonDecode(res).map<SimDataModel>((e) {
          return SimDataModel.fromJson(e);
        }).toList();
      }catch(e,s){
        throw Exception(e);
      }
    }else{
      return <SimDataModel>[];
    }
  }

  Future<String?> getRawSimData()async{
    return await SimDataPlatform.instance.getSimData();
  }

  Future<bool?> sendSMS({required String phoneNumber, required String message, required int subId})async{
    return await SimDataPlatform.instance.sendSMS(
      phoneNumber: phoneNumber,
      message: message,
      subId: subId
    );
  }
}
