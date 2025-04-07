import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unimaps/screens/home/homepage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> searchResults = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false; // <-- Added loading state

  void _searchClass() async {
    String query = _searchController.text.toUpperCase().trim();
    if (query.isNotEmpty) {
      setState(() {
        isLoading = true;
        searchResults.clear();
      });

      try {
        var snapshot = await _firestore.collection('timetable').get();
        Map<String, Map<String, String>> uniqueResults = {}; // Use a Map to track unique classes

        for (var doc in snapshot.docs) {
          var classData = doc.data();
          String className = classData['Name'] ?? '';
          List<String> classParts = className.split('/');
          String classCode = classParts.isNotEmpty ? classParts[0].trim() : className.trim();

          if (classCode.contains(query)) {
            String uniqueKey = "${classData['Name']}_${classData['Allocated Location Name']}"; // Unique identifier

            if (!uniqueResults.containsKey(uniqueKey)) { // Prevent duplicates
              uniqueResults[uniqueKey] = {
                "name": classData['Name'] ?? "Unknown Class",
                "venue": classData['Allocated Location Name'] ?? "Unknown Venue",
                "time": "${classData['Scheduled Start Time']} - ${classData['Scheduled End Time']}",
                "days": classData['Scheduled Days'] ?? "Unknown Days",
              };
            }
          }
        }

        setState(() {
          searchResults = uniqueResults.values.toList(); // Convert Map back to List
          isLoading = false;
        });
      } catch (e) {
        print("Error fetching class data: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search for a Class")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Enter Class Code (e.g., CSI 468)",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchClass,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator()) // Show loading spinner
                  : searchResults.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            var classInfo = searchResults[index];
                            return Card(
                              child: ListTile(
                                title: Text(classInfo['name'] ?? "Unknown Class", style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Venue: ${classInfo['venue'] ?? "Unknown Venue"}"),
                                    Text("Time: ${classInfo['time'] ?? "Unknown Time"}"),
                                    Text("Days: ${classInfo['days'] ?? "Unknown Days"}"),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Homepage(),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        )
                      : Center(child: Text("No classes found. Try searching!", style: TextStyle(fontSize: 16))),
            ),
          ],
        ),
      ),
    );
  }
}
