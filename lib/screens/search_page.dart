import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  Map<String, Map<String, String>> classData = {
    "CS101": {
      "name": "Introduction to Programming",
      "venue": "Room A1",
      "time": "10:00 AM - 12:00 PM",
      "lecturer": "Dr. Smith"
    },
    "CS202": {
      "name": "Data Structures",
      "venue": "Room B2",
      "time": "2:00 PM - 4:00 PM",
      "lecturer": "Prof. Johnson"
    },
  };

  Map<String, String>? selectedClass;

  void _searchClass() {
    String query = _searchController.text.toUpperCase().trim();
    setState(() {
      selectedClass = classData[query];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search for a Class")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Enter Class Code (e.g., CS101)",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchClass,
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Class Information Container
            selectedClass != null
                ? Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Class: ${selectedClass!['name']}", 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text("Venue: ${selectedClass!['venue']}", style: TextStyle(fontSize: 16)),
                        Text("Time: ${selectedClass!['time']}", style: TextStyle(fontSize: 16)),
                        Text("Lecturer: ${selectedClass!['lecturer']}", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                : Text("No class found. Try searching!", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
