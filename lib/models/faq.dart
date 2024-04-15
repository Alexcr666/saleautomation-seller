import 'package:cloud_firestore/cloud_firestore.dart';

class SellerFaq {
  List<Faq> faqs;

  SellerFaq({
    this.faqs,
  });

  factory SellerFaq.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return SellerFaq(
      faqs: List<Faq>.from(
        data['faqs'].map(
          (address) {
            return Faq.fromHashmap(address);
          },
        ),
      ),
    );
  }
}

class Faq {
  String que;
  String ans;

  Faq({
    this.ans,
    this.que,
  });

  factory Faq.fromHashmap(Map<String, dynamic> faq) {
    return Faq(
      ans: faq['ans'],
      que: faq['que'],
    );
  }
}
