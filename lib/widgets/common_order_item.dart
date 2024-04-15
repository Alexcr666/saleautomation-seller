import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/order.dart';
import 'package:multivendor_seller/screens/orders_screens/common_view_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CommonOrderItem extends StatelessWidget {
  final Size size;
  final Order order;

  const CommonOrderItem({
    @required this.size,
    @required this.order,
  });

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      width: size.width,
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(
            height: 12.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Order id:',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    ' ${order.orderId}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Text(
                dateFormat.format(order.orderTimestamp.toDate()),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                'Order amount:',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                ' ${Config().currency}${(double.parse(order.charges.totalAmt) + double.parse(order.charges.walletAmt)).toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.75),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: <Widget>[
              Text(
                'Name:',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                ' ${order.custDetails.name}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.75),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: <Widget>[
              Text(
                'Order status:',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                ' ${order.orderStatus}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: order.orderStatus == 'Cancelled'
                      ? Colors.red.shade500
                      : Colors.black.withOpacity(0.75),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommonViewOrderScreen(
                        order: order,
                      ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                      width: 1.0,
                      color: Colors.black.withOpacity(0.5),
                      style: BorderStyle.solid),
                ),
                child: Text(
                  'Order Details',
                  style: GoogleFonts.poppins(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Text(
                'Items: ${order.products.length}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.75),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
        ],
      ),
    );
  }
}
