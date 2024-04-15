import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/blocs/payout_bloc/payout_bloc.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/global_settings.dart';
import 'package:multivendor_seller/models/payout.dart';
import 'package:multivendor_seller/widgets/dialogs/processing_dialog.dart';
import 'package:multivendor_seller/widgets/dialogs/product_added_dialog.dart';

class RequestNewPayoutScreen extends StatefulWidget {
  final Payout payout;

  const RequestNewPayoutScreen({Key key, @required this.payout})
      : super(key: key);
  @override
  _AddNewAdminScreenState createState() => _AddNewAdminScreenState();
}

class _AddNewAdminScreenState extends State<RequestNewPayoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> payoutMap = Map();
  PayoutBloc payoutBloc;
  bool isAdding;
  int selectedPayoutType;
  GlobalSettings globalSettings;

  @override
  void initState() {
    super.initState();

    isAdding = false;
    payoutBloc = BlocProvider.of<PayoutBloc>(context);
    selectedPayoutType = 0;
    payoutMap.update(
      'payoutVia',
      (val) => Config().payoutPaymentTypes[selectedPayoutType],
      ifAbsent: () => Config().payoutPaymentTypes[selectedPayoutType],
    );

    payoutBloc.listen((state) {
      if (state is RequestPayoutInProgressState) {
        //in progress
        showUpdatingDialog();
      }
      if (state is RequestPayoutFailedState) {
        //failed
        if (isAdding) {
          Navigator.pop(context);
          showSnack('Failed to request new payout!', context);
          isAdding = false;
        }
      }
      if (state is RequestPayoutCompletedState) {
        //completed
        if (isAdding) {
          isAdding = false;
          Navigator.pop(context);
          showProductAddedDialog();
        }
      }
    });

    payoutBloc.add(GetCartInfo());
  }

  showProductAddedDialog() async {
    var res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProductAddedDialog(
          message: 'Payout requested successfully!',
        );
      },
    );

    if (res == 'ADDED') {
      //added

      Navigator.pop(context, true);
    }
  }

  addNewAdmin() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      payoutBloc.add(
        RequestPayout(payoutMap),
      );
      isAdding = true;
    }
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Requesting payout..\nPlease wait!',
        );
      },
    );
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
                      'Request New Payout',
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
              bloc: payoutBloc,
              buildWhen: (previous, current) {
                if (current is GetCartInfoInProgressState ||
                    current is GetCartInfoFailedState ||
                    current is GetCartInfoCompletedState) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetCartInfoInProgressState) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is GetCartInfoFailedState) {
                  return Center(
                    child: Text('FAILED TO LOAD!'),
                  );
                }
                if (state is GetCartInfoCompletedState) {
                  globalSettings = state.globalSettings;

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            double.parse(globalSettings
                                            .sellerSettings.minPayoutAmt)
                                        .toInt() ==
                                    0
                                ? SizedBox()
                                : Column(
                                    children: [
                                      Text(
                                        'NOTE: Minimum payout amount of ${Config().currency}${globalSettings.sellerSettings.minPayoutAmt} is required to request a payout.',
                                        style: GoogleFonts.poppins(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                    ],
                                  ),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    '${Config().currency}${double.parse(widget.payout.availablePayout.toString()).toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: 8),
                                      child: Text(
                                        "Available payout",
                                        style: GoogleFonts.poppins(
                                          color: Colors.black87,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ))
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              validator: (String val) {
                                if (val.trim().isEmpty) {
                                  return 'Payout amount is required';
                                }
                                if (double.parse(val.trim()) >
                                    widget.payout.availablePayout) {
                                  return 'Payout amount can\'t be more than ${Config().currency}${double.parse(widget.payout.availablePayout.toString()).toStringAsFixed(2)}';
                                }
                                if (double.parse(val.trim()) <
                                    double.parse(globalSettings
                                        .sellerSettings.minPayoutAmt)) {
                                  return 'Payout amount can\'t be less than ${Config().currency}${double.parse(globalSettings.sellerSettings.minPayoutAmt).toStringAsFixed(2)}';
                                }
                                return null;
                              },
                              onSaved: (val) {
                                payoutMap.update(
                                  'payoutAmt',
                                  (val) => double.parse(val.trim()),
                                  ifAbsent: () => double.parse(val.trim()),
                                );
                              },
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15.0),
                                helperStyle: GoogleFonts.poppins(
                                  color: Colors.black.withOpacity(0.65),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                prefixText: '${Config().currency}',
                                labelText: 'Payout amount',
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Payout via',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            ListView.builder(
                              itemCount: Config().payoutPaymentTypes.length,
                              shrinkWrap: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return RadioListTile(
                                  dense: true,
                                  title: Text(
                                    '${Config().payoutPaymentTypes[index]}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  value: index,
                                  groupValue: selectedPayoutType,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPayoutType = value;

                                      payoutMap.update(
                                        'payoutVia',
                                        (val) => Config().payoutPaymentTypes[
                                            selectedPayoutType],
                                        ifAbsent: () =>
                                            Config().payoutPaymentTypes[
                                                selectedPayoutType],
                                      );
                                    });
                                  },
                                );
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            selectedPayoutType == 0
                                ? Column(
                                    children: [
                                      TextFormField(
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        validator: (String val) {
                                          if (val.trim().isEmpty) {
                                            return 'Bank name is required';
                                          }

                                          return null;
                                        },
                                        onSaved: (val) {
                                          payoutMap.update(
                                            'bankName',
                                            (val) => val.trim(),
                                            ifAbsent: () => val.trim(),
                                          );
                                        },
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 15.0),
                                          helperStyle: GoogleFonts.poppins(
                                            color:
                                                Colors.black.withOpacity(0.65),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          errorStyle: GoogleFonts.poppins(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          hintStyle: GoogleFonts.poppins(
                                            color: Colors.black54,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          labelText: 'Bank name',
                                          labelStyle: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      TextFormField(
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        validator: (String val) {
                                          if (val.trim().isEmpty) {
                                            return 'Account no. is required';
                                          }

                                          return null;
                                        },
                                        onSaved: (val) {
                                          payoutMap.update(
                                            'accountNo',
                                            (val) => val.trim(),
                                            ifAbsent: () => val.trim(),
                                          );
                                        },
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 15.0),
                                          helperStyle: GoogleFonts.poppins(
                                            color:
                                                Colors.black.withOpacity(0.65),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          errorStyle: GoogleFonts.poppins(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          hintStyle: GoogleFonts.poppins(
                                            color: Colors.black54,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          labelText: 'Account no.',
                                          labelStyle: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      TextFormField(
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        validator: (String val) {
                                          if (val.trim().isEmpty) {
                                            return 'Account holder name is required';
                                          }

                                          return null;
                                        },
                                        onSaved: (val) {
                                          payoutMap.update(
                                            'accountName',
                                            (val) => val.trim(),
                                            ifAbsent: () => val.trim(),
                                          );
                                        },
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 15.0),
                                          helperStyle: GoogleFonts.poppins(
                                            color:
                                                Colors.black.withOpacity(0.65),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          errorStyle: GoogleFonts.poppins(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          hintStyle: GoogleFonts.poppins(
                                            color: Colors.black54,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          labelText: 'Account holder name',
                                          labelStyle: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      TextFormField(
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        // validator: (String val) {
                                        //   if (val.trim().isEmpty) {
                                        //     return 'IFSC code is required';
                                        //   }

                                        //   return null;
                                        // },
                                        onSaved: (val) {
                                          payoutMap.update(
                                            'ifscCode',
                                            (val) => val.trim(),
                                            ifAbsent: () => val.trim(),
                                          );
                                        },
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 15.0),
                                          helperStyle: GoogleFonts.poppins(
                                            color:
                                                Colors.black.withOpacity(0.65),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          errorStyle: GoogleFonts.poppins(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          hintStyle: GoogleFonts.poppins(
                                            color: Colors.black54,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          labelText: 'IFSC code (Optional)',
                                          labelStyle: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            selectedPayoutType == 1
                                ? TextFormField(
                                    validator: (String val) {
                                      if (val.trim().isEmpty) {
                                        return 'UPI ID is required';
                                      }

                                      return null;
                                    },
                                    onSaved: (val) {
                                      payoutMap.update(
                                        'upiId',
                                        (val) => val.trim(),
                                        ifAbsent: () => val.trim(),
                                      );
                                    },
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      color: Colors.black87,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      helperStyle: GoogleFonts.poppins(
                                        color: Colors.black.withOpacity(0.65),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                      errorStyle: GoogleFonts.poppins(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.black54,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                      labelText: 'UPI ID',
                                      labelStyle: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                            selectedPayoutType == 2
                                ? TextFormField(
                                    validator: (String val) {
                                      if (val.trim().isEmpty) {
                                        return 'Payout details is required';
                                      }

                                      return null;
                                    },
                                    onSaved: (val) {
                                      payoutMap.update(
                                        'payoutDetails',
                                        (val) => val.trim(),
                                        ifAbsent: () => val.trim(),
                                      );
                                    },
                                    keyboardType: TextInputType.multiline,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    textInputAction: TextInputAction.newline,

                                    maxLines: 4,
                                    minLines: 1,
                                    // maxLength: 300,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      color: Colors.black87,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      helperStyle: GoogleFonts.poppins(
                                        color: Colors.black.withOpacity(0.65),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                      errorStyle: GoogleFonts.poppins(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.black54,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                      labelText: 'Type your payout details',
                                      labelStyle: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              onSaved: (val) {
                                payoutMap.update(
                                  'notes',
                                  (val) => val.trim(),
                                  ifAbsent: () => val.trim(),
                                );
                              },
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 15),
                                helperStyle: GoogleFonts.poppins(
                                  color: Colors.black.withOpacity(0.65),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                labelText: 'Notes (Optional)',
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Container(
                              height: 45.0,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0.0),
                              child: FlatButton(
                                onPressed: () {
                                  if (double.parse(globalSettings
                                              .sellerSettings.minPayoutAmt)
                                          .toInt() >
                                      widget.payout.availablePayout) {
                                    showSnack(
                                        'Minimum payout amount of ${Config().currency}${globalSettings.sellerSettings.minPayoutAmt} is required to request a payout.',
                                        context);
                                    return;
                                  }
                                  //add payoutMap
                                  addNewAdmin();
                                },
                                color: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    // Icon(
                                    //   Icons.attach_money_outlined,
                                    //   color: Colors.white,
                                    //   size: 20.0,
                                    // ),
                                    // SizedBox(
                                    //   width: 10.0,
                                    // ),
                                    Text(
                                      'Request Payout',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                          ],
                        ),
                      ),
                    ],
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
