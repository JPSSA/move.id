import 'package:flutter/material.dart';

class PatientModel {
  final String? fname;
  final String? lname;
  final String? deviceid;

  PatientModel(
    {
      @required this.deviceid,
      @required this.fname,
      @required this.lname,
    }
  );
}