import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multivendor_seller/models/payout.dart';

class Seller {
  String accountStatus;
  String approvalStatus;
  String reason;
  String uid;
  String name;
  String email;
  bool isBlocked;
  String mobileNo;
  String profileImageUrl;
  String tokenId;
  Timestamp timestamp;
  LocationDetails locationDetails;
  Payout payout;
  Zipcode zipcode;

  Seller({
    this.accountStatus,
    this.approvalStatus,
    this.reason,
    this.uid,
    this.name,
    this.email,
    this.isBlocked,
    this.mobileNo,
    this.profileImageUrl,
    this.tokenId,
    this.timestamp,
    this.locationDetails,
    this.payout,
    this.zipcode,
  });

  factory Seller.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return Seller(
      accountStatus: data['accountStatus'],
      approvalStatus: data['approvalStatus'],
      reason: data['reason'],
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      isBlocked: data['isBlocked'],
      mobileNo: data['mobileNo'],
      profileImageUrl: data['profileImageUrl'],
      tokenId: data['tokenId'],
      timestamp: data['timestamp'],
      locationDetails: LocationDetails.fromHashmap(data['locationDetails']),
      payout: Payout.fromMap(data['payout']),
      zipcode: Zipcode.fromMap(doc['zipcodeRestriction']),
    );
  }
  factory Seller.fromMap(Map data) {
    return Seller(
      accountStatus: data['accountStatus'],
      approvalStatus: data['approvalStatus'],
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      isBlocked: data['isBlocked'],
      mobileNo: data['mobileNo'],
      profileImageUrl: data['profileImageUrl'],
      tokenId: data['tokenId'],
      locationDetails: LocationDetails.fromHashmap(data['locationDetails']),
    );
  }
}

class LocationDetails {
  String address;
  String placeId;
  double lat;
  double lng;
  String postalCode;

  LocationDetails({
    this.address,
    this.lat,
    this.lng,
    this.placeId,
    this.postalCode,
  });

  factory LocationDetails.fromHashmap(Map<String, dynamic> address) {
    return LocationDetails(
      address: address['address'],
      lat: /* address['lat']*/ 1.0,
      lng: /*address['lng']*/ 1.0,
      placeId: address['placeId'],
      postalCode: address['postalCode'],
    );
  }
}

class Zipcode {
  bool isEnabled;
  List zipcodes;

  Zipcode({
    this.isEnabled,
    this.zipcodes,
  });

  factory Zipcode.fromMap(Map doc) {
    return Zipcode(
      isEnabled: doc['isEnabled'],
      zipcodes: doc['zipcodes'],
    );
  }
}
