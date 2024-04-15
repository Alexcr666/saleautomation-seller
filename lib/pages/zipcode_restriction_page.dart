import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/blocs/zipcode_restriction_bloc/zipcode_restriction_bloc.dart';
import 'package:multivendor_seller/models/seller.dart';

import 'package:multivendor_seller/widgets/dialogs/processing_dialog.dart';

class ZipcodeRestrictionPage extends StatefulWidget {
  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<ZipcodeRestrictionPage>
    with AutomaticKeepAliveClientMixin {
  ZipcodeRestrictionBloc zipcodeRestrictionBloc;
  bool inProgress;
  List zipcodesList;
  TextEditingController controller = TextEditingController();
  bool isEnabled;
  Zipcode zipcode;

  @override
  void initState() {
    super.initState();

    zipcodesList = [];
    isEnabled = false;
    zipcodeRestrictionBloc = BlocProvider.of<ZipcodeRestrictionBloc>(context);
    zipcodeRestrictionBloc.add(GetAllZipcodes());

    zipcodeRestrictionBloc.stream.listen((state) {
      print('MY ACCOUNT BLOC :: $state');

      if (state is UpdateZipcodesInProgressState) {
        //in progress
        if (inProgress) {
          showUpdatingDialog();
        }
      }
      if (state is UpdateZipcodesFailedState) {
        //FAILED
        if (inProgress) {
          Navigator.pop(context);
          inProgress = false;
          showSnack('Failed to update!', context);
        }
      }
      if (state is UpdateZipcodesCompletedState) {
        //completed
        if (inProgress) {
          //send to home
          Navigator.pop(context);
          inProgress = false;
          showCompletedSnack('Zipcodes updated successfully!', context);
        }
      }
    });
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Updating zipcodes..\nPlease wait!',
        );
      },
    );
  }

  void showCompletedSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: Colors.green.shade500,
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
        Icons.done,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
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
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  updateZipcodes() async {
    zipcodeRestrictionBloc.add(UpdateZipcodes({
      'zipcodes': zipcodesList,
      'isEnabled': isEnabled,
    }));
    inProgress = true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: BlocBuilder(
          bloc: zipcodeRestrictionBloc,
          buildWhen: (previous, current) {
            if (current is GetAllZipcodesInProgressState ||
                current is GetAllZipcodesFailedState ||
                current is GetAllZipcodesCompletedState) {
              return true;
            }
            return false;
          },
          builder: (context, state) {
            if (state is GetAllZipcodesInProgressState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is GetAllZipcodesFailedState) {
              return Center(
                child: Text('FAILED TO LOAD!'),
              );
            }
            if (state is GetAllZipcodesCompletedState) {
              if (zipcode == null) {
                zipcode = state.zipcode;
                zipcodesList = zipcode.zipcodes;
                isEnabled = zipcode.isEnabled;
              }

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Do you want to restrict the zipcodes that can place order?',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      FlutterSwitch(
                        width: 60.0,
                        height: 30.0,
                        valueFontSize: 14.0,
                        toggleSize: 15.0,
                        value: isEnabled,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Colors.black38,
                        borderRadius: 15.0,
                        padding: 8.0,
                        onToggle: (val) {
                          setState(() {
                            isEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          'Allowed Zipcodes',
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // ClipRRect(
                        //   borderRadius: BorderRadius.circular(8.0),
                        //   child: Material(
                        //     color: Theme.of(context).primaryColor,
                        //     child: InkWell(
                        //       splashColor:
                        //           Colors.white.withOpacity(0.5),
                        //       onTap: () {
                        //         //add sub category
                        //         showAddSKUDialog();
                        //       },
                        //       child: Container(
                        //         decoration: BoxDecoration(
                        //           color: Colors.transparent,
                        //         ),
                        //         width: 35.0,
                        //         height: 35.0,
                        //         child: Icon(
                        //           Icons.add,
                        //           color: Colors.white,
                        //           size: 23.0,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Divider(),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    textAlignVertical: TextAlignVertical.center,
                    controller: controller,
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          zipcodesList.add(value.trim());
                        });
                      }
                      controller.clear();
                    },
                    enableInteractiveSelection: false,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
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
                        labelText: 'Input Zipcode',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.next_plan,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            if (controller.text.trim().isNotEmpty) {
                              setState(() {
                                zipcodesList.add(controller.text.trim());
                              });
                              controller.clear();
                            }
                          },
                        )),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  zipcodesList.length > 0
                      ? Wrap(
                          runSpacing: 8,
                          spacing: 8,
                          children: zipcodesList
                              .map((val) => Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.black12,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$val',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black87,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: InkWell(
                                              onTap: () {
                                                print('del');
                                                setState(() {
                                                  zipcodesList.remove(val);
                                                });
                                              },
                                              child: Icon(
                                                Icons.delete,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'No zipcode found',
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 45.0,
                    width: size.width,
                    child: FlatButton(
                      onPressed: () {
                        //update
                        updateZipcodes();
                      },
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        'Update Zipcodes',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                ],
              );
            }
            return SizedBox();
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
