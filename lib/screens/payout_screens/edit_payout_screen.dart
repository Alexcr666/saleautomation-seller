import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/blocs/payout_bloc/payout_bloc.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/payout.dart';
import 'package:multivendor_seller/widgets/dialogs/processing_dialog.dart';
import 'package:multivendor_seller/widgets/dialogs/product_added_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditPayoutScreen extends StatefulWidget {
  final Payouts payout;
  final int index;

  const EditPayoutScreen({Key key, @required this.payout, this.index})
      : super(key: key);
  @override
  _AddNewAdminScreenState createState() => _AddNewAdminScreenState();
}

class _AddNewAdminScreenState extends State<EditPayoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> payoutMap = Map();
  PayoutBloc payoutBloc;
  bool isAdding;
  int selectedPayoutType;

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

    switch (widget.payout.payoutVia) {
      case 'Bank Account':
        selectedPayoutType = 0;
        break;
      case 'UPI':
        selectedPayoutType = 1;
        break;
      case 'Other':
        selectedPayoutType = 2;
        break;
      default:
    }

    payoutBloc.listen((state) {
      if (state is ModifyRequestPayoutInProgressState) {
        //in progress
        showUpdatingDialog();
      }
      if (state is ModifyRequestPayoutFailedState) {
        //failed
        if (isAdding) {
          Navigator.pop(context);
          showSnack('Failed to update payout!', context);
          isAdding = false;
        }
      }
      if (state is ModifyRequestPayoutCompletedState) {
        //completed
        if (isAdding) {
          isAdding = false;
          Navigator.pop(context);
          showProductAddedDialog();
        }
      }
    });
  }

  showProductAddedDialog() async {
    var res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProductAddedDialog(
          message: 'Payout updated successfully!',
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

      payoutMap.putIfAbsent('payoutId', () => widget.payout.payoutId);

      payoutBloc.add(
        ModifyRequestPayout(payoutMap),
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
          message: 'Updating payout..\nPlease wait!',
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
                      'Edit Payout',
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        // validator: (String val) {
                        //   if (val.trim().isEmpty) {
                        //     return 'Payout amount is required';
                        //   }
                        //   if (double.parse(val.trim()) >
                        //       widget.payout.availablePayout) {
                        //     return 'Payout amount can\'t be more than ${Config().currency}${widget.payout.availablePayout}';
                        //   }
                        //   return null;
                        // },
                        onSaved: (val) {
                          payoutMap.update(
                            'payoutAmt',
                            (val) => double.parse(val.trim()),
                            ifAbsent: () => double.parse(val.trim()),
                          );
                        },
                        readOnly: true,
                        initialValue:
                            double.parse(widget.payout.payoutAmt.toString())
                                .toStringAsFixed(2),
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
                        height: 15.0,
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
                        padding: const EdgeInsets.symmetric(horizontal: 0),
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
                                  (val) => Config()
                                      .payoutPaymentTypes[selectedPayoutType],
                                  ifAbsent: () => Config()
                                      .payoutPaymentTypes[selectedPayoutType],
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
                                  textAlignVertical: TextAlignVertical.center,
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
                                  initialValue:
                                      widget.payout.payoutBankDetails.bankName,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
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
                                    labelText: 'Bank name',
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
                                TextFormField(
                                  textAlignVertical: TextAlignVertical.center,
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
                                  initialValue:
                                      widget.payout.payoutBankDetails.accountNo,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
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
                                    labelText: 'Account no.',
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
                                TextFormField(
                                  textAlignVertical: TextAlignVertical.center,
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
                                  initialValue: widget
                                      .payout.payoutBankDetails.accountName,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
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
                                    labelText: 'Account holder name',
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
                                TextFormField(
                                  textAlignVertical: TextAlignVertical.center,
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
                                  initialValue:
                                      widget.payout.payoutBankDetails.ifscCode,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
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
                                    labelText: 'IFSC code',
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
                              initialValue:
                                  widget.payout.payoutBankDetails.upiId,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                color: Colors.black87,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w500,
                              ),
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
                                labelText: 'UPI ID',
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
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
                              initialValue:
                                  widget.payout.payoutBankDetails.payoutDetails,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
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
                                labelText: 'Type your payout details',
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
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
                        initialValue: widget.payout.notes,
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
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: FlatButton(
                          onPressed: () {
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
                                'Update Payout',
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
            ),
          ),
        ],
      ),
    );
  }
}
