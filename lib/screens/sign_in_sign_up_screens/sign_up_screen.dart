import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:multivendor_seller/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/widgets/dialogs/processing_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:styled_text/styled_text.dart';
import 'package:geocoding/geocoding.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignupBloc signupBloc;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController locationController = TextEditingController();
  LatLng selectedLatLng;
  String address, placeId;

  String mobileNo, email, name, password;
  bool inProgress;
  var image;
  var selectedImage;
  bool passwordVisible;

  @override
  void initState() {
    super.initState();
    inProgress = false;

    signupBloc = BlocProvider.of<SignupBloc>(context);
    passwordVisible = true;

    signupBloc.listen((state) {
      if (state is SignUpWithEmailCompletedState) {
        //check if any error
        if (state.res.isNotEmpty) {
          showFailedSnakbar(state.res);
          inProgress = false;
          Navigator.pop(context);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
          inProgress = false;
        }
      }
      if (state is SignUpWithEmailFailedState) {
        //failed to sign up
        showFailedSnakbar('Failed to sign up');
        inProgress = false;
        Navigator.pop(context);
      }
      if (state is SignUpWithEmailInProgressState) {
        if (inProgress) {
          showUpdatingDialog();
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
          message: 'Signing up..\nPlease wait!',
        );
      },
    );
  }

  signUpWithMobileNo() {
    //validate first
    if (_formKey.currentState.validate()) {
      //proceed
      _formKey.currentState.save();
      if (selectedImage == null) {
        showFailedSnakbar('Please select vendor image!');
        return;
      }

      mobileNo = '${Config().countryMobileNoPrefix}$mobileNo';

      signupBloc.add(SignUpWithEmail({
        'name': name,
        'email': email,
        'password': password,
        'address': address,
        'mobileNo': mobileNo,
        'image': selectedImage,
        'locationLat': /*selectedLatLng.latitude.toString()*/ 1,
        'locationLng': /*selectedLatLng.longitude.toString()*/ 1,
        'placeId': placeId,
      }));

      inProgress = true;
    }
  }

  openLocationPicker() async {
    /*  LocationResult locationResult = await showLocationPicker(
      context,
      'AIzaSyBwEJGrDjxExdtaea7XQ6gXthuVpFMAAr4',
      // Platform.isIOS
      //     ? "AIzaSyBbAn8KAeRsmMxfmiYycfsHY0gqjSlDXhQ"
      //     : "AIzaSyC1XAVYi0CD_UleT7QP4KtSfs-fO0pZO0c", //TODO: Change the ANDROID API KEY
      myLocationButtonEnabled: true,
      layersButtonEnabled: false,
      automaticallyAnimateToCurrentLocation: true,
    );

    if (locationResult != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(locationResult.latLng.latitude, locationResult.latLng.longitude);

      print(locationResult.address);
      print(locationResult.latLng);
      print(locationResult.placeId);
      setState(() {
        address = (placemarks.first.street.isNotEmpty ? placemarks.first.street + ', ' : '') +
            (placemarks.first.name.isNotEmpty ? placemarks.first.name + ', ' : '') +
            (placemarks.first.locality.isNotEmpty ? placemarks.first.locality + ', ' : '') +
            (placemarks.first.subLocality.isNotEmpty ? placemarks.first.subLocality + ', ' : '') +
            (placemarks.first.administrativeArea.isNotEmpty ? placemarks.first.administrativeArea + ', ' : '') +
            (placemarks.first.country.isNotEmpty ? placemarks.first.country : '') +
            (placemarks.first.postalCode.isNotEmpty ? ', ' + placemarks.first.postalCode : '');
        // placemarks.first.locality +
        // placemarks.first.street +
        // placemarks.first.postalCode +
        // placemarks.first.country;
        // '${placemarks.first.subLocality}, ${placemarks.first.locality.isEmpty ? placemarks.first.street : placemarks.first.locality}, ${placemarks.first.country}';
        placeId = locationResult.placeId;
        selectedLatLng = locationResult.latLng;

        locationController.text = address;
      });
    } else {
      print('NOT SELECTED LOCATION');
    }*/
  }

  void showFailedSnakbar(String s) {
    SnackBar snackbar = SnackBar(
      content: Text(
        s,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.red,
      action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Future cropImage(context) async {
    image = await ImagePicker().getImage(source: ImageSource.gallery);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        cropStyle: CropStyle.rectangle,
        compressFormat: ImageCompressFormat.jpg,
        maxHeight: 400,
        maxWidth: 400,
        compressQuality: 50,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          showCropGrid: false,
          lockAspectRatio: true,
          statusBarColor: Theme.of(context).primaryColor,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,
        ));

    if (croppedFile != null) {
      print('File size: ' + croppedFile.lengthSync().toString());
      setState(() {
        selectedImage = croppedFile;
      });
    } else {
      //not croppped

    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 200.0,
              width: size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColorDark,
                    Theme.of(context).primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/banners/signup_top.svg',
                    fit: BoxFit.fitWidth,
                  ),
                  Positioned(
                    left: 12.0,
                    top: 35.0,
                    child: ClipRRect(
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
                              Icons.close,
                              color: Colors.white.withOpacity(0.85),
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: size.height - 200.0,
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: ListView(
                primary: true,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                children: <Widget>[
                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.85),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: size.width * 0.25,
                                width: size.width * 0.25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
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
                                child: selectedImage == null
                                    ? Icon(
                                        Icons.person,
                                        size: 50.0,
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(100.0),
                                        child: Image.file(
                                          selectedImage,
                                        ),
                                      ),
                              ),
                              selectedImage != null
                                  ? Positioned(
                                      bottom: 0.0,
                                      left: 0.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50.0),
                                        child: Material(
                                          color: Theme.of(context).primaryColor,
                                          child: InkWell(
                                            splashColor: Colors.white.withOpacity(0.5),
                                            onTap: () {
                                              //TODO: take user to edit
                                              cropImage(context);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(),
                                              width: 30.0,
                                              height: 30.0,
                                              child: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 16.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Positioned(
                                      bottom: 0.0,
                                      left: 0.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50.0),
                                        child: Material(
                                          color: Theme.of(context).primaryColor,
                                          child: InkWell(
                                            splashColor: Colors.white.withOpacity(0.5),
                                            onTap: () {
                                              //TODO: take user to edit
                                              cropImage(context);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(),
                                              width: 30.0,
                                              height: 30.0,
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 16.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.isEmpty) {
                              return 'Seller name is required';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            name = val;
                          },
                          enableInteractiveSelection: false,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(0),
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
                            prefixIcon: Icon(
                              Icons.person,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: 'Seller name',
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
                        TextFormField(
                          // controller: mobileNoController,
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.isEmpty) {
                              return 'Mobile No. is required';
                            }

                            return null;
                          },
                          onSaved: (val) {
                            mobileNo = val;
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
                            contentPadding: EdgeInsets.all(0),
                            helperStyle: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            prefixText: '${Config().countryMobileNoPrefix} ',
                            prefixStyle: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 13.5,
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
                            prefixIcon: Icon(
                              Icons.phone,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: 'Mobile no.',
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: locationController,
                                textAlignVertical: TextAlignVertical.center,
                                validator: (String val) {
                                  /* if (val.trim().isEmpty) {
                                    return 'Address is required';
                                  }*/
                                  return null;
                                },
                                enableInteractiveSelection: false,
                                readOnly: true,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                textInputAction: TextInputAction.done,
                                minLines: 1,
                                maxLines: 3,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 50.0,
                                  ),
                                  labelText: 'Address',
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
                            ),
                            // Expanded(
                            //   child: TextFormField(
                            //     controller: locationController,
                            //     textAlignVertical: TextAlignVertical.center,
                            //     validator: (String val) {
                            //       if (val.isEmpty) {
                            //         return 'Address is required';
                            //       }
                            //       return null;
                            //     },
                            //     onSaved: (val) {
                            //       address = val;
                            //     },
                            //     readOnly: true,
                            //     enableInteractiveSelection: false,
                            //     style: GoogleFonts.poppins(
                            //       color: Colors.black,
                            //       fontSize: 13.5,
                            //       fontWeight: FontWeight.w500,
                            //       letterSpacing: 0.5,
                            //     ),
                            //     minLines: 1,
                            //     maxLines: 3,
                            //     keyboardType: TextInputType.multiline,
                            //     textInputAction: TextInputAction.done,
                            //     textCapitalization: TextCapitalization.words,
                            //     decoration: InputDecoration(
                            //       contentPadding: EdgeInsets.all(0),
                            //       helperStyle: GoogleFonts.poppins(
                            //         color: Colors.black.withOpacity(0.65),
                            //         fontWeight: FontWeight.w500,
                            //         letterSpacing: 0.5,
                            //       ),
                            //       errorStyle: GoogleFonts.poppins(
                            //         fontSize: 13.0,
                            //         fontWeight: FontWeight.w500,
                            //         letterSpacing: 0.5,
                            //       ),
                            //       hintStyle: GoogleFonts.poppins(
                            //         color: Colors.black54,
                            //         fontSize: 13.5,
                            //         fontWeight: FontWeight.w500,
                            //         letterSpacing: 0.5,
                            //       ),
                            //       prefixIcon: Icon(
                            //         Icons.location_on,
                            //       ),
                            //       prefixIconConstraints: BoxConstraints(
                            //         minWidth: 50.0,
                            //       ),
                            //       labelText: 'Address',
                            //       labelStyle: GoogleFonts.poppins(
                            //         fontSize: 13.5,
                            //         fontWeight: FontWeight.w500,
                            //         letterSpacing: 0.5,
                            //       ),
                            //       border: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(12.0),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
                              width: 10,
                            ),
                            TextButton(
                              onPressed: () {
                                openLocationPicker();
                              },
                              child: Text(
                                'Select Location',
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return 'Email Address is required';
                            }
                            if (!RegExp(
                                    r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$")
                                .hasMatch(val)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            email = val;
                          },
                          enableInteractiveSelection: false,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(0),
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
                            prefixIcon: Icon(
                              Icons.email,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: 'Email address',
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
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return 'Password is required';
                            }
                            if (val.trim().length < 6) {
                              return 'Password should be of 6 or more characters';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            password = val.trim();
                          },
                          enableInteractiveSelection: true,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          obscureText: passwordVisible,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(0),
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
                            prefixIcon: Icon(
                              Icons.lock,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: 'Password',
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
                                passwordVisible ? MdiIcons.eyeOutline : MdiIcons.eyeOffOutline,
                              ),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        print('T & C');
                      },
                      child: StyledText(
                        text:
                            'By signing up you&apos;\'re accepting the <bold>Terms and Conditions</bold> of becoming a seller on this platform.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12.0,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                        tags: {
                          'bold': StyledTextTag(
                            style: GoogleFonts.poppins(
                              fontSize: 12.0,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          )
                        },
                      ),
                    ),
                  ),
                  // Text(
                  //   'By signing up you\'re accepting the Terms and Conditions of becoming a vendor on this platform.',
                  //   textAlign: TextAlign.center,
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 12.0,
                  //     color: Colors.black54,
                  //     fontWeight: FontWeight.w400,
                  //     letterSpacing: 0.5,
                  //   ),
                  // ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: Container(
                      width: size.width,
                      height: 48.0,
                      child: FlatButton(
                        onPressed: () {
                          //validate inputs
                          signUpWithMobileNo();
                        },
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
