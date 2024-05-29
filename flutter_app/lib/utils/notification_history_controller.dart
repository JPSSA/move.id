import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:move_id/utils/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class NotificationHistoryController extends GetxController{

  List<dynamic> allNotifications = [];

  Future<List<dynamic>> getNotificationHistory() async {
    const String url = ApiUrls.getNotificationHistoryUrl;
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email").toString();
    bool group = prefs.getBool('groupNotifications')?? false;

    try {

      final Map<String, String> userData = {
        'email': email,
      };

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

  void evaluateNotification(List<String> ids, bool classification) async{
    const String url = ApiUrls.notificationHistoryUrl;

    try{
      final prefs = await SharedPreferences.getInstance();
      String email = prefs.getString("email").toString();

      for (String id in ids) {
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