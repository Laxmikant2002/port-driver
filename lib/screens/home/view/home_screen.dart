// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   LatLng? currentPosition;
//   final Completer<GoogleMapController> _controller = Completer();
//   Set<Marker> markers = {};

//   @override
//   void initState() {
//     getCurrentLocation();
//     super.initState();
//   }

//   void getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       return Future.error('Location services are disabled.');
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }


//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//         'Location permissions are permanently denied, we cannot request permissions.',
//       );
//     }

//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       currentPosition = LatLng(position.latitude, position.longitude);
//       markers.add(
//         Marker(
//           markerId: const MarkerId('1'),
//           position: currentPosition!,
//           infoWindow: const InfoWindow(title: 'Your Location'),
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//       child: currentPosition != null
//           ? GoogleMap(
//               mapType: MapType.normal,
//               markers: markers,
//               initialCameraPosition:
//                   CameraPosition(target: currentPosition!, zoom: 15),
//               onMapCreated: (GoogleMapController controller) {
//                 _controller.complete(controller);
//               },
//             )
//           : SizedBox.shrink(),
//     );
//   }
// }

// ignore_for_file: lines_longer_than_80_chars
import 'package:flutter/material.dart';
import 'package:driver/screens/account_screen/views/account_screen.dart';
import 'package:driver/screens/rides/view/ride_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 1;

  final List<Widget> pages = [
    const RideScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}
