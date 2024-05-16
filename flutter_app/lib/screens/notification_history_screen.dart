import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:move_id/utils/notification_history_controller.dart';
import 'package:move_id/utils/color_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationHistoryScreen extends GetView<NotificationHistoryController> {
  const NotificationHistoryScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: controller.getNotificationHistoryFromPrefs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Return an error message if an error occurs
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final List<dynamic> results = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      hexStringToColor("#D8F3DC"),
                      hexStringToColor("#B7E4C7"),
                      hexStringToColor("#95D5B2"),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final notification = results[index];
                        return ListTile(
                          title: Text('Sensor ID: ${notification['id']}'),
                          subtitle: Text(
                            'Location: ${notification['location']}\n'
                            'Date: ${DateTime.parse(notification['datetime']).toLocal().day}-${DateTime.parse(notification['datetime']).toLocal().month}-${DateTime.parse(notification['datetime']).toLocal().year}\n'
                            'Hour: ${DateTime.parse(notification['datetime']).toLocal().hour}:${DateTime.parse(notification['datetime']).toLocal().minute}\n'
                            'Name: ${notification['fname']} ${notification['lname']}\n'
                            'Room: ${notification['room']}\n'
                            'Bed: ${notification['bed']}',
                          ),
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
                  ],
                ),
              ),
            );
          }
        },
      ),
      
    );
  }
}
