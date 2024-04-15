import 'package:multivendor_seller/blocs/inventory_bloc/inventory_bloc.dart';
import 'package:multivendor_seller/blocs/messages_bloc/messages_bloc.dart';
import 'package:multivendor_seller/blocs/orders_bloc/orders_bloc.dart';
import 'package:multivendor_seller/blocs/products_bloc/products_bloc.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/inventory_analytics.dart';
import 'package:multivendor_seller/models/message_analytics.dart';
import 'package:multivendor_seller/models/order_analytics.dart';
import 'package:multivendor_seller/models/product_analytics.dart';
import 'package:multivendor_seller/screens/inventory_screens/low_inventory_screen.dart';
import 'package:multivendor_seller/screens/message_screens/new_messages_screen.dart';
import 'package:multivendor_seller/screens/orders_screens/new_orders_screen.dart';
import 'package:multivendor_seller/screens/product_screens/all_products_screen.dart';
import 'package:multivendor_seller/widgets/shimmers/shimmer_common_main_page.dart';
import 'package:multivendor_seller/widgets/shimmers/shimmer_common_main_page_small.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with AutomaticKeepAliveClientMixin {
  OrdersBloc ordersBloc;
  InventoryBloc inventoryBloc;
  ProductsBloc productsBloc;
  MessagesBloc messagesBloc;

  OrderAnalytics orderAnalytics;
  // InventoryAnalytics inventoryAnalytics;
  MessageAnalytics messageAnalytics;
  ProductAnalytics productAnalytics;

  @override
  void initState() {
    super.initState();

    ordersBloc = BlocProvider.of<OrdersBloc>(context);
    // inventoryBloc = BlocProvider.of<InventoryBloc>(context);
    productsBloc = BlocProvider.of<ProductsBloc>(context);
    messagesBloc = BlocProvider.of<MessagesBloc>(context);

    //TODO: close all the BLOCS
    ordersBloc.add(GetOrderAnalyticsEvent());
    // inventoryBloc.add(GetInventoryAnalyticsEvent());
    productsBloc.add(GetProductAnalyticsEvent());
    messagesBloc.add(GetMessagesAnalyticsEvent());
  }

  // @override
  // void dispose() {
  //   super.dispose();

  //   ordersBloc.close();
  //   inventoryBloc.close();
  //   productsBloc.close();
  //   messagesBloc.close();
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        scrollDirection: Axis.vertical,
        children: <Widget>[
          BlocBuilder(
            bloc: ordersBloc,
            buildWhen: (previous, current) {
              if (current is UpdateOrderAnalyticsState ||
                  current is GetOrderAnalyticsFailedState ||
                  current is GetOrderAnalyticsInProgressState) {
                return true;
              }
              return false;
            },
            builder: (context, state) {
              if (state is GetOrderAnalyticsInProgressState) {
                return Shimmer.fromColors(
                  period: Duration(milliseconds: 800),
                  baseColor: Colors.grey.withOpacity(0.5),
                  highlightColor: Colors.black.withOpacity(0.5),
                  child: ShimmerCommonMainPageItem(size: size),
                );
              }
              if (state is GetOrderAnalyticsFailedState) {
                return Center(child: Text('FAILED'));
              }
              if (state is UpdateOrderAnalyticsState) {
                orderAnalytics = state.orderAnalytics;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Material(
                    child: InkWell(
                      splashColor: Colors.blue.withOpacity(0.3),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewOrdersScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.01),
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            width: 1.0,
                            style: BorderStyle.solid,
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  '${orderAnalytics.newOrders}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  'New Orders',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange.withOpacity(0.2),
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.shoppingBag,
                                color: Colors.orange.shade500,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SizedBox();
            },
          ),
          SizedBox(
            height: 15.0,
          ),
          BlocBuilder(
            bloc: productsBloc,
            buildWhen: (previous, current) {
              if (current is GetProductAnalyticsCompletedState ||
                  current is GetProductAnalyticsFailedState ||
                  current is GetProductAnalyticsInProgressState) {
                return true;
              }
              return false;
            },
            builder: (context, state) {
              if (state is GetProductAnalyticsInProgressState) {
                return Shimmer.fromColors(
                  period: Duration(milliseconds: 800),
                  baseColor: Colors.grey.withOpacity(0.5),
                  highlightColor: Colors.black.withOpacity(0.5),
                  child: ShimmerCommonMainPageItem(size: size),
                );
              }
              if (state is GetProductAnalyticsFailedState) {
                return Center(child: Text('FAILED'));
              }
              if (state is GetProductAnalyticsCompletedState) {
                productAnalytics = state.productAnalytics;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Material(
                    child: InkWell(
                      splashColor: Colors.blue.withOpacity(0.3),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllProductsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.01),
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            width: 1.0,
                            style: BorderStyle.solid,
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  '${productAnalytics.allProducts}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  'Total Products',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 55.0,
                              height: 55.0,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.2),
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.boxes,
                                color: Colors.blue.shade500,
                                size: 23.0,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SizedBox();
            },
          ),
          SizedBox(
            height: 15.0,
          ),
          BlocBuilder(
            bloc: messagesBloc,
            buildWhen: (previous, current) {
              if (current is GetMessageAnalyticsCompletedState ||
                  current is GetMessageAnalyticsFailedState ||
                  current is GetMessageAnalyticsInProgressState) {
                return true;
              }
              return false;
            },
            builder: (context, state) {
              if (state is GetMessageAnalyticsInProgressState) {
                return Shimmer.fromColors(
                  period: Duration(milliseconds: 800),
                  baseColor: Colors.grey.withOpacity(0.5),
                  highlightColor: Colors.black.withOpacity(0.5),
                  child: ShimmerCommonMainPageItem(size: size),
                );
              }
              if (state is GetMessageAnalyticsFailedState) {
                return Center(child: Text('FAILED'));
              }
              if (state is GetMessageAnalyticsCompletedState) {
                messageAnalytics = state.messageAnalytics;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Material(
                    child: InkWell(
                      splashColor: Colors.blue.withOpacity(0.3),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewMessagesScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.01),
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            width: 1.0,
                            style: BorderStyle.solid,
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  '${messageAnalytics.newMessages}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  'New Messages',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 55.0,
                              height: 55.0,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.pink.withOpacity(0.2),
                              ),
                              child: Icon(
                                Icons.mail,
                                color: Colors.pink.shade500,
                                size: 25.0,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SizedBox();
            },
          ),
          SizedBox(
            height: 15.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'SUMMARY',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          BlocBuilder(
            bloc: ordersBloc,
            buildWhen: (previous, current) {
              if (current is UpdateOrderAnalyticsState ||
                  current is GetOrderAnalyticsFailedState ||
                  current is GetOrderAnalyticsInProgressState) {
                return true;
              }
              return false;
            },
            builder: (context, state) {
              if (state is GetOrderAnalyticsInProgressState) {
                return Shimmer.fromColors(
                  period: Duration(milliseconds: 800),
                  baseColor: Colors.grey.withOpacity(0.5),
                  highlightColor: Colors.black.withOpacity(0.5),
                  child: ShimmerCommonMainPageSmallItem(size: size),
                );
              }
              if (state is GetOrderAnalyticsFailedState) {
                return Center(child: Text('FAILED'));
              }
              if (state is UpdateOrderAnalyticsState) {
                orderAnalytics = state.orderAnalytics;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.blue.withOpacity(0.3),
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.01),
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                  color: Colors.black.withOpacity(0.08),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Total Orders',
                                    overflow: TextOverflow.clip,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          '${orderAnalytics.totalOrders}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black87,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.blue.withOpacity(0.3),
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.01),
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                  color: Colors.black.withOpacity(0.08),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Total Sales',
                                    overflow: TextOverflow.clip,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          '${Config().currency}${double.parse(orderAnalytics.totalSales.toString()).toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black87,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return SizedBox();
            },
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
