import 'dart:async';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/config/paths.dart';
import 'package:multivendor_seller/models/seller.dart';
import 'package:multivendor_seller/pages/faq_page.dart';

import 'package:multivendor_seller/pages/payout_page.dart';
import 'package:multivendor_seller/pages/zipcode_restriction_page.dart';
import 'package:multivendor_seller/screens/inventory_screens/low_inventory_screen.dart';
import 'package:multivendor_seller/widgets/dialogs/not_verified_dialog.dart';
import 'package:open_appstore/open_appstore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multivendor_seller/blocs/notification_bloc/notification_bloc.dart';
import 'package:multivendor_seller/blocs/orders_bloc/new_orders_bloc.dart';
import 'package:multivendor_seller/blocs/orders_bloc/orders_bloc.dart';
import 'package:multivendor_seller/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:multivendor_seller/models/seller_notification.dart';
import 'package:multivendor_seller/pages/dashboard_page.dart';
import 'package:multivendor_seller/pages/inventory_page.dart';
import 'package:multivendor_seller/pages/manage_delivery_users_page.dart';
import 'package:multivendor_seller/pages/messages_page.dart';
import 'package:multivendor_seller/pages/my_account_page.dart';
import 'package:multivendor_seller/pages/orders_page.dart';
import 'package:multivendor_seller/pages/products_page.dart';
import 'package:multivendor_seller/pages/user_reports_page.dart';
import 'package:multivendor_seller/services/firebase_service.dart';
import 'package:multivendor_seller/widgets/dialogs/delete_confirm_dialog.dart';
import 'package:multivendor_seller/widgets/dialogs/processing_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'notification_screens/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final Seller seller;

  const HomeScreen({Key key, this.seller}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController = PageController(initialPage: 0);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedPage;
  String _title;
  bool signingOut;
  OrdersBloc ordersBloc;
  NewOrdersBloc newOrdersBloc;
  SignInBloc signinBloc;
  NotificationBloc notificationBloc;
  SellerNotification sellerNotification;
  User currentUser;
  bool first;

  Seller seller;

  @override
  void initState() {
    super.initState();

    first = true;
    ordersBloc = BlocProvider.of<OrdersBloc>(context);
    newOrdersBloc = BlocProvider.of<NewOrdersBloc>(context);
    signinBloc = BlocProvider.of<SignInBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);

    notificationBloc.add(GetAllNotificationsEvent());
    // signinBloc.add(GetCurrentUserEvent());

    signingOut = false;
    seller = widget.seller;

    signinBloc.listen((state) {
      print('SIGN IN BLOC :: $state');
      if (state is SignoutInProgressState) {
        //in progress
        if (signingOut) {
          showUpdatingDialog('Signing out..\nPlease wait!');
        }
      }
      if (state is SignoutFailedState) {
        //FAILED
        if (signingOut) {
          Navigator.pop(context);
          setState(() {
            signingOut = false;
            showSnack('Failed to sign out!', context);
          });
        }
      }
      if (state is SignoutCompletedState) {
        //completed
        if (signingOut) {
          Navigator.pop(context);
          signingOut = false;
          Navigator.popAndPushNamed(context, '/sign_in');
        }
      }
    });
    _selectedPage = 0;
    _title = 'Dashboard';

    if (first) {
      currentUser = FirebaseAuth.instance.currentUser;

      first = false;

      print('INITIALIZING SERVICE ______________');

      FirebaseService.init(context, currentUser.uid, currentUser);
    }

    checkIfVerified();
  }

  checkIfVerified() async {
    Timer(Duration(milliseconds: 100), () async {
      print('Checking approval...');
      showUpdatingDialog('Processing..\nPlease wait');

      if (seller == null) {
        print('again');
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection(Paths.sellersPath)
            .doc(FirebaseAuth.instance.currentUser.uid)
            .get();

        seller = Seller.fromFirestore(snapshot);
      }
      print(seller.approvalStatus);
      switch (seller.approvalStatus) {
        case 'In verification':
          Navigator.pop(context);
          showNotVerifiedPopup(seller);
          break;
        case 'Rejected':
          Navigator.pop(context);
          showNotVerifiedPopup(seller);
          break;
        case 'Verified':
          Navigator.pop(context);
          break;
        default:
      }
    });
  }

  showNotVerifiedPopup(Seller seller) async {
    bool res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return NotVerifiedDialog(
          seller: seller,
        );
      },
    );

    if (res != null) {
      if (res) {
        //check again
        this.seller = null;
        checkIfVerified();
      }
    }
  }

  temp() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Sellers').get();

    for (var item in querySnapshot.docs) {
      await FirebaseFirestore.instance.collection('Payouts').doc(item.id).set({
        'availablePayout': 0,
        'payouts': {},
        'previousPayout': 0,
        'uid': item.id,
      });
    }
  }

  @override
  void dispose() {
    notificationBloc.close();
    super.dispose();
  }

  showConfirmationPopup() async {
    bool res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return DeleteConfirmDialog(
          message: 'Do you want to sign out?',
        );
      },
    );

    if (res == true) {
      //move ahead
      signinBloc.add(SignoutEvent());
      signingOut = true;
    }
  }

  showUpdatingDialog(String message) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: '$message',
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
          fontSize: 13.5,
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
    return WillPopScope(
      onWillPop: () async {
        ordersBloc.close();
        newOrdersBloc.close();
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              // DrawerHeader(
              //   decoration: BoxDecoration(
              //     color: Colors.amber,
              //   ),
              //   child: Container(),
              // ),
              ListTile(
                dense: true,
                onTap: () {
                  setState(() {
                    _selectedPage = 0;
                    Navigator.pop(context);
                    _pageController.jumpToPage(0);
                    _title = 'Dashboard';
                  });
                },
                leading: FaIcon(
                  FontAwesomeIcons.home,
                  size: 20.0,
                  color: _selectedPage == 0
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                title: Text(
                  'Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _selectedPage == 0
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _selectedPage = 1;
                    Navigator.pop(context);
                    _pageController.jumpToPage(1);
                    _title = 'Orders';
                  });
                },
                leading: FaIcon(
                  FontAwesomeIcons.shoppingBasket,
                  size: 20.0,
                  color: _selectedPage == 1
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                title: Text(
                  'Orders',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _selectedPage == 1
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _selectedPage = 2;
                    Navigator.pop(context);
                    _pageController.jumpToPage(2);
                    _title = 'Low Inventory';
                  });
                },
                leading: FaIcon(
                  FontAwesomeIcons.warehouse,
                  size: 18.0,
                  color: _selectedPage == 2
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                title: Text(
                  'Low Inventory',
                  style: GoogleFonts.poppins(
                    color: _selectedPage == 2
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _selectedPage = 3;
                    Navigator.pop(context);
                    _pageController.jumpToPage(3);
                    _title = 'Products';
                  });
                },
                leading: FaIcon(
                  FontAwesomeIcons.boxes,
                  size: 19.0,
                  color: _selectedPage == 3
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                title: Text(
                  'Products',
                  style: GoogleFonts.poppins(
                    color: _selectedPage == 3
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _selectedPage = 4;
                    Navigator.pop(context);
                    _pageController.jumpToPage(4);
                    _title = 'Messages';
                  });
                },
                leading: Icon(
                  Icons.mail,
                  size: 24.0,
                  color: _selectedPage == 4
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                title: Text(
                  'Messages',
                  style: GoogleFonts.poppins(
                    color: _selectedPage == 4
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _selectedPage = 5;
                    Navigator.pop(context);
                    _pageController.jumpToPage(5);
                    _title = 'Manage Delivery Users';
                  });
                },
                leading: FaIcon(
                  FontAwesomeIcons.biking,
                  size: 19.0,
                  color: _selectedPage == 5
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                title: Text(
                  'Manage Delivery Users',
                  style: GoogleFonts.poppins(
                    color: _selectedPage == 5
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // ListTile(
              //   onTap: () {
              //     setState(() {
              //       _selectedPage = 6;
              //       Navigator.pop(context);
              //       _pageController.jumpToPage(6);
              //       _title = 'Manage Users';
              //     });
              //   },
              //   leading: Icon(
              //     Icons.people,
              //     size: 25.0,
              //     color: _selectedPage == 6
              //         ? Theme.of(context).primaryColor
              //         : Colors.black87,
              //   ),
              //   title: Text(
              //     'Manage Users',
              //     style: GoogleFonts.poppins(
              //       color: _selectedPage == 6
              //           ? Theme.of(context).primaryColor
              //           : Colors.black87,
              //       fontSize: 13.5,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
              // ListTile(
              //   onTap: () {
              //     setState(() {
              //       _selectedPage = 7;
              //       Navigator.pop(context);
              //       _pageController.jumpToPage(7);
              //       _title = 'Manage Banners';
              //     });
              //   },
              //   leading: Icon(
              //     Icons.branding_watermark,
              //     size: 23.0,
              //     color: _selectedPage == 7
              //         ? Theme.of(context).primaryColor
              //         : Colors.black87,
              //   ),
              //   title: Text(
              //     'Manage Banners',
              //     style: GoogleFonts.poppins(
              //       color: _selectedPage == 7
              //           ? Theme.of(context).primaryColor
              //           : Colors.black87,
              //       fontSize: 13.5,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
              // ListTile(
              //   onTap: () {
              //     setState(() {
              //       _selectedPage = 8;
              //       Navigator.pop(context);
              //       _pageController.jumpToPage(8);
              //       _title = 'Manage Cart';
              //     });
              //   },
              //   leading: Icon(
              //     Icons.shopping_cart,
              //     size: 23.0,
              //     color: _selectedPage == 8
              //         ? Theme.of(context).primaryColor
              //         : Colors.black87,
              //   ),
              //   title: Text(
              //     'Manage Cart',
              //     style: GoogleFonts.poppins(
              //       color: _selectedPage == 8
              //           ? Theme.of(context).primaryColor
              //           : Colors.black87,
              //       fontSize: 13.5,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
              // ListTile(
              //   onTap: () {
              //     setState(() {
              //       _selectedPage = 9;
              //       Navigator.pop(context);
              //       _pageController.jumpToPage(9);
              //       _title = 'Payment Method Settings';
              //     });
              //   },
              //   leading: Icon(
              //     Icons.attach_money_sharp,
              //     size: 23.0,
              //     color: _selectedPage == 9
              //         ? Theme.of(context).primaryColor
              //         : Colors.black87,
              //   ),
              //   title: Text(
              //     'Payment Method Settings',
              //     style: GoogleFonts.poppins(
              //       color: _selectedPage == 9
              //           ? Theme.of(context).primaryColor
              //           : Colors.black87,
              //       fontSize: 13.5,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
              ListTile(
                onTap: () {
                  setState(() {
                    _selectedPage = 6;
                    Navigator.pop(context);
                    _pageController.jumpToPage(6);
                    _title = 'My Account';
                  });
                },
                leading: Icon(
                  Icons.person,
                  size: 25.0,
                  color: _selectedPage == 6
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                title: Text(
                  'My Account',
                  style: GoogleFonts.poppins(
                    color: _selectedPage == 6
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _selectedPage = 7;
                    Navigator.pop(context);
                    _pageController.jumpToPage(7);
                    _title = 'User Reports';
                  });
                },
                leading: Icon(
                  Icons.report,
                  size: 25.0,
                  color: _selectedPage == 7
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                title: Text(
                  'User Reports',
                  style: GoogleFonts.poppins(
                    color: _selectedPage == 7
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _selectedPage = 8;
                    Navigator.pop(context);
                    _pageController.jumpToPage(8);
                    _title = 'Payout';
                  });
                },
                leading: Icon(
                  Icons.monetization_on,
                  size: 25.0,
                  color: _selectedPage == 8
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                title: Text(
                  'Payout',
                  style: GoogleFonts.poppins(
                    color: _selectedPage == 8
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _selectedPage = 9;
                    Navigator.pop(context);
                    _pageController.jumpToPage(9);
                    _title = 'Zipcode Restriction';
                  });
                },
                leading: Icon(
                  Icons.location_city,
                  size: 23.0,
                  color: _selectedPage == 9
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                title: Text(
                  'Zipcode Restriction',
                  style: GoogleFonts.poppins(
                    color: _selectedPage == 9
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    _selectedPage = 10;
                    Navigator.pop(context);
                    _pageController.jumpToPage(10);
                    _title = 'FAQ';
                  });
                },
                leading: Icon(
                  Icons.help_outlined,
                  size: 25.0,
                  color: _selectedPage == 10
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                title: Text(
                  'FAQ',
                  style: GoogleFonts.poppins(
                    color: _selectedPage == 10
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // ListTile(
              //   onTap: () {
              //     setState(() {
              //       _selectedPage = 8;
              //       Navigator.pop(context);
              //       _pageController.jumpToPage(8);
              //       _title = 'Push Notifications';
              //     });
              //   },
              //   leading: Icon(
              //     Icons.notifications,
              //     size: 25.0,
              //     color: _selectedPage == 8
              //         ? Theme.of(context).primaryColor
              //         : Colors.black87,
              //   ),
              //   title: Text(
              //     'Push Notifications',
              //     style: GoogleFonts.poppins(
              //       color: _selectedPage == 8
              //           ? Theme.of(context).primaryColor
              //           : Colors.black87,
              //       fontSize: 13.5,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
              // ListTile(
              //   onTap: () {
              //     setState(() {
              //       _selectedPage = 9;
              //       Navigator.pop(context);
              //       _pageController.jumpToPage(9);
              //       _title = 'Manage Coupons';
              //     });
              //   },
              //   leading: Icon(
              //     FontAwesomeIcons.ticketAlt,
              //     size: 22.0,
              //     color: _selectedPage == 9
              //         ? Theme.of(context).primaryColor
              //         : Colors.black87,
              //   ),
              //   title: Text(
              //     'Manage Coupons',
              //     style: GoogleFonts.poppins(
              //       color: _selectedPage == 9
              //           ? Theme.of(context).primaryColor
              //           : Colors.black87,
              //       fontSize: 13.5,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.white.withOpacity(0.5),
                                  onTap: () {
                                    print('Drawer');
                                    _scaffoldKey.currentState.openDrawer();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    width: 38.0,
                                    height: 38.0,
                                    child: Icon(
                                      Icons.dehaze,
                                      color: Colors.white,
                                      size: 26.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Text(
                                '$_title',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _selectedPage == 6
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.white.withOpacity(0.5),
                                  onTap: () {
                                    //sign out
                                    showConfirmationPopup();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    width: 38.0,
                                    height: 35.0,
                                    child: Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.signOutAlt,
                                        color: Colors.white,
                                        size: 22.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : BlocBuilder(
                              bloc: notificationBloc,
                              buildWhen: (previous, current) {
                                if (current
                                        is GetAllNotificationsInProgressState ||
                                    current is GetAllNotificationsFailedState ||
                                    current
                                        is GetAllNotificationsCompletedState ||
                                    current is GetNotificationsUpdateState) {
                                  return true;
                                }
                                return false;
                              },
                              builder: (context, state) {
                                if (state
                                    is GetAllNotificationsInProgressState) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(50.0),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        splashColor:
                                            Colors.white.withOpacity(0.5),
                                        onTap: () {
                                          print('Notification');
                                          showSnack('No notifications found!',
                                              context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          width: 38.0,
                                          height: 35.0,
                                          child: Icon(
                                            Icons.notifications,
                                            color: Colors.white,
                                            size: 26.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                if (state is GetNotificationsUpdateState) {
                                  if (state.sellerNotification != null) {
                                    if (state.sellerNotification.notifications
                                            .length ==
                                        0) {
                                      return ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            splashColor:
                                                Colors.white.withOpacity(0.5),
                                            onTap: () {
                                              print('Notification');
                                              //show snackbar with no notifications
                                              showSnack(
                                                  'No notifications found!',
                                                  context);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                              ),
                                              width: 38.0,
                                              height: 35.0,
                                              child: Icon(
                                                Icons.notifications,
                                                color: Colors.white,
                                                size: 26.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    sellerNotification =
                                        state.sellerNotification;
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Positioned(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                splashColor: Colors.white
                                                    .withOpacity(0.5),
                                                onTap: () {
                                                  // temp();
                                                  // uploadImg();
                                                  print('Notification');
                                                  if (sellerNotification
                                                      .unread) {
                                                    notificationBloc.add(
                                                      NotificationMarkReadEvent(),
                                                    );
                                                  }
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          NotificationScreen(
                                                        sellerNotification,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                  ),
                                                  width: 38.0,
                                                  height: 35.0,
                                                  child: Icon(
                                                    Icons.notifications,
                                                    color: Colors.white,
                                                    size: 26.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        sellerNotification.unread
                                            ? Positioned(
                                                right: 4.0,
                                                top: 4.0,
                                                child: Container(
                                                  height: 7.5,
                                                  width: 7.5,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    );
                                  }
                                  return SizedBox();
                                }
                                return SizedBox();
                              },
                            )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  DashboardPage(),
                  OrdersPage(),
                  // InventoryPage(),
                  LowInventoryScreen(),
                  ProductsPage(),
                  MessagesPage(),
                  ManageDeliveryUsersPage(),
                  // ManageUsersPage(),
                  // ManageBannersPage(),
                  // ManageCartPage(),
                  // PaymentMethodSettingsPage(),
                  MyAccountPage(),
                  UserReportsPage(),
                  PayoutPage(),
                  ZipcodeRestrictionPage(),
                  FaqPage(),
                  // PushNotificationsPage(),
                  // ManageCouponsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
