class SimDataModel{
  final String carrierName;
  final bool isESIM;
  final int subscriptionId;
  final int simSlotIndex;
  final int cardId;
  final String phoneNumber;
  final String displayName;
  final String countryCode;

  SimDataModel({required this.carrierName, required this.isESIM, required this.subscriptionId, required this.simSlotIndex,
        required this.cardId, required this.phoneNumber, required this.displayName, required this.countryCode});

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
}