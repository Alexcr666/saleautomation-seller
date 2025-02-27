import 'package:multivendor_seller/blocs/orders_bloc/orders_bloc.dart';
import 'package:multivendor_seller/blocs/orders_bloc/delivered_orders_bloc.dart';
import 'package:multivendor_seller/models/order.dart';
import 'package:multivendor_seller/widgets/common_order_item.dart';
import 'package:multivendor_seller/widgets/shimmers/shimmer_order_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class DeliveredOrdersScreen extends StatefulWidget {
  @override
  _DeliveredOrdersScreenState createState() => _DeliveredOrdersScreenState();
}

class _DeliveredOrdersScreenState extends State<DeliveredOrdersScreen>
    with SingleTickerProviderStateMixin {
  List<Order> deliveredOrders;
  DeliveredOrdersBloc deliveredOrdersBloc;
  @override
  void initState() {
    super.initState();

    deliveredOrdersBloc = BlocProvider.of<DeliveredOrdersBloc>(context);

    deliveredOrders = List();

    deliveredOrdersBloc.add(GetDeliveredOrdersEvent());
  }

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
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
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
                      'Delivered Orders',
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
            child: BlocBuilder(
              bloc: deliveredOrdersBloc,
              buildWhen: (previous, current) {
                if (current is GetDeliveredOrdersCompletedState ||
                    current is GetDeliveredOrdersInProgressState ||
                    current is GetDeliveredOrdersFailedState) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetDeliveredOrdersInProgressState) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        period: Duration(milliseconds: 800),
                        baseColor: Colors.grey.withOpacity(0.5),
                        highlightColor: Colors.black.withOpacity(0.5),
                        child: ShimmerOrderItem(size: size),
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
                if (state is GetDeliveredOrdersFailedState) {
                  return Center(
                    child: Text(
                      'Failed to load orders!',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                }
                if (state is GetDeliveredOrdersCompletedState) {
                  if (state.deliveredOrders != null) {
                    deliveredOrders = List();

                    if (state.deliveredOrders.length == 0) {
                      return Column(
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
                            'No orders found!',
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
                      );
                    } else {
                      deliveredOrders = state.deliveredOrders;

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        itemBuilder: (context, index) {
                          return CommonOrderItem(
                            size: size,
                            order: deliveredOrders[index],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 16.0,
                          );
                        },
                        itemCount: deliveredOrders.length,
                      );
                    }
                  }
                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
