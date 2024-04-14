import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:move_id/Notification/notification_controller.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:move_id/Notification/notification_controller.dart';


void main() async {
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: "MoveID_channel_group",
        channelKey: "MoveID_Notification_Channel", 
        channelName: "MoveID Notification", 
        channelDescription: "MoveID Notification Channel"
        )
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: "MoveID_channel_group", 
        channelGroupName: "MoveID Group"
      )

    ]
  );
  bool isAllowedToSendNotifications = await AwesomeNotifications().isNotificationAllowed();

  if(!isAllowedToSendNotifications){
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final MqttServerClient client;
  final List<String> messages = [];

  @override
  void initState() {
    super.initState();
   AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.OnNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationController.OnNotificationDisplayedMethod
      );
    _initializeMqttClient();
  }

  Future<void> _initializeMqttClient() async {

 
    
  final String broker = 'broker.emqx.io'; // MQTT broker hostname or IP address
  final int port = 1883; // Default MQTT port
  final String clientId = 'my_flutter_app'; // Unique client identifier
 

  client = MqttServerClient(broker, clientId);
  client.port = port;
  client.secure = false;

  if (client == null || client.connectionStatus == MqttConnectionState.connected) {
    return;
  }
 

  // Set up event listeners
  client.onConnected = _onConnected;
  client.onDisconnected = _onDisconnected;
  client.onSubscribed = _subscribeToTopic;
  
  // Add a null check before calling listen on client.updates
  client.updates?.listen(_onMessageReceived);

  try {
    await client.connect(); // Connect to the MQTT broker
  } catch (e) {
    print('Error connecting to MQTT broker: $e');
  }
}

  // Callback function for when the client is connected
  void _onConnected() {
    print('Connected to MQTT broker');
    _subscribeToTopic('flutter/move_id');
    client.updates?.listen(_onMessageReceived);
  }

  // Callback function for when the client is disconnected
  void _onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  // Subscribe to a topic
  void _subscribeToTopic(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
    print('Subscribed to topic: $topic');
  }

  void _unsubscribeFromTopic(String topic) {
  client.unsubscribe(topic);
  print('Unsubscribed from topic: $topic');
}

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage>> event) {
  final MqttPublishMessage receivedMessage = event[0].payload as MqttPublishMessage;
  final String message = MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);


  AwesomeNotifications().createNotification(content: NotificationContent(
    id: 1, 
    channelKey: "MoveID_Notification_Channel",
    title: "OH JOCA OH JOCA JURO QUE É FACIL",
    body: "$message"),
    );

  print('Received message: $message');

  // Assuming the payload is JSON-encoded, decode it
  try {
    final Map<String, dynamic> jsonMessage = jsonDecode(message);
    final String msg = jsonMessage['msg'] ?? '';
    print('Decoded message: $msg');

    setState(() {
      messages.add(msg);
    });
  } catch (e) {
    print('Error decoding message: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MQTT Test',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter MQTT Test'),
        ),
        body: Center(
          child: Text('MQTT Connection Status: ${client.connectionStatus}'),
        ),
      ),
    );
  }
}
