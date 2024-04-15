import 'package:carousel_pro/carousel_pro.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/product.dart';
import 'package:multivendor_seller/widgets/dialogs/product_sku_dialog.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/widgets/question_answer_item.dart';
import 'package:multivendor_seller/widgets/review_item.dart';

import 'all_questions_screen.dart';
import 'all_reviews_screen.dart';
import 'fullscreen_image_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  ProductDetailScreen({this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<Widget> productImages = List();
  double rating;

  @override
  void initState() {
    super.initState();

    _selectedSku = widget.product.skus[0];

    // discount = ((1 -
    //             (int.parse(_selectedSku.skuPrice) /
    //                 (int.parse(_selectedSku.skuMrp)))) *
    //         100)
    //     .round()
    //     .toString();

    rating = 0;

    if (widget.product.reviews.length == 0) {
    } else {
      if (widget.product.reviews.length > 0) {
        for (var review in widget.product.reviews) {
          rating = rating + double.parse(review.rating);
        }
        rating = rating / widget.product.reviews.length;
      }
    }

    if (widget.product.productImages.length == 0) {
      productImages.add(
        Center(
          child: Text(
            'No product image available',
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.75),
            ),
          ),
        ),
      );
    } else {
      for (var item in widget.product.productImages) {
        productImages.add(
          Center(
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/icons/category_placeholder.png',
              image: item,
              fadeInDuration: Duration(milliseconds: 250),
              fadeInCurve: Curves.easeInOut,
              fadeOutDuration: Duration(milliseconds: 150),
              fadeOutCurve: Curves.easeInOut,
            ),
          ),
        );
      }
    }
  }

  Sku _selectedSku;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: 38.0,
                            height: 35.0,
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'Product Details',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0.0),
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Container(
                  height: 240.0,
                  width: size.width,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 0,
                        child: Container(
                          height: 180.0,
                          padding: const EdgeInsets.only(
                              bottom: 20.0, left: 16.0, right: 16.0, top: 10.0),
                          width: size.width,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        width: size.width,
                        child: Container(
                          height: 230.0,
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 15.0,
                                offset: Offset(1, 10.0),
                                spreadRadius: 2.0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Carousel(
                              images: productImages,
                              dotSize: 4.0,
                              dotSpacing: 15.0,
                              dotColor: Colors.lightGreenAccent,
                              dotIncreasedColor: Colors.amber,
                              autoplayDuration: Duration(milliseconds: 3000),
                              autoplay: false,
                              showIndicator: true,
                              indicatorBgPadding: 5.0,
                              dotBgColor: Colors.transparent,
                              borderRadius: false,
                              animationDuration: Duration(milliseconds: 450),
                              animationCurve: Curves.easeInOut,
                              boxFit: BoxFit.contain,
                              dotVerticalPadding: 5.0,
                              dotPosition: DotPosition.bottomCenter,
                              noRadiusForIndicator: true,
                              onImageTap: (index) {
                                print('Tapped: $index');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImageScreen(
                                      images: widget.product.productImages,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          widget.product.name,
                          overflow: TextOverflow.clip,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.product.isDiscounted
                            ? '${Config().currency}${((1 - (widget.product.discount / 100)) * double.parse(_selectedSku.skuPrice)).toStringAsFixed(2)}'
                            : '${Config().currency}${double.parse(_selectedSku.skuPrice).toStringAsFixed(2)}',
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                      widget.product.isDiscounted
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  '${Config().currency}${double.parse(_selectedSku.skuPrice).toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  width: 15.0,
                                ),
                                Text(
                                  '${widget.product.discount.toInt()}% off',
                                  maxLines: 1,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                GestureDetector(
                  onTap: () async {
                    //show sku dialog
                    var res = await showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return ProductSkuDialog(
                          product: widget.product,
                          selectedSku: _selectedSku,
                        );
                      },
                    );

                    if (res != null) {
                      setState(() {
                        _selectedSku = res;
                      });
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      // color: Colors.white,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.18),
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${_selectedSku.skuName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.75),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.black.withOpacity(0.75),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        _selectedSku.quantity > 0 ? 'In Stock' : 'Out of Stock',
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: _selectedSku.quantity > 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Text(
                            'Free Delivery',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: Colors.brown,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Text(
                            'Easy cancellation',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: Colors.brown,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        widget.product.description,
                        style: GoogleFonts.poppins(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Additional Information',
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        widget.product.additionalInfo.bestBefore.length == 0
                            ? '\u2022 Best before: NA'
                            : '\u2022 Best before: ${widget.product.additionalInfo.bestBefore}',
                        style: GoogleFonts.poppins(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.product.additionalInfo.manufactureDate.length ==
                                0
                            ? '\u2022 Manufacture date: NA'
                            : '\u2022 Manufacture date: ${widget.product.additionalInfo.manufactureDate}',
                        style: GoogleFonts.poppins(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.product.additionalInfo.shelfLife.length == 0
                            ? '\u2022 Shelf life: NA'
                            : '\u2022 Shelf life: ${widget.product.additionalInfo.shelfLife}',
                        style: GoogleFonts.poppins(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.product.additionalInfo.brand.length == 0
                            ? '\u2022 Brand: NA'
                            : '\u2022 Brand: ${widget.product.additionalInfo.brand}',
                        style: GoogleFonts.poppins(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seller',
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      ListTile(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => VendorScreen(
                          //       seller: widget.product.seller,
                          //     ),
                          //   ),
                          // );
                        },
                        dense: false,
                        contentPadding: const EdgeInsets.all(0),
                        isThreeLine: false,
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.black.withAlpha(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            child: Image.network(
                              widget.product.seller.profileImageUrl,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  color: Colors.blue.shade200,
                                );
                              },
                            ),
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${widget.product.seller.name}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.black.withOpacity(0.8),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 1,
                            ),
                            Text(
                              "${widget.product.seller.locationDetails.address}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        // trailing: Container(
                        //   height: 33.0,
                        //   child: OutlineButton(
                        //     onPressed: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => SellerScreen(
                        //             seller: widget.product.seller,
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //     borderSide: BorderSide(
                        //       color: Colors.black54,
                        //       width: 0.5,
                        //     ),
                        //     color: Theme.of(context).primaryColor,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(10.0),
                        //     ),
                        //     child: Text(
                        //       'View Shop',
                        //       style: GoogleFonts.poppins(
                        //         color: Colors.black87,
                        //         fontSize: 13.5,
                        //         fontWeight: FontWeight.w500,
                        //         letterSpacing: 0.3,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // trailing: OutlineButton(
                        //   onPressed: () {
                        //     // Navigator.push(
                        //     //   context,
                        //     //   MaterialPageRoute(
                        //     //     builder: (context) => VendorScreen(
                        //     //       seller: widget.product.seller,
                        //     //     ),
                        //     //   ),
                        //     // );
                        //   },
                        //   borderSide: BorderSide(
                        //     color: Theme.of(context).accentColor,
                        //   ),
                        //   color: Theme.of(context).accentColor,
                        //   child: Text(
                        //     'View Shop',
                        //     style: GoogleFonts.poppins(
                        //       color: Theme.of(context).accentColor,
                        //       fontSize: 12.0,
                        //       fontWeight: FontWeight.w400,
                        //     ),
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Questions & Answers',
                              style: GoogleFonts.poppins(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          // Container(
                          //   height: 33.0,
                          //   child: FlatButton(
                          //     onPressed: () {
                          //       //post question
                          //       if (FirebaseAuth.instance.currentUser == null) {
                          //         Navigator.pushNamed(context, '/sign_in');
                          //         return;
                          //       }

                          //       showPostQuestionPopup();
                          //     },
                          //     color: Theme.of(context).primaryColor,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(10.0),
                          //     ),
                          //     child: Text(
                          //       'Post Question',
                          //       style: GoogleFonts.poppins(
                          //         color: Colors.white,
                          //         fontSize: 13.5,
                          //         fontWeight: FontWeight.w500,
                          //         letterSpacing: 0.3,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      widget.product.queAndAns.length == 0
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'No questions found!',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.7),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: <Widget>[
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  itemBuilder: (context, index) {
                                    return QuestionAnswerItem(
                                        widget.product.queAndAns[index]);
                                  },
                                  separatorBuilder: (context, index) {
                                    return Divider();
                                  },
                                  itemCount: widget.product.queAndAns.length > 3
                                      ? 3
                                      : widget.product.queAndAns.length,
                                ),
                                widget.product.queAndAns.length > 3
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Divider(),
                                          Container(
                                            height: 36.0,
                                            width: double.infinity,
                                            child: FlatButton(
                                              onPressed: () {
                                                //TODO: take to all questions screen
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AllQuestionsScreen(
                                                            widget.product
                                                                .queAndAns),
                                                  ),
                                                );
                                              },
                                              color: Colors.transparent,
                                              padding: const EdgeInsets.all(0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'View All Questions',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.black87,
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                              ],
                            ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Reviews & Ratings',
                              style: GoogleFonts.poppins(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          // Container(
                          //   height: 33.0,
                          //   child: FlatButton(
                          //     onPressed: () {
                          //       //rate

                          //       if (FirebaseAuth.instance.currentUser == null) {
                          //         Navigator.pushNamed(context, '/sign_in');
                          //         return;
                          //       }

                          //       rateProductBloc.add(CheckRateProductEvent(
                          //         FirebaseAuth.instance.currentUser.uid,
                          //         widget.product.id,
                          //         widget.product,
                          //       ));
                          //     },
                          //     color: Theme.of(context).primaryColor,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(10.0),
                          //     ),
                          //     child: Text(
                          //       'Rate Product',
                          //       style: GoogleFonts.poppins(
                          //         color: Colors.white,
                          //         fontSize: 13.5,
                          //         fontWeight: FontWeight.w500,
                          //         letterSpacing: 0.3,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  '${widget.product.reviews.length}',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.poppins(
                                    color: Colors.green.shade700,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  'reviews',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  widget.product.reviews.length == 0
                                      ? '0'
                                      : '${rating.toStringAsFixed(1)}',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.poppins(
                                    color: Colors.green.shade700,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 1.5),
                                  child: Text(
                                    '\u2605',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.clip,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black.withOpacity(0.7),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      widget.product.reviews.length == 0
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Center(
                                child: Text(
                                  'No reviews found!',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.7),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: <Widget>[
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  itemBuilder: (context, index) {
                                    return ReviewItem(
                                      review: widget.product.reviews[index],
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return Divider();
                                  },
                                  itemCount: widget.product.reviews.length > 3
                                      ? 3
                                      : widget.product.reviews.length,
                                ),
                                widget.product.reviews.length > 3
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Divider(),
                                          Container(
                                            height: 36.0,
                                            width: double.infinity,
                                            child: FlatButton(
                                              onPressed: () {
                                                //TODO: take to all reviews screen
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AllReviewsScreen(
                                                      widget.product.reviews,
                                                      rating,
                                                    ),
                                                  ),
                                                );
                                              },
                                              color: Colors.transparent,
                                              padding: const EdgeInsets.all(0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'View All Reviews',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.black87,
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                              ],
                            ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
