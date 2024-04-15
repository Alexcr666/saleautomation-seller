import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/order.dart';
import 'package:multivendor_seller/models/payout.dart';
import 'package:multivendor_seller/screens/orders_screens/manage_new_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/screens/payout_screens/payout_details_screen.dart';
import 'package:intl/intl.dart';

class PayoutItem extends StatelessWidget {
  final Payouts payout;
  final int index;

  const PayoutItem({
    this.index,
    this.payout,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      width: size.width,
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
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
                    'Payout id:',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    ' ${payout.payoutId}',
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
                dateFormat.format(payout.requestedOn.toDate()),
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
                'Payout amount:',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                ' ${Config().currency}${double.parse(payout.payoutAmt.toString()).toStringAsFixed(2)}',
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
                'Status:',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                ' ${payout.status}',
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
                      builder: (context) => PayoutDetailsScreen(
                        payout: payout,
                        index: index,
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
                  'View Details',
                  style: GoogleFonts.poppins(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              // Text(
              //   'Items: ${payout.products.length}',
              //   textAlign: TextAlign.center,
              //   style: GoogleFonts.poppins(
              //     color: Colors.black.withOpacity(0.75),
              //     fontSize: 13.5,
              //     fontWeight: FontWeight.w500,
              //     letterSpacing: 0.3,
              //   ),
              // ),
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
