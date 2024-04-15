import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/blocs/payout_bloc/payout_bloc.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/payout.dart';
import 'package:multivendor_seller/screens/payout_screens/edit_payout_screen.dart';
import 'package:multivendor_seller/widgets/dialogs/delete_confirm_dialog.dart';
import 'package:multivendor_seller/widgets/dialogs/processing_dialog.dart';
import 'package:multivendor_seller/widgets/dialogs/product_added_dialog.dart';

class PayoutDetailsScreen extends StatefulWidget {
  final Payouts payout;
  final int index;

  const PayoutDetailsScreen({Key key, this.payout, this.index})
      : super(key: key);
  @override
  _PayoutDetailsScreenState createState() => _PayoutDetailsScreenState();
}

class _PayoutDetailsScreenState extends State<PayoutDetailsScreen> {
  PayoutBloc payoutBloc;

  bool isAdding;
  @override
  void initState() {
    super.initState();

    isAdding = false;
    payoutBloc = BlocProvider.of<PayoutBloc>(context);

    payoutBloc.listen((state) {
      if (state is CancelPayoutInProgressState) {
        //in progress
        showUpdatingDialog('Cancelling payout request\nPlease wait..');
      }
      if (state is CancelPayoutFailedState) {
        //failed
        if (isAdding) {
          Navigator.pop(context);
          showSnack('Failed to cancel payout!', context);
          isAdding = false;
        }
      }
      if (state is CancelPayoutCompletedState) {
        //completed
        if (isAdding) {
          isAdding = false;
          Navigator.pop(context);
          showProductEditedDialog('Cancelled payout request!');
        }
      }
    });
  }

  showUpdatingDialog(String message) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: message,
        );
      },
    );
  }

  showProductEditedDialog(String message) async {
    var res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProductAddedDialog(
          message: message,
        );
      },
    );

    if (res == 'ADDED') {
      //added
      Navigator.pop(context, true);
    }
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: Colors.red.shade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1.0,
          blurRadius: 5.0,
          offset: Offset(0.0, 2.0),
        )
      ],
      shouldIconPulse: false,
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.error,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  showConfirmationDialog(String message) async {
    bool res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return DeleteConfirmDialog(
          message: '$message',
        );
      },
    );
    if (res == true) {
      payoutBloc.add(CancelPayout({
        'payoutAmt': widget.payout.payoutAmt,
        'payoutId': widget.payout.payoutId,
      }));
      isAdding = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
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
                      'Payout Details',
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
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 0.0),
                        blurRadius: 15.0,
                        spreadRadius: 2.0,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Payout details: ',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Divider(),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Payout id: ',
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.65),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            '${widget.payout.payoutId}',
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.8),
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
                            'Payout amount: ',
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.65),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            '${Config().currency}${double.parse(widget.payout.payoutAmt.toString()).toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.8),
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
                            'Notes: ',
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.65),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            widget.payout.notes.isEmpty
                                ? 'NA'
                                : '${widget.payout.notes}',
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.8),
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
                            'Status: ',
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.65),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            '${widget.payout.status}',
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      widget.payout.status == 'Rejected'
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 8.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Reason: ',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black.withOpacity(0.65),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${widget.payout.reason}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black.withOpacity(0.8),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 0.0),
                        blurRadius: 15.0,
                        spreadRadius: 2.0,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Bank details: ',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Divider(),
                      SizedBox(
                        height: 5.0,
                      ),
                      widget.payout.payoutVia == 'UPI'
                          ? Row(
                              children: <Widget>[
                                Text(
                                  'UPI ID: ',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.65),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  '${widget.payout.payoutBankDetails.upiId}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      widget.payout.payoutVia == 'Other'
                          ? Row(
                              children: <Widget>[
                                Text(
                                  'Details: ',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.65),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  '${widget.payout.payoutBankDetails.payoutDetails}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      widget.payout.payoutVia == 'Bank Account'
                          ? Column(
                              children: [
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Account no.: ',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black.withOpacity(0.65),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${widget.payout.payoutBankDetails.accountNo}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black.withOpacity(0.8),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Account holder name: ',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black.withOpacity(0.65),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${widget.payout.payoutBankDetails.accountName}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black.withOpacity(0.8),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Bank name: ',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black.withOpacity(0.65),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${widget.payout.payoutBankDetails.bankName}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black.withOpacity(0.8),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
                widget.payout.status == 'Requested'
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 25.0,
                                ),
                                Container(
                                  height: 43.0,
                                  width: size.width,
                                  child: FlatButton(
                                    onPressed: () async {
                                      bool res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditPayoutScreen(
                                            payout: widget.payout,
                                            index: widget.index,
                                          ),
                                        ),
                                      );

                                      if (res != null) {
                                        if (res) {
                                          //updated
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                                    color: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Text(
                                      'Edit Payout',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10.0,
                                ),
                                Container(
                                  height: 43.0,
                                  width: size.width,
                                  child: FlatButton(
                                    onPressed: () {
                                      showConfirmationDialog(
                                          'Do you want to cancel the payout?');
                                    },
                                    color: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Text(
                                      'Cancel Payout',
                                      style: GoogleFonts.poppins(
                                        color: Colors.red,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
