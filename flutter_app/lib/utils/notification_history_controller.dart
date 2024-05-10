import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:move_id/utils/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class NotificationHistoryController extends GetxController{


  Future<void> getNotificationHistoryAndSaveToPrefs() async {
    const String url = ApiUrls.notificationHistoryUrl;

    try {
    final http.Response response = await http.get(Uri.parse(url));

   

    if (response.statusCode == 200) {
    
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('notifications', response.body);
      
      print('Notifications saved to SharedPreferences.');
    } else {
      print('Failed to fetch locations and IDs. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred: $e');
  }

  }

  Future<List<dynamic>> getNotificationHistoryFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString('notifications');

    final Map<String, dynamic> responseBody = json.decode(notificationsJson!);


    return responseBody['notification'];
  }

  void evaluateNotification(String id, bool classification) async{
    const String url = ApiUrls.notificationHistoryUrl;

    try{
      final prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email").toString();

      final Map<String, String> notification = {
        'id': id,
        'email': email,
        'classification': classification.toString()
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
        textColor: Colors.black
      );
      
    } else {
      Fluttertoast.showToast(
        msg: "Failed to classify the notification with that id",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        textColor: Colors.black
      );
    }


    }catch (e) {
    print('Exception occurred: $e');
    Fluttertoast.showToast(
      msg: "Failed to classify the notification with that id",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.white,
      textColor: Colors.black
    );
    }

  }





}