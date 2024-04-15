import 'package:multivendor_seller/blocs/manage_users_bloc/block_user_bloc.dart';
import 'package:multivendor_seller/blocs/manage_users_bloc/inactive_users_bloc.dart';
import 'package:multivendor_seller/blocs/manage_users_bloc/manage_users_bloc.dart';
import 'package:multivendor_seller/models/user.dart';
import 'package:multivendor_seller/widgets/common_user_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class InactiveUsersScreen extends StatefulWidget {
  @override
  _InactiveUsersScreenState createState() => _InactiveUsersScreenState();
}

class _InactiveUsersScreenState extends State<InactiveUsersScreen>
    with SingleTickerProviderStateMixin {
  List<GroceryUser> inactiveUsers;
  InactiveUsersBloc inactiveUsersBloc;
  BlockUserBloc blockUserBloc;

  @override
  void initState() {
    super.initState();

    inactiveUsersBloc = BlocProvider.of<InactiveUsersBloc>(context);
    blockUserBloc = BlocProvider.of<BlockUserBloc>(context);

    blockUserBloc.listen((state) {
      if (state is BlockUserCompletedState ||
          state is UnblockUserCompletedState) {
        //refresh
        inactiveUsersBloc.add(GetInactiveUsersManageUsersEvent());
      }
    });
    inactiveUsers = List();

    inactiveUsersBloc.add(GetInactiveUsersManageUsersEvent());
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
                      'Inactive Users',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 19.0,
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
              bloc: inactiveUsersBloc,
              buildWhen: (previous, current) {
                if (current is GetInactiveUsersCompletedState ||
                    current is GetInactiveUsersInProgressState ||
                    current is GetInactiveUsersFailedState) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetInactiveUsersInProgressState) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );

                  //TODO: ADD SHIMMER
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    itemBuilder: (context, index) {
                      // return Shimmer.fromColors(
                      //   period: Duration(milliseconds: 800),
                      //   baseColor: Colors.grey.withOpacity(0.5),
                      //   highlightColor: Colors.black.withOpacity(0.5),
                      //   child: ShimmerUserItem(size: size),
                      // );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 15.0,
                      );
                    },
                    itemCount: 5,
                  );
                }
                if (state is GetInactiveUsersFailedState) {
                  return Center(
                    child: Text(
                      'Failed to load users!',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                }
                if (state is GetInactiveUsersCompletedState) {
                  if (state.inactiveUsers != null) {
                    inactiveUsers = List();

                    if (state.inactiveUsers.length == 0) {
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
                            'No users found!',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 14.5,
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
                      inactiveUsers = state.inactiveUsers;

                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                        itemBuilder: (context, index) {
                          return CommonUserItem(
                            size: size,
                            user: inactiveUsers[index],
                            blockUserBloc: blockUserBloc,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 16.0,
                          );
                        },
                        itemCount: inactiveUsers.length,
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
