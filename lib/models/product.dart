import 'package:cloud_firestore/cloud_firestore.dart';

import 'seller.dart';

class Product {
  AdditionalInfo additionalInfo;
  String category;
  String description;
  String id;
  bool inStock;
  bool isListed;
  String name;
  List productImages;
  List<QuestionAnswer> queAndAns;
  List<Review> reviews;
  String subCategory;
  Timestamp timestamp;
  bool trending;
  bool featured;
  var views;
  List<Sku> skus;
  List keywords;
  Seller seller;
  bool isDiscounted;
  var discount;

  Product({
    this.additionalInfo,
    this.category,
    this.description,
    this.id,
    this.inStock,
    this.isListed,
    this.name,
    this.productImages,
    this.queAndAns,
    this.reviews,
    this.subCategory,
    this.timestamp,
    this.trending,
    this.featured,
    this.views,
    this.skus,
    this.keywords,
    this.discount,
    this.isDiscounted,
    this.seller,
  });

  factory Product.fromFirestore(
      DocumentSnapshot snapshot, DocumentSnapshot sellerSnap) {
    Map data = snapshot.data();
    return Product(
      additionalInfo: AdditionalInfo.fromHashmap(data['additionalInfo']),
      category: data['category'],
      description: data['description'],
      id: data['id'],
      inStock: data['inStock'],
      isListed: data['isListed'],
      name: data['name'],
      productImages: data['productImages'],
      queAndAns: getListOfQueAns(data['queAndAns']),
      reviews: getListOfReviews(data['reviews']),
      skus: getListOfSkus(data['skus']),
      subCategory: data['subCategory'],
      timestamp: data['timestamp'],
      trending: data['trending'],
      featured: data['featured'],
      views: data['views'],
      keywords: data['keywords'],
      discount: data['discount'],
      isDiscounted: data['isDiscounted'],
      seller: Seller.fromFirestore(sellerSnap),
    );
  }
}

class QuestionAnswer {
  String ans;
  String que;
  Timestamp timestamp;
  String userId;
  String userName;
  String queId;

  QuestionAnswer({
    this.ans,
    this.que,
    this.timestamp,
    this.userId,
    this.userName,
    this.queId,
  });

  factory QuestionAnswer.fromHashMap(Map<String, dynamic> queAndAns) {
    return QuestionAnswer(
      ans: queAndAns['ans'],
      que: queAndAns['que'],
      timestamp: queAndAns['timestamp'],
      userId: queAndAns['userId'],
      userName: queAndAns['userName'],
      queId: queAndAns['queId'],
    );
  }
}

class Review {
  String review;
  String rating;
  Timestamp timestamp;
  String userId;
  String userName;
  String reviewId;

  Review({
    this.rating,
    this.review,
    this.timestamp,
    this.userId,
    this.userName,
    this.reviewId,
  });

  factory Review.fromHashMap(Map<String, dynamic> review) {
    return Review(
      rating: review['rating'],
      review: review['review'],
      timestamp: review['timestamp'],
      userId: review['userId'],
      userName: review['userName'],
      reviewId: review['reviewId'],
    );
  }
}

class AdditionalInfo {
  String bestBefore;
  String brand;
  String manufactureDate;
  String shelfLife;

  AdditionalInfo({
    this.bestBefore,
    this.brand,
    this.manufactureDate,
    this.shelfLife,
  });

  factory AdditionalInfo.fromHashmap(Map<String, dynamic> additionalInfo) {
    return AdditionalInfo(
      bestBefore: additionalInfo['bestBefore'],
      brand: additionalInfo['brand'],
      manufactureDate: additionalInfo['manufactureDate'],
      shelfLife: additionalInfo['shelfLife'],
    );
  }
}

class Sku {
  String skuName;
  String skuPrice;
  // String skuMrp;
  int quantity;
  String skuId;

  Sku({
    this.skuPrice,
    this.skuName,
    // this.skuMrp,
    this.quantity,
    this.skuId,
  });

  factory Sku.fromHashmap(Map<String, dynamic> additionalInfo) {
    return Sku(
      skuName: additionalInfo['skuName'],
      skuPrice: additionalInfo['skuPrice'],
      // skuMrp: additionalInfo['skuMrp'],
      quantity: additionalInfo['quantity'],
      skuId: additionalInfo['skuId'],
    );
  }
}

List<QuestionAnswer> getListOfQueAns(Map queAns) {
  List<QuestionAnswer> list = List();
  queAns.forEach((key, value) {
    list.add(QuestionAnswer(
      ans: value['ans'],
      que: value['que'],
      timestamp: value['timestamp'],
      userId: value['userId'],
      userName: value['userName'],
      queId: value['queId'],
    ));
  });

  return list;
}

List<Review> getListOfReviews(Map reviews) {
  List<Review> list = List();
  reviews.forEach((key, value) {
    list.add(Review(
      rating: value['rating'],
      review: value['review'],
      timestamp: value['timestamp'],
      userId: value['userId'],
      userName: value['userName'],
      reviewId: value['reviewId'],
    ));
  });

  return list;
}

List<Sku> getListOfSkus(Map skuMap) {
  List<Sku> list = List();
  skuMap.forEach((key, value) {
    list.add(Sku(
      skuName: value['skuName'],
      skuPrice: value['skuPrice'],
      // skuMrp: value['skuMrp'],
      quantity: value['quantity'],
      skuId: value['skuId'],
    ));
  });

  list.sort(
      (a, b) => double.parse(a.skuPrice).compareTo(double.parse(b.skuPrice)));

  return list;
}
