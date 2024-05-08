

import 'dart:convert';

import 'package:get/get.dart';
import 'package:move_id/utils/api_urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHistoryController extends GetxController{

  @override
  void onInit() {
    super.onInit();
    

  }

  @override
  void onReady(){
    super.onReady();
  }

  @override
  void onClose(){
    super.onClose();
  }

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
    final String? notifications_json = prefs.getString('notifications');

    final Map<String, dynamic> responseBody = json.decode(notifications_json!);


    return responseBody['notification'];
  }



}