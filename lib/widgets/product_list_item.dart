import 'package:multivendor_seller/blocs/products_bloc/active_products_bloc.dart';
import 'package:multivendor_seller/blocs/products_bloc/all_products_bloc.dart';
import 'package:multivendor_seller/blocs/products_bloc/featured_products_bloc.dart';
import 'package:multivendor_seller/blocs/products_bloc/inactive_products_bloc.dart';
import 'package:multivendor_seller/blocs/products_bloc/products_bloc.dart';
import 'package:multivendor_seller/blocs/products_bloc/trending_products_bloc.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/product.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/screens/product_screens/edit_product_screen.dart';
import 'package:multivendor_seller/screens/product_screens/product_detail_screen.dart';

import 'package:shimmer/shimmer.dart';

import 'dialogs/product_sku_dialog.dart';

class ProductListItem extends StatefulWidget {
  final Size size;
  final Product product;
  final String productType;
  final AllProductsBloc allProductsBloc;
  final ActiveProductsBloc activeProductsBloc;
  final InactiveProductsBloc inactiveProductsBloc;
  final TrendingProductsBloc trendingProductsBloc;
  final FeaturedProductsBloc featuredProductsBloc;

  const ProductListItem({
    @required this.size,
    @required this.product,
    this.allProductsBloc,
    this.activeProductsBloc,
    this.featuredProductsBloc,
    this.inactiveProductsBloc,
    this.trendingProductsBloc,
    this.productType,
  });

  @override
  _ProductListItemState createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  Sku selectedSku;
  double rating;
  // String discount;

  @override
  void initState() {
    super.initState();

    print(widget.product.skus[0].skuName);
    print(widget.product.skus[0].skuPrice);

    selectedSku = widget.product.skus[0];

    // for (var item in widget.product.skus) {
    //   if (item.quantity > 0) {
    //     selectedSku = item;
    //     break;
    //   }
    // }

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

    // discount = ((1 -
    //             (int.parse(selectedSku.skuPrice) /
    //                 (int.parse(selectedSku.skuMrp)))) *
    //         100)
    //     .round()
    //     .toString();
  }

  sendToEditProduct() async {
    bool isEdited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: widget.product),
      ),
    );
    if (isEdited != null) {
      if (isEdited) {
        switch (widget.productType) {
          case 'ALL_PRODUCTS':
            widget.allProductsBloc.add(GetAllProductsEvent());
            break;
          case 'ACTIVE_PRODUCTS':
            widget.activeProductsBloc.add(GetActiveProductsEvent());
            break;
          case 'INACTIVE_PRODUCTS':
            widget.inactiveProductsBloc.add(GetInactiveProductsEvent());
            break;
          case 'TRENDING_PRODUCTS':
            widget.trendingProductsBloc.add(GetTrendingProductsEvent());
            break;
          case 'FEATURED_PRODUCTS':
            widget.featuredProductsBloc.add(GetFeaturedProductsEvent());
            break;
          default:
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        print('Open Product');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: widget.product,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ProductScreen(
                    //       productId: widget.product.id,
                    //     ),
                    //   ),
                    // );
                  },
                  child: Container(
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Center(
                              child: FadeInImage.assetNetwork(
                                placeholder:
                                    'assets/icons/category_placeholder.png',
                                image: widget.product.productImages[0],
                                fadeInDuration: Duration(milliseconds: 250),
                                fadeInCurve: Curves.easeInOut,
                                fit: BoxFit.cover,
                                fadeOutDuration: Duration(milliseconds: 150),
                                fadeOutCurve: Curves.easeInOut,
                              ),
                            ),
                          ),
                        ),
                        widget.product.trending
                            ? Container(
                                height: 25.0,
                                width: MediaQuery.of(context).size.width * 0.25,
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.0),
                                    bottomRight: Radius.circular(12.0),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Shimmer.fromColors(
                                  baseColor: Colors.white60,
                                  highlightColor: Colors.white,
                                  period: Duration(milliseconds: 1000),
                                  child: Text(
                                    'Trending',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.product.name}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.85),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 7.0,
                        ),
                        widget.product.reviews.length == 0
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 3.0),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade300,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  widget.product.reviews.length == 0
                                      ? 'No ratings'
                                      : '${rating.toStringAsFixed(1)} \u2605',
                                  maxLines: 1,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 3.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade300,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      widget.product.reviews.length == 0
                                          ? 'No ratings'
                                          : '${rating.toStringAsFixed(1)} \u2605',
                                      maxLines: 1,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '${widget.product.reviews.length} Ratings',
                                    maxLines: 1,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.0,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: 7.0,
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
                                  selectedSku: selectedSku,
                                );
                              },
                            );

                            if (res != null) {
                              setState(() {
                                selectedSku = res;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              // color: Colors.white,
                              border: Border.all(
                                color: Colors.black12,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${selectedSku.skuName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black.withOpacity(0.75),
                                      fontSize: 13.0,
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
                          height: 7.0,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              widget.product.isDiscounted
                                  ? '${Config().currency}${((1 - (widget.product.discount / 100)) * double.parse(selectedSku.skuPrice)).toStringAsFixed(2)}'
                                  : '${Config().currency}${double.parse(selectedSku.skuPrice).toStringAsFixed(2)}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            widget.product.isDiscounted
                                ? Text(
                                    '${Config().currency}${double.parse(selectedSku.skuPrice).toStringAsFixed(2)}',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.black54,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : SizedBox(),
                            // SizedBox(
                            //   width: 10.0,
                            // ),
                            // Text(
                            //   '${Config().currency}${selectedSku.skuMrp}',
                            //   maxLines: 1,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: GoogleFonts.poppins(
                            //     decoration: TextDecoration.lineThrough,
                            //     color: Colors.black54,
                            //     fontSize: 14.0,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                            // SizedBox(
                            //   width: 15.0,
                            // ),
                            // Text(
                            //   '$discount% off',
                            //   maxLines: 1,
                            //   style: GoogleFonts.poppins(
                            //     fontSize: 14.0,
                            //     color: Colors.green.shade700,
                            //     fontWeight: FontWeight.w500,
                            //     letterSpacing: 0.5,
                            //   ),
                            // ),
                          ],
                        ),
                        // Text(
                        //   '${Config().currency}${selectedSku.skuPrice}',
                        //   maxLines: 1,
                        //   overflow: TextOverflow.ellipsis,
                        //   style: GoogleFonts.poppins(
                        //     color: Colors.black,
                        //     fontSize: 15.0,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      // //TODO: temp disabled
                      // showSnack(
                      //     'You\'re not a Primary admin.\nAction not allowed!',
                      //     context);
                      sendToEditProduct();
                    },
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    splashColor: Colors.white.withOpacity(0.4),
                    child: Text(
                      'Edit Product',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: widget.product,
                          ),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                          width: 1.0,
                          color: Colors.black.withOpacity(0.4),
                          style: BorderStyle.solid),
                    ),
                    child: Text(
                      'View Product',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     mainAxisSize: MainAxisSize.max,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: <Widget>[
            //       SizedBox(
            //         width: 6,
            //       ),
            //       Expanded(
            //         child: Text(
            //           selectedSku.quantity > 0 ? 'In Stock' : 'Out of Stock',
            //           style: GoogleFonts.poppins(
            //             fontSize: 13.5,
            //             color: selectedSku.quantity > 0
            //                 ? Colors.green.shade700
            //                 : Colors.red.shade700,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ),
            //       // Expanded(
            //       //   child: Text(
            //       //     'Category: ${widget.product.category.toUpperCase()}',
            //       //     maxLines: 1,
            //       //     overflow: TextOverflow.ellipsis,
            //       //     style: GoogleFonts.poppins(
            //       //       color: Colors.black.withOpacity(0.75),
            //       //       fontSize: 14.0,
            //       //       fontWeight: FontWeight.w500,
            //       //     ),
            //       //   ),
            //       // ),
            //       SizedBox(
            //         width: 8.0,
            //       ),
            //       ClipRRect(
            //         borderRadius: BorderRadius.circular(8.0),
            //         child: Material(
            //           child: InkWell(
            //             splashColor: Colors.green.withOpacity(0.5),
            //             onTap: () {
            //               print('Add to cart');
            //             },
            //             child: Container(
            //               decoration: BoxDecoration(
            //                 color: Colors.black.withOpacity(0.01),
            //                 borderRadius: BorderRadius.circular(8.0),
            //                 border: Border.all(
            //                   width: 0.8,
            //                   color: Colors.black.withOpacity(0.15),
            //                 ),
            //               ),
            //               padding: const EdgeInsets.symmetric(
            //                   horizontal: 15, vertical: 8),
            //               child: Row(
            //                 children: [
            //                   Icon(
            //                     Icons.edit,
            //                     color: selectedSku.quantity > 0
            //                         ? Colors.black.withOpacity(0.7)
            //                         : Colors.black38,
            //                     size: 20.0,
            //                   ),
            //                   SizedBox(
            //                     width: 8,
            //                   ),
            //                   Text(
            //                     'Edit',
            //                     maxLines: 1,
            //                     overflow: TextOverflow.ellipsis,
            //                     style: GoogleFonts.poppins(
            //                       color: selectedSku.quantity > 0
            //                           ? Colors.black
            //                           : Colors.black45,
            //                       fontSize: 14.0,
            //                       fontWeight: FontWeight.w600,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(
              height: 8.0,
            ),
          ],
        ),
      ),
    );
  }
}
