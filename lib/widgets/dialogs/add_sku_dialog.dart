import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddSKUDialog extends StatefulWidget {
  @override
  _AddSKUDialogState createState() => _AddSKUDialogState();
}

class _AddSKUDialogState extends State<AddSKUDialog> {
  var image;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String skuName, price;
  int quantity;

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
        image = croppedFile;
      });
    } else {
      //not croppped

    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      elevation: 5.0,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Center(
                child: Text(
                  'Add SKU',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                enableInteractiveSelection: false,
                maxLines: 1,
                validator: (String val) {
                  if (val.trim().isEmpty) {
                    return 'SKU Title is required';
                  }
                  return null;
                },
                onSaved: (val) {
                  skuName = val.trim();
                },
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                  // border: InputBorder.none,
                  labelText: 'SKU Title',
                  hintText: 'eg: 1 kg',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14.0,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              // TextFormField(
              //   keyboardType: TextInputType.number,
              //   textInputAction: TextInputAction.done,
              //   enableInteractiveSelection: false,
              //   validator: (String val) {
              //     if (val.trim().isEmpty) {
              //       return 'MRP is required';
              //     }
              //     return null;
              //   },
              //   onSaved: (val) {
              //     mrp = val.trim();
              //   },
              //   style: GoogleFonts.poppins(
              //     fontSize: 14.0,
              //     color: Colors.black87,
              //     letterSpacing: 0.5,
              //     fontWeight: FontWeight.w500,
              //   ),
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //     contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
              //     // border: InputBorder.none,
              //     labelText: 'MRP',
              //     hintStyle: GoogleFonts.poppins(
              //       fontSize: 14.0,
              //       color: Colors.black54,
              //       letterSpacing: 0.5,
              //       fontWeight: FontWeight.w400,
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: 15.0,
              // ),
              TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                enableInteractiveSelection: false,
                validator: (String val) {
                  if (val.trim().isEmpty) {
                    return 'Price is required';
                  }
                  return null;
                },
                onSaved: (val) {
                  price = val.trim();
                },
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                  // border: InputBorder.none,
                  labelText: 'Price', hintText: 'eg: 15',

                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14.0,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                enableInteractiveSelection: false,
                validator: (String val) {
                  if (val.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  // if (int.parse(val) > 0) {
                  //   return 'Quantity must be more than 0';
                  // }
                  return null;
                },
                onSaved: (val) {
                  quantity = int.parse(val.trim());
                },
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                  // border: InputBorder.none,
                  labelText: 'Quantity', hintText: 'eg: 150',

                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14.0,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    onPressed: () {
                      //add sub category

                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();

                        Navigator.pop(context, {
                          'skuName': skuName,
                          'skuPrice': price,
                          'quantity': quantity,
                          'skuId': Uuid().v4(),
                        });
                      }
                    },
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      'Add SKU',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: size.width * 0.5,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
