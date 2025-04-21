import 'dart:async';
import 'package:flutter/foundation.dart';

class IMUData {
  // IMU values
  double accX;
  double accY;
  double accZ;
  double gyroX;
  double gyroY;
  double gyroZ;
  
  // Step count
  int stepCount;

  IMUData({
    this.accX = 0.0,
    this.accY = 0.0,
    this.accZ = 0.0,
    this.gyroX = 0.0,
    this.gyroY = 0.0,
    this.gyroZ = 0.0,
    this.stepCount = 0,
  });
  
  @override
  String toString() {
    return 'IMUData(accX: $accX, accY: $accY, accZ: $accZ, gyroX: $gyroX, gyroY: $gyroY, gyroZ: $gyroZ, stepCount: $stepCount)';
  }
}

class BleDataService {
  static final BleDataService _instance = BleDataService._internal();
  factory BleDataService() => _instance;
  
  final IMUData imuData = IMUData();
  final _imuDataController = StreamController<IMUData>.broadcast();
  
  Stream<IMUData> get imuDataStream => _imuDataController.stream;
  
  BleDataService._internal() {
    if (kDebugMode) {
      print("BleDataService initialized");
    }
  }
  
  void updateIMUData(List<double> values) {
    if (values.length >= 6) {
      imuData.accX = values[0];
      imuData.accY = values[1];
      imuData.accZ = values[2];
      imuData.gyroX = values[3];
      imuData.gyroY = values[4];
      imuData.gyroZ = values[5];
      
      if (kDebugMode) {
        print("BleDataService updating IMU values: $imuData");
      }
      
      _notifyListeners();
    }
  }
  
  void updateStepCount(int count) {
    imuData.stepCount = count;
    
    if (kDebugMode) {
      print("BleDataService updating step count: $count");
    }
    
    _notifyListeners();
  }
  
  void _notifyListeners() {
    if (!_imuDataController.isClosed) {
      _imuDataController.add(imuData);
    }
  }
  
  void dispose() {
    _imuDataController.close();
  }
}