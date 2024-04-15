import 'package:multivendor_seller/models/admin.dart';
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
import 'package:multivendor_seller/models/product.dart';
import 'package:multivendor_seller/models/product_analytics.dart';
import 'package:multivendor_seller/models/seller.dart';
import 'package:multivendor_seller/models/seller_notification.dart';
import 'package:multivendor_seller/models/user.dart';
import 'package:multivendor_seller/models/user_analytics.dart';
import 'package:multivendor_seller/models/user_report.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseProvider {
  void dispose();
}

abstract class BaseAuthenticationProvider extends BaseProvider {
  Future<bool> checkIfSignedIn();
  Future<bool> signOutUser();
  Future<User> getCurrentUser();
  Future<String> signInWithEmail(String email, String password);
  Future<String> signUpWithEmail(Map map);
}

abstract class BaseUserDataProvider extends BaseProvider {
  Stream<List<Order>> getNewOrders();

  Future<List<Order>> getProcessedOrders();

  Future<List<Order>> getOutForDeliveryOrders();

  Future<List<Order>> getDeliveredOrders();

  Future<List<Order>> getCancelledOrders();

  Future<List<Order>> getPendingRefundOrders();

  Future<List<Order>> updateNewOrders(List<Order> allOrders);

  Stream<OrderAnalytics> getOrderAnalytics();

  Future<List<Product>> getAllProducts();

  Future<List<Product>> getActiveProducts();

  Future<List<Product>> getInactiveProducts();

  Future<List<Product>> getTrendingProducts();

  Future<List<Product>> getFeaturedProducts();

  Stream<List<Product>> getLowInventoryProducts();

  Future<bool> updateLowInventoryProduct(String id, int quantity);

  Future<List<Category>> getAllCategories();

  Stream<ProductAnalytics> getProductAnalytics();

  Stream<InventoryAnalytics> getInventoryAnalytics();

  Stream<MessageAnalytics> getMessageAnalytics();

  Stream<UserAnalytics> getUserAnalytics();

  Future<List<Product>> getAllMessages();

  Future<List<Product>> getNewMessages();

  Future<bool> addNewProduct(Map<dynamic, dynamic> product);

  Future<bool> editProduct(Map<dynamic, dynamic> product);

  Future<bool> addNewCategory(Map<dynamic, dynamic> category);

  Future<bool> editCategory(Map<dynamic, dynamic> category);

  Future<bool> postAnswer(String id, String ans, String queId);

  Future<bool> deleteProduct(String id);

  Future<bool> deleteCategory(String categoryId);

  Future<List<GroceryUser>> getAllUsers();

  Future<List<GroceryUser>> getActiveUsers();

  Future<List<GroceryUser>> getInactiveUsers();

  Future<List<GroceryUser>> getBlockedUsers();

  Stream<List<UserReport>> getUserReports();

  Future<Product> getUserReportProduct(String id);

  Future<List<Order>> getUsersOrder(String uid);

  Future<Seller> getMyAccountDetails();
  Future<String> changePassword(Map map);

  Future<bool> blockUser(String uid);

  Future<bool> unblockUser(String uid);

  Future<bool> proceedInitialSetup(Map map);

  Future<bool> checkIfNewAdmin(String uid);

  Future<bool> checkIfInitialSetupDone();

  Future<bool> updateAdminDetails(Map adminMap);

  Future<List<Admin>> getAllAdmins();

  Future<Map> getAllBanners();

  Future<bool> updateBanners(Map bannersMap);

  Future<bool> addNewDeliveryUser(Map deliveryUserMap);

  Future<bool> editDeliveryUser(Map deliveryUserMap);

  Stream<DeliveryUserAnalytics> getDeliveryUserAnalytics();

  Future<List<DeliveryUser>> getActivatedDeliveryUsers();

  Future<List<DeliveryUser>> getDeactivatedDeliveryUsers();

  Future<List<DeliveryUser>> getActiveDeliveryUsers();

  Future<List<DeliveryUser>> getInactiveDeliveryUsers();

  Future<List<DeliveryUser>> getAllDeliveryUsers();

  Future<List<DeliveryUser>> getReadyDeliveryUsers();

  Future<bool> activateDeliveryUser(String uid);

  Future<bool> deactivateDeliveryUser(String uid);

  Future<bool> proceedOrder(Map proceedOrderMap);

  Future<bool> cancelOrder(Map cancelOrderMap);

  Future<bool> initiateRefund(Map initiateRefundMap);

  Future<bool> addNewAdmin(Map adminMap);

  Future<bool> activateAdmin(String uid);

  Future<bool> deactivateAdmin(String uid);

  //notifications
  Stream<SellerNotification> getNotifications();
  Future<void> markNotificationRead();

  //mange cart
  Future<GlobalSettings> getCartInfo();
  Future<bool> updateCartInfo(Map map);

  //payment method settings
  Future<PaymentMethods> getPaymentMethods();
  Future<bool> updatePaymentMethods(Map map);

  //Push notifications
  Future<String> sendNewNotification(Map map);

  //manage coupons
  Future<String> addNewCoupon(Map<String, dynamic> map);
  Future<String> editCoupon(Map<String, dynamic> map);
  Future<List<Coupon>> getAllCoupons();

  //payouts
  Future<bool> requestPayout(Map<String, dynamic> map);
  Future<bool> modifyRequestPayout(Map<String, dynamic> map);
  Future<bool> cancelPayout(Map<String, dynamic> map);
  Stream<List<Payouts>> getAllPayouts();
  Stream<Payout> getPayoutAnalytics();

  //faq
  Future<SellerFaq> getAllFaqs();

  //zipcode restriction
  Future<bool> updateZipcodes(Map map);
  Future<Zipcode> getAllZipcodes();
}

abstract class BaseStorageProvider extends BaseProvider {}
