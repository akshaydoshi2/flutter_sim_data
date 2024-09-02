/// SIM Data Plugin
/// Author: Akshay Doshi
class SimDataModel {
  /// SIM card carrier name
  final String carrierName;

  /// if the detected SIM card is an eSIM
  final bool isESIM;

  /// Subscription ID of the SIM card
  final int subscriptionId;

  /// Sim slot index of the SIM card. 0 of 1st slot and 1 for 2nd slot
  final int simSlotIndex;

  /// Card Id of the SIM card
  final int cardId;

  /// Phone number associated with the SIM card
  final String phoneNumber;

  /// Display name of the SIM card
  final String displayName;

  /// Country code associated with the SIM card
  final String countryCode;

  ///Constructor
  SimDataModel(
      {required this.carrierName,
      required this.isESIM,
      required this.subscriptionId,
      required this.simSlotIndex,
      required this.cardId,
      required this.phoneNumber,
      required this.displayName,
      required this.countryCode});

  ///Parses the json data into SimDataModel
  factory SimDataModel.fromJson(Map<String, dynamic> json) => SimDataModel(
        carrierName: json['CARRIER_NAME'] ?? "",
        isESIM: json['IS_EMBEDDED'] ?? "",
        subscriptionId: json['SUBSCRIPTION_ID'] ?? "",
        simSlotIndex: json['SIM_SLOT_INDEX'] ?? "",
        cardId: json['CARD_ID'] ?? "",
        phoneNumber: json['PHONE_NUMBER'] ?? "",
        displayName: json['DISPLAY_NAME'] ?? "",
        countryCode: json['COUNTRY_CODE'] ?? "",
      );

  ///returns the sim data models as a Map
  Map<String, dynamic> toMap() {
    return {
      "carrierName": carrierName,
      "isESIM": isESIM,
      "subscriptionId": subscriptionId,
      "simSlotIndex": simSlotIndex,
      "cardId": cardId,
      "phoneNumber": phoneNumber,
      "displayName": displayName,
      "countryCode": countryCode,
    };
  }
}
