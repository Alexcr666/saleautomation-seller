import 'package:cloud_firestore/cloud_firestore.dart';

class Payout {
  var availablePayout;
  // var previousPayout;

  Payout({
    this.availablePayout,
    // this.previousPayout,
  });

  factory Payout.fromMap(Map data) {
    return Payout(
      // previousPayout: data['previousPayout'],
      availablePayout: data['availablePayout'],
    );
  }
}

class Payouts {
  PayoutBankDetails payoutBankDetails;
  Timestamp paidOn;
  Timestamp requestedOn;
  var payoutAmt;
  String payoutId;
  String status;
  String notes;
  String reason;
  String payoutVia;

  Payouts({
    this.paidOn,
    this.payoutId,
    this.payoutAmt,
    this.payoutBankDetails,
    this.requestedOn,
    this.status,
    this.notes,
    this.reason,
    this.payoutVia,
  });

  factory Payouts.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data();
    return Payouts(
      paidOn: data['paidOn'],
      payoutId: data['payoutId'],
      payoutAmt: data['payoutAmt'],
      payoutBankDetails: PayoutBankDetails.fromHashmap(data['bankDetails']),
      requestedOn: data['requestedOn'],
      status: data['status'],
      notes: data['notes'],
      reason: data['reason'],
      payoutVia: data['payoutVia'],
    );
  }
}

class PayoutBankDetails {
  String accountName;
  String accountNo;
  String bankName;
  String upiId;
  String ifscCode;
  String payoutDetails;

  PayoutBankDetails({
    this.accountName,
    this.accountNo,
    this.bankName,
    this.payoutDetails,
    this.upiId,
    this.ifscCode,
  });

  factory PayoutBankDetails.fromHashmap(Map<String, dynamic> address) {
    return PayoutBankDetails(
      accountName: address['accountName'],
      accountNo: address['accountNo'],
      bankName: address['bankName'],
      ifscCode: address['ifscCode'],
      payoutDetails: address['payoutDetails'],
      upiId: address['upiId'],
    );
  }
}

// List<Payouts> getListOfPayouts(Map<String, dynamic> map) {
//   List<Payouts> list = List();
//   map.forEach((key, value) {
//     list.add(Payouts.fromHashmap(value));
//   });

//   list.sort((a, b) => b.requestedOn.compareTo(a.requestedOn));

//   return list;
// }
