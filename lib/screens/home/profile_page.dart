import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase authentication
import 'addVenue.dart';
import '../auth/welcome.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController detailsController = TextEditingController();
  String? userName;
  List<String> favoriteClasses = [];
  String? selectedVenue;
  List<String> venueNames = [
    "Building A",
    "Building B",
    "Library",
    "Hall 1",
  ]; // Example venues

  // Example Class Data
  final List<Map<String, String>> myClasses = [
    {"code": "CS101", "time": "10:00 AM - 12:00 PM", "building": "Building A"},
    {"code": "CS202", "time": "2:00 PM - 4:00 PM", "building": "Building B"},
    {"code": "CS303", "time": "8:00 AM - 10:00 AM", "building": "Library"},
  ];

  // Fetch user data (name) from Firestore
  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get the user document from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (userDoc.exists) {
        setState(() {
          userName =
              userDoc['name']; // Assuming 'name' is a field in the 'users' document
        });
      }
    }
  }

  // Fetch the user's favorite classes
  Future<void> fetchFavorites() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('favorites')
              .doc(user.uid)
              .collection('classes')
              .get();
      setState(() {
        favoriteClasses =
            snapshot.docs.map((doc) => doc['code'] as String).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data on page load
    fetchFavorites(); // Fetch favorite classes on page load
  }

  void logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Optionally show a message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("You have been logged out")));

      // Wait a bit to ensure the sign-out state is registered
      await Future.delayed(Duration(milliseconds: 300));

      // Replace current route with login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
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
            // Display the user’s name
            if (userName != null)
              Text(
                "Hello, $userName!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

            // Display favorite classes
            if (favoriteClasses.isNotEmpty)
              Column(
                children:
                    favoriteClasses.map((classCode) {
                      return ListTile(
                        title: Text(classCode),
                        subtitle: Text('Class details go here'),
                      );
                    }).toList(),
              ),

            // My Classes Section
            Text(
              "My Classes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CarouselSlider(
              options: CarouselOptions(
                height: 150,
                enlargeCenterPage: true,
                autoPlay: true,
              ),
              items:
                  myClasses.map((classData) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              classData["code"]!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              classData["time"]!,
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              classData["building"]!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 30),

            // Help Contribute Section
            Text(
              "Help Contribute",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // New Contribution ListTile Button
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.add_location_alt, color: Colors.blue),
                    title: Text("Contribute a Venue"),
                    subtitle: Text("Add new venue details to the map"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddVenueScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Existing Contribution Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                      items:
                          venueNames.map((venue) {
                            return DropdownMenuItem(
                              value: venue,
                              child: Text(venue),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => selectedVenue = value),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Submitted! (No actual functionality yet)",
                            ),
                          ),
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
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Manage Account"),
            ),
            SizedBox(height: 20),

            // Logout Section
            ElevatedButton(
              onPressed: () => logOut(context), // ✅ Now it works
              // Log out the user
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
