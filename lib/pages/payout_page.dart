import 'package:flushbar/flushbar.dart';
import 'package:multivendor_seller/blocs/payout_bloc/all_payouts_bloc.dart';
import 'package:multivendor_seller/blocs/payout_bloc/payout_bloc.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/payout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/screens/payout_screens/all_payouts_screen.dart';
import 'package:multivendor_seller/screens/payout_screens/request_new_payout_screen.dart';

class PayoutPage extends StatefulWidget {
  @override
  _PayoutPageState createState() => _PayoutPageState();
}

class _PayoutPageState extends State<PayoutPage>
    with AutomaticKeepAliveClientMixin {
  Payout payout;

  PayoutBloc payoutBloc;

  @override
  void initState() {
    super.initState();

    payoutBloc = BlocProvider.of<PayoutBloc>(context);
    payoutBloc.add(GetPayoutAnalytics());
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocBuilder(
        bloc: payoutBloc,
        buildWhen: (previous, current) {
          if (current is GetPayoutAnalyticsInProgressState ||
              current is GetPayoutAnalyticsFailedState ||
              current is GetPayoutAnalyticsCompletedState) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          if (state is GetPayoutAnalyticsInProgressState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is GetPayoutAnalyticsFailedState) {
            return Center(
              child: Text(
                'Failed to fetch payouts!',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          } else if (state is GetPayoutAnalyticsCompletedState) {
            payout = state.payout;

            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              scrollDirection: Axis.vertical,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Material(
                    child: InkWell(
                      splashColor: Colors.red.withOpacity(0.3),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllPayoutsScreen(
                              payout: payout,
                            ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: size.width * 0.25,
                              height: size.width * 0.25,
                              padding: const EdgeInsets.all(15.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withOpacity(0.2),
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.moneyBill,
                                color: Colors.red.shade500,
                                size: size.width * 0.1,
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Text(
                              'All Payouts',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Material(
                    child: InkWell(
                      splashColor: Colors.blue.withOpacity(0.3),
                      onTap: () {
                        if (payout.availablePayout == 0) {
                          showSnack(
                              'You don\'t have any available payout!', context);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestNewPayoutScreen(
                              payout: payout,
                            ),
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
                                Icon(
                                  Icons.add,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  'Request new payout',
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
                                color: Colors.brown.withOpacity(0.2),
                              ),
                              child: FaIcon(
                                Icons.monetization_on,
                                color: Colors.brown.shade500,
                                size: 23.0,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'PAYOUT OVERVIEW',
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
                ClipRRect(
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
                                  'Available payout',
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
                                Text(
                                  '${Config().currency}${double.parse(payout.availablePayout.toString()).toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
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
                                color: Colors.purple.withOpacity(0.2),
                              ),
                              child: FaIcon(
                                Icons.attach_money,
                                color: Colors.purple.shade500,
                                size: 23.0,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
              ],
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
