import 'dart:io';

import 'package:geocoding/geocoding.dart';
//import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/blocs/my_account_bloc/my_account_bloc.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/seller.dart';
import 'package:multivendor_seller/screens/my_account_screen/change_password_screen.dart';
import 'package:multivendor_seller/widgets/dialogs/processing_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class MyAccountPage extends StatefulWidget {
  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> with AutomaticKeepAliveClientMixin {
  MyAccountBloc myAccountBloc;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController locationController = TextEditingController();
  LatLng selectedLatLng;
  String address, placeId;
  String name, email, mobileNo;
  bool primaryAdmin;
  bool inProgress;
  var image;
  var selectedImage;

  Seller seller;

  @override
  void initState() {
    super.initState();

    myAccountBloc = BlocProvider.of<MyAccountBloc>(context);
    myAccountBloc.add(GetMyAccountDetailsEvent());

    myAccountBloc.listen((state) {
      print('MY ACCOUNT BLOC :: $state');

      if (state is UpdateAdminDetailsInProgressState) {
        //in progress
        if (inProgress) {
          showUpdatingDialog();
        }
      }
      if (state is UpdateAdminDetailsFailedState) {
        //FAILED
        if (inProgress) {
          Navigator.pop(context);
          inProgress = false;
          showSnack('Failed to update!', context);
        }
      }
      if (state is UpdateAdminDetailsCompletedState) {
        //completed
        if (inProgress) {
          //send to home
          Navigator.pop(context);
          inProgress = false;
          showCompletedSnack('Account details updated successfully!', context);
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
          message: 'Updating account details..\nPlease wait!',
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
          fontSize: 14.0,
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
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  updateAccountDetails() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      Map sellerMap = Map();
      sellerMap.putIfAbsent('uid', () => seller.uid);
      sellerMap.putIfAbsent('name', () => name);
      sellerMap.putIfAbsent('email', () => email);
      sellerMap.putIfAbsent('mobileNo', () => mobileNo);
      sellerMap.putIfAbsent('address', () => address);

      //check if location changed
      if (selectedLatLng != null) {
        sellerMap.addAll({
          'locationLat': selectedLatLng.latitude,
          'locationLng': selectedLatLng.longitude,
          'placeId': placeId,
        });
      } else {
        sellerMap.addAll({
          'locationLat': seller.locationDetails.lat,
          'locationLng': seller.locationDetails.lng,
          'placeId': seller.locationDetails.placeId,
        });
      }

      if (selectedImage != null) {
        sellerMap.putIfAbsent('profileImage', () => selectedImage);
      } else {
        sellerMap.putIfAbsent('profileImageUrl', () => seller.profileImageUrl);
      }

      myAccountBloc.add(UpdateAdminDetailsEvent(sellerMap));
      inProgress = true;
    }
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

  openLocationPicker() async {
    /*LocationResult locationResult = await showLocationPicker(
      context,
      Platform.isIOS
          ? "AIzaSyBwEJGrDjxExdtaea7XQ6gXthuVpFMAAr4"
          : "AIzaSyC1XAVYi0CD_UleT7QP4KtSfs-fO0pZO0c", //TODO: Change the ANDROID API KEY
      myLocationButtonEnabled: true,
      layersButtonEnabled: false,
      automaticallyAnimateToCurrentLocation: true,
    );*/

    /* if (locationResult != null) {
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
          bloc: myAccountBloc,
          buildWhen: (previous, current) {
            if (current is GetMyAccountDetailsInProgressState ||
                current is GetMyAccountDetailsFailedState ||
                current is GetMyAccountDetailsCompletedState) {
              return true;
            }
            return false;
          },
          builder: (context, state) {
            if (state is GetMyAccountDetailsInProgressState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is GetMyAccountDetailsFailedState) {
              return Center(
                child: Text('FAILED TO LOAD!'),
              );
            }
            if (state is GetMyAccountDetailsCompletedState) {
              if (seller == null) {
                seller = state.seller;
                email = seller.email;
                mobileNo = seller.mobileNo;
                name = seller.name;
                address = seller.locationDetails.address;

                locationController.text = seller.locationDetails.address;
                selectedLatLng = LatLng(seller.locationDetails.lat, seller.locationDetails.lng);
                placeId = seller.locationDetails.placeId;
              }
              // seller = state.seller;

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                scrollDirection: Axis.vertical,
                children: <Widget>[
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
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(100.0),
                                        child: Image.network(
                                          seller.profileImageUrl,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(100.0),
                                        child: Image.file(
                                          selectedImage,
                                        ),
                                      ),
                              ),
                              Positioned(
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
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return 'Seller name is required';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            name = val.trim();
                          },
                          initialValue: name,
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
                          height: 20.0,
                        ),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return 'Mobile no. is required';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            mobileNo = val.trim();
                          },
                          initialValue: mobileNo.isNotEmpty ? mobileNo.substring(Config().countryMobileNoPrefix.length) : '',
                          enableInteractiveSelection: false,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(0),
                            helperStyle: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            prefixText: '${Config().countryMobileNoPrefix}-',
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
                          height: 20.0,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: locationController,
                                textAlignVertical: TextAlignVertical.center,
                                validator: (String val) {
                                  if (val.trim().isEmpty) {
                                    return 'Address is required';
                                  }
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
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
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
                            email = val.trim();
                          },
                          initialValue: email,
                          enableInteractiveSelection: false,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          readOnly: true,
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
                          height: 20.0,
                        ),
                        // Row(
                        //   children: <Widget>[
                        //     Text(
                        //       'Primary seller: ',
                        //       style: GoogleFonts.poppins(
                        //         color: Colors.black.withOpacity(0.7),
                        //         fontSize: 13.5,
                        //         fontWeight: FontWeight.w500,
                        //         letterSpacing: 0.5,
                        //       ),
                        //     ),
                        //     Text(
                        //       seller.primaryAdmin ? 'YES' : 'NO',
                        //       style: GoogleFonts.poppins(
                        //         color: Colors.black87,
                        //         fontSize: 13.5,
                        //         fontWeight: FontWeight.w500,
                        //         letterSpacing: 0.5,
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        Row(
                          children: <Widget>[
                            Text(
                              'Last updated: ',
                              style: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${new DateFormat('dd MMM yyyy, hh:mm a').format(seller.timestamp.toDate())}',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Account status: ',
                              style: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${seller.approvalStatus}',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Material(
                            child: InkWell(
                              splashColor: Colors.blue.withOpacity(0.3),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangePasswordScreen(
                                      seller: seller,
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
                                        Text(
                                          'Change Password',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black87,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 40.0,
                                      height: 40.0,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue.withOpacity(0.2),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.userLock,
                                        color: Colors.blue.shade500,
                                        size: 15.0,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          height: 45.0,
                          width: size.width,
                          child: FlatButton(
                            onPressed: () {
                              //update
                              updateAccountDetails();
                            },
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Text(
                              'Update Account Details',
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
                          height: 20.0,
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
