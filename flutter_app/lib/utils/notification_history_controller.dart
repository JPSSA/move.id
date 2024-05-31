import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:move_id/utils/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationHistoryController extends GetxController {
  List<dynamic> allNotifications = [];
  List<dynamic> filteredNotifications = [];

  Future<List<dynamic>> getNotificationHistory() async {
    const String url = ApiUrls.getNotificationHistoryUrl;
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email").toString();
    bool group = prefs.getBool('groupNotifications') ?? false;

    try {
      final Map<String, String> userData = {'email': email};

      final http.Response response = await http.post(
        Uri.parse(url),
        body: json.encode(userData),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        print('Notification history saved to SharedPreferences.');
        return responseBody['notifications'];
      } else {
        print('Failed to fetch notification history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }

    return [];
  }

  void evaluateNotification(List<String> ids, bool classification) async {
    const String url = ApiUrls.notificationHistoryUrl;

    try {
      final prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email").toString();

      for (String id in ids) {
        final Map<String, String> notification = {
          'id': id,
          'email': email,
          'classification': classification.toString(),
        };

        final http.Response response = await http.post(
          Uri.parse(url),
          body: json.encode(notification),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "Notification classified successfully",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.white,
            textColor: Colors.black,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Failed to classify the notification with that id",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.white,
            textColor: Colors.black,
          );
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
      Fluttertoast.showToast(
        msg: "Failed to classify the notification with that id",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
    }
  }

  List<dynamic> filterNotifications(List<dynamic> notifications, {DateTime? start, DateTime? end, String? nameFilter}) {
    return notifications.where((notification) {
      bool matchesTime = true;
      bool matchesName = true;

      if (start != null && end != null) {
        DateTime notificationTime = DateTime.parse(notification['datetime']).toLocal();
        int notificationHour = notificationTime.hour;
        int notificationMinute = notificationTime.minute;
        int startHour = start.hour;
        int startMinute = start.minute;
        int endHour = end.hour;
        int endMinute = end.minute;

        matchesTime = (notificationHour > startHour && notificationHour < endHour) ||
            (notificationHour == startHour && notificationMinute >= startMinute) ||
            (notificationHour == endHour && notificationMinute <= endMinute);
      }

      if (nameFilter != null && nameFilter.isNotEmpty) {
        matchesName = notification['fname'].toLowerCase().contains(nameFilter.toLowerCase()) ||
            notification['lname'].toLowerCase().contains(nameFilter.toLowerCase());
      }

      return matchesTime && matchesName;
    }).toList();
  }

  Future<List<dynamic>> getNotificationHistoryDummy() async {
  await Future.delayed(Duration(seconds: 1)); // Simulate a network delay

  final prefs = await SharedPreferences.getInstance();
  String? startHour = prefs.getString('startHour');
  String? endHour = prefs.getString('endHour');
  String? nameFilter = prefs.getString('nameFilter');

  List<dynamic> notifications = [
    {
      'id': 1,
      'fname': 'John',
      'lname': 'Doe',
      'location': 'Room A',
      'datetime': '2024-05-29T14:30:00Z',
      'room': '101',
      'bed': '1'
    },
    {
      'id': 2,
      'fname': 'Jane',
      'lname': 'Doe',
      'location': 'Room B',
      'datetime': '2024-05-29T15:45:00Z',
      'room': '102',
      'bed': '2'
    },
    // Add more dummy data here...
    {
      'id': 3,
      'fname': 'Alice',
      'lname': 'Smith',
      'location': 'Room C',
      'datetime': '2024-05-29T16:00:00Z',
      'room': '103',
      'bed': '3'
    },
  ];

  DateTime? start;
  DateTime? end;

  if (startHour != null && startHour.isNotEmpty && endHour != null && endHour.isNotEmpty) {
    start = DateFormat("HH:mm").parse(startHour);
    end = DateFormat("HH:mm").parse(endHour);
  }

  // Filter by concatenated full name if nameFilter is not empty
  if (nameFilter != null && nameFilter.isNotEmpty) {
    return filterNotificationsByName(notifications, nameFilter, start, end);
  } else {
    return filterNotifications(notifications, start: start, end: end);
  }
}

// Method to filter notifications by concatenated full name
List<dynamic> filterNotificationsByName(List<dynamic> notifications, String nameFilter, DateTime? start, DateTime? end) {
  return notifications.where((notification) {
    String fullName = '${notification['fname']} ${notification['lname']}';
    bool matchesName = fullName.toLowerCase().contains(nameFilter.toLowerCase());

    if (start != null && end != null) {
      // Filter by time if start and end are provided
      DateTime notificationTime = DateTime.parse(notification['datetime']).toLocal();
      int notificationHour = notificationTime.hour;
      int notificationMinute = notificationTime.minute;
      int startHour = start.hour;
      int startMinute = start.minute;
      int endHour = end.hour;
      int endMinute = end.minute;

      bool matchesTime = (notificationHour > startHour && notificationHour < endHour) ||
          (notificationHour == startHour && notificationMinute >= startMinute) ||
          (notificationHour == endHour && notificationMinute <= endMinute);

      return matchesName && matchesTime;
    } else {
      // Only filter by name if start and end are not provided
      return matchesName;
    }
  }).toList();
}
}