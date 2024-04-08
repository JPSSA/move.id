
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/models/patient_model.dart';

import 'package:get/get.dart';




class HomeController extends GetxController{



  RxString selectedLocation = RxString("Hospital Santa Maria");
  Rx<List<PatientModel>> patients = Rx<List<PatientModel>>([]);
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
    deviceIDTextEditingController.dispose();
  }
  addPatient(String location, String deviceid){
    patientModel = PatientModel(deviceid: deviceid,location: selectedLocation);
    patients.value.add(patientModel);
    itemCount.value = patients.value.length;
    selectedLocation.value = "Hospital Santa Maria"; 
    deviceIDTextEditingController.clear();
  }

  removePatient(int index){
    patients.value.removeAt(index);
    itemCount.value = patients.value.length;
  }
}