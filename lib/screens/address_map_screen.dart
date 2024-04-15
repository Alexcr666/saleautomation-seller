import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:multivendor_seller/models/user.dart';

class AddressMapScreen extends StatefulWidget {
  final Address address;
  final GroceryUser user;

  const AddressMapScreen({Key key, this.address, this.user}) : super(key: key);

  @override
  _AddressMapScreenState createState() => _AddressMapScreenState();
}

class _AddressMapScreenState extends State<AddressMapScreen> {
  GoogleMapController googleMapController;
  CameraPosition initialCameraPosition;
  Marker marker;
  Circle circle;

  @override
  void initState() {
    super.initState();

    initialCameraPosition = CameraPosition(
      target: LatLng(
          widget.address.location.latitude, widget.address.location.longitude),
      zoom: 17,
    );

    getCurrentLocation();
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();

      updateMarkerAndCircle(imageData);
    } catch (e) {
      print(e);
    }
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load(
      'assets/icons/location.png',
    );
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(Uint8List imageData) {
    LatLng latLng = LatLng(
        widget.address.location.latitude, widget.address.location.longitude);

    this.setState(() {
      marker = Marker(
        markerId: MarkerId('value'),
        position: latLng,
        flat: true,
        icon: BitmapDescriptor.fromBytes(imageData),
        zIndex: 2,
        anchor: Offset(0.5, 0.8),
        draggable: false,
      );

      circle = Circle(
        circleId: CircleId('value'),
        center: latLng,
        radius: 10,
        strokeWidth: 1,
        strokeColor: Colors.blue,
        zIndex: 1,
        fillColor: Colors.blue.withAlpha(70),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
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
                          'Location',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    setState(() {
                      googleMapController = controller;
                    });
                  },
                  initialCameraPosition: initialCameraPosition,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                  markers: Set.of((marker != null) ? [marker] : []),
                  circles: Set.of((circle != null) ? [circle] : []),
                ),
                Positioned(
                  bottom: 10.0,
                  width: size.width,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 3,
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.address.fullAddress,
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Material(
                            color: Theme.of(context).accentColor,
                            child: InkWell(
                              splashColor: Colors.white.withOpacity(0.5),
                              onTap: () {
                                googleMapController.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                          widget.address.location.latitude,
                                          widget.address.location.longitude),
                                      zoom: 17,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(),
                                width: 40.0,
                                height: 40.0,
                                child: Icon(
                                  Icons.location_on,
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
