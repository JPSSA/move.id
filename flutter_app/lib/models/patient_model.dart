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