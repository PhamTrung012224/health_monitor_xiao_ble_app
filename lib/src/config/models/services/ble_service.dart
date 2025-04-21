import 'dart:async';
import 'dart:typed_data';
import 'package:capstone_mobile_app/src/config/models/services/ble_data_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';

class BleService {
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<int>>? _imuCharacteristicSubscription;
  StreamSubscription<List<int>>? _stepCountCharacteristicSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  // Stream for IMU data
  final StreamController<List<double>> _dataStreamController =
      StreamController<List<double>>.broadcast();
  Stream<List<double>> get dataStream => _dataStreamController.stream;

  // Stream for step count
  final StreamController<int> _stepCountStreamController =
      StreamController<int>.broadcast();
  Stream<int> get stepCountStream => _stepCountStreamController.stream;

  // Singleton pattern
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal() {
    if (kDebugMode) {
      print("BleService initialized");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // Cancel any existing connection subscriptions
      await _connectionStateSubscription?.cancel();

      // Connect to device
      await device.connect();
      _connectedDevice = device;

      // Set up connection state listener
      _connectionStateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          if (kDebugMode) {
            print("Device disconnected unexpectedly");
          }
          _cleanupConnection();
        }
      });

      await _discoverServicesAndSubscribe(device);
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to device: $e');
      }
      throw e;
    }
  }

  Future<void> _discoverServicesAndSubscribe(BluetoothDevice device) async {
    try {
      if (kDebugMode) {
        print("Discovering services...");
      }

      List<BluetoothService> services = await device.discoverServices();
      if (services.isEmpty) {
        throw Exception('No services found');
      }

      // Print all services and characteristics for debugging
      if (kDebugMode) {
        print("Found ${services.length} services:");
        for (var service in services) {
          print("Service: ${service.uuid}");
          for (var char in service.characteristics) {
            print(" - Char: ${char.uuid}, properties: ${char.properties}");
          }
        }
      }

      // Define UUIDs for your characteristics
      final imuCharUuid = Guid("00001526-1212-efde-1523-785feabcd123");
      final stepCountCharUuid = Guid("00001527-1212-efde-1523-785feabcd123");

      // Variables to hold the characteristics when found
      BluetoothCharacteristic? imuCharacteristic;
      BluetoothCharacteristic? stepCountCharacteristic;

      // Search for the characteristics across all services
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid == imuCharUuid) {
            imuCharacteristic = characteristic;
            if (kDebugMode) {
              print("Found IMU characteristic: ${characteristic.uuid}");
            }
          } else if (characteristic.uuid == stepCountCharUuid) {
            stepCountCharacteristic = characteristic;
            if (kDebugMode) {
              print("Found step count characteristic: ${characteristic.uuid}");
            }
          }
        }
      }

      // Check if both characteristics were found
      if (imuCharacteristic != null && stepCountCharacteristic != null) {
        // Subscribe to both characteristics
        await _subscribeToIMUCharacteristic(imuCharacteristic);
        await _subscribeToStepCountCharacteristic(stepCountCharacteristic);
      } else {
        // Log which characteristic wasn't found
        if (imuCharacteristic == null) {
          if (kDebugMode) {
            print("IMU characteristic not found: $imuCharUuid");
          }
        }
        if (stepCountCharacteristic == null) {
          if (kDebugMode) {
            print("Step count characteristic not found: $stepCountCharUuid");
          }
        }
        throw Exception('Required characteristics not found');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error discovering services or subscribing: $e');
      }
      throw e;
    }
  }

  Future<void> _subscribeToIMUCharacteristic(
      BluetoothCharacteristic characteristic) async {
    if (kDebugMode) {
      print("Subscribing to IMU characteristic: ${characteristic.uuid}");
    }

    // Cancel existing subscription
    await _imuCharacteristicSubscription?.cancel();

    // Set up notification
    await characteristic.setNotifyValue(true);

    // Subscribe to notifications
    _imuCharacteristicSubscription =
        characteristic.onValueReceived.listen((value) {
      if (value.length >= 48) {
        // 6 doubles × 8 bytes
        List<double> doubleValues = [];

        // Process each double value (8 bytes each)
        for (int i = 0; i < 6; i++) {
          int startPos = i * 8;
          ByteData byteData = ByteData(8);
          for (int j = 0; j < 8; j++) {
            byteData.setUint8(j, value[startPos + j]);
          }
          double doubleValue = byteData.getFloat64(0, Endian.little);
          doubleValues.add(doubleValue);
        }

        if (kDebugMode) {
          print("Received IMU data: ${doubleValues.join(', ')}");
        }

        // Update IMU data service
        BleDataService().updateIMUData(doubleValues);

        // Add to stream
        _dataStreamController.add(doubleValues);
      }
    });
  }

  Future<void> _subscribeToStepCountCharacteristic(
      BluetoothCharacteristic characteristic) async {
    if (kDebugMode) {
      print("Subscribing to step count characteristic: ${characteristic.uuid}");
    }

    // Cancel existing subscription
    await _stepCountCharacteristicSubscription?.cancel();

    // Set up notification
    await characteristic.setNotifyValue(true);

    // Subscribe to notifications
    _stepCountCharacteristicSubscription =
        characteristic.onValueReceived.listen((value) {
      if (value.length >= 4) {
        // Assuming int32 (4 bytes) for step count
        ByteData byteData = ByteData(4);
        for (int j = 0; j < 4; j++) {
          byteData.setUint8(j, value[j]);
        }
        int stepCount = byteData.getInt32(0, Endian.little);

        if (kDebugMode) {
          print("Received step count: $stepCount");
        }

        // Update step count in BleDataService
        BleDataService().updateStepCount(stepCount);

        // Add to stream
        _stepCountStreamController.add(stepCount);
      }
    });
  }

  void _cleanupConnection() {
    _connectedDevice = null;
    _imuCharacteristicSubscription?.cancel();
    _imuCharacteristicSubscription = null;
    _stepCountCharacteristicSubscription?.cancel();
    _stepCountCharacteristicSubscription = null;
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
  }

  Future<void> disconnectDevice() async {
    if (_connectedDevice != null) {
      try {
        // Only disconnect if specifically requested
        await _connectedDevice!.disconnect();
      } catch (e) {
        if (kDebugMode) {
          print("Error disconnecting device: $e");
        }
      } finally {
        _cleanupConnection();
      }
    }
  }

  // Scan methods
  Future<void> startScan({Duration? timeout}) async {
    try {
      await FlutterBluePlus.startScan(
        timeout: timeout ?? const Duration(seconds: 10),
        androidScanMode: AndroidScanMode.lowLatency,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error starting scan: $e");
      }
      throw e;
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      if (kDebugMode) {
        print("Error stopping scan: $e");
      }
    }
  }

  void updateConnectionState(BluetoothDevice device, bool isConnected) {
    if (isConnected) {
      _connectedDevice = device;
    } else if (_connectedDevice?.remoteId == device.remoteId) {
      _connectedDevice = null;
    }
  }

  void dispose() {
    _dataStreamController.close();
    _stepCountStreamController.close();
  }

  BluetoothDevice? getConnectedDevice() => _connectedDevice;
}
