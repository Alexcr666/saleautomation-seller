import 'package:multivendor_seller/blocs/products_bloc/all_products_bloc.dart';
import 'package:multivendor_seller/blocs/products_bloc/products_bloc.dart';
import 'package:multivendor_seller/models/product.dart';
import 'package:multivendor_seller/widgets/low_inventory_item.dart';
import 'package:multivendor_seller/widgets/product_item.dart';
import 'package:multivendor_seller/widgets/shimmers/shimmer_low_inventory_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class AllProductsScreen extends StatefulWidget {
  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen>
    with SingleTickerProviderStateMixin {
  AllProductsBloc allProductsBloc;
  List<Product> productsList;
  List<Product> filteredList;
  String searchWord = '';
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();

    productsList = List();

    allProductsBloc = BlocProvider.of<AllProductsBloc>(context);

    allProductsBloc.add(GetAllProductsEvent());
  }

  Future<List<Product>> search() async {
    List<Product> sortList = List();

    if (searchWord.isEmpty) {
      sortList = productsList;

      return sortList;
    }
    for (var item in productsList) {
      if (item.name.toLowerCase().contains(searchWord.toLowerCase()) ||
          item.category.toLowerCase().contains(searchWord.toLowerCase()) ||
          item.subCategory.toLowerCase().contains(searchWord.toLowerCase()) ||
          item.description.toLowerCase().contains(searchWord.toLowerCase())) {
        sortList.add(item);
      }
    }
    print(sortList.length);

    return sortList;
    // setState(() {});
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
                      'All Products',
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
              bloc: allProductsBloc,
              buildWhen: (previous, current) {
                if (current is GetAllProductsCompletedState ||
                    current is GetAllProductsInProgressState ||
                    current is GetAllProductsFailedState) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetAllProductsInProgressState) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        period: Duration(milliseconds: 800),
                        baseColor: Colors.grey.withOpacity(0.5),
                        highlightColor: Colors.black.withOpacity(0.5),
                        child: ShimmerLowInventoryItem(size: size),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 15.0,
                      );
                    },
                    itemCount: 5,
                  );
                }
                if (state is GetAllProductsFailedState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/banners/retry.svg',
                        width: size.width * 0.6,
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        'Failed to load products!',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  );
                }
                if (state is GetAllProductsCompletedState) {
                  if (state.products != null) {
                    productsList = List();

                    if (state.products.length == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          SvgPicture.asset(
                            'assets/images/empty_prod.svg',
                            width: size.width * 0.6,
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            'No products found!',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                        ],
                      );
                    } else {
                      productsList = state.products;

                      if (filteredList == null) {
                        filteredList = List();
                        filteredList = productsList;
                      }

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                top: 16.0,
                                bottom: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 43.0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 0.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: TextField(
                                      controller: searchController,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.search,
                                      enableInteractiveSelection: true,
                                      onChanged: (value) {
                                        print('CHANGED');
                                        if (value.trim().length > 0) {
                                          searchWord = value.trim();

                                          search();
                                        } else {
                                          searchWord = '';
                                          search();
                                        }

                                        setState(() {});
                                      },
                                      onSubmitted: (value) {
                                        if (value.trim().length > 0) {
                                          searchWord = value.trim();

                                          search();
                                        } else {
                                          searchWord = '';
                                          search();
                                        }
                                      },
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        color: Colors.black87,
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 5.0, vertical: 8.0),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.black54,
                                          size: 20.0,
                                        ),
                                        border: InputBorder.none,
                                        hintText: 'Search',
                                        hintStyle: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          color: Colors.black54,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    searchController.text.isNotEmpty
                                        ? Icons.close
                                        : Icons.search,
                                  ),
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();

                                    if (searchController.text.isNotEmpty) {
                                      searchController.text = '';
                                      searchWord = '';
                                      search();
                                    }

                                    // if (searchController.text.trim().length >
                                    //     0) {
                                    //   searchWord = searchController.text.trim();

                                    //   search();
                                    // } else {
                                    //   searchWord = '';
                                    //   search();
                                    // }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: FutureBuilder(
                              future: search(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Product>> snapshot) {
                                if (snapshot.data == null) {
                                  return ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                    itemBuilder: (context, index) {
                                      return Shimmer.fromColors(
                                        period: Duration(milliseconds: 800),
                                        baseColor: Colors.grey.withOpacity(0.5),
                                        highlightColor:
                                            Colors.black.withOpacity(0.5),
                                        child:
                                            ShimmerLowInventoryItem(size: size),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return SizedBox(
                                        height: 15.0,
                                      );
                                    },
                                    itemCount: 5,
                                  );
                                }

                                print('HERE');
                                print(snapshot.data.length);

                                filteredList = snapshot.data;

                                if (filteredList.isEmpty) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      SvgPicture.asset(
                                        'assets/images/empty_prod.svg',
                                        width: size.width * 0.6,
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      Text(
                                        'No products found!',
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.clip,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                    ],
                                  );
                                }

                                return ListView.separated(
                                  padding: const EdgeInsets.only(
                                      bottom: 16.0, top: 0.0),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return ProductItem(
                                      size: size,
                                      product: filteredList[index],
                                      allProductsBloc: allProductsBloc,
                                      productType: 'ALL_PRODUCTS',
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(
                                      height: 16.0,
                                    );
                                  },
                                  itemCount: filteredList.length,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  }
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
