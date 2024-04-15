import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/blocs/payout_bloc/all_payouts_bloc.dart';
import 'package:multivendor_seller/blocs/payout_bloc/payout_bloc.dart';
import 'package:multivendor_seller/models/payout.dart';
import 'package:multivendor_seller/widgets/payout_item.dart';

class AllPayoutsScreen extends StatefulWidget {
  final Payout payout;

  const AllPayoutsScreen({Key key, this.payout}) : super(key: key);
  @override
  _AllPayoutsScreenState createState() => _AllPayoutsScreenState();
}

class _AllPayoutsScreenState extends State<AllPayoutsScreen> {
  List<Payouts> payouts;

  AllPayoutsBloc allPayoutsBloc;

  @override
  void initState() {
    super.initState();

    allPayoutsBloc = BlocProvider.of<AllPayoutsBloc>(context);
    allPayoutsBloc.add(GetAllPayouts());
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
                      'All Payouts',
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
              bloc: allPayoutsBloc,
              buildWhen: (previous, current) {
                if (current is GetAllPayoutsInProgressState ||
                    current is GetAllPayoutsFailedState ||
                    current is GetAllPayoutsCompletedState) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetAllPayoutsInProgressState) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is GetAllPayoutsFailedState) {
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
                } else if (state is GetAllPayoutsCompletedState) {
                  payouts = state.payout;

                  return payouts.length == 0
                      ? Center(
                          child: Text(
                            'No payouts found!',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                          ),
                          itemBuilder: (context, index) {
                            return PayoutItem(
                              index: index,
                              payout: payouts[index],
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: 16.0,
                            );
                          },
                          itemCount: payouts.length,
                        );
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
