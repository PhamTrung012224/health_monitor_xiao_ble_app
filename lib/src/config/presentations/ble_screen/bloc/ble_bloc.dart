// ble_bloc.dart
import 'dart:async';
import 'dart:io';
import 'package:capstone_mobile_app/src/config/models/services/ble_data_service.dart';
import 'package:capstone_mobile_app/src/config/models/services/ble_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ble_event.dart';
import 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  final BleService _bleService = BleService(); // Use the singleton instance
  StreamSubscription<List<double>>? _dataSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  BleBloc() : super(BleInitial()) {
    // First register all the event handlers
    on<BleInit>(_onBleInit);
    on<AdapterStateChanged>(_onAdapterStateChanged);
    on<StartScanRequested>(_onStartScanRequested);
    on<StopScanRequested>(_onStopScanRequested);
    on<DeviceSelected>(_onDeviceSelected);
    on<ConnectRequested>(_onConnectRequested);
    on<DisconnectRequested>(_onDisconnectRequested);
    on<DataReceived>(_onDataReceived);

    // Then add initial event
    add(BleInit());
  }

  Future<void> _onBleInit(BleInit event, Emitter<BleState> emit) async {
    // Set up adapter state listener
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      add(AdapterStateChanged(state));
    });

    // Set up data stream listener
    _dataSubscription?.cancel();
    _dataSubscription = _bleService.dataStream.listen(
      (data) => add(DataReceived(data)),
      onError: (error) => add(BleError(error.toString())),
    );

    // Check current Bluetooth state
    try {
      final currentState = await FlutterBluePlus.adapterState.first;
      emit(BluetoothStateChange(currentState));
    } catch (e) {
      if (kDebugMode) {
        print("Error getting initial Bluetooth state: $e");
      }
    }
  }

  void _onAdapterStateChanged(
      AdapterStateChanged event, Emitter<BleState> emit) {
    emit(BluetoothStateChange(event.state));
  }

  Future<void> _onStartScanRequested(
      StartScanRequested event, Emitter<BleState> emit) async {
    if (!await _checkAndRequestPermissions()) {
      emit(const BleErrorState("Required permissions are not granted"));
      return;
    }
    if (kDebugMode) {
      print("Starting BLE scan...");
    }

    emit(BleScanning());

    // Add subscription to scan results for immediate feedback
    StreamSubscription<List<ScanResult>>? scanResultsSubscription;
    scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (kDebugMode) {
        print("Scan results (${results.length} devices):");
        for (var result in results) {
          print(" - ${result.device.platformName} (${result.device.remoteId})");
        }
      }
    });

    try {
      // Check Bluetooth state before scanning
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        if (kDebugMode) {
          print("Bluetooth is not on: $adapterState");
        }
        emit(BleErrorState("Bluetooth is not enabled"));
        scanResultsSubscription.cancel();
        return;
      }

      // Start scan with longer timeout
      await _bleService.startScan(timeout: const Duration(seconds: 15));

      // Wait for scan to complete
      await FlutterBluePlus.isScanning
          .where((isScanning) => isScanning == false)
          .first
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print("Scan completed normally");
      }
      emit(BleScanCompleted(await FlutterBluePlus.scanResults.first));
    } catch (e) {
      if (kDebugMode) {
        print("Scan error or timeout: $e");
      }
      // Try to get scan results even after timeout
      final results = await FlutterBluePlus.scanResults.first;
      if (results.isNotEmpty) {
        if (kDebugMode) {
          print("Found ${results.length} devices despite timeout");
        }
        emit(BleScanCompleted(results));
      } else {
        emit(BleErrorState("No devices found: $e"));
      }

      // Ensure scan is stopped if we hit timeout
      try {
        await _bleService.stopScan();
      } catch (stopError) {
        print("Error stopping scan: $stopError");
      }
    } finally {
      scanResultsSubscription?.cancel();
    }
  }

  Future<void> _onStopScanRequested(
      StopScanRequested event, Emitter<BleState> emit) async {
    try {
      await _bleService.stopScan();
      emit(BleScanStopped());
    } catch (e) {
      if (kDebugMode) {
        print("Error stopping scan: $e");
      }
      emit(BleErrorState(e.toString()));
    }
  }

  Future<void> _onDeviceSelected(
      DeviceSelected event, Emitter<BleState> emit) async {
    emit(DeviceSelectedState(event.device));
  }

  Future<void> _onConnectRequested(
      ConnectRequested event, Emitter<BleState> emit) async {
    emit(BleConnecting());
    try {
      await _bleService.connectToDevice(event.device);
      emit(BleConnected(event.device));
    } catch (e) {
      if (kDebugMode) {
        print("Error connecting to device: $e");
      }
      emit(BleErrorState(e.toString()));
    }
  }

  Future<void> _onDisconnectRequested(
      DisconnectRequested event, Emitter<BleState> emit) async {
    try {
      await _bleService.disconnectDevice();
      emit(BleDisconnected());
    } catch (e) {
      if (kDebugMode) {
        print("Error disconnecting device: $e");
      }
      emit(BleErrorState(e.toString()));
    }
  }

  void _onDataReceived(DataReceived event, Emitter<BleState> emit) {
    try {
      List<double> doubleValues = event.data;

      if (kDebugMode) {
        print("BleBloc received data: ${doubleValues.join(', ')}");
      }

      // Update the BLE data service
      BleDataService().updateIMUData(doubleValues);

      // Emit new state with data
      emit(BleDataAvailable(event.data));
    } catch (e) {
      if (kDebugMode) {
        print("Error processing received data: $e");
      }
      emit(BleErrorState(e.toString()));
    }
  }

  // Add this method to your BleBloc
  Future<bool> _checkAndRequestPermissions() async {
    if (kDebugMode) {
      print("Checking BLE permissions...");
    }

    // For Android 12+ we need these permissions
    if (Platform.isAndroid) {
      bool bleScanGranted = false;
      bool bleConnectGranted = false;
      bool locationGranted = false;

      try {
        bleScanGranted = await Permission.bluetoothScan.request().isGranted;
        bleConnectGranted =
            await Permission.bluetoothConnect.request().isGranted;
        locationGranted = await Permission.location.request().isGranted;

        if (kDebugMode) {
          print(
              "Permissions status: Scan=$bleScanGranted, Connect=$bleConnectGranted, Location=$locationGranted");
        }

        return bleScanGranted && bleConnectGranted && locationGranted;
      } catch (e) {
        if (kDebugMode) {
          print("Error requesting permissions: $e");
        }
        return false;
      }
    }

    return true; // iOS has different permission model
  }

  @override
  Future<void> close() {
    if (kDebugMode) {
      print("Closing BleBloc and cleaning up resources");
    }
    _dataSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    return super.close();
  }
}
