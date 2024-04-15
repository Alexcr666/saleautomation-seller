import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/config/paths.dart';
import 'package:multivendor_seller/models/admin.dart';
import 'package:multivendor_seller/models/banner.dart';
import 'package:multivendor_seller/models/cart_info.dart';
import 'package:multivendor_seller/models/category.dart';
import 'package:multivendor_seller/models/coupon.dart';
import 'package:multivendor_seller/models/delivery_user.dart';
import 'package:multivendor_seller/models/delivery_user_analytics.dart';
import 'package:multivendor_seller/models/faq.dart';
import 'package:multivendor_seller/models/global_settings.dart';
import 'package:multivendor_seller/models/inventory_analytics.dart';
import 'package:multivendor_seller/models/message_analytics.dart';
import 'package:multivendor_seller/models/order.dart';
import 'package:multivendor_seller/models/order_analytics.dart';
import 'package:multivendor_seller/models/payment_methods.dart';
import 'package:multivendor_seller/models/payout.dart';
import 'package:multivendor_seller/models/payout_analytics.dart';
import 'package:multivendor_seller/models/product.dart';
import 'package:multivendor_seller/models/product_analytics.dart';
import 'package:multivendor_seller/models/seller_notification.dart';
import 'package:multivendor_seller/models/seller_settings.dart';
import 'package:multivendor_seller/models/user.dart';
import 'package:multivendor_seller/models/user_analytics.dart';
import 'package:multivendor_seller/models/user_report.dart';
import 'package:multivendor_seller/models/seller.dart';

import 'package:multivendor_seller/providers/base_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';

class UserDataProvider extends BaseUserDataProvider {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth mAuth = FirebaseAuth.instance;

  @override
  void dispose() {}

  @override
  Stream<List<Order>> getNewOrders() {
    List<Order> newOrders = [];

    try {
      CollectionReference collectionReference = db.collection(Paths.ordersPath);

      return collectionReference
          .where('orderStatus', isEqualTo: 'Processing')
          .orderBy('orderTimestamp', descending: true)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .snapshots()
          .transform(StreamTransformer<QuerySnapshot, List<Order>>.fromHandlers(
            handleData: (QuerySnapshot snap, EventSink<List<Order>> sink) {
              if (snap.docs != null) {
                newOrders = List<Order>.from(
                  snap.docs.map(
                    (e) => Order.fromFirestore(e),
                  ),
                );
                sink.add(newOrders);
              }
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Order>> getDeliveredOrders() async {
    List<Order> deliveredOrders = [];

    try {
      QuerySnapshot snapshot = await db
          .collection(Paths.ordersPath)
          .orderBy('orderTimestamp', descending: true)
          .where('orderStatus', isEqualTo: 'Delivered')
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      if (snapshot.docs != null) {
        deliveredOrders = List<Order>.from(
          (snapshot.docs).map(
            (e) => Order.fromFirestore(e),
          ),
        );
        return deliveredOrders;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Order>> getCancelledOrders() async {
    List<Order> cancelledOrders = [];

    try {
      QuerySnapshot snapshot = await db
          .collection(Paths.ordersPath)
          .orderBy('orderTimestamp', descending: true)
          .where('orderStatus', isEqualTo: 'Cancelled')
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      if (snapshot.docs != null) {
        cancelledOrders = List<Order>.from(
          (snapshot.docs).map(
            (e) => Order.fromFirestore(e),
          ),
        );
        return cancelledOrders;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Order>> updateNewOrders(List<Order> allOrders) async {
    try {
      List<Order> newOrders = [];
      for (var order in allOrders) {
        if (order.orderStatus == 'Processing' ||
            order.orderStatus == 'Processed') {
          newOrders.add(order);
        }
      }
      return newOrders;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Stream<OrderAnalytics> getOrderAnalytics() {
    OrderAnalytics orderAnalytics;

    try {
      DocumentReference documentReference = db
          .collection(Paths.sellersPath)
          .doc('${mAuth.currentUser.uid}/${Paths.sellerOrderAnalyticsPath}');

      return documentReference.snapshots().transform(
              StreamTransformer<DocumentSnapshot, OrderAnalytics>.fromHandlers(
            handleData:
                (DocumentSnapshot snap, EventSink<OrderAnalytics> sink) {
              if (snap.data != null) {
                orderAnalytics = OrderAnalytics.fromFirestore(snap);
                sink.add(orderAnalytics);
              }
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Order>> getProcessedOrders() async {
    List<Order> processedOrders = [];

    try {
      QuerySnapshot snapshot = await db
          .collection(Paths.ordersPath)
          .where('orderStatus', isEqualTo: 'Processed')
          .orderBy('orderTimestamp', descending: true)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      if (snapshot.docs != null) {
        processedOrders = List<Order>.from(
          (snapshot.docs).map(
            (e) => Order.fromFirestore(e),
          ),
        );
        return processedOrders;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Order>> getOutForDeliveryOrders() async {
    List<Order> outForDeliveryOrders = [];

    try {
      QuerySnapshot snapshot = await db
          .collection(Paths.ordersPath)
          .where('orderStatus', isEqualTo: 'Out for delivery')
          .orderBy('orderTimestamp', descending: true)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      if (snapshot.docs != null) {
        outForDeliveryOrders = List<Order>.from(
          (snapshot.docs).map(
            (e) => Order.fromFirestore(e),
          ),
        );
        return outForDeliveryOrders;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Product>> getAllProducts() async {
    List<Product> products;
    try {
      QuerySnapshot snap = await db
          .collection(Paths.productsPath)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      DocumentSnapshot sellerSnap = await db
          .collection(Paths.sellersPath)
          .doc(mAuth.currentUser.uid)
          .get();

      products = List<Product>.from(
        (snap.docs).map(
          (e) => Product.fromFirestore(e, sellerSnap),
        ),
      );

      return products;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Stream<List<Product>> getLowInventoryProducts() {
    List<Product> products;

    try {
      CollectionReference collectionReference =
          db.collection(Paths.productsPath);

      return collectionReference
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .snapshots()
          .transform(
              StreamTransformer<QuerySnapshot, List<Product>>.fromHandlers(
            handleData:
                (QuerySnapshot snap, EventSink<List<Product>> sink) async {
              if (snap.docs != null) {
                DocumentSnapshot sellerSnap = await db
                    .collection(Paths.sellersPath)
                    .doc(mAuth.currentUser.uid)
                    .get();

                products = List<Product>.from(
                  snap.docs.map(
                    (e) => Product.fromFirestore(e, sellerSnap),
                  ),
                );

                List<Product> lowProds = [];

                for (var item in products) {
                  for (var sku in item.skus) {
                    if (sku.quantity < Config().lowInventoryNo) {
                      lowProds.add(item);
                      break;
                    }
                  }
                }
                sink.add(lowProds);
              }
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Category>> getAllCategories() async {
    List<Category> categories;

    try {
      CollectionReference collectionReference =
          db.collection(Paths.categoriesPath);

      QuerySnapshot querySnapshot = await collectionReference.get();

      categories = List<Category>.from(
        querySnapshot.docs.map(
          (e) => Category.fromFirestore(e),
        ),
      );
      return categories;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Stream<ProductAnalytics> getProductAnalytics() {
    ProductAnalytics productAnalytics;

    try {
      DocumentReference documentReference = db
          .collection(Paths.sellersPath)
          .doc('${mAuth.currentUser.uid}/${Paths.sellerProductAnalyticsPath}');

      return documentReference.snapshots().transform(StreamTransformer<
              DocumentSnapshot, ProductAnalytics>.fromHandlers(
            handleData:
                (DocumentSnapshot snap, EventSink<ProductAnalytics> sink) {
              if (snap.data != null) {
                productAnalytics = ProductAnalytics.fromFirestore(snap);
                sink.add(productAnalytics);
              }
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Stream<InventoryAnalytics> getInventoryAnalytics() {
    InventoryAnalytics inventoryAnalytics;

    try {
      DocumentReference documentReference = db
          .collection(Paths.sellersPath)
          .doc(
              '${mAuth.currentUser.uid}/${Paths.sellerInventoryAnalyticsPath}');

      return documentReference.snapshots().transform(StreamTransformer<
              DocumentSnapshot, InventoryAnalytics>.fromHandlers(
            handleData:
                (DocumentSnapshot snap, EventSink<InventoryAnalytics> sink) {
              if (snap.data != null) {
                inventoryAnalytics = InventoryAnalytics.fromFirestore(snap);
                sink.add(inventoryAnalytics);
              }
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Product>> getActiveProducts() async {
    List<Product> products;
    try {
      QuerySnapshot snap = await db
          .collection(Paths.productsPath)
          .where('isListed', isEqualTo: true)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      DocumentSnapshot sellerSnap = await db
          .collection(Paths.sellersPath)
          .doc(mAuth.currentUser.uid)
          .get();

      products = List<Product>.from(
        (snap.docs).map(
          (e) => Product.fromFirestore(e, sellerSnap),
        ),
      );

      return products;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    List<Product> products;
    try {
      QuerySnapshot snap = await db
          .collection(Paths.productsPath)
          .where('featured', isEqualTo: true)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();
      DocumentSnapshot sellerSnap = await db
          .collection(Paths.sellersPath)
          .doc(mAuth.currentUser.uid)
          .get();

      products = List<Product>.from(
        (snap.docs).map(
          (e) => Product.fromFirestore(e, sellerSnap),
        ),
      );

      return products;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Product>> getInactiveProducts() async {
    List<Product> products;
    try {
      QuerySnapshot snap = await db
          .collection(Paths.productsPath)
          .where('isListed', isEqualTo: false)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      DocumentSnapshot sellerSnap = await db
          .collection(Paths.sellersPath)
          .doc(mAuth.currentUser.uid)
          .get();

      products = List<Product>.from(
        (snap.docs).map(
          (e) => Product.fromFirestore(e, sellerSnap),
        ),
      );

      return products;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Product>> getTrendingProducts() async {
    List<Product> products;
    try {
      QuerySnapshot snap = await db
          .collection(Paths.productsPath)
          .where('trending', isEqualTo: true)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();
      DocumentSnapshot sellerSnap = await db
          .collection(Paths.sellersPath)
          .doc(mAuth.currentUser.uid)
          .get();
      products = List<Product>.from(
        (snap.docs).map(
          (e) => Product.fromFirestore(e, sellerSnap),
        ),
      );

      return products;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Stream<MessageAnalytics> getMessageAnalytics() {
    MessageAnalytics messageAnalytics;

    try {
      DocumentReference documentReference = db
          .collection(Paths.sellersPath)
          .doc('${mAuth.currentUser.uid}/${Paths.sellerMessageAnalyticsPath}');

      return documentReference.snapshots().transform(StreamTransformer<
              DocumentSnapshot, MessageAnalytics>.fromHandlers(
            handleData:
                (DocumentSnapshot snap, EventSink<MessageAnalytics> sink) {
              if (snap.data != null) {
                messageAnalytics = MessageAnalytics.fromFirestore(snap);
                sink.add(messageAnalytics);
              }
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Product>> getAllMessages() async {
    List<Product> products = [];
    List<Product> allMessagesProducts = [];
    try {
      QuerySnapshot querySnapshot = await db
          .collection(Paths.productsPath)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      DocumentSnapshot sellerSnap = await db
          .collection(Paths.sellersPath)
          .doc(mAuth.currentUser.uid)
          .get();

      products = List<Product>.from(
        (querySnapshot.docs).map(
          (e) => Product.fromFirestore(e, sellerSnap),
        ),
      );

      for (var prod in products) {
        if (prod.queAndAns.length > 0) {
          allMessagesProducts.add(prod);
        }
      }

      return allMessagesProducts;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Product>> getNewMessages() async {
    List<Product> products = [];
    List<Product> newMessagesProducts = [];
    try {
      QuerySnapshot querySnapshot = await db
          .collection(Paths.productsPath)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      DocumentSnapshot sellerSnap = await db
          .collection(Paths.sellersPath)
          .doc(mAuth.currentUser.uid)
          .get();

      products = List<Product>.from(
        (querySnapshot.docs).map(
          (e) => Product.fromFirestore(e, sellerSnap),
        ),
      );

      for (var prod in products) {
        for (var que in prod.queAndAns) {
          if (que.ans.isEmpty) {
            newMessagesProducts.add(prod);
            break;
          }
        }
      }

      return newMessagesProducts;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> updateLowInventoryProduct(String id, int quantity) async {
    try {
      await db.collection(Paths.productsPath).doc(id).set(
        {
          'quantity': quantity,
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> addNewProduct(Map product) async {
    String productId;
    List<String> urls = [];

    try {
      //get the current PID
      DocumentSnapshot productCounterDoc =
          await db.doc(Paths.productCounterPath).get();

      String productPrefix = productCounterDoc.data()['prefix'];
      String productIdCounter = productCounterDoc.data()['productIdCounter'];
      productIdCounter = (int.parse(productIdCounter) + 1)
          .toString()
          .padLeft(productIdCounter.length, '0');

      productId = productPrefix + productIdCounter;

      //upload images first
      for (var image in product['productImages']) {
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('productImages/$uuid');
        await storageReference.putFile(image);
        var url = await storageReference.getDownloadURL();

        urls.add(url);
      }

      Map skusMap = Map();

      for (var i = 0; i < product['skus'].length; i++) {
        skusMap.putIfAbsent(
          '${product['skus'][i]['skuId']}',
          () => {
            'skuName': product['skus'][i]['skuName'],
            'skuPrice': product['skus'][i]['skuPrice'],
            // 'skuMrp': product['skus'][i]['skuMrp'],
            'quantity': product['skus'][i]['quantity'],
            'skuId': product['skus'][i]['skuId'],
          },
        );
      }

      //upload product to db
      db.collection(Paths.productsPath).doc(productId).set({
        'additionalInfo': {
          'bestBefore': product['bestBefore'],
          'brand': product['brand'],
          'manufactureDate': product['manufactureDate'],
          'shelfLife': product['shelfLife'],
        },
        'category': product['category'],
        'description': product['description'],
        'featured': product['featured'],
        'id': productId,
        'inStock': product['inStock'],
        'isListed': product['isListed'],
        'name': product['name'],
        'productImages': urls,
        'queAndAns': {},
        'reviews': {},
        'subCategory': product['subCategory'],
        'timestamp': Timestamp.now(),
        'trending': false,
        'views': 0,
        'skus': skusMap,
        'isDiscounted': product['isDiscounted'],
        'discount': product['discount'],
        'keywords': product['keywords'],
        'seller': FirebaseAuth.instance.currentUser.uid,
      });

      //update PID
      await db.doc(Paths.productCounterPath).set(
        {
          'currentProductId': productId,
          'productIdCounter': productIdCounter,
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> editProduct(Map product) async {
    String productId;
    List<String> urls = [];
    List productImagesUrl = [];

    try {
      productId = product['id'];
      productImagesUrl = product['productImages'];

      //upload images first
      if (product['newProductImages'].length > 0) {
        for (var image in product['newProductImages']) {
          var uuid = Uuid().v4();
          Reference storageReference =
              firebaseStorage.ref().child('productImages/$uuid');
          await storageReference.putFile(image);
          var url = await storageReference.getDownloadURL();

          urls.add(url);
        }

        for (var item in urls) {
          productImagesUrl.add(item);
        }
      }

      Map skusMap = Map();

      for (var i = 0; i < product['skus'].length; i++) {
        skusMap.putIfAbsent(
          '${product['skus'][i]['skuId']}',
          () => {
            'skuName': product['skus'][i]['skuName'],
            'skuPrice': product['skus'][i]['skuPrice'],
            'quantity': product['skus'][i]['quantity'],
            'skuId': product['skus'][i]['skuId'],
          },
        );
      }

      //upload product to db
      db.collection(Paths.productsPath).doc(productId).update(
        {
          'additionalInfo': {
            'bestBefore': product['bestBefore'],
            'brand': product['brand'],
            'manufactureDate': product['manufactureDate'],
            'shelfLife': product['shelfLife'],
          },
          'category': product['category'],
          'description': product['description'],
          'featured': product['featured'],
          'inStock': product['inStock'],
          'isListed': product['isListed'],
          'name': product['name'],
          'productImages': productImagesUrl,
          'subCategory': product['subCategory'],
          'timestamp': Timestamp.now(),
          'skus': skusMap,
          'isDiscounted': product['isDiscounted'],
          'discount': product['discount'],
          'keywords': product['keywords'],
        },
        // SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> addNewCategory(Map category) async {
    try {
      var uuid = Uuid().v4();
      Reference storageReference =
          firebaseStorage.ref().child('categoryImages/$uuid');
      await storageReference.putFile(category['categoryImage']);
      var url = await storageReference.getDownloadURL();

      var docId = Uuid().v4();

      db.collection(Paths.categoriesPath).doc(docId).set({
        'categoryName': category['categoryName'],
        'imageLink': url,
        'categoryId': docId,
        'subCategories': category['subCategories'],
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> editCategory(Map category) async {
    try {
      if (category['newImage'] != null) {
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('categoryImages/$uuid');
        await storageReference.putFile(category['newImage']);
        var url = await storageReference.getDownloadURL();

        var docId = category['categoryId'];

        db.collection(Paths.categoriesPath).doc(docId).set(
          {
            'categoryName': category['categoryName'],
            'imageLink': url,
            'subCategories': category['subCategories'],
          },
          SetOptions(merge: true),
        );
      } else {
        var docId = category['categoryId'];

        db.collection(Paths.categoriesPath).doc(docId).set(
          {
            'categoryName': category['categoryName'],
            'subCategories': category['subCategories'],
          },
          SetOptions(merge: true),
        );
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> postAnswer(String id, String ans, String queId) async {
    try {
      await db.collection(Paths.productsPath).doc(id).set(
        {
          'queAndAns': {
            queId: {
              'ans': ans,
            }
          }
        },
        SetOptions(merge: true),
      );

      //update analytics
      await http.post(Uri.parse(Config().updateMessagesUrl));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> deleteProduct(String id) async {
    try {
      await db.collection(Paths.productsPath).doc(id).delete();

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await db.collection(Paths.categoriesPath).doc(categoryId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Stream<UserAnalytics> getUserAnalytics() {
    UserAnalytics userAnalytics;

    try {
      DocumentReference documentReference = db.doc(Paths.userAnalyticsPath);

      return documentReference.snapshots().transform(
              StreamTransformer<DocumentSnapshot, UserAnalytics>.fromHandlers(
            handleData: (DocumentSnapshot snap, EventSink<UserAnalytics> sink) {
              if (snap.data != null) {
                userAnalytics = UserAnalytics.fromFirestore(snap);
                sink.add(userAnalytics);
              }
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<GroceryUser>> getActiveUsers() async {
    List<GroceryUser> users;
    try {
      QuerySnapshot snap = await db
          .collection(Paths.usersPath)
          .where('accountStatus', isEqualTo: 'Active')
          .get();

      users = List<GroceryUser>.from(
        (snap.docs).map(
          (e) => GroceryUser.fromFirestore(e),
        ),
      );

      return users;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<GroceryUser>> getAllUsers() async {
    List<GroceryUser> users;
    try {
      QuerySnapshot snap = await db.collection(Paths.usersPath).get();

      users = List<GroceryUser>.from(
        (snap.docs).map(
          (e) => GroceryUser.fromFirestore(e),
        ),
      );

      return users;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<GroceryUser>> getBlockedUsers() async {
    List<GroceryUser> users;
    try {
      QuerySnapshot snap = await db
          .collection(Paths.usersPath)
          .where('isBlocked', isEqualTo: true)
          .get();

      users = List<GroceryUser>.from(
        (snap.docs).map(
          (e) => GroceryUser.fromFirestore(e),
        ),
      );

      return users;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<GroceryUser>> getInactiveUsers() async {
    List<GroceryUser> users;
    try {
      QuerySnapshot snap = await db
          .collection(Paths.usersPath)
          .where('accountStatus', isEqualTo: 'Inactive')
          .get();

      users = List<GroceryUser>.from(
        (snap.docs).map(
          (e) => GroceryUser.fromFirestore(e),
        ),
      );

      return users;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Stream<List<UserReport>> getUserReports() {
    List<UserReport> userReports;

    try {
      CollectionReference collectionReference =
          db.collection(Paths.userReportsPath);

      return collectionReference.snapshots().transform(
              StreamTransformer<QuerySnapshot, List<UserReport>>.fromHandlers(
            handleData: (QuerySnapshot snap, EventSink<List<UserReport>> sink) {
              if (snap.docs != null) {
                userReports = List<UserReport>.from(
                  snap.docs.map(
                    (e) => UserReport.fromFirestore(e),
                  ),
                );
                sink.add(userReports);
              }
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<Product> getUserReportProduct(String id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await db.collection(Paths.productsPath).doc(id).get();
      DocumentSnapshot sellerSnap = await db
          .collection(Paths.sellersPath)
          .doc(mAuth.currentUser.uid)
          .get();

      return Product.fromFirestore(documentSnapshot, sellerSnap);
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Order>> getUsersOrder(String uid) async {
    try {
      List<Order> orders = [];
      QuerySnapshot querySnapshot = await db
          .collection(Paths.ordersPath)
          .where('custDetails.uid', isEqualTo: uid)
          .get();
      for (var item in querySnapshot.docs) {
        orders.add(Order.fromFirestore(item));
      }
      return orders;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<Seller> getMyAccountDetails() async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      print('INSIDE');

      if (firebaseAuth.currentUser != null) {
        User firebaseUser = firebaseAuth.currentUser;
        print(firebaseUser.uid);
        DocumentSnapshot snapshot =
            await db.collection(Paths.sellersPath).doc(firebaseUser.uid).get();
        return Seller.fromFirestore(snapshot);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> blockUser(String uid) async {
    try {
      await db.collection(Paths.usersPath).doc(uid).set(
        {
          'isBlocked': true,
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> unblockUser(String uid) async {
    try {
      await db.collection(Paths.usersPath).doc(uid).set(
        {
          'isBlocked': false,
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> proceedInitialSetup(Map map) async {
    try {
      //creating analytics
      await db
          .collection(Paths.sellersPath)
          .doc(map['uid'])
          .collection(Paths.sellerInfoPath)
          .doc('inventoryAnalytics')
          .set({
        'lowInventory': 0,
      });

      await db
          .collection(Paths.sellersPath)
          .doc(map['uid'])
          .collection(Paths.sellerInfoPath)
          .doc('messageAnalytics')
          .set({
        'allMessages': 0,
        'newMessages': 0,
      });

      await db
          .collection(Paths.sellersPath)
          .doc(map['uid'])
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
          .doc(map['uid'])
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
          .doc(map['uid'])
          .collection(Paths.sellerInfoPath)
          .doc('deliveryUserAnalytics')
          .set({
        'activatedUsers': 0,
        'activeUsers': 0,
        'allUsers': 0,
        'deactivatedUsers': 0,
        'inactiveUsers': 0,
      });

      return true;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> checkIfNewAdmin(String uid) async {
    try {
      QuerySnapshot querySnapshot = await db.collection(Paths.adminsPath).get();
      if (querySnapshot.docs.length > 0) {
        //already created
        DocumentSnapshot snap =
            await db.collection(Paths.adminsPath).doc(uid).get();

        if (snap.exists) {
          //not new
          return true;
        } else {
          //new
          FirebaseAuth firebaseAuth = FirebaseAuth.instance;
          User firebaseUser = firebaseAuth.currentUser;

          await db.collection('Admins').doc(uid).set({
            'uid': uid,
            'primaryAdmin': true,
            'name': 'ADMIN_' + Random.secure().nextInt(10000).toString(),
            'email': firebaseUser.email,
            'timestamp': FieldValue.serverTimestamp(),
            'tokenId': '',
            'mobileNo': '',
            'accountStatus': 'Active',
            'profileImageUrl': '',
            'password': '',
            'activated': true,
          });
          return true;
        }
      } else {
        //new
        FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        User firebaseUser = firebaseAuth.currentUser;

        db.collection('Admins').doc(uid).set({
          'uid': uid,
          'primaryAdmin': true,
          'name': 'ADMIN_' + Random.secure().nextInt(10000).toString(),
          'email': firebaseUser.email,
          'timestamp': FieldValue.serverTimestamp(),
          'tokenId': '',
          'mobileNo': '',
          'accountStatus': 'Active',
          'profileImageUrl': '',
          'password': '',
          'activated': true,
        });
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> checkIfInitialSetupDone() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    try {
      DocumentSnapshot snap = await db.doc(Paths.cartInfo).get();
      if (snap.exists) {
        sharedPreferences.setBool('initialSetupCompleted', true);

        return true;
      } else {
        sharedPreferences.setBool('initialSetupCompleted', false);

        return false;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Admin>> getAllAdmins() async {
    List<Admin> admins = [];
    try {
      QuerySnapshot querySnapshot = await db.collection(Paths.adminsPath).get();

      for (var item in querySnapshot.docs) {
        admins.add(Admin.fromFirestore(item));
      }
      return admins;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> updateAdminDetails(Map adminMap) async {
    try {
      var url = adminMap['profileImageUrl'];

      if (adminMap['profileImage'] != null) {
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('sellerImages/$uuid');
        await storageReference.putFile(adminMap['profileImage']);
        url = await storageReference.getDownloadURL();
      }
      await db.collection(Paths.sellersPath).doc(adminMap['uid']).set(
        {
          'name': adminMap['name'],
          'email': adminMap['email'],
          // 'address': adminMap['address'],
          'timestamp': FieldValue.serverTimestamp(),
          'mobileNo':
              '${Config().countryMobileNoPrefix}${adminMap['mobileNo']}',
          'profileImageUrl': url ?? adminMap['profileImageUrl'],
          'locationDetails': {
            'address': adminMap['address'],
            'lat': adminMap['locationLat'],
            'lng': adminMap['locationLng'],
            'placeId': adminMap['placeId'],
          },
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<Map> getAllBanners() async {
    Map map = Map();
    List<Category> categories = [];
    try {
      QuerySnapshot querySnapshot =
          await db.collection(Paths.categoriesPath).get();

      categories = List<Category>.from(
        querySnapshot.docs.map(
          (e) => Category.fromFirestore(e),
        ),
      );

      map.putIfAbsent('categories', () => categories);

      DocumentSnapshot snapshot = await db.doc(Paths.bannersPath).get();
      map.putIfAbsent('banner', () => Banner.fromFirestore(snapshot));

      return map;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> updateBanners(Map bannersMap) async {
    List topBanners = [];
    List newTopBannerUrls = [];
    String middleBannerUrl;
    String bottomBannerUrl;

    try {
      //top banner
      for (var image in bannersMap['newTopBannerImages']) {
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('banners/$uuid');
        await storageReference.putFile(image);
        var url = await storageReference.getDownloadURL();

        newTopBannerUrls.add(url);
      }
      //add new top banner images
      for (var item in newTopBannerUrls) {
        topBanners.add(item);
      }

      //add previous top banner images
      for (var item in bannersMap['topBanner']) {
        topBanners.add(item);
      }

      //middle banner
      if (bannersMap['newMiddleBannerImage'] != null) {
        //new image upload
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('banners/$uuid');
        await storageReference.putFile(bannersMap['newMiddleBannerImage']);
        var url = await storageReference.getDownloadURL();
        middleBannerUrl = url;
      } else {
        middleBannerUrl = bannersMap['middleBanner'].middleBanner;
      }

      //bottom banner
      if (bannersMap['newBottomBannerImage'] != null) {
        //new image upload
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('banners/$uuid');
        await storageReference.putFile(bannersMap['newBottomBannerImage']);
        var url = await storageReference.getDownloadURL();
        bottomBannerUrl = url;
      } else {
        bottomBannerUrl = bannersMap['bottomBanner'].bottomBanner;
      }

      //update all data
      await db.doc(Paths.bannersPath).set(
        {
          'bottomBanner': {
            'bottomBanner': bottomBannerUrl,
            'category': bannersMap['bottomBanner'].category,
          },
          'middleBanner': {
            'middleBanner': middleBannerUrl,
            'category': bannersMap['middleBanner'].category,
          },
          'topBanner': topBanners,
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> addNewDeliveryUser(Map deliveryUserMap) async {
    try {
      var url = '';

      if (deliveryUserMap['profileImage'] != null) {
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('deliveryProfileImages/$uuid');
        await storageReference.putFile(deliveryUserMap['profileImage']);
        url = await storageReference.getDownloadURL();
      }

      //call function
      Map<dynamic, dynamic> map = {
        'mobileNo':
            '${Config().countryMobileNoPrefix}${deliveryUserMap['mobileNo']}',
        'name': deliveryUserMap['name'],
        'url': url,
        'password': deliveryUserMap['password'],
        'email': deliveryUserMap['email'],
        'activated': '${deliveryUserMap['activated']}',
        'seller': mAuth.currentUser.uid,
      };

      var refundRes = await http.post(
        Uri.parse(Config()
            .createDeliveryUserAccountUrl), //TODO: change this URL //it should look something like : https://us-********-**********.cloudfunctions.net/createDeliveryUserAccount
        body: map,
      );

      var refund = jsonDecode(refundRes.body);

      if (refund['message'] != 'Success') {
        return false;
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Stream<DeliveryUserAnalytics> getDeliveryUserAnalytics() {
    DeliveryUserAnalytics userAnalytics;

    try {
      DocumentReference documentReference = db.collection(Paths.sellersPath).doc(
          '${mAuth.currentUser.uid}/${Paths.sellerDeliveryUserAnalyticsPath}');

      return documentReference.snapshots().transform(StreamTransformer<
              DocumentSnapshot, DeliveryUserAnalytics>.fromHandlers(
            handleData:
                (DocumentSnapshot snap, EventSink<DeliveryUserAnalytics> sink) {
              if (snap.data != null) {
                userAnalytics = DeliveryUserAnalytics.fromFirestore(snap);
                sink.add(userAnalytics);
              }
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<DeliveryUser>> getActivatedDeliveryUsers() async {
    try {
      List<DeliveryUser> deliveryUsers = [];

      QuerySnapshot snapshot = await db
          .collection(Paths.deliveryUsersPath)
          .where('activated', isEqualTo: true)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      deliveryUsers = List.from(
        snapshot.docs.map(
          (e) => DeliveryUser.fromFirestore(e),
        ),
      );

      return deliveryUsers;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<DeliveryUser>> getActiveDeliveryUsers() async {
    try {
      List<DeliveryUser> deliveryUsers = [];

      QuerySnapshot snapshot = await db
          .collection(Paths.deliveryUsersPath)
          .where('accountStatus', isEqualTo: 'Active')
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      deliveryUsers = List.from(
        snapshot.docs.map(
          (e) => DeliveryUser.fromFirestore(e),
        ),
      );

      return deliveryUsers;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<DeliveryUser>> getAllDeliveryUsers() async {
    try {
      List<DeliveryUser> deliveryUsers = [];

      QuerySnapshot snapshot = await db
          .collection(Paths.deliveryUsersPath)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      deliveryUsers = List.from(
        snapshot.docs.map(
          (e) => DeliveryUser.fromFirestore(e),
        ),
      );

      return deliveryUsers;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<DeliveryUser>> getDeactivatedDeliveryUsers() async {
    try {
      List<DeliveryUser> deliveryUsers = [];

      QuerySnapshot snapshot = await db
          .collection(Paths.deliveryUsersPath)
          .where('activated', isEqualTo: false)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      deliveryUsers = List.from(
        snapshot.docs.map(
          (e) => DeliveryUser.fromFirestore(e),
        ),
      );

      return deliveryUsers;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<DeliveryUser>> getInactiveDeliveryUsers() async {
    try {
      List<DeliveryUser> deliveryUsers = [];

      QuerySnapshot snapshot = await db
          .collection(Paths.deliveryUsersPath)
          .where('accountStatus', isEqualTo: 'Inactive')
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      deliveryUsers = List.from(
        snapshot.docs.map(
          (e) => DeliveryUser.fromFirestore(e),
        ),
      );

      return deliveryUsers;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> activateDeliveryUser(String uid) async {
    try {
      await db.collection(Paths.deliveryUsersPath).doc(uid).set(
        {
          'activated': true,
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> deactivateDeliveryUser(String uid) async {
    try {
      await db.collection(Paths.deliveryUsersPath).doc(uid).set(
        {
          'activated': false,
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> editDeliveryUser(Map deliveryUserMap) async {
    try {
      var url = deliveryUserMap['profileImageUrl'];

      if (deliveryUserMap['profileImageNew'] != null) {
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('deliveryProfileImages/$uuid');
        await storageReference.putFile(deliveryUserMap['profileImageNew']);
        url = await storageReference.getDownloadURL();
      }

      await db
          .collection(Paths.deliveryUsersPath)
          .doc(deliveryUserMap['uid'])
          .set(
        {
          'activated': deliveryUserMap['activated'],
          'email': deliveryUserMap['email'],
          'mobileNo':
              '${Config().countryMobileNoPrefix}${deliveryUserMap['mobileNo']}',
          'name': deliveryUserMap['name'],
          'profileImageUrl': url,
          'timestamp': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> cancelOrder(Map cancelOrderMap) async {
    try {
      print(cancelOrderMap['paymentMethod']);
      switch (cancelOrderMap['paymentMethod']) {
        case 'COD':
          //COD
          //no refund
          await db
              .collection(Paths.ordersPath)
              .doc(cancelOrderMap['orderId'])
              .set(
            {
              'deliveryDetails': {
                'timestamp': FieldValue.serverTimestamp(),
              },
              'orderStatus': 'Cancelled',
              'cancelledBy': 'Seller',
              'reason': cancelOrderMap['reason'],
              'refundStatus': 'NA',
              'deliveryTracking': FieldValue.arrayUnion([
                {
                  'status': 'Cancelled',
                  'statusMessage': 'Your order is cancelled by seller',
                  'timestamp': Timestamp.now(),
                }
              ]),
            },
            SetOptions(merge: true),
          );

          List<OrderProduct> prods = cancelOrderMap['products'];

          //update the product quantities
          for (var item in prods) {
            await db.collection(Paths.productsPath).doc(item.id).update(
              {
                'skus.${item.skuId}.quantity':
                    FieldValue.increment(int.parse(item.quantity)),
              },
            );
          }
          return true;
          break;
        case 'STRIPE':
          //card
          //refund

          // if (double.parse(cancelOrderMap['walletAmt']) > 0) {
          //   //wallet used
          //   DocumentSnapshot userSnap = await db
          //       .collection(Paths.usersPath)
          //       .doc(cancelOrderMap['uid'])
          //       .get();
          //   GroceryUser groceryUser = GroceryUser.fromFirestore(userSnap);

          //   double currentWalletAmt =
          //       double.parse(groceryUser.myWallet.walletAmt);
          //   double newWalletAmt =
          //       currentWalletAmt + double.parse(cancelOrderMap['walletAmt']);

          //   await db.collection(Paths.usersPath).doc(groceryUser.uid).set({
          //     'myWallet': {
          //       'transactions': FieldValue.arrayUnion([
          //         {
          //           'detail': 'Refund for order #${cancelOrderMap['orderId']}',
          //           'timestamp': DateTime.now(),
          //           'transactionAmt': cancelOrderMap['walletAmt'],
          //           'transactionId': Uuid().v4(),
          //           'transactionType': 'Credit',
          //         }
          //       ]),
          //       'walletAmt': newWalletAmt.toStringAsFixed(2),
          //     }
          //   }, SetOptions(merge: true));
          // }

          // Map<dynamic, dynamic> refundMap = {
          //   'transactionId': cancelOrderMap['transactionId'],
          // };
          // var refundRes = await http.post(
          //   Uri.parse(
// ''), //TODO: Change this URL //it should look something like : https://us-********-**********.cloudfunctions.net/createStripeRefund
          //   body: refundMap,
          // );

          // var refund = jsonDecode(refundRes.body);

          // if (refund['message'] != 'Success' ||
          //     (refund['data']['status'] == 'failed' ||
          //         refund['data']['status'] == 'canceled')) {
          //   return false;
          // }

          // String refundId = refund['data']['id'];

          await db
              .collection(Paths.ordersPath)
              .doc(cancelOrderMap['orderId'])
              .set(
            {
              'deliveryDetails': {
                'timestamp': FieldValue.serverTimestamp(),
              },
              'orderStatus': 'Cancelled',
              'cancelledBy': 'Seller',
              'reason': cancelOrderMap['reason'],
              'refundStatus': 'Processed',
              // 'refundTransactionId': refundId,
              'deliveryTracking': FieldValue.arrayUnion([
                {
                  'status': 'Cancelled',
                  'statusMessage': 'Your order is cancelled by seller',
                  'timestamp': Timestamp.now(),
                }
              ]),
            },
            SetOptions(merge: true),
          );

          DocumentSnapshot userSnap = await db
              .collection(Paths.usersPath)
              .doc(cancelOrderMap['uid'])
              .get();
          GroceryUser groceryUser = GroceryUser.fromFirestore(userSnap);

          double currentWalletAmt =
              double.parse(groceryUser.myWallet.walletAmt);
          double newWalletAmt =
              currentWalletAmt + double.parse(cancelOrderMap['refundAmt']);

          await db.collection(Paths.usersPath).doc(groceryUser.uid).set({
            'myWallet': {
              'transactions': FieldValue.arrayUnion([
                {
                  'detail': 'Refund for order #${cancelOrderMap['orderId']}',
                  'timestamp': DateTime.now(),
                  'transactionAmt': cancelOrderMap['refundAmt'],
                  'transactionId': Uuid().v4(),
                  'transactionType': 'Credit',
                }
              ]),
              'walletAmt': newWalletAmt.toStringAsFixed(2),
            }
          }, SetOptions(merge: true));

          List<OrderProduct> prods = cancelOrderMap['products'];

          //update the product quantities
          for (var item in prods) {
            await db.collection(Paths.productsPath).doc(item.id).update(
              {
                'skus.${item.skuId}.quantity':
                    FieldValue.increment(int.parse(item.quantity)),
              },
            );
          }
          return true;
          break;
        case 'RAZORPAY':
          //razorpay
          //refund

          // if (double.parse(cancelOrderMap['walletAmt']) > 0) {
          //   //wallet used
          //   DocumentSnapshot userSnap = await db
          //       .collection(Paths.usersPath)
          //       .doc(cancelOrderMap['uid'])
          //       .get();
          //   GroceryUser groceryUser = GroceryUser.fromFirestore(userSnap);

          //   double currentWalletAmt =
          //       double.parse(groceryUser.myWallet.walletAmt);
          //   double newWalletAmt =
          //       currentWalletAmt + double.parse(cancelOrderMap['walletAmt']);

          //   await db.collection(Paths.usersPath).doc(groceryUser.uid).set({
          //     'myWallet': {
          //       'transactions': FieldValue.arrayUnion([
          //         {
          //           'detail': 'Refund for order #${cancelOrderMap['orderId']}',
          //           'timestamp': DateTime.now(),
          //           'transactionAmt': cancelOrderMap['walletAmt'],
          //           'transactionId': Uuid().v4(),
          //           'transactionType': 'Credit',
          //         }
          //       ]),
          //       'walletAmt': newWalletAmt.toStringAsFixed(2),
          //     }
          //   }, SetOptions(merge: true));
          // }

          // Map<dynamic, dynamic> refundMap = {
          //   'paymentId': cancelOrderMap['transactionId'],
          // };
          // var refundRes = await http.post(
          //   Uri.parse(
          //       ''), //TODO: change this URL //it should look something like : https://us-********-**********.cloudfunctions.net/initiateRefundForRazorpay
          //   body: refundMap,
          // );

          // print(refundRes.body);
          // var refund = jsonDecode(refundRes.body);

          // if (refund['message'] != 'Success') {
          //   return false;
          // }

          // String refundId = refund['data']['id'];

          await db
              .collection(Paths.ordersPath)
              .doc(cancelOrderMap['orderId'])
              .set(
            {
              'deliveryDetails': {
                'timestamp': FieldValue.serverTimestamp(),
              },
              'orderStatus': 'Cancelled',
              'cancelledBy': 'Seller',
              'reason': cancelOrderMap['reason'],
              'refundStatus': 'Processed',
              // 'refundTransactionId': refundId,
              'deliveryTracking': FieldValue.arrayUnion([
                {
                  'status': 'Cancelled',
                  'statusMessage': 'Your order is cancelled by seller',
                  'timestamp': Timestamp.now(),
                }
              ]),
            },
            SetOptions(merge: true),
          );

          DocumentSnapshot userSnap = await db
              .collection(Paths.usersPath)
              .doc(cancelOrderMap['uid'])
              .get();
          GroceryUser groceryUser = GroceryUser.fromFirestore(userSnap);

          double currentWalletAmt =
              double.parse(groceryUser.myWallet.walletAmt);
          double newWalletAmt =
              currentWalletAmt + double.parse(cancelOrderMap['refundAmt']);

          await db.collection(Paths.usersPath).doc(groceryUser.uid).set({
            'myWallet': {
              'transactions': FieldValue.arrayUnion([
                {
                  'detail': 'Refund for order #${cancelOrderMap['orderId']}',
                  'timestamp': DateTime.now(),
                  'transactionAmt': cancelOrderMap['refundAmt'],
                  'transactionId': Uuid().v4(),
                  'transactionType': 'Credit',
                }
              ]),
              'walletAmt': newWalletAmt.toStringAsFixed(2),
            }
          }, SetOptions(merge: true));

          List<OrderProduct> prods = cancelOrderMap['products'];

          //update the product quantities
          for (var item in prods) {
            await db.collection(Paths.productsPath).doc(item.id).update(
              {
                'skus.${item.skuId}.quantity':
                    FieldValue.increment(int.parse(item.quantity)),
              },
            );
          }

          return true;
          break;
        case 'PREPAID':
          await db
              .collection(Paths.ordersPath)
              .doc(cancelOrderMap['orderId'])
              .set(
            {
              'deliveryDetails': {
                'timestamp': FieldValue.serverTimestamp(),
              },
              'orderStatus': 'Cancelled',
              'cancelledBy': 'Seller',
              'reason': cancelOrderMap['reason'],
              'refundStatus': 'Processed',
              'deliveryTracking': FieldValue.arrayUnion([
                {
                  'status': 'Cancelled',
                  'statusMessage': 'Your order is cancelled by seller',
                  'timestamp': Timestamp.now(),
                }
              ]),
            },
            SetOptions(merge: true),
          );

          DocumentSnapshot userSnap = await db
              .collection(Paths.usersPath)
              .doc(cancelOrderMap['uid'])
              .get();
          GroceryUser groceryUser = GroceryUser.fromFirestore(userSnap);

          double currentWalletAmt =
              double.parse(groceryUser.myWallet.walletAmt);
          double newWalletAmt =
              currentWalletAmt + double.parse(cancelOrderMap['refundAmt']);

          await db.collection(Paths.usersPath).doc(groceryUser.uid).set({
            'myWallet': {
              'transactions': FieldValue.arrayUnion([
                {
                  'detail': 'Refund for order #${cancelOrderMap['orderId']}',
                  'timestamp': DateTime.now(),
                  'transactionAmt': cancelOrderMap['refundAmt'],
                  'transactionId': Uuid().v4(),
                  'transactionType': 'Credit',
                }
              ]),
              'walletAmt': newWalletAmt.toStringAsFixed(2),
            }
          }, SetOptions(merge: true));

          List<OrderProduct> prods = cancelOrderMap['products'];

          //update the product quantities
          for (var item in prods) {
            await db.collection(Paths.productsPath).doc(item.id).update(
              {
                'skus.${item.skuId}.quantity':
                    FieldValue.increment(int.parse(item.quantity)),
              },
            );
          }

          // if (double.parse(cancelOrderMap['walletAmt']) > 0) {
          //   //wallet used
          //   DocumentSnapshot userSnap = await db
          //       .collection(Paths.usersPath)
          //       .doc(cancelOrderMap['uid'])
          //       .get();
          //   GroceryUser groceryUser = GroceryUser.fromFirestore(userSnap);

          //   double currentWalletAmt =
          //       double.parse(groceryUser.myWallet.walletAmt);
          //   double newWalletAmt =
          //       currentWalletAmt + double.parse(cancelOrderMap['walletAmt']);

          //   await db.collection(Paths.usersPath).doc(groceryUser.uid).set({
          //     'myWallet': {
          //       'transactions': FieldValue.arrayUnion([
          //         {
          //           'detail': 'Refund for order #${cancelOrderMap['orderId']}',
          //           'timestamp': DateTime.now(),
          //           'transactionAmt': cancelOrderMap['walletAmt'],
          //           'transactionId': Uuid().v4(),
          //           'transactionType': 'Credit',
          //         }
          //       ]),
          //       'walletAmt': newWalletAmt.toStringAsFixed(2),
          //     }
          //   }, SetOptions(merge: true));
          // }

          return true;
          break;
        default:
          return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> proceedOrder(Map proceedOrderMap) async {
    try {
      if (proceedOrderMap['assignDeliveryGuy']) {
        await db
            .collection(Paths.ordersPath)
            .doc(proceedOrderMap['orderId'])
            .set(
          {
            'deliveryDetails': {
              'deliveryStatus': proceedOrderMap['deliveryStatus'],
              'mobileNo': proceedOrderMap['mobileNo'],
              'name': proceedOrderMap['name'],
              'otp': proceedOrderMap['otp'],
              'timestamp': FieldValue.serverTimestamp(),
              'uid': proceedOrderMap['uid'],
            },
            'orderStatus': 'Out for delivery',
            'deliveryTracking': FieldValue.arrayUnion([
              {
                'status': 'Out for delivery',
                'statusMessage': 'Your order is out for delivery',
                'timestamp': Timestamp.now(),
              }
            ]),
          },
          SetOptions(merge: true),
        );
      } else {
        await db
            .collection(Paths.ordersPath)
            .doc(proceedOrderMap['orderId'])
            .set(
          {
            'deliveryDetails': {
              'deliveryStatus': proceedOrderMap['deliveryStatus'],
              'timestamp': FieldValue.serverTimestamp(),
            },
            'orderStatus': 'Processed',
            'deliveryTracking': FieldValue.arrayUnion([
              {
                'status': 'Processed',
                'statusMessage': 'Your order is processed by seller',
                'timestamp': Timestamp.now(),
              }
            ]),
          },
          SetOptions(merge: true),
        );
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<List<DeliveryUser>> getReadyDeliveryUsers() async {
    try {
      List<DeliveryUser> deliveryUsers = [];

      QuerySnapshot snapshot = await db
          .collection(Paths.deliveryUsersPath)
          .where('activated', isEqualTo: true)
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .get();

      deliveryUsers = List.from(
        snapshot.docs.map(
          (e) => DeliveryUser.fromFirestore(e),
        ),
      );

      return deliveryUsers;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Order>> getPendingRefundOrders() async {
    List<Order> pendingRefundOrders = [];

    try {
      QuerySnapshot snapshot = await db
          .collection(Paths.ordersPath)
          .orderBy('orderTimestamp', descending: true)
          .where('orderStatus', isEqualTo: 'Cancelled')
          .where('refundStatus', isEqualTo: 'Not processed')
          .get();

      if (snapshot.docs != null) {
        pendingRefundOrders = List<Order>.from(
          (snapshot.docs).map(
            (e) => Order.fromFirestore(e),
          ),
        );
        return pendingRefundOrders;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> initiateRefund(Map initiateRefundMap) async {
    try {
      //refund
      switch (initiateRefundMap['paymentMethod']) {
        case 'CARD':
          Map<dynamic, dynamic> refundMap = {
            'transactionId': initiateRefundMap['transactionId'],
          };
          var refundRes = await http.post(
            Uri.parse(Config()
                .createStripeRefundUrl), //TODO: Change this URL //it should look something like : https://us-********-**********.cloudfunctions.net/createStripeRefund
            body: refundMap,
          );

          var refund = jsonDecode(refundRes.body);

          if (refund['message'] != 'Success' ||
              (refund['data']['status'] == 'failed' ||
                  refund['data']['status'] == 'canceled')) {
            return false;
          }

          String refundId = refund['data']['id'];

          await db
              .collection(Paths.ordersPath)
              .doc(initiateRefundMap['orderId'])
              .set(
            {
              'refundStatus': 'Processed',
              'refundTransactionId': refundId,
            },
            SetOptions(merge: true),
          );
          return true;
          break;
        case 'RAZORPAY':
          Map<dynamic, dynamic> refundMap = {
            'paymentId': initiateRefundMap['transactionId'],
          };
          var refundRes = await http.post(
            Uri.parse(Config()
                .initiateRefundForRazorpayUrl), //TODO: CHANGE this to your url //it should look something like : https://us-********-**********.cloudfunctions.net/initiateRefundForRazorpay
            body: refundMap,
          );

          var refund = jsonDecode(refundRes.body);

          if (refund['message'] != 'Success') {
            return false;
          }

          String refundId = refund['data']['id'];

          await db
              .collection(Paths.ordersPath)
              .doc(initiateRefundMap['orderId'])
              .set(
            {
              'refundStatus': 'Processed',
              'refundTransactionId': refundId,
            },
            SetOptions(merge: true),
          );
          return true;
          break;
        default:
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> addNewAdmin(Map adminMap) async {
    try {
      String password = Uuid().v4().substring(0, 8);
      var url = '';

      if (adminMap['profileImage'] != null) {
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('adminProfileImages/$uuid');
        await storageReference.putFile(adminMap['profileImage']);
        url = await storageReference.getDownloadURL();
      }

      //call function
      Map<dynamic, dynamic> map = {
        'mobileNo': '${Config().countryMobileNoPrefix}${adminMap['mobileNo']}',
        'name': 'ADMIN_' + Random.secure().nextInt(10000).toString(),
        'url': url,
        'password': password,
        'email': adminMap['email']
      };
      var refundRes = await http.post(
        Uri.parse(
            ''), //TODO: change this URL //it should look something like : https://us-********-**********.cloudfunctions.net/createAdminAccount
        body: map,
      );

      var refund = jsonDecode(refundRes.body);

      if (refund['message'] != 'Success') {
        return false;
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Stream<SellerNotification> getNotifications() {
    String uid = mAuth.currentUser.uid;

    DocumentReference documentReference =
        db.collection(Paths.sellerNoticationsPath).doc(uid);

    print('inside notifications');
    return documentReference.snapshots().transform(
          StreamTransformer<DocumentSnapshot, SellerNotification>.fromHandlers(
            handleData:
                (DocumentSnapshot docSnap, EventSink<SellerNotification> sink) {
              SellerNotification userNotification =
                  SellerNotification.fromFirestore(docSnap);
              print('UID :: ${userNotification.uid}');
              sink.add(userNotification);
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ),
        );
  }

  @override
  Future<void> markNotificationRead() async {
    try {
      String uid = mAuth.currentUser.uid;

      await db.collection(Paths.sellerNoticationsPath).doc(uid).set({
        'unread': false,
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> activateAdmin(String uid) async {
    try {
      await db.collection(Paths.adminsPath).doc(uid).set(
        {
          'activated': true,
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> deactivateAdmin(String uid) async {
    try {
      await db.collection(Paths.adminsPath).doc(uid).set(
        {
          'activated': false,
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<GlobalSettings> getCartInfo() async {
    try {
      DocumentSnapshot snapCartInfo = await db.doc(Paths.cartInfo).get();
      DocumentSnapshot snapSellerSettings =
          await db.doc(Paths.sellerSettings).get();

      return GlobalSettings(
        cartInfo: CartInfo.fromFirestore(snapCartInfo),
        sellerSettings: SellerSettings.fromFirestore(snapSellerSettings),
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> updateCartInfo(Map map) async {
    try {
      db.doc(Paths.cartInfo).set(
        {
          'discountAmt': map['discountAmt'],
          'discountPer': map['discountPer'],
          'shippingAmt': map['shippingAmt'],
          'taxPer': map['taxPer'],
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<PaymentMethods> getPaymentMethods() async {
    try {
      DocumentSnapshot snap = await db.doc(Paths.paymentMethods).get();
      return PaymentMethods.fromFirestore(snap);
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> updatePaymentMethods(Map map) async {
    try {
      db.doc(Paths.paymentMethods).set(
        {
          'cod': map['cod'],
          'razorpay': map['razorpay'],
          'storePickup': map['storePickup'],
          'stripe': map['stripe'],
          'paypal': map['paypal'],
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<String> sendNewNotification(Map map) async {
    try {
      var url = '';
      Map notifMap = Map();
      notifMap.putIfAbsent('title', () => map['title']);
      notifMap.putIfAbsent('body', () => map['body']);
      notifMap.putIfAbsent('notificationType', () => map['notificationType']);

      if (map['category'] != null) {
        notifMap.putIfAbsent('category', () => map['category']);
      }

      if (map['image'] != null) {
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('pushNotificationImages/$uuid');
        await storageReference.putFile(map['image']);
        url = await storageReference.getDownloadURL();

        notifMap.putIfAbsent('imageUrl', () => url);
      }

      print(url);

      //call function
      var refundRes = await http.post(
        Uri.parse(
            ''), //TODO: change this URL //it should look something like : https://us-********-**********.cloudfunctions.net/sendNewNotification
        body: notifMap,
      );

      var refund = jsonDecode(refundRes.body);

      if (refund['message'] != 'Success') {
        return 'Failed to send notification!';
      }

      return '';
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<String> addNewCoupon(Map<String, dynamic> map) async {
    try {
      var docId = Uuid().v4();

      map.putIfAbsent('couponId', () => docId);
      map.putIfAbsent('active', () => true);

      QuerySnapshot snapshot = await db
          .collection(Paths.couponsPath)
          .where('couponCode', isEqualTo: map['couponCode'])
          .where('active', isEqualTo: true)
          .get();

      if (snapshot.size > 0) {
        //exists
        return '${map['couponCode']} coupon code is already active!';
      }

      await db.collection(Paths.couponsPath).doc(docId).set(map);

      return '';
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<String> editCoupon(Map<String, dynamic> map) async {
    try {
      await db.collection(Paths.couponsPath).doc(map['couponId']).set(
            map,
            SetOptions(merge: true),
          );

      return '';
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Coupon>> getAllCoupons() async {
    try {
      List<Coupon> coupons = [];
      QuerySnapshot snapshot = await db
          .collection(Paths.couponsPath)
          .orderBy('active', descending: true)
          .get();

      if (snapshot.size > 0) {
        //exists
        coupons = List.from(
          snapshot.docs.map(
            (e) => Coupon.fromFirestore(e),
          ),
        );
      }
      return coupons;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<String> changePassword(Map map) async {
    try {
      //login with old password and check if can login
      //if logs in then password is correct otherwise return invalid old password
      UserCredential userCredential;

      //login
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: mAuth.currentUser.email, password: map['oldPassword']);

      print(userCredential.credential);
      print(userCredential.user.email);

      if (userCredential.user.email != null) {
        //logged in
        mAuth.currentUser.updatePassword(map['newPassword']);
        return '';
      } else {
        return 'Old password is incorrect';
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  //payouts
  @override
  Stream<List<Payouts>> getAllPayouts() {
    try {
      CollectionReference documentReference = db.collection(Paths.payoutsPath);

      return documentReference
          .where('seller', isEqualTo: mAuth.currentUser.uid)
          .orderBy('requestedOn', descending: true)
          .snapshots()
          .transform(
              StreamTransformer<QuerySnapshot, List<Payouts>>.fromHandlers(
            handleData: (QuerySnapshot snap, EventSink<List<Payouts>> sink) {
              List<Payouts> payouts = [];

              if (snap.size > 0) {
                for (var item in snap.docs) {
                  payouts.add(Payouts.fromFirestore(item));
                }
              }

              sink.add(payouts);
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Stream<Payout> getPayoutAnalytics() {
    try {
      DocumentReference documentReference =
          db.collection(Paths.sellersPath).doc(mAuth.currentUser.uid);

      return documentReference
          .snapshots()
          .transform(StreamTransformer<DocumentSnapshot, Payout>.fromHandlers(
            handleData: (DocumentSnapshot snap, EventSink<Payout> sink) {
              print(snap);

              sink.add(Payout.fromMap(snap.data()['payout']));
            },
            handleError: (error, stackTrace, sink) {
              print('ERROR: $error');
              print(stackTrace);
              sink.addError(error);
            },
          ));
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> requestPayout(Map<String, dynamic> map) async {
    try {
      //getting the latest payout
      DocumentSnapshot snapshot = await db
          .collection(Paths.sellersPath)
          .doc(mAuth.currentUser.uid)
          .get();

      Payout payout = Payout.fromMap(snapshot.data()['payout']);

      var newAvailablePayout = payout.availablePayout - map['payoutAmt'];

      DocumentSnapshot payoutCounterDoc =
          await db.doc(Paths.payoutCounterPath).get();

      String payoutPrefix = payoutCounterDoc.data()['prefix'];
      String payoutIdCounter = payoutCounterDoc.data()['payoutIdCounter'];
      payoutIdCounter = (int.parse(payoutIdCounter) + 1)
          .toString()
          .padLeft(payoutIdCounter.length, '0');

      String payoutId = payoutPrefix + payoutIdCounter;

      await db.collection(Paths.payoutsPath).doc(payoutId).set({
        'bankDetails': {
          'accountName': map['accountName'],
          'accountNo': map['accountNo'],
          'bankName': map['bankName'],
          'upiId': map['upiId'],
          'payoutDetails': map['payoutDetails'],
          'ifscCode': map['ifscCode'],
        },
        'notes': map['notes'],
        'payoutVia': map['payoutVia'],
        'paidOn': null,
        'payoutAmt': map['payoutAmt'],
        'payoutId': payoutId,
        'requestedOn': Timestamp.now(),
        'status': 'Requested',
        'reason': '',
        'seller': mAuth.currentUser.uid,
      });

      //updating payout analytics
      await db.collection(Paths.sellersPath).doc(mAuth.currentUser.uid).set(
        {
          'payout': {
            'availablePayout': newAvailablePayout,
            'previousPayout': map['payoutAmt'],
          }
        },
        SetOptions(merge: true),
      );

      await db.doc(Paths.payoutCounterPath).set({
        'currentPayoutId': payoutId,
        'payoutIdCounter': payoutIdCounter,
      }, SetOptions(merge: true));

      await db.doc(Paths.payoutAnalyticsPath).set(
        {
          'requestedPayouts': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> modifyRequestPayout(Map<String, dynamic> map) async {
    try {
      String payoutId = map['payoutId'];

      await db.collection(Paths.payoutsPath).doc(payoutId).set(
        {
          'bankDetails': {
            'accountName': map['accountName'],
            'accountNo': map['accountNo'],
            'bankName': map['bankName'],
            'upiId': map['upiId'],
            'payoutDetails': map['payoutDetails'],
            'ifscCode': map['ifscCode'],
          },
          'notes': map['notes'],
          'payoutVia': map['payoutVia'],
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> cancelPayout(Map<String, dynamic> map) async {
    try {
      //getting the latest payout
      DocumentSnapshot snapshot = await db
          .collection(Paths.sellersPath)
          .doc(mAuth.currentUser.uid)
          .get();

      Payout payout = Payout.fromMap(snapshot.data()['payout']);

      var newAvailablePayout = payout.availablePayout + map['payoutAmt'];

      // for (var i = 0; i < newPayout.payouts.length; i++) {
      //   if (newPayout.payouts[i].payoutId == map['payoutId']) {
      //     newPayout.payouts.removeAt(i);
      //     break;
      //   }
      // }

      // var newPreviousPayout;

      // if (newPayout.payouts.length > 0) {
      //   Payouts prevLastPayout = newPayout.payouts.last;

      //   newPreviousPayout = prevLastPayout.payoutAmt;
      // } else {
      //   newPreviousPayout = 0;
      // }

      String payoutId = map['payoutId'];

      //delete the payout request
      await db.collection(Paths.sellersPath).doc(mAuth.currentUser.uid).update({
        'payout': {
          'availablePayout': newAvailablePayout,
        }
        // 'previousPayout': newPreviousPayout,
      });

      await db.collection(Paths.payoutsPath).doc(payoutId).set(
        {
          'status': 'Cancelled',
        },
        SetOptions(merge: true),
      );

      DocumentSnapshot snapshot2 =
          await db.doc(Paths.payoutAnalyticsPath).get();

      PayoutAnalytics payoutAnalytics =
          PayoutAnalytics.fromFirestore(snapshot2);

      await db.doc(Paths.payoutAnalyticsPath).set(
        {
          'requestedPayouts': payoutAnalytics.requestedPayouts - 1,
          'cancelledPayouts': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<SellerFaq> getAllFaqs() async {
    try {
      DocumentSnapshot snapshot = await db.doc(Paths.sellerFaqs).get();

      SellerFaq sellerFaq = SellerFaq.fromFirestore(snapshot);

      return sellerFaq;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<Zipcode> getAllZipcodes() async {
    try {
      DocumentSnapshot documentSnapshot = await db
          .collection(Paths.sellersPath)
          .doc(mAuth.currentUser.uid)
          .get();

      Seller seller = Seller.fromFirestore(documentSnapshot);
      return seller.zipcode;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<bool> updateZipcodes(Map map) async {
    try {
      await db.collection(Paths.sellersPath).doc(mAuth.currentUser.uid).set(
        {
          'zipcodeRestriction': {
            'zipcodes': map['zipcodes'],
            'isEnabled': map['isEnabled'],
          },
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
