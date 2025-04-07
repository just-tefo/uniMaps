import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:uuid/uuid.dart';
import '../home/profile_page.dart';
import '../home/search_page.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  bool _isLoading = true;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  var uuid = const Uuid();
  List<dynamic> listOfLocations = [];
  String token = '1234567890';

  Set<Marker> _markers = {}; // Set to hold the markers

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-24.6551, 25.9089),
    zoom: 14,
  );

  @override
  void initState() {
    _searchController.addListener(() {
      _onChange();
    });
    super.initState();
    _getUserLocation();
  }

  _onChange() {
    placeSuggestion(_searchController.text);
  }

  void placeSuggestion(String input) async {
    const String googleApiKey = "AIzaSyAtWZFFViuTXnZHGJepI-WcEN1s7ogheF4";
    try {
      String passedUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request =
          '$passedUrl?input=$input&key=$googleApiKey&sessiontoken=$token&components=country:BW';

      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          listOfLocations = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception("Failed to load");
      }
    } catch (e) {
      (e.toString());
    }
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
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition!, zoom: 16),
          ),
        );
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
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      listOfLocations = [];
    });
  }

  void _addMarker(LatLng location, String markerId) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: location,
          infoWindow: InfoWindow(title: "Selected Location"),
        ),
      );
    });
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
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildMapPage();
      case 1:
        return SearchPage();
      case 2:
        return ProfilePage();
      default:
        return _buildMapPage();
    }
  }

  Widget _buildMapPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search here...',
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              prefixIcon: Icon(Icons.search, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        Visibility(
          visible: _searchController.text.isNotEmpty,
          child: Expanded(
            child: ListView.builder(
              itemCount: listOfLocations.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    String placeId = listOfLocations[index]['place_id'];
                    String googleApiKey = "AIzaSyAtWZFFViuTXnZHGJepI-WcEN1s7ogheF4";
                    String detailsUrl =
                        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey";

                    var response = await http.get(Uri.parse(detailsUrl));
                    var data = json.decode(response.body);

                    if (response.statusCode == 200) {
                      var location = data['result']['geometry']['location'];
                      double lat = location['lat'];
                      double lng = location['lng'];

                      _addMarker(LatLng(lat, lng), uuid.v4());
                      _clearSearch();

                      final GoogleMapController controller = await _controller.future;
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(lat, lng),
                            zoom: 16,
                          ),
                        ),
                      );
                    } else {
                      throw Exception("Failed to fetch location details");
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        listOfLocations[index]["description"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      trailing: Icon(
                        Icons.location_on,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                );
              },
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
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
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