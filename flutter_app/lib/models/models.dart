import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientModel {
  final RxString? location;
  final String? deviceid;

  PatientModel(
    {
      @required this.deviceid,
      @required this.location
    }
  );
}

class NotificationHistoryModel{
  final String? id;
  final DateTime? datetime;
  final String? message;
  final bool? classification;
  final String? userId;

  NotificationHistoryModel(
    {
      @required this.id,
      @required this.datetime,
      @required this.message,
      @required this.classification,
      @required this.userId
    }
  );
}