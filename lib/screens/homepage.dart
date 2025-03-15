import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'search_page.dart'; // Import Search Page
import 'profile_page.dart'; // Import Profile Page
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart'; // Import Salomon Bottom Bar

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  mp.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  final user = FirebaseAuth.instance.currentUser!;
  int _currentIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    Container(), // Placeholder for the Map
    SearchPage(), // Search Page
    ProfilePage(), // Profile Page
  ];

  @override
  void initState() {
    super.initState();
    _setUpPositionTracking();
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    super.dispose();
  }

  // Sign user out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))],
      ),
      body: _currentIndex == 0
          ? mp.MapWidget(
              onMapCreated: _onMapCreated,
              styleUri: mp.MapboxStyles.MAPBOX_STREETS,
            )
          : _pages[_currentIndex], // Show selected page (Search or Profile)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() {
              _currentIndex = index;
            }),
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            items: [
              SalomonBottomBarItem(
                icon: Icon(Icons.home),
                title: Text("Home"),
                selectedColor: Colors.blueAccent,
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.search),
                title: Text("Search"),
                selectedColor: Colors.green,
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.person),
                title: Text("Profile"),
                selectedColor: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMapCreated(mp.MapboxMap controller) {
    setState(() {
      mapboxMapController = controller;
    });

    mapboxMapController?.location.updateSettings(
      mp.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
  }

  Future<void> _setUpPositionTracking() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      return Future.error(
        "Location permissions are permanently denied, we cannot request permission",
      );
    }

    gl.LocationSettings locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 100,
    );

    userPositionStream?.cancel();
    userPositionStream = gl.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((gl.Position? position) {
      if (position != null && mapboxMapController != null) {
        mapboxMapController?.setCamera(
          mp.CameraOptions(
            zoom: 15,
            center: mp.Point(
              coordinates: mp.Position(position.longitude, position.latitude),
            ),
          ),
        );
      }
    });
  }
}
