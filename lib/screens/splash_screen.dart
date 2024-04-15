import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multivendor_seller/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multivendor_seller/config/config.dart';
import 'package:multivendor_seller/config/paths.dart';
import 'package:multivendor_seller/models/seller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'sign_in_sign_up_screens/sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SignInBloc signInBloc;
  Map<dynamic, Widget> mapping = {
    1: SignInScreen(),
    2: HomeScreen(),
  };

  //TODO: check if initial setup is done for the first time and save it in shared prefs

  @override
  void initState() {
    super.initState();

    signInBloc = BlocProvider.of<SignInBloc>(context);

    signInBloc.listen((state) {
      if (state is CheckIfSignedInEventCompletedState) {
        //proceed to home
        if (state.isSignedIn) {
          print('logged in');
          checkIfInitialSetupIsCompleteSignedIn();
        } else {
          //not signed in
          print('not logged in');
          Navigator.popAndPushNamed(context, '/sign_in');
        }
      }

      if (state is CheckIfSignedInEventFailedState) {
        //proceed to sign in
        print('failed to check if logged in');
        Navigator.popAndPushNamed(context, '/sign_in');
      }
    });

    signInBloc.add(CheckIfSignedInEvent());
  }

  checkIfInitialSetupIsCompleteSignedIn() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(Paths.sellersPath)
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();

    if (snapshot.exists) {
      Seller seller = Seller.fromFirestore(snapshot);
      print(seller.approvalStatus);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            seller: seller,
          ),
        ),
      );
    } else {
      FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(),
        ),
      );
    }

    // switch (seller.approvalStatus) {
    //   case 'In verification':
    //     Navigator.popAndPushNamed(
    //       context,
    //       '/home',
    //       arguments: {
    //         seller.approvalStatus,
    //       },
    //     );
    //     // showNotVerifiedPopup(seller);
    //     break;
    //   case 'Rejected':
    //     Navigator.popAndPushNamed(
    //       context,
    //       '/home',
    //       arguments: {},
    //     );
    //     // showNotVerifiedPopup(seller);
    //     break;
    //   case 'Verified':
    //     Navigator.popAndPushNamed(
    //       context,
    //       '/home',
    //       arguments: {},
    //     );
    //     break;
    //   default:
    // }
    // Navigator.popAndPushNamed(
    //   context,
    //   '/home',
    //   arguments: {},
    // );

    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // bool isSetupCompleted = sharedPreferences.getBool('initialSetupCompleted');

    // if (isSetupCompleted == null) {
    //   //not done
    //   Navigator.popAndPushNamed(context, '/initial_setup');
    // } else {
    //   if (isSetupCompleted) {
    //     //done
    //     Navigator.popAndPushNamed(context, '/home');
    //   } else {
    //     //not done
    //     Navigator.popAndPushNamed(context, '/initial_setup');
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    // Timer(Duration(milliseconds: 0), () {
    //   Navigator.popAndPushNamed(context, '/sign_in');
    // });
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/shop.svg',
              width: size.width * 0.25,
              height: size.width * 0.25,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              '${Config().appName}',
              style: GoogleFonts.poppins(
                color: Colors.black.withOpacity(0.85),
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
