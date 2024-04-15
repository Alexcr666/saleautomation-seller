import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multivendor_seller/config/paths.dart';
import 'package:multivendor_seller/models/seller_settings.dart';
import 'package:multivendor_seller/providers/base_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class AuthenticationProvider extends BaseAuthenticationProvider {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void dispose() {}

  @override
  Future<bool> checkIfSignedIn() async {
    final user = firebaseAuth.currentUser;
    return user != null;
  }

  @override
  Future<User> getCurrentUser() async {
    return firebaseAuth.currentUser;
  }

  @override
  Future<bool> signOutUser() async {
    try {
      Future.wait([
        firebaseAuth.signOut(),
        // googleSignIn.signOut(),
      ]);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> signInWithEmail(String email, String password) async {
    try {
      QuerySnapshot snapshot = await db
          .collection(Paths.sellersPath)
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.size == 0) {
        return 'Seller account does not exist! Please sign up first.';
      }
      UserCredential authResult = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      if (authResult.user != null) {
        return '';
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<String> signUpWithEmail(Map map) async {
    try {
      UserCredential userCredential;
      //check if already exists
      QuerySnapshot snapshot = await db
          .collection(Paths.sellersPath)
          .where('email', isEqualTo: map['email'])
          .get();

      if (snapshot.size > 0) {
        return 'Seller with this email already exists!';
      }

      try {
        userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: map['email'],
          password: map['password'],
        );
      } catch (e) {
        print(e);
        return e;
      }

      var uuid = Uuid().v4();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('vendorImages/$uuid');
      await storageReference.putFile(map['image']);

      var url = await storageReference.getDownloadURL();

      //check if automatic approval is on
      DocumentSnapshot sellerSettingsSnapshot =
          await db.doc(Paths.sellerSettingsPath).get();

      SellerSettings sellerSettings =
          SellerSettings.fromFirestore(sellerSettingsSnapshot);

      await db.collection(Paths.sellersPath).doc(userCredential.user.uid).set({
        'accountStatus': 'Active',
        'approvalStatus':
            sellerSettings.automaticApproval ? 'Verified' : 'In verification',
        'reason': '',
        'isBlocked': false,
        'uid': userCredential.user.uid,
        'name': map['name'],
        'email': map['email'],
        'mobileNo': map['mobileNo'],
        'locationDetails': {
          'address': map['address'],
          'lat': map['locationLat'],
          'lng': map['locationLng'],
          'placeId': map['placeId'],
        },
        'profileImageUrl': url,
        'payout': {
          'availablePayout': 0,
          // 'previousPayout': 0,
        },
        'zipcodeRestriction': {
          'zipcodes': [],
          'isEnabled': false,
        },
        'tokenId': '',
        'isFeatured': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      //update seller  analytics
      if (sellerSettings.automaticApproval) {
        await db.collection(Paths.adminInfoPath).doc('sellerAnalytics').set(
          {
            'allSellers': FieldValue.increment(1),
            'verifiedSellers': FieldValue.increment(1),
          },
          SetOptions(merge: true),
        );
      } else {
        await db.collection(Paths.adminInfoPath).doc('sellerAnalytics').set(
          {
            'allSellers': FieldValue.increment(1),
            'unverifiedSellers': FieldValue.increment(1),
          },
          SetOptions(merge: true),
        );
      }

      //creating the analytics
      await db
          .collection(Paths.sellersPath)
          .doc(userCredential.user.uid)
          .collection(Paths.sellerInfoPath)
          .doc('inventoryAnalytics')
          .set({
        'lowInventory': 0,
      });

      await db
          .collection(Paths.sellersPath)
          .doc(userCredential.user.uid)
          .collection(Paths.sellerInfoPath)
          .doc('messageAnalytics')
          .set({
        'allMessages': 0,
        'newMessages': 0,
      });

      await db
          .collection(Paths.sellersPath)
          .doc(userCredential.user.uid)
          .collection(Paths.sellerInfoPath)
          .doc('orderAnalytics')
          .set({
        'cancelledOrders': 0,
        'cancelledSales': 0,
        'deliveredOrders': 0,
        'deliveredSales': 0,
        'newOrders': 0,
        'newSales': 0,
        'processedOrders': 0,
        'processedSales': 0,
        'totalOrders': 0,
        'totalSales': 0,
      });

      await db
          .collection(Paths.sellersPath)
          .doc(userCredential.user.uid)
          .collection(Paths.sellerInfoPath)
          .doc('productAnalytics')
          .set({
        'activeProducts': 0,
        'allProducts': 0,
        'featuredProducts': 0,
        'inactiveProducts': 0,
        'trendingProducts': 0,
      });

      await db
          .collection(Paths.sellersPath)
          .doc(userCredential.user.uid)
          .collection(Paths.sellerInfoPath)
          .doc('deliveryUserAnalytics')
          .set({
        'activatedUsers': 0,
        'activeUsers': 0,
        'allUsers': 0,
        'deactivatedUsers': 0,
        'inactiveUsers': 0,
      });

      // //create payout
      // await db.collection(Paths.payoutsPath).doc(userCredential.user.uid).set({
      //   'availablePayout': 0,
      //   'payouts': {},
      //   'previousPayout': 0,
      //   'uid': userCredential.user.uid,
      // });

      return '';
    } catch (e) {
      print(e);
      return null;
    }
  }
}
