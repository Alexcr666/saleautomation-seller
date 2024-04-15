import 'package:cloud_firestore/cloud_firestore.dart';

class SellerSettings {
  bool automaticApproval;
  String minPayoutAmt;
  String serviceChargePer;

  SellerSettings({
    this.automaticApproval,
    this.minPayoutAmt,
    this.serviceChargePer,
  });

  factory SellerSettings.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return SellerSettings(
      automaticApproval: data['automaticApproval'],
      minPayoutAmt: data['minPayoutAmt'],
      serviceChargePer: data['serviceChargePer'],
    );
  }
}
