import 'dart:io';

import 'package:multivendor_seller/blocs/inventory_bloc/all_categories_bloc.dart';
import 'package:multivendor_seller/blocs/inventory_bloc/inventory_bloc.dart';
import 'package:multivendor_seller/blocs/products_bloc/add_new_product_bloc.dart';
import 'package:multivendor_seller/blocs/products_bloc/products_bloc.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/models/category.dart';
import 'package:multivendor_seller/widgets/dialogs/add_sku_dialog.dart';
import 'package:multivendor_seller/widgets/dialogs/edit_sku_dialog.dart';
import 'package:multivendor_seller/widgets/dialogs/processing_dialog.dart';
import 'package:multivendor_seller/widgets/dialogs/product_added_dialog.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController keywordController = TextEditingController();

  AllCategoriesBloc allCategoriesBloc;
  AddNewProductBloc addNewProductBloc;
  List<Category> categories;
  List categoryNames;
  List subcategoryNames;
  String _selectedCategory;
  String _selectedSubCategory;
  int index;
  var image;
  List productImages;
  bool isAdding;
  Map<dynamic, dynamic> product = Map();
  bool inStock, isListed, isFeatured, isDiscounted;
  double discountPer;
  List skusList;
  List keywords;

  @override
  void initState() {
    super.initState();

    categories = List();
    subcategoryNames = List();
    productImages = List();
    isAdding = false;
    inStock = false;
    isListed = false;
    isFeatured = false;
    isDiscounted = false;
    skusList = List();
    keywords = List();

    allCategoriesBloc = BlocProvider.of<AllCategoriesBloc>(context);
    addNewProductBloc = BlocProvider.of<AddNewProductBloc>(context);

    allCategoriesBloc.listen((state) {
      print('ADD PRODUCT SCREEN :: $state');
    });

    addNewProductBloc.listen((state) {
      if (state is AddNewProductInProgressState) {
        //in progress
        showUpdatingDialog();
      }
      if (state is AddNewProductFailedState) {
        //failed
        if (isAdding) {
          Navigator.pop(context);
          showSnack('Failed to add the product!', context);
          isAdding = false;
        }
      }
      if (state is AddNewProductCompletedState) {
        //completed
        if (isAdding) {
          isAdding = false;
          Navigator.pop(context);
          showProductAddedDialog();
        }
      }
    });

    allCategoriesBloc.add(GetAllCategoriesEvent());
  }

  addProduct() {
    // //TODO: temp disabled
    // showSnack('You\'re not a Primary admin.\nAction not allowed!', context);

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (_selectedCategory != null &&
          _selectedSubCategory != null &&
          productImages.length > 0) {
        if (skusList.isEmpty) {
          showSnack('Please add SKU\'s to proceed!', context);
          return;
        }
        if (keywords.length == 0) {
          showSnack('Please add keywords to proceed!', context);
          return;
        }
        product.putIfAbsent('isListed', () => isListed);
        product.putIfAbsent('inStock', () => inStock);
        product.putIfAbsent('featured', () => isFeatured);
        product.putIfAbsent('isDiscounted', () => isDiscounted);
        product.putIfAbsent('discount', () => discountPer ?? 0);

        product.putIfAbsent('productImages', () => productImages);

        product.putIfAbsent('skus', () => skusList);
        product.putIfAbsent('keywords', () => keywords);

        addNewProductBloc.add(AddNewProductEvent(product));
        isAdding = true;
      } else {
        showSnack('Please fill all the details!', context);
      }
    }
  }

  Future showEditSKUDialog(int index, Map sku) async {
    Map skuMap = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return EditSKUDialog(
          skuMap: sku,
        );
      },
    );

    if (skuMap != null) {
      //add to list
      setState(() {
        skusList.removeAt(index);
        skusList.insert(index, skuMap);
      });
    }

    print(skusList);
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Adding new product..\nPlease wait!',
        );
      },
    );
  }

  showProductAddedDialog() async {
    var res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProductAddedDialog(
          message: 'Product added successfully!',
        );
      },
    );

    if (res == 'ADDED') {
      //added
      Navigator.pop(context, true);
    }
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
        productImages.add(croppedFile);
      });
    } else {
      //not croppped

    }
  }

  Future showAddSKUDialog() async {
    Map skuMap = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AddSKUDialog();
      },
    );

    if (skuMap != null) {
      //add to list
      setState(() {
        skusList.add(skuMap);
      });
    }

    print(skusList);
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
                      'Add New Product',
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
              bloc: allCategoriesBloc,
              buildWhen: (previous, current) {
                if (current is GetAllCategoriesCompletedState ||
                    current is GetAllCategoriesInProgressState ||
                    current is GetAllCategoriesFailedState) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetAllCategoriesInProgressState) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is GetAllCategoriesFailedState) {
                  return Center(
                    child: Text(
                      'Failed to load!',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                if (state is GetAllCategoriesCompletedState) {
                  categories = state.categories;

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
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              validator: (String val) {
                                if (val.trim().isEmpty) {
                                  return 'Product name is required';
                                }
                                return null;
                              },
                              onSaved: (val) {
                                product.putIfAbsent('name', () => val.trim());
                              },
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
                                labelText: 'Product name',
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
                              height: 10.0,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(15.0),
                                  labelText: 'Select a category',
                                  labelStyle: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                isEmpty: _selectedCategory == null,
                                child: DropdownButton<String>(
                                    underline: SizedBox(
                                      height: 0,
                                    ),
                                    value: _selectedCategory,
                                    isExpanded: true,
                                    isDense: true,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    items: categories
                                        .map((e) => DropdownMenuItem(
                                              child: Text(
                                                e.categoryName,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black87,
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              value: e.categoryName,
                                            ))
                                        .toList(),
                                    onChanged: (String category) {
                                      setState(() {
                                        _selectedCategory = category;

                                        product.putIfAbsent('category',
                                            () => _selectedCategory);

                                        _selectedSubCategory = null;

                                        for (var i = 0;
                                            i < categories.length;
                                            i++) {
                                          if (categories[i].categoryName ==
                                              _selectedCategory) {
                                            index = i;
                                            break;
                                          }
                                        }
                                      });
                                    }),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            _selectedCategory != null
                                ? Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 5.0, bottom: 5.0),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(15.0),
                                            labelText: 'Select a sub-category',
                                            labelStyle: GoogleFonts.poppins(
                                              color: Colors.black87,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                          ),
                                          isEmpty: _selectedSubCategory == null,
                                          child: DropdownButton<String>(
                                              underline: SizedBox(
                                                height: 0,
                                              ),
                                              style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              value: _selectedSubCategory,
                                              isExpanded: true,
                                              isDense: true,
                                              items: categories[index]
                                                  .subCategories
                                                  .map((e) => DropdownMenuItem(
                                                        child: Text(
                                                          e.subCategoryName,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 13.5,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        value:
                                                            e.subCategoryName,
                                                      ))
                                                  .toList(),
                                              onChanged: (String newVal) {
                                                setState(() {
                                                  _selectedSubCategory = newVal;
                                                });

                                                product.putIfAbsent(
                                                    'subCategory',
                                                    () => _selectedSubCategory);
                                              }),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    'SKU\'s',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                            Colors.white.withOpacity(0.5),
                                        onTap: () {
                                          //add sub category
                                          showAddSKUDialog();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Divider(),
                            SizedBox(
                              height: 5.0,
                            ),
                            skusList.length == 0
                                ? Center(
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(
                                          'No SKU\'s added',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black87,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                6.0,
                                              ),
                                              child: Material(
                                                color: Colors.green,
                                                child: InkWell(
                                                  splashColor: Colors.white
                                                      .withOpacity(0.4),
                                                  onTap: () {
                                                    //edit sku
                                                    showEditSKUDialog(
                                                      index,
                                                      skusList[index],
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 28.0,
                                                    height: 28.0,
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: Colors.white,
                                                      size: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6,
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                6.0,
                                              ),
                                              child: Material(
                                                color: Colors.red,
                                                child: InkWell(
                                                  splashColor: Colors.white
                                                      .withOpacity(0.4),
                                                  onTap: () {
                                                    //remove image
                                                    setState(() {
                                                      skusList.removeAt(index);
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 28.0,
                                                    height: 28.0,
                                                    child: Icon(
                                                      Icons.remove,
                                                      color: Colors.white,
                                                      size: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.all(0.0),
                                        title: Row(
                                          children: [
                                            Text(
                                              '${index + 1}. ${skusList[index]['skuName']}',
                                              style: GoogleFonts.poppins(
                                                color: Colors.black87,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            skusList[index]['quantity'] <
                                                    Config().lowInventoryNo
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.red,
                                                    ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5,
                                                        vertical: 1),
                                                    child: Text(
                                                      'Low Qty',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '   Price: ${Config().currency}${skusList[index]['skuPrice']}',
                                              style: GoogleFonts.poppins(
                                                color: Colors.black87,
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              '   Quantity: ${skusList[index]['quantity']}',
                                              style: GoogleFonts.poppins(
                                                color: Colors.black87,
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return SizedBox(
                                        height: 10.0,
                                      );
                                    },
                                    itemCount: skusList.length),

                            SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              validator: (String val) {
                                if (val.trim().isEmpty) {
                                  return 'Description is required';
                                }
                                return null;
                              },
                              onSaved: (val) {
                                product.putIfAbsent(
                                    'description', () => val.trim());
                              },
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.start,
                              textInputAction: TextInputAction.newline,
                              minLines: 3,
                              maxLines: 5,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 15.0),
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
                                labelText: 'Description',
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    'Keywords',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            SizedBox(
                              height: 8.0,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              controller: keywordController,
                              onFieldSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  setState(() {
                                    keywords.add(value.trim());
                                  });
                                }
                                keywordController.clear();
                              },
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
                                  labelText: 'Input Keyword',
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
                                      if (keywordController.text
                                          .trim()
                                          .isNotEmpty) {
                                        setState(() {
                                          keywords.add(
                                              keywordController.text.trim());
                                        });
                                        keywordController.clear();
                                      }
                                    },
                                  )),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            keywords.length > 0
                                ? Wrap(
                                    runSpacing: 8,
                                    spacing: 8,
                                    children: keywords
                                        .map((val) => Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '$val',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.black87,
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 30,
                                                    width: 30,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      child: InkWell(
                                                        onTap: () {
                                                          print('del');
                                                          setState(() {
                                                            keywords
                                                                .remove(val);
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
                                : Center(
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(
                                          'No keywords added',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black87,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                      ],
                                    ),
                                  ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Product Images',
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            productImages.length > 0
                                ? Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      GridView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.all(0.0),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1,
                                          mainAxisSpacing: 15.0,
                                          crossAxisSpacing: 15.0,
                                        ),
                                        shrinkWrap: true,
                                        itemCount: productImages.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: <Widget>[
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.file(
                                                  productImages[index],
                                                ),
                                              ),
                                              Positioned(
                                                top: 5.0,
                                                right: 5.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    6.0,
                                                  ),
                                                  child: Material(
                                                    color: Colors.red,
                                                    child: InkWell(
                                                      splashColor: Colors.white
                                                          .withOpacity(0.4),
                                                      onTap: () {
                                                        //remove image
                                                        setState(() {
                                                          productImages
                                                              .removeAt(index);
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 28.0,
                                                        height: 28.0,
                                                        child: Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 18.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 15.0,
                                        ),
                                        Text(
                                          'No images added',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black87,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15.0,
                                        ),
                                      ],
                                    ),
                                  ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              height: 45.0,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0.0),
                              child: FlatButton(
                                onPressed: () {
                                  //add product
                                  cropImage(context);
                                },
                                color: Colors.green.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                      size: 18.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      'Add Image',
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
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Do you want to discount this product?',
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 6.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Is Discounted?',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                FlutterSwitch(
                                  width: 60.0,
                                  height: 30.0,
                                  valueFontSize: 14.0,
                                  toggleSize: 15.0,
                                  value: isDiscounted,
                                  activeColor: Theme.of(context).primaryColor,
                                  inactiveColor: Colors.black38,
                                  borderRadius: 15.0,
                                  padding: 8.0,
                                  onToggle: (val) {
                                    setState(() {
                                      isDiscounted = val;
                                      product.putIfAbsent(
                                          'isDiscounted', () => val);
                                    });
                                  },
                                ),
                              ],
                            ),
                            isDiscounted
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      TextFormField(
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        onSaved: (val) {
                                          discountPer =
                                              double.parse(val.trim());
                                        },
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.number,
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
                                          labelText: 'Discount %',
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
                            SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Additional Information (Optional)',
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
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              onSaved: (val) {
                                product.putIfAbsent(
                                    'bestBefore', () => val.trim());
                              },
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
                                labelText: 'Best before',
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
                              onSaved: (val) {
                                product.putIfAbsent('brand', () => val.trim());
                              },
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
                                labelText: 'Brand',
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
                              onSaved: (val) {
                                product.putIfAbsent(
                                    'manufactureDate', () => val.trim());
                              },
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
                                labelText: 'Manufacture date',
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
                              onSaved: (val) {
                                product.putIfAbsent(
                                    'shelfLife', () => val.trim());
                              },
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
                                labelText: 'Shelf life',
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
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   mainAxisSize: MainAxisSize.max,
                            //   children: <Widget>[
                            //     Padding(
                            //       padding: const EdgeInsets.all(8.0),
                            //       child: Text(
                            //         'In Stock',
                            //         style: GoogleFonts.poppins(
                            //           color: Colors.black87,
                            //           fontSize: 14.0,
                            //           fontWeight: FontWeight.w500,
                            //         ),
                            //       ),
                            //     ),
                            //     FlutterSwitch(
                            //       width: 60.0,
                            //       height: 30.0,
                            //       valueFontSize: 14.0,
                            //       toggleSize: 15.0,
                            //       value: false,
                            //       activeColor: Theme.of(context).primaryColor,
                            //       inactiveColor: Colors.black38,
                            //       borderRadius: 15.0,
                            //       padding: 8.0,
                            //       onToggle: (val) {
                            //         setState(() {
                            //           product.putIfAbsent('inStock', () => val);
                            //         });
                            //       },
                            //     ),
                            //   ],
                            // ),
                            // SizedBox(
                            //   height: 10.0,
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Active product',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                FlutterSwitch(
                                  width: 60.0,
                                  height: 30.0,
                                  valueFontSize: 14.0,
                                  toggleSize: 15.0,
                                  value: isListed,
                                  activeColor: Theme.of(context).primaryColor,
                                  inactiveColor: Colors.black38,
                                  borderRadius: 15.0,
                                  padding: 8.0,
                                  onToggle: (val) {
                                    setState(() {
                                      isListed = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            // SizedBox(
                            //   height: 10.0,
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   mainAxisSize: MainAxisSize.max,
                            //   children: <Widget>[
                            //     Padding(
                            //       padding: const EdgeInsets.all(8.0),
                            //       child: Text(
                            //         'Featured product',
                            //         style: GoogleFonts.poppins(
                            //           color: Colors.black87,
                            //           fontSize: 14.0,
                            //           fontWeight: FontWeight.w500,
                            //         ),
                            //       ),
                            //     ),
                            //     FlutterSwitch(
                            //       width: 60.0,
                            //       height: 30.0,
                            //       valueFontSize: 14.0,
                            //       toggleSize: 15.0,
                            //       value: false,
                            //       activeColor: Theme.of(context).primaryColor,
                            //       inactiveColor: Colors.black38,
                            //       borderRadius: 15.0,
                            //       padding: 8.0,
                            //       onToggle: (val) {
                            //         setState(() {
                            //           product.putIfAbsent(
                            //               'featured', () => val);
                            //         });
                            //       },
                            //     ),
                            //   ],
                            // ),
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
                                  //add product
                                  addProduct();
                                },
                                color: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      'Add Product',
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
