import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController {
  // Use this method to detect when a new notification or schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification) async{
      //code here
      }

  // Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> OnNotificationDisplayedMethod(
    ReceivedNotification receivedNotification) async{
      // code here
    }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction) async {
      // code here
    }

  // use this method to detect when the user taps on a notification or action
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction) async {
      // code here
    }
  

    
}