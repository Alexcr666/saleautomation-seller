import 'package:multivendor_seller/blocs/orders_bloc/orders_bloc.dart';
import 'package:multivendor_seller/blocs/orders_bloc/proceed_order_bloc.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/order.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CancelOrderDialog extends StatefulWidget {
  final ProceedOrderBloc proceedOrderBloc;
  final Order order;

  CancelOrderDialog({
    this.order,
    this.proceedOrderBloc,
  });

  @override
  _CancelOrderDialogState createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  final TextEditingController controller = TextEditingController();
  int selectedValue;
  String cancelReason;
  Map cancelOrderMap;
  double refundAmt;

  @override
  void initState() {
    super.initState();

    selectedValue = -1;
    cancelOrderMap = Map();
    refundAmt = double.parse(widget.order.charges.totalAmt) +
        double.parse(widget.order.charges.walletAmt);
  }

  cancelOrder() async {
    if (selectedValue != -1) {
      // //check the wallet amt and total amt
      // if (widget.order.paymentDetails.paymentMethod == 'PREPAID') {
      //   //used wallet completely
      //   cancelOrderMap.putIfAbsent(
      //       'walletAmt', () => widget.order.charges.walletAmt);
      // } else {
      //   if (double.parse(widget.order.charges.walletAmt) > 0) {
      //     //wallet used
      //     cancelOrderMap.putIfAbsent(
      //         'walletAmt', () => widget.order.charges.walletAmt);
      //     cancelOrderMap.putIfAbsent(
      //         'totalAmt', () => widget.order.charges.totalAmt);
      //   } else {
      //     cancelOrderMap.putIfAbsent(
      //         'totalAmt', () => widget.order.charges.totalAmt);
      //   }
      // }

      // cancelOrderMap.putIfAbsent(
      //     'walletAmt', () => widget.order.charges.walletAmt);
      // cancelOrderMap.putIfAbsent(
      //     'totalAmt', () => widget.order.charges.totalAmt);
      //   cancelOrderMap.putIfAbsent('uid', () => widget.order.custDetails.uid);
      //   cancelOrderMap.putIfAbsent('refundAmt', () => refundAmt);

      //   if (cancelReason == 'Other') {
      //     if (controller.text.trim().length > 0) {
      //       cancelReason = controller.text.trim();

      //       cancelOrderMap.putIfAbsent('orderStatus', () => 'Cancelled');
      //       cancelOrderMap.putIfAbsent('reason', () => cancelReason);
      //       cancelOrderMap.putIfAbsent('cancelledBy', () => 'Seller');
      //       cancelOrderMap.putIfAbsent('orderId', () => widget.order.orderId);
      //       cancelOrderMap.putIfAbsent(
      //           'paymentMethod', () => widget.order.paymentDetails.paymentMethod);

      //       switch (widget.order.paymentDetails.paymentMethod) {
      //         case 'COD':
      //           cancelOrderMap.putIfAbsent('refundStatus', () => 'NA');
      //           break;
      //         case 'CARD':
      //           cancelOrderMap.putIfAbsent('transactionId',
      //               () => widget.order.paymentDetails.transactionId);
      //           cancelOrderMap.putIfAbsent('refundStatus', () => 'Not processed');
      //           break;
      //         case 'RAZORPAY':
      //           cancelOrderMap.putIfAbsent('transactionId',
      //               () => widget.order.paymentDetails.transactionId);
      //           cancelOrderMap.putIfAbsent('refundStatus', () => 'Not processed');
      //           break;
      //       }

      //       widget.proceedOrderBloc.add(CancelOrderEvent(cancelOrderMap));
      //     }
      //   } else {
      //     cancelOrderMap.putIfAbsent('orderStatus', () => 'Cancelled');
      //     cancelOrderMap.putIfAbsent('reason', () => cancelReason);
      //     cancelOrderMap.putIfAbsent('cancelledBy', () => 'Seller');
      //     cancelOrderMap.putIfAbsent('orderId', () => widget.order.orderId);
      //     cancelOrderMap.putIfAbsent(
      //         'paymentMethod', () => widget.order.paymentDetails.paymentMethod);

      //     switch (widget.order.paymentDetails.paymentMethod) {
      //       case 'COD':
      //         cancelOrderMap.putIfAbsent('refundStatus', () => 'NA');
      //         break;
      //       case 'CARD':
      //         cancelOrderMap.putIfAbsent('transactionId',
      //             () => widget.order.paymentDetails.transactionId);
      //         cancelOrderMap.putIfAbsent('refundStatus', () => 'Not processed');
      //         break;
      //       case 'RAZORPAY':
      //         cancelOrderMap.putIfAbsent('transactionId',
      //             () => widget.order.paymentDetails.transactionId);
      //         cancelOrderMap.putIfAbsent('refundStatus', () => 'Not processed');
      //         break;
      //     }

      //     widget.proceedOrderBloc.add(CancelOrderEvent(cancelOrderMap));
      //   }
      //   Navigator.pop(context, true);
      cancelOrderMap.putIfAbsent(
          'refundAmt', () => refundAmt.toStringAsFixed(2));
      cancelOrderMap.putIfAbsent('uid', () => widget.order.custDetails.uid);
      cancelOrderMap.putIfAbsent('products', () => widget.order.products);

      if (cancelReason == 'Other') {
        if (controller.text.trim().length > 0) {
          cancelReason = controller.text.trim();

          cancelOrderMap.putIfAbsent('reason', () => cancelReason);
          cancelOrderMap.putIfAbsent('orderId', () => widget.order.orderId);
          cancelOrderMap.putIfAbsent(
              'paymentMethod', () => widget.order.paymentDetails.paymentMethod);

          widget.proceedOrderBloc.add(CancelOrderEvent(cancelOrderMap));
        }
      } else {
        cancelOrderMap.putIfAbsent('reason', () => cancelReason);
        cancelOrderMap.putIfAbsent('orderId', () => widget.order.orderId);
        cancelOrderMap.putIfAbsent(
            'paymentMethod', () => widget.order.paymentDetails.paymentMethod);

        widget.proceedOrderBloc.add(CancelOrderEvent(cancelOrderMap));
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      elevation: 5.0,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: Text(
                'Cancel Order',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(
              height: 25.0,
            ),
            Container(
              child: ListView.builder(
                itemCount: Config().cancelOrderReasons.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return RadioListTile(
                    dense: true,
                    title: Text(
                      '${Config().cancelOrderReasons[index]}',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    value: index,
                    groupValue: selectedValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                        cancelReason = Config().cancelOrderReasons[index];
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            cancelReason == 'Other'
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      enableInteractiveSelection: false,
                      maxLines: 2,
                      maxLength: 150,
                      style: GoogleFonts.poppins(
                        fontSize: 13.0,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 8.0),
                        border: InputBorder.none,
                        hintText: 'Type your reason',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13.0,
                          color: Colors.black54,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w400,
                        ),
                        counterStyle: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: Colors.black54,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
            SizedBox(
              height: 10.0,
            ),
            Center(
              child: Text(
                'NOTE: Refund amount of ${Config().currency}$refundAmt will be credited in the wallet.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Center(
              child: SizedBox(
                width: size.width * 0.5,
                child: FlatButton(
                  onPressed: () {
                    //cancel
                    cancelOrder();
                  },
                  color: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    'Cancel Order',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: size.width * 0.5,
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
          ],
        ),
      ),
    );
  }
}
