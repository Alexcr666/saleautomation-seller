import 'package:multivendor_seller/blocs/my_account_bloc/my_account_bloc.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/seller.dart';

import 'package:multivendor_seller/widgets/dialogs/processing_dialog.dart';
import 'package:multivendor_seller/widgets/dialogs/product_added_dialog.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  final Seller seller;

  const ChangePasswordScreen({Key key, this.seller}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  MyAccountBloc myAccountBloc;
  bool isAdding;
  bool repeatPasswordVisible, newPasswordVisible, oldPasswordVisible;

  String oldPassword, newPassword, newPasswordConfirm;

  @override
  void initState() {
    super.initState();

    isAdding = false;
    myAccountBloc = BlocProvider.of<MyAccountBloc>(context);
    repeatPasswordVisible = true;
    newPasswordVisible = true;
    oldPasswordVisible = true;

    myAccountBloc.listen((state) {
      print('EDIT ADMIN BLOC :: $state');

      if (state is ChangePasswordInProgressState) {
        //in progress
        showUpdatingDialog();
      }
      if (state is ChangePasswordFailedState) {
        //failed
        if (isAdding) {
          Navigator.pop(context);
          showSnack('Failed to change password!', context);
          isAdding = false;
        }
      }
      if (state is ChangePasswordCompletedState) {
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
          message: 'Password updated successfully!',
        );
      },
    );

    if (res == 'ADDED') {
      //added
      Navigator.pop(context, true);
    }
  }

  changePassword() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      myAccountBloc.add(
        ChangePasswordEvent({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
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
          message: 'Updating password..\nPlease wait!',
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
                      'Change Password',
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
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        validator: (String val) {
                          if (val.trim().isEmpty) {
                            return 'Old password is required';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          oldPassword = val.trim();
                        },
                        enableInteractiveSelection: false,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        obscureText: oldPasswordVisible,
                        textInputAction: TextInputAction.done,
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
                          prefixIcon: Icon(Icons.lock),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: 'Old password',
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
                              oldPasswordVisible
                                  ? MdiIcons.eyeOutline
                                  : MdiIcons.eyeOffOutline,
                            ),
                            onPressed: () {
                              setState(() {
                                oldPasswordVisible = !oldPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        validator: (String val) {
                          if (val.trim().isEmpty) {
                            return 'New password is required';
                          }
                          if (val.trim().length < 6) {
                            return 'Password should be of 6 or more characters';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          newPassword = val.trim();
                        },
                        onChanged: (value) {
                          newPassword = value.trim();
                        },
                        enableInteractiveSelection: false,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        obscureText: newPasswordVisible,
                        textInputAction: TextInputAction.done,
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
                          prefixIcon: Icon(Icons.lock),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: 'New password',
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
                              newPasswordVisible
                                  ? MdiIcons.eyeOutline
                                  : MdiIcons.eyeOffOutline,
                            ),
                            onPressed: () {
                              setState(() {
                                newPasswordVisible = !newPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        validator: (String val) {
                          if (val.trim().isEmpty) {
                            return 'Confirm new password is required';
                          }
                          if (val.trim() != newPassword) {
                            return 'New passwords does not match';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          newPasswordConfirm = val.trim();
                        },
                        obscureText: repeatPasswordVisible,
                        enableInteractiveSelection: false,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
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
                          prefixIcon: Icon(Icons.lock),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: 'Confirm new password',
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
                              repeatPasswordVisible
                                  ? MdiIcons.eyeOutline
                                  : MdiIcons.eyeOffOutline,
                            ),
                            onPressed: () {
                              setState(() {
                                repeatPasswordVisible = !repeatPasswordVisible;
                              });
                            },
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
                            //change pass
                            changePassword();
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'Change Password',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14.0,
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
