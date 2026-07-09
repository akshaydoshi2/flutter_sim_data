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
        isESIM: json['IS_EMBEDDED'] ?? false,
        subscriptionId: json['SUBSCRIPTION_ID'] ?? 0,
        simSlotIndex: json['SIM_SLOT_INDEX'] ?? 0,
        cardId: json['CARD_ID'] ?? 0,
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

/// Result of the iOS cellular availability check.
class CellularCheckResult {
  /// Passive check — a cellular interface/path exists (active data SIM present).
  final bool cellularInterfaceAvailable;

  /// Active check — traffic actually reached a host over cellular.
  final bool cellularDataReachable;

  /// Creates a [CellularCheckResult] from the passive and active check flags.
  CellularCheckResult({
    required this.cellularInterfaceAvailable,
    required this.cellularDataReachable,
  });

  /// Practical "is there active mobile data" signal.
  bool get hasActiveMobileData => cellularDataReachable;

  /// Parses the raw map returned by the platform channel into a
  /// [CellularCheckResult].
  factory CellularCheckResult.fromMap(Map<String, dynamic> map) =>
      CellularCheckResult(
        cellularInterfaceAvailable:
        map['cellularInterfaceAvailable'] as bool? ?? false,
        cellularDataReachable: map['cellularDataReachable'] as bool? ?? false,
      );

  /// Returns this result as a `Map`.
  Map<String, dynamic> toMap() => {
    "cellularInterfaceAvailable": cellularInterfaceAvailable,
    "cellularDataReachable": cellularDataReachable,
  };
}
