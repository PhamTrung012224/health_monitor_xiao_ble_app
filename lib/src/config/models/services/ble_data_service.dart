// ble_data_service.dart
import 'dart:async';

class IMUData {
  double accX;
  double accY;
  double accZ;
  double gyroX;
  double gyroY;
  double gyroZ;

  IMUData({
    this.accX = 0.0,
    this.accY = 0.0,
    this.accZ = 0.0,
    this.gyroX = 0.0,
    this.gyroY = 0.0,
    this.gyroZ = 0.0,
  });
}

class BleDataService {
  static final BleDataService _instance = BleDataService._internal();
  factory BleDataService() => _instance;

  BleDataService._internal() {
    // Initialization logic if needed
  }

  final StreamController<IMUData> _imuDataStreamController = StreamController<IMUData>.broadcast();
  Stream<IMUData> get imuDataStream => _imuDataStreamController.stream;

  void updateIMUData(List<double> data) {
    if(data.length == 6){
      _imuDataStreamController.add(IMUData(
          accX: data[0],
          accY: data[1],
          accZ: data[2],
          gyroX: data[3],
          gyroY: data[4],
          gyroZ: data[5]
      ));
    }
  }

  void dispose() {
    _imuDataStreamController.close();
  }
}