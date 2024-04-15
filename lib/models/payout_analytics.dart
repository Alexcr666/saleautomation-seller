import 'package:cloud_firestore/cloud_firestore.dart';

class PayoutAnalytics {
  var cancelledPayouts;
  var completedPayouts;
  var requestedPayouts;

  PayoutAnalytics({
    this.cancelledPayouts,
    this.completedPayouts,
    this.requestedPayouts,
  });

  factory PayoutAnalytics.fromFirestore(DocumentSnapshot documentSnapshot) {
    return PayoutAnalytics(
      cancelledPayouts: documentSnapshot.data()['cancelledPayouts'],
      completedPayouts: documentSnapshot.data()['completedPayouts'],
      requestedPayouts: documentSnapshot.data()['requestedPayouts'],
    );
  }
}
