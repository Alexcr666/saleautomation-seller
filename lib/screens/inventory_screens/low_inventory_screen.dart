import 'package:multivendor_seller/blocs/inventory_bloc/inventory_bloc.dart';
import 'package:multivendor_seller/blocs/inventory_bloc/low_inventory_bloc.dart';
import 'package:multivendor_seller/blocs/products_bloc/products_bloc.dart';
import 'package:multivendor_seller/models/product.dart';
import 'package:multivendor_seller/widgets/low_inventory_item.dart';
import 'package:multivendor_seller/widgets/product_list_item.dart';
import 'package:multivendor_seller/widgets/shimmers/shimmer_low_inventory_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class LowInventoryScreen extends StatefulWidget {
  @override
  _LowInventoryScreenState createState() => _LowInventoryScreenState();
}

class _LowInventoryScreenState extends State<LowInventoryScreen>
    with SingleTickerProviderStateMixin {
  LowInventoryBloc lowInventoryBloc;
  List<Product> productsList;

  @override
  void initState() {
    super.initState();

    productsList = List();
    lowInventoryBloc = BlocProvider.of<LowInventoryBloc>(context);

    lowInventoryBloc.add(GetLowInventoryProductsEvent());

    lowInventoryBloc.listen((state) {
      print('LOW INVENTORY STATE :: $state');
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocBuilder(
        bloc: lowInventoryBloc,
        buildWhen: (previous, current) {
          if (current is GetLowInventoryProductsCompletedState ||
              current is GetLowInventoryProductsInProgressState ||
              current is GetLowInventoryProductsFailedState) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          if (state is GetLowInventoryProductsInProgressState) {
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  period: Duration(milliseconds: 800),
                  baseColor: Colors.grey.withOpacity(0.5),
                  highlightColor: Colors.black.withOpacity(0.5),
                  child: ShimmerLowInventoryItem(size: size),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 15.0,
                );
              },
              itemCount: 5,
            );
          }
          if (state is GetLowInventoryProductsFailedState) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/banners/retry.svg',
                    width: size.width * 0.6,
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    'Failed to load products!',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            );
          }
          if (state is GetLowInventoryProductsCompletedState) {
            if (state.products != null) {
              productsList = List();

              if (state.products.length == 0) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/images/empty_prod.svg',
                        width: size.width * 0.6,
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        'No products found!',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                );
              } else {
                productsList = state.products;

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return LowInventoryItem(
                      product: productsList[index],
                      size: size,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 16.0,
                    );
                  },
                  itemCount: productsList.length,
                );
              }
            }
          }
          return SizedBox();
        },
      ),
    );
  }
}
