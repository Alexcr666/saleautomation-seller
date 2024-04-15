import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multivendor_seller/config/config.dart';

class Order {
  String cancelledBy;
  String reason;
  String refundStatus;
  CustDetails custDetails;
  DeliveryDetails deliveryDetails;
  Timestamp deliveryTimestamp;
  String orderId;
  String orderStatus;
  Timestamp orderTimestamp;
  List<OrderProduct> products;
  String seller;
  Charges charges;
  String deliveryNote;
  PaymentDetails paymentDetails;
  DeliveryTracking deliveryTracking;

  Order({
    this.cancelledBy,
    this.reason,
    this.refundStatus,
    this.custDetails,
    this.deliveryDetails,
    this.deliveryTimestamp,
    this.orderId,
    this.orderStatus,
    this.orderTimestamp,
    this.products,
    this.charges,
    this.deliveryNote,
    this.deliveryTracking,
    this.paymentDetails,
    this.seller,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return Order(
      cancelledBy: data['cancelledBy'],
      reason: data['reason'],
      refundStatus: data['refundStatus'],
      custDetails: CustDetails.fromHashmap(data['custDetails']),
      deliveryDetails: DeliveryDetails.fromHashmap(data['deliveryDetails']),
      deliveryTimestamp: data['deliveryTimestamp'],
      orderId: data['orderId'],
      orderStatus: data['orderStatus'],
      orderTimestamp: data['orderTimestamp'],
      seller: data['seller'],
      products: List<OrderProduct>.from(
        data['products'].map(
          (data) {
            return OrderProduct(
              category: data['category'],
              id: data['id'],
              ogPrice: data['ogPrice'],
              price: data['price'],
              productImage: data['productImage'],
              quantity: data['quantity'],
              subCategory: data['subCategory'],
              totalAmt: data['totalAmt'],
              unitQuantity: data['unitQuantity'],
              name: data['name'],
              skuId: data['skuId'],
            );
          },
        ),
      ),
      deliveryNote: data['deliveryNote'],
      charges: Charges.fromHashmap(data['charges']),
      paymentDetails: PaymentDetails.fromHashmap(data['paymentDetails']),
      deliveryTracking: DeliveryTracking.fromHashmap(data['deliveryTracking']),
    );
  }
}

class Charges {
  String orderAmt;
  String shippingAmt;
  String discountAmt;
  String totalAmt;
  String taxAmt;
  String couponDiscountAmt;
  bool appliedCoupon;
  String couponCode;
  String couponId;
  String walletAmt;

  Charges({
    this.discountAmt,
    this.orderAmt,
    this.shippingAmt,
    this.totalAmt,
    this.taxAmt,
    this.appliedCoupon,
    this.couponCode,
    this.couponDiscountAmt,
    this.couponId,
    this.walletAmt,
  });

  factory Charges.fromHashmap(Map<String, dynamic> charges) {
    return Charges(
      discountAmt: charges['discountAmt'],
      orderAmt: charges['orderAmt'],
      shippingAmt: charges['shippingAmt'],
      totalAmt: charges['totalAmt'],
      taxAmt: charges['taxAmt'],
      appliedCoupon: charges['appliedCoupon'],
      couponCode: charges['couponCode'],
      couponDiscountAmt: charges['couponDiscountAmt'],
      couponId: charges['couponId'],
      walletAmt: charges['walletAmt'],
    );
  }
}

class DeliveryDetails {
  String deliveryStatus;
  String mobileNo;
  String name;
  String uid;
  String otp;
  String reason;
  Timestamp timestamp;

  DeliveryDetails({
    this.mobileNo,
    this.name,
    this.uid,
    this.deliveryStatus,
    this.otp,
    this.reason,
    this.timestamp,
  });

  factory DeliveryDetails.fromHashmap(Map<String, dynamic> deliveryDetails) {
    return DeliveryDetails(
      deliveryStatus: deliveryDetails['deliveryStatus'],
      mobileNo: deliveryDetails['mobileNo'],
      name: deliveryDetails['name'],
      uid: deliveryDetails['uid'],
      otp: deliveryDetails['otp'],
      reason: deliveryDetails['reason'],
      timestamp: deliveryDetails['timestamp'],
    );
  }
}

class CustDetails {
  String address;
  String mobileNo;
  String name;
  String uid;
  String profileImageUrl;
  CustLocationDetails locationDetails;
  String email;

  CustDetails({
    this.address,
    this.mobileNo,
    this.name,
    this.uid,
    this.email,
    this.locationDetails,
    this.profileImageUrl,
  });

  factory CustDetails.fromHashmap(Map<String, dynamic> custDetails) {
    return CustDetails(
      address: custDetails['address'],
      mobileNo: custDetails['mobileNo'],
      name: custDetails['name'],
      uid: custDetails['uid'],
      email: custDetails['email'],
      locationDetails:
          CustLocationDetails.fromHashmap(custDetails['locationDetails']),
      profileImageUrl: custDetails['profileImageUrl'],
    );
  }
}

class CustLocationDetails {
  String address;
  String placeId;
  GeoPoint location;
  String postalCode;
  String tag;

  CustLocationDetails({
    this.address,
    this.placeId,
    this.postalCode,
    this.location,
    this.tag,
  });

  factory CustLocationDetails.fromHashmap(Map<String, dynamic> address) {
    return CustLocationDetails(
      address: address['address'],
      placeId: address['placeId'],
      postalCode: address['postalCode'],
      tag: address['tag'],
      location: address['location'],
    );
  }
}

class OrderProduct {
  String category;
  String id;
  String ogPrice;
  String price;
  String productImage;
  String quantity;
  String subCategory;
  String totalAmt;
  String unitQuantity;
  String name;
  String skuId;

  OrderProduct({
    this.category,
    this.id,
    this.ogPrice,
    this.price,
    this.productImage,
    this.quantity,
    this.subCategory,
    this.totalAmt,
    this.unitQuantity,
    this.name,
    this.skuId,
  });

  factory OrderProduct.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return OrderProduct(
      category: data['category'],
      id: data['id'],
      ogPrice: data['ogPrice'],
      price: data['price'],
      productImage: data['productImage'],
      quantity: data['quantity'],
      subCategory: data['subCategory'],
      totalAmt: data['totalAmt'],
      unitQuantity: data['unitQuantity'],
      name: data['name'],
      skuId: data['skuId'],
    );
  }

  String getIndex(int index) {
    switch (index) {
      case 0:
        return name;
      case 1:
        return unitQuantity;
      case 2:
        return category;
      case 3:
        return quantity;
      case 4:
        return '${Config().currency}$price';
      case 5:
        return '${Config().currency}$totalAmt';
    }
    return '';
  }
}

class PaymentDetails {
  String refundTransactionId;
  String paymentMethod;
  String transactionId;

  PaymentDetails({
    this.paymentMethod,
    this.refundTransactionId,
    this.transactionId,
  });

  factory PaymentDetails.fromHashmap(Map<String, dynamic> map) {
    return PaymentDetails(
      paymentMethod: map['paymentMethod'],
      refundTransactionId: map['refundTransactionId'],
      transactionId: map['transactionId'],
    );
  }
}

class DeliveryTracking {
  List<DeliveryTrackingStatus> deliveryStatus;

  DeliveryTracking({
    this.deliveryStatus,
  });

  factory DeliveryTracking.fromHashmap(List deliveryDetails) {
    return DeliveryTracking(
      deliveryStatus: List<DeliveryTrackingStatus>.from(
        deliveryDetails.map(
          (data) {
            return DeliveryTrackingStatus(
              status: data['status'],
              timestamp: data['timestamp'],
              statusMessage: data['statusMessage'],
            );
          },
        ),
      ),
    );
  }
}

class DeliveryTrackingStatus {
  Timestamp timestamp;
  String status;
  String statusMessage;

  DeliveryTrackingStatus({
    this.status,
    this.statusMessage,
    this.timestamp,
  });

  factory DeliveryTrackingStatus.fromHashmap(Map<String, dynamic> map) {
    return DeliveryTrackingStatus(
      status: map['status'],
      statusMessage: map['statusMessage'],
      timestamp: map['timestamp'],
    );
  }
}
