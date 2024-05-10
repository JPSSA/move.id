import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:move_id/utils/notification_history_controller.dart';





class NotificationHistoryScreen extends GetView<NotificationHistoryController> {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<dynamic>>(
      future: controller.getNotificationHistoryFromPrefs(),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Return an error message if an error occurs
          return Text('Error: ${snapshot.error}');
        } else {

          final List<dynamic> results = snapshot.data!;

          return Scaffold(
        appBar: AppBar(
          title: const Text('Notification History'),
        ),
        body: ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final notification = results[index];
            return ListTile(
              title: Text('Sensor ID: ${notification['id']}'),
              // ignore: prefer_interpolation_to_compose_strings
              subtitle: Text('Location: ${notification['location']}\n' 'Date: ${DateTime.parse(notification['datetime']).toLocal().day}-${DateTime.parse(notification['datetime']).toLocal().month}-${DateTime.parse(notification['datetime']).toLocal().year}\n''Hour: ${DateTime.parse(notification['datetime']).toLocal().hour}:${DateTime.parse(notification['datetime']).toLocal().minute}\n''Name: ${notification['fname']} ${notification['lname']}\n''Room: ${notification['room']}\n'+
              'Bed: ${notification['bed']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      // Processar a avaliação como correta
                      controller.evaluateNotification(notification, true);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      // Processar a avaliação como errada
                      controller.evaluateNotification(notification, false);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
      }
      }

    );












    
  }
}
