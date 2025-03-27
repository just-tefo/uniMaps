import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import '../home/profile_page.dart';
import '../home/search_page.dart';

const String googleApiKey = "YOUR_GOOGLE_MAPS_API_KEY"; // Replace with your key

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-24.6551, 25.9089),
    zoom: 14,
  );

  LatLng? _currentPosition;
  bool _isLoading = true;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      if (_controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition!, zoom: 16),
        ));
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print("Location permission denied.");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unimaps"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 5,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Search for a venue...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition: _initialPosition,
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          if (!_controller.isCompleted) {
                            _controller.complete(controller);
                          }
                        },
                      ),
              ),
            ],
          ),
          SearchPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Colors.blueAccent,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.grey[100]!,
            color: Colors.black,
            tabs: const [
              GButton(icon: LineIcons.map, text: 'Map'),
              GButton(icon: LineIcons.search, text: 'Search'),
              GButton(icon: LineIcons.user, text: 'Profile'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
