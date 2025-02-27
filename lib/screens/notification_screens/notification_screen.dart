import 'package:multivendor_seller/models/seller_notification.dart';
import 'package:multivendor_seller/screens/orders_screens/manage_new_order_screen.dart';
import 'package:multivendor_seller/widgets/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/seller_notification.dart' as prefix;

class NotificationScreen extends StatelessWidget {
  final SellerNotification sellerNotification;

  NotificationScreen(this.sellerNotification);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<prefix.Notification> notificationList =
        sellerNotification.notifications.reversed.toList();

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
                      'Notifications',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    //  switch ( notificationList[index].notificationType.toString()) {
                    //    case 'ORDER_NOTIFICATION':
                    //     await
                    //   Navigator.push(context, MaterialPageRoute(builder: (context) => ManageNewOrderScreen(order: ,),));
                    //      break;
                    //    default:
                    //  }
                  },
                  child: NotificationItem(
                    size: size,
                    sellerNotification: sellerNotification,
                    notificationList: notificationList,
                    index: index,
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 15.0,
                );
              },
              itemCount: notificationList.length,
            ),
          ),
        ],
      ),
    );
  }
}
