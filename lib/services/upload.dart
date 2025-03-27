import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_core/firebase_core.dart';

class TimetableService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> uploadTimetableToFirestore() async {
    try {
      // Load JSON from assets
      String jsonString = await rootBundle.loadString('assets/timetable.json');
      Map<String, dynamic> jsonData = json.decode(jsonString); // Decode as Map

      if (!jsonData.containsKey("json_data")) {
        print("❌ JSON format incorrect: Missing 'json_data' key.");
        return;
      }

      List<dynamic> timetableData = jsonData["json_data"]; // Extract the actual data list

      // Reference Firestore collection
      CollectionReference timetableRef = firestore.collection('timetable');

      // Upload each class schedule
      for (var entry in timetableData) {
        await timetableRef.add(entry); // Auto-generates a document ID
      }

      print("✅ Timetable uploaded successfully!");
    } catch (e) {
      print("❌ Error uploading timetable: $e");
    }
  }
}
