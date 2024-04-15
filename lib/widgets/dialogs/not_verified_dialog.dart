import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/models/seller.dart';
import 'package:minimize_app/minimize_app.dart';

class NotVerifiedDialog extends StatelessWidget {
  final Seller seller;

  const NotVerifiedDialog({@required this.seller});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      elevation: 5.0,
      contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // SizedBox(
          //   height: 15.0,
          // ),
          // Image.asset(
          //   'assets/images/order_placed.png',
          //   width: size.width * 0.4,
          // ),
          // SizedBox(
          //   height: 35.0,
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                seller.approvalStatus == 'Rejected'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Account Rejected',
                            style: GoogleFonts.poppins(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: Colors.red.shade700,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Text(
                          //   'Your account was not approved!',
                          //   style: GoogleFonts.poppins(
                          //     fontSize: 13.5,
                          //     fontWeight: FontWeight.w600,
                          //     letterSpacing: 0.3,
                          //     color: Colors.black87,
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          Text(
                            'Reason: ${seller.reason}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Your account is under verification.\nPlease wait till it is verified.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          color: Colors.black87,
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          SizedBox(
            width: size.width * 0.5,
            child: FlatButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'Check again',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          SizedBox(
            width: size.width * 0.5,
            child: FlatButton(
              onPressed: () {
                if (Platform.isIOS) {
                  MinimizeApp.minimizeApp();
                } else {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                }
              },
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'Exit App',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
