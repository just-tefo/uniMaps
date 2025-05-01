import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import '../home/profile_page.dart';
import '../home/search_page.dart';

class Homepage extends StatefulWidget {
  final Map<String, dynamic>? selectedBuilding;
  final String? roomDescription;
  final Map<String, dynamic>? selectedClass;

  const Homepage({
    super.key,
    this.selectedBuilding,
    this.roomDescription,
    this.selectedClass,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class CustomMarker {
  final String id;
  final LatLng position;
  final String title;
  final MarkerType type;
  final Map<String, dynamic>? additionalData;

  CustomMarker({
    required this.id,
    required this.position,
    required this.title,
    required this.type,
    this.additionalData,
  });

  Marker toMarker() {
    BitmapDescriptor icon;
    switch (type) {
      case MarkerType.campusBuilding:
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        break;
      case MarkerType.searchedBuilding:
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        break;
      case MarkerType.classLocation:
        icon = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
        break;
    }

    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(title: title),
      icon: icon,
    );
  }
}

enum MarkerType { campusBuilding, searchedBuilding, classLocation }

class _HomepageState extends State<Homepage> {
  List<Map<String, dynamic>> _buildings = [];
  List<Map<String, dynamic>> _filteredBuildings = [];
  List<Map<String, dynamic>> _currentBuildingRooms = [];

  final Completer<GoogleMapController> _controller = Completer();
  bool _showBuildingDetails = false;
  bool _showRoomDetails = false;
  LatLng? _currentPosition;
  bool _isLoading = true;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  Map<String, dynamic>? _currentBuildingDetails;
  Map<String, dynamic>? _currentRoomDetails;
  String? _currentRoomDescription;
  Map<String, dynamic>? _currentClassDetails;
  bool _showClassDetails = false;
  List<Map<String, dynamic>> _classes = [];

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-24.6551, 25.9089),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initializeData();

    if (widget.selectedBuilding != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleIncomingBuilding(widget.selectedBuilding!);
      });
    }

    if (widget.selectedClass != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleClassSelection(widget.selectedClass!);
      });
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      await _getUserLocation();
      await _loadBuildings();
      await _loadCampusBuildings();
    } catch (e) {
      debugPrint("Initialization error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCampusBuildings() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('venue').get();

      Set<Marker> campusMarkers = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final geoPoint = data['Location'] as GeoPoint?;
        if (geoPoint != null) {
          final marker =
              CustomMarker(
                id: 'building_${doc.id}',
                position: LatLng(geoPoint.latitude, geoPoint.longitude),
                title: data['Name'] ?? 'Building',
                type: MarkerType.campusBuilding,
                additionalData: data,
              ).toMarker();
          campusMarkers.add(marker);
        }
      }

      setState(() {
        _markers.addAll(campusMarkers);
      });
    } catch (e) {
      debugPrint("Error loading campus buildings: $e");
    }
  }

  Future<void> _loadBuildings() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('venue').get();

      debugPrint('Found ${querySnapshot.docs.length} documents');

      setState(() {
        _buildings =
            querySnapshot.docs.map((doc) {
              debugPrint('Document data: ${doc.data()}');
              final data = doc.data();
              return {
                'id': doc.id,
                'Name':
                    data['Name'] ?? 'Unnamed Venue', // Ensure proper field name
                'Location': data['Location'],
                'rooms': data['rooms'] ?? [],
              };
            }).toList();
        _filteredBuildings = List.from(_buildings);
      });
    } catch (e) {
      debugPrint("Error loading buildings: $e");
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBuildings = List.from(_buildings);
      } else {
        _filteredBuildings =
            _buildings.where((building) {
              final name = building['Name']?.toString().toLowerCase() ?? '';
              return name.contains(query);
            }).toList();
      }
    });
  }

  void _handleBuildingSelection(Map<String, dynamic> building) {
    final geoPoint = building['Location'] as GeoPoint;

    // Clear previous searched markers
    _markers.removeWhere((m) => m.markerId.value.startsWith('searched_'));

    // Add new searched marker
    final searchedMarker =
        CustomMarker(
          id: 'searched_${building['id']}',
          position: LatLng(geoPoint.latitude, geoPoint.longitude),
          title: building['Name'] ?? 'Searched Building',
          type: MarkerType.searchedBuilding,
          additionalData: building,
        ).toMarker();

    setState(() {
      _markers.add(searchedMarker);
      _currentBuildingDetails = building;
      _showBuildingDetails = true;
    });

    // Center map on selection
    _controller.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(geoPoint.latitude, geoPoint.longitude),
          17,
        ),
      );
    });
  }

  void _handleClassSelection(Map<String, dynamic> classData) {
    // Clear previous class markers
    _markers.removeWhere((m) => m.markerId.value.startsWith('class_'));

    // Get location from class data (assuming class has a building reference)
    final geoPoint = classData['building']['Location'] as GeoPoint;

    final classMarker =
        CustomMarker(
          id: 'class_${classData['id']}',
          position: LatLng(geoPoint.latitude, geoPoint.longitude),
          title: classData['name'] ?? 'Class Location',
          type: MarkerType.classLocation,
          additionalData: classData,
        ).toMarker();

    setState(() {
      _markers.add(classMarker);
      _currentClassDetails = classData;
      _showClassDetails = true;
    });

    // Center map on class
    _controller.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(geoPoint.latitude, geoPoint.longitude),
          17,
        ),
      );
    });
  }

  void _handleIncomingBuilding(Map<String, dynamic> buildingData) {
    setState(() {
      _currentBuildingDetails = buildingData;
      _currentBuildingRooms = List<Map<String, dynamic>>.from(
        buildingData['rooms'] ?? [],
      );
      _showBuildingDetails = true;
      _showRoomDetails = false;
    });
    _showBuildingOnMap();
  }

  void _showBuildingOnMap() async {
    if (_currentBuildingDetails == null ||
        _currentBuildingDetails!['Location'] == null)
      return;

    try {
      final geoPoint = _currentBuildingDetails!['Location'] as GeoPoint;
      final buildingLocation = LatLng(geoPoint.latitude, geoPoint.longitude);

      // Keep campus buildings and remove only searched/class markers
      _markers.removeWhere(
        (m) =>
            m.markerId.value.startsWith('searched_') ||
            m.markerId.value.startsWith('class_'),
      );

      // Add the new searched building marker
      _markers.add(
        CustomMarker(
          id: 'searched_${_currentBuildingDetails!['id']}',
          position: buildingLocation,
          title: _currentBuildingDetails!['Name'] ?? 'Building',
          type: MarkerType.searchedBuilding,
          additionalData: _currentBuildingDetails,
        ).toMarker(),
      );

      final controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: buildingLocation, zoom: 17),
        ),
      );
    } catch (e) {
      debugPrint("Error showing building: $e");
    }
  }

  Widget _buildBuildingDetailsCard() {
    final building = _currentBuildingDetails!;
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                building['Name'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (building['images'] != null && building['images'].isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: building['images'].length,
                    itemBuilder:
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(building['images'][i]),
                        ),
                  ),
                ),
              if (_currentBuildingRooms.isNotEmpty) ...[
                SizedBox(height: 12),
                Text('Rooms:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._currentBuildingRooms
                    .map(
                      (room) => ListTile(
                        title: Text(room['name'] ?? 'Room'),
                        subtitle:
                            room['Description'] != null
                                ? Text(room['Description'])
                                : null,
                        onTap: () {
                          setState(() {
                            _currentRoomDetails = room;
                            _showRoomDetails = true;
                          });
                        },
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassDetailsCard() {
    final classData = _currentClassDetails!;
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classData['name'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('Building: ${classData['building']['Name']}'),
              // Add other class details
            ],
          ),
        ),
      ),
    );
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
      debugPrint("Location permission denied.");
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredBuildings = List.from(_buildings);
    });
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black)],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Color(0xFF1B5E20),
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
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
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

  bool _isPositionOnMarker(LatLng position, Marker marker) {
    // Simple distance check - you might need to adjust the threshold
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      marker.position.latitude,
      marker.position.longitude,
    );
    return distance < 50; // 50 meters threshold
  }

  void _handleMarkerTap(Marker marker) {
    final markerId = marker.markerId.value;
    
    if (markerId.startsWith('building_')) {
      final buildingId = markerId.replaceFirst('building_', '');
      final building = _buildings.firstWhere((b) => b['id'] == buildingId);
      _handleBuildingSelection(building);
    }
    else if (markerId.startsWith('class_')) {
      final classId = markerId.replaceFirst('class_', '');
      final classData = _classes.firstWhere((c) => c['id'] == classId);
      _handleClassSelection(classData);
    }
    else if (markerId.startsWith('searched_')) {
      final buildingId = markerId.replaceFirst('searched_', '');
      final building = _buildings.firstWhere((b) => b['id'] == buildingId);
      _handleBuildingSelection(building);
    }
  }

  Widget _buildSearchResultsList() {
    return ListView.builder(
      itemCount: _filteredBuildings.length,
      itemBuilder: (context, index) {
        final building = _filteredBuildings[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              building['Name'] ?? 'Unnamed Venue',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:
                building['rooms'] != null && building['rooms'].isNotEmpty
                    ? Text('${building['rooms'].length} rooms available')
                    : Text('No rooms listed'),
            onTap:
                () => _handleBuildingSelection(
                  building,
                ), // Changed from _selectBuilding
          ),
        );
      },
    );
  }

  Widget _buildMapPage() {
    return Stack(
      children: [
        Column(
          children: [
            // ... your search field and other widgets ...
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
                      onTap: (LatLng position) {
                        bool tappedMarker = false;
                        for (final marker in _markers) {
                          if (_isPositionOnMarker(position, marker)) {
                            _handleMarkerTap(marker);
                            tappedMarker = true;
                            break;
                          }
                        }
                        if (!tappedMarker) {
                          setState(() {
                            _showBuildingDetails = false;
                            _showClassDetails = false;
                          });
                        }
                      },
                    ),
            ),
          ],
        ),
        if (_showBuildingDetails) _buildBuildingDetailsCard(),
        if (_showClassDetails) _buildClassDetailsCard(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "unimaps",
          style: GoogleFonts.marcellus(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: Color(0xFF1B5E20),
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 5,
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
