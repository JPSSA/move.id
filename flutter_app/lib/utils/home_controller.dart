import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/models/patient_model.dart';

import 'package:get/get.dart';




class HomeController extends GetxController{

  Rx<List<PatientModel>> patients = Rx<List<PatientModel>>([]);
  TextEditingController fnameTextEditingController = TextEditingController();
  TextEditingController lnameTextEditingController = TextEditingController();
  TextEditingController deviceIDTextEditingController = TextEditingController();
  late PatientModel patientModel;
  var itemCount = 0.obs;
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
    fnameTextEditingController.dispose();
    lnameTextEditingController.dispose();
    deviceIDTextEditingController.dispose();
  }
  addPatient(String fname,String lname, String deviceid){
    patientModel = PatientModel(deviceid: deviceid, fname: fname, lname: lname);
    patients.value.add(patientModel);
    itemCount.value = patients.value.length;
    fnameTextEditingController.clear();
    lnameTextEditingController.clear();
    deviceIDTextEditingController.clear();
  }

  removePatient(int index){
    patients.value.removeAt(index);
    itemCount.value = patients.value.length;
  }
}