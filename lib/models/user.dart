import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryUser {
  String accountStatus;
  bool isBlocked;
  String uid;
  String name;
  String email;
  String mobileNo;
  String profileImageUrl;
  String tokenId;
  String defaultAddress;
  List<Address> address;
  List<dynamic> wishlist;
  Map<String, dynamic> cart;
  String loggedInVia;
  MyWallet myWallet;

  GroceryUser({
    this.accountStatus,
    this.isBlocked,
    this.uid,
    this.email,
    this.mobileNo,
    this.name,
    this.profileImageUrl,
    this.defaultAddress,
    this.address,
    this.tokenId,
    this.wishlist,
    this.cart,
    this.loggedInVia,
    this.myWallet,
  });

  factory GroceryUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return GroceryUser(
      accountStatus: data['accountStatus'],
      isBlocked: data['isBlocked'],
      uid: data['uid'],
      email: data['email'],
      mobileNo: data['mobileNo'],
      name: data['name'],
      profileImageUrl: data['profileImageUrl'],
      defaultAddress: data['defaultAddress'],
      address: List<Address>.from(
        data['address'].map(
          (address) {
            return Address.fromHashmap(address);
          },
        ),
      ),
      tokenId: data['tokenId'],
      wishlist: data['wishlist'],
      cart: data['cart'],
      loggedInVia: data['loggedInVia'],
      myWallet: MyWallet.fromHashmap(data['myWallet']),
    );
  }
  factory GroceryUser.fromMap(Map data) {
    return GroceryUser(
      accountStatus: data['accountStatus'],
      isBlocked: data['isBlocked'],
      uid: data['uid'],
      email: data['email'],
      mobileNo: data['mobileNo'],
      name: data['name'],
      profileImageUrl: data['profileImageUrl'],
      address: data['address'],
      tokenId: data['tokenId'],
      wishlist: data['wishlist'],
      cart: data['cart'],
      loggedInVia: data['loggedInVia'],
    );
  }
}

class Address {
  String fullAddress;
  GeoPoint location;
  String placeId;
  String tag;
  String postalCode;

  Address({
    this.fullAddress,
    this.location,
    this.placeId,
    this.tag,
    this.postalCode,
  });

  factory Address.fromHashmap(Map<String, dynamic> address) {
    return Address(
      fullAddress: address['fullAddress'],
      location: address['location'],
      placeId: address['placeId'],
      tag: address['tag'],
      postalCode: address['postalCode'],
    );
  }
}

class MyWallet {
  var walletAmt;
  List<WalletTransaction> transactions;

  MyWallet({
    this.transactions,
    this.walletAmt,
  });

  factory MyWallet.fromHashmap(Map<String, dynamic> map) {
    return MyWallet(
      transactions: List<WalletTransaction>.from(
        map['transactions'].map(
          (transaction) {
            return WalletTransaction.fromHashmap(transaction);
          },
        ),
      ),
      walletAmt: map['walletAmt'],
    );
  }
}

class WalletTransaction {
  Timestamp timestamp;
  String detail;
  String transactionType;
  String transactionAmt;
  String transactionId;

  WalletTransaction({
    this.detail,
    this.timestamp,
    this.transactionAmt,
    this.transactionType,
    this.transactionId,
  });

  factory WalletTransaction.fromHashmap(Map<String, dynamic> map) {
    return WalletTransaction(
      detail: map['detail'],
      timestamp: map['timestamp'],
      transactionAmt: map['transactionAmt'],
      transactionType: map['transactionType'],
      transactionId: map['transactionId'],
    );
  }
}
