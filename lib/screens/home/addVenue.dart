import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddVenueScreen extends StatefulWidget {
  @override
  _AddVenueScreenState createState() => _AddVenueScreenState();
}

class _AddVenueScreenState extends State<AddVenueScreen> {
  final TextEditingController descriptionController = TextEditingController();
  LatLng? selectedLocation;
  String? selectedVenue;
  List<String> venueNames = [];
  List<File> selectedImages = [];

  @override
  void initState() {
    super.initState();
    _fetchVenueNames();
  }

  Future<void> _fetchVenueNames() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('venue').get();
    setState(() {
      venueNames = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      selectedLocation = position;
    });
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (File image in selectedImages) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('venue_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  void _saveVenue() async {
    if (selectedVenue == null || descriptionController.text.isEmpty || selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields and select a location.")),
      );
      return;
    }

    List<String> imageUrls = await _uploadImages();

    await FirebaseFirestore.instance.collection('venue').add({
      'name': selectedVenue,
      'description': descriptionController.text,
      'location': GeoPoint(selectedLocation!.latitude, selectedLocation!.longitude),
      'images': imageUrls,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Venue added successfully!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Venue")),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(-24.6282, 25.9231),
                    zoom: 15,
                  ),
                  onTap: _onMapTapped,
                  markers: selectedLocation != null
                      ? {
                          Marker(
                            markerId: MarkerId("selectedLocation"),
                            position: selectedLocation!,
                          ),
                        }
                      : {},
                ),
                if (selectedLocation != null)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Card(
                      color: Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Selected Location: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}"),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedVenue,
                  hint: Text("Select Venue Name"),
                  items: venueNames.map((venue) {
                    return DropdownMenuItem(value: venue, child: Text(venue));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedVenue = value),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: Text("Pick Images"),
                ),
                if (selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.file(selectedImages[index], width: 80, height: 80, fit: BoxFit.cover),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveVenue,
                  child: Text("Save Venue"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}