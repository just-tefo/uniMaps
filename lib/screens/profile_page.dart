import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase authentication

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController detailsController = TextEditingController();
  String? selectedVenue;
  List<String> venueNames = ["Building A", "Building B", "Library", "Hall 1"]; // Example venues

  // Example Class Data
  final List<Map<String, String>> myClasses = [
    {"code": "CS101", "time": "10:00 AM - 12:00 PM", "building": "Building A"},
    {"code": "CS202", "time": "2:00 PM - 4:00 PM", "building": "Building B"},
    {"code": "CS303", "time": "8:00 AM - 10:00 AM", "building": "Library"},
  ];

  // Log out the user
  void logOut() {
    FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You have been logged out")),
    );
    // You can navigate the user back to the login screen here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Classes Section
            Text("My Classes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            CarouselSlider(
              options: CarouselOptions(
                height: 150,
                enlargeCenterPage: true,
                autoPlay: true,
              ),
              items: myClasses.map((classData) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(classData["code"]!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text(classData["time"]!, style: TextStyle(fontSize: 16)),
                        Text(classData["building"]!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 30),

            // Help Contribute Section
            Text("Help Contribute", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {}, // No functionality yet
                      icon: Icon(Icons.my_location),
                      label: Text("Get Point"),
                    ),
                    SizedBox(height: 10),
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
                    ElevatedButton.icon(
                      onPressed: () {}, // No functionality yet
                      icon: Icon(Icons.upload),
                      label: Text("Upload Photos"),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: detailsController,
                      decoration: InputDecoration(
                        labelText: "Additional Details (e.g., Floor, Room No.)",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // No functionality yet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Submitted! (No actual functionality yet)")),
                        );
                      },
                      child: Text("Submit"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Manage Account Section
            ElevatedButton(
              onPressed: () {}, // No functionality yet
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              child: Text("Manage Account"),
            ),
            SizedBox(height: 20),

            // Logout Section
            ElevatedButton(
              onPressed: logOut, // Log out the user
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
