// ble_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:capstone_mobile_app/src/config/models/services/ble_data_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';

class BleService {
  // Remove instance reference (deprecated)
  // final _flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<int>>? _characteristicSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  // StreamController for receiving data (List<double>)
  final StreamController<List<double>> _dataStreamController = StreamController<List<double>>.broadcast();
  Stream<List<double>> get dataStream => _dataStreamController.stream;

  // Singleton pattern
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

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
      print('Error connecting to device: $e');
      throw e; // Re-throw to be handled in Bloc
    }
  }

  Future<void> disconnectDevice() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        _cleanupConnection();
      } catch (e) {
        print('Error disconnecting: $e');
      }
    }
  }
  
  void _cleanupConnection() {
    _connectedDevice = null;
    _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
  }

  Future<void> _discoverServicesAndSubscribe(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      if (services.isEmpty) {
        throw Exception('No services found');
      }
      BluetoothService lastService = services.last;
      BluetoothCharacteristic lastCharacteristic = lastService.characteristics.last;

      // Cancel existing subscription if any
      await _characteristicSubscription?.cancel();
      
      // Set up notification
      await lastCharacteristic.setNotifyValue(true);
      
      _characteristicSubscription = lastCharacteristic.onValueReceived.listen((value) {
        if (value.length >= 48) {
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

          // Update global BLE data service
          if (kDebugMode) {
            print("Received BLE data: ${doubleValues.join(', ')}");
          }
          BleDataService().updateIMUData(doubleValues);
          _dataStreamController.add(doubleValues); // Add directly to stream
        }
      });
      
    } catch (e) {
      print('Error discovering services or subscribing: $e');
      disconnectDevice();  //Attempt to disconnect.
      throw e;
    }
  }

  // Updated scan methods using static methods from FlutterBluePlus
// In BleService class
Future<void> startScan({Duration? timeout}) async {
  try {
    // Use these scan settings for better results
    await FlutterBluePlus.startScan(
      timeout: timeout ?? const Duration(seconds: 5),
      androidScanMode: AndroidScanMode.lowLatency, // More aggressive scanning
    );
    
    if (kDebugMode) {
      print("Scan started successfully");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error starting scan: $e");
    }
    throw e;
  }
}

  Future<void> stopScan() async {
    return await FlutterBluePlus.stopScan();
  }

  // Updated property getters to use static streams from FlutterBluePlus
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;
  Stream<BluetoothAdapterState> get adapterState => FlutterBluePlus.adapterState;
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  
  // Updated method to get system devices
  Future<List<BluetoothDevice>> getSystemDevices() {
    return FlutterBluePlus.systemDevices([]);
  }
  
  // Helper methods to turn Bluetooth on/off
  Future<void> turnOnBluetooth() async {
    await FlutterBluePlus.turnOn();
  }

  void dispose() {
    _characteristicSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _dataStreamController.close();
  }

  BluetoothDevice? getConnectedDevice() => _connectedDevice;
}