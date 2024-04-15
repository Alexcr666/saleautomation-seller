class Config {
//TODO: change the currency and country prefix as per your need
  String currency = 'Rs.';
  String countryMobileNoPrefix = "+91";

  //stripe api keys
  String apiBase = 'https://api.stripe.com';

  String currencyCode = 'inr';

  //dynamic link url //TODO: change this to yours
  String urlPrefix = 'DYNAMIC_LINK_URL';

//TODO:change this package name to yours
  String packageName = 'PACKAGE_NAME'; //eg: com.b2x.multivendorstore
  String packageNameIos = 'PACKAGE_NAME'; //eg: com.b2x.multivendorstore

  //TODO: change the app name and support url as per your need
  String appName = 'Multivendor Seller';
  String supportUrl = 'support@b2xdev.com';

  //TODO: set your low inventory threshold
  int lowInventoryNo = 20;

  //TODO: change the url to yours
  //to see your url go to Firebase console -> Functions and check urls
  String updateMessagesUrl =
      'URL_HERE'; //it should look something like : https://us-********-**********.cloudfunctions.net/updateAnsweredMessageAnalytics
  String createDeliveryUserAccountUrl =
      'URL_HERE'; //it should look something like : https://us-********-**********.cloudfunctions.net/createDeliveryUserAccount
  String createStripeRefundUrl =
      'URL_HERE'; //it should look something like : https://us-********-**********.cloudfunctions.net/createStripeRefund
  String initiateRefundForRazorpayUrl =
      'URL_HERE'; //it should look something like : https://us-********-**********.cloudfunctions.net/initiateRefundForRazorpay

  //NOTE: DO NOT CHANGE THE BELOW GIVEN VALUES
  List<String> cancelOrderReasons = [
    'Product is not available',
    'Product is out of stock',
    'Product is in high demand',
    'Don\'t want to specify',
    'Other',
  ];
  List<String> payoutPaymentTypes = [
    'Bank Account',
    'UPI',
    'Other',
  ];

  List<Map> notificationTypes = [
    {
      'name': 'Trending',
      'desc': 'This will take user to Trending screen.',
      'id': 'TRENDING_NOTIF',
    },
    {
      'name': 'Featured',
      'desc': 'This will take user to Featured screen.',
      'id': 'FEATURED_NOTIF',
    },
    {
      'name': 'General',
      'desc': 'This is a general notification which will just open the app.',
      'id': 'GENERAL_NOTIF',
    },
    {
      'name': 'Category',
      'desc': 'This will take user to the mentioned category screen.',
      'id': 'CATEGORY_NOTIF',
    },
  ];

  List<Map> couponTypes = [
    {
      'name': 'Limited time coupon',
      'desc': 'This will have a limited activated time period.',
      'id': 'LIMITED_TIME_COUPON',
    },
    {
      'name': 'Limited use coupon',
      'desc': 'This can be used limited no. of times.',
      'id': 'LIMITED_USE_COUPON',
    },
  ];
}
