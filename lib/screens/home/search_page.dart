import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unimaps/screens/home/homepage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = []; // Changed to dynamic to hold more complex data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  void _searchClass() async {
    String query = _searchController.text.toUpperCase().trim();
    if (query.isNotEmpty) {
      setState(() {
        isLoading = true;
        searchResults.clear();
      });

      try {
        // 1. First search for classes in timetable
        var timetableSnapshot = await _firestore.collection('timetable').get();
        Map<String, Map<String, dynamic>> uniqueResults = {};

        for (var doc in timetableSnapshot.docs) {
          var classData = doc.data();
          String className = classData['Name'] ?? '';
          String venueName = classData['Allocated Location Name'] ?? '';
          
          if (className.toUpperCase().contains(query)) {
            String uniqueKey = "${classData['Name']}_$venueName";

            if (!uniqueResults.containsKey(uniqueKey)) {
              // 2. For each matching class, find its building details
              var buildingQuery = await _firestore.collection('Venue')
                  .where('Name', isEqualTo: venueName)
                  .limit(1)
                  .get();

              Map<String, dynamic> buildingData = {};
              if (buildingQuery.docs.isNotEmpty) {
                buildingData = buildingQuery.docs.first.data();
                // Ensure the document has Location field
                if (buildingData['Location'] == null) {
                  print('Venue document missing Location field');
                }
              }

              uniqueResults[uniqueKey] = {
                "className": classData['Name'] ?? "Unknown Class",
                "venue": venueName,
                "time": "${classData['Scheduled Start Time']} - ${classData['Scheduled End Time']}",
                "days": classData['Scheduled Days'] ?? "Unknown Days",
                // Include building data to pass to Homepage
                "buildingData": buildingData,
                "roomDescription": classData['Room Description'] ?? "", // Add if available
              };
            }
          }
        }

        setState(() {
          searchResults = uniqueResults.values.toList();
          isLoading = false;
        });
      } catch (e) {
        print("Error fetching data: $e");
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
                labelText: "Enter class name or code",
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
                  ? Center(child: CircularProgressIndicator())
                  : searchResults.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            var classInfo = searchResults[index];
                            return Card(
                              child: ListTile(
                                title: Text(classInfo['className'], 
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Venue: ${classInfo['venue']}"),
                                    Text("Time: ${classInfo['time']}"),
                                    Text("Days: ${classInfo['days']}"),
                                    if (classInfo['roomDescription']?.isNotEmpty ?? false)
                                      Text("Location: ${classInfo['roomDescription']}"),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Homepage(
                                        selectedBuilding: classInfo['buildingData'],
                                        roomDescription: classInfo['roomDescription'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        )
                      : Center(child: Text("No classes found. Try searching!", 
                          style: TextStyle(fontSize: 16))),
            ),
          ],
        ),
      ),
    );
  }
}