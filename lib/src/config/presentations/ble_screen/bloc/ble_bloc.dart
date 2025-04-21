import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ble_event.dart';
import 'ble_state.dart';
import 'package:capstone_mobile_app/src/config/models/services/ble_service.dart';
import 'package:capstone_mobile_app/src/config/models/objects/ble_object.dart';

class BleBloc extends Bloc<BleEvent, BleAppState> {
  final BleService _bleService = BleService();
  StreamSubscription<List<double>>? _dataSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<BluetoothConnectionState>? _deviceConnectionSubscription;

  BleBloc() : super(const BleAppState()) {
    on<BleInit>(_onBleInit);
    on<AdapterStateChanged>(_onAdapterStateChanged);
    on<StartScanRequested>(_onStartScanRequested);
    on<StopScanRequested>(_onStopScanRequested);
    on<DeviceSelected>(_onDeviceSelected);
    on<ConnectRequested>(_onConnectRequested);
    on<DisconnectRequested>(_onDisconnectRequested);
    on<DataReceived>(_onDataReceived);
    on<BleError>(_onBleError);
    add(BleInit());
  }

  Future<void> _onBleInit(BleInit event, Emitter<BleAppState> emit) async {
    if (kDebugMode) {
      print('BleBloc: Initializing...');
    }

    // Sync with BleService
    final connectedDevice = _bleService.getConnectedDevice();
    emit(state.copyWith(
      selectedDevice: connectedDevice,
      isConnected: connectedDevice != null,
    ));

    // Set up adapter state listener
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((adapterState) {
      if (kDebugMode) {
        print('BleBloc: Adapter state changed to $adapterState');
      }
      add(AdapterStateChanged(adapterState));
    });

    // Set up data stream listener
    _dataSubscription?.cancel();
    _dataSubscription = _bleService.dataStream.listen(
          (data) {
        if (kDebugMode) {
          print('BleBloc: Received data: $data');
        }
        add(DataReceived(data));
      },
      onError: (error) {
        if (kDebugMode) {
          print('BleBloc: Data stream error: $error');
        }
        add(BleError(error.toString()));
      },
    );

    // Check current Bluetooth adapter state
    try {
      final currentState = await FlutterBluePlus.adapterState.first;
      if (kDebugMode) {
        print('BleBloc: Initial adapter state: $currentState');
      }
      emit(state.copyWith(adapterState: currentState));
    } catch (e) {
      if (kDebugMode) {
        print('BleBloc: Error getting initial Bluetooth state: $e');
      }
      emit(state.copyWith(errorMessage: 'Failed to initialize Bluetooth: $e'));
    }

    // Set up connection listener if a device is connected
    if (connectedDevice != null) {
      _setupDeviceConnectionListener(connectedDevice);
    }
  }

  void _onAdapterStateChanged(AdapterStateChanged event, Emitter<BleAppState> emit) {
    if (kDebugMode) {
      print('BleBloc: Emitting adapter state: ${event.state}');
    }
    emit(state.copyWith(adapterState: event.state));
  }

  Future<void> _onStartScanRequested(StartScanRequested event, Emitter<BleAppState> emit) async {
    if (kDebugMode) {
      print('BleBloc: Starting scan...');
    }

    // Check Bluetooth state
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      if (kDebugMode) {
        print('BleBloc: Bluetooth is off, requesting to turn on');
      }
      try {
        await FlutterBluePlus.turnOn();
        // Wait briefly to ensure Bluetooth is enabled
        await Future.delayed(const Duration(seconds: 1));
        final newState = await FlutterBluePlus.adapterState.first;
        if (newState != BluetoothAdapterState.on) {
          if (kDebugMode) {
            print('BleBloc: Bluetooth still off after request');
          }
          emit(state.copyWith(errorMessage: 'Please enable Bluetooth to scan for devices.'));
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          print('BleBloc: Failed to turn on Bluetooth: $e');
        }
        emit(state.copyWith(errorMessage: 'Failed to enable Bluetooth: $e'));
        return;
      }
    }

    // Check and request permissions
    if (!await _checkAndRequestPermissions()) {
      if (kDebugMode) {
        print('BleBloc: Permissions not granted');
      }
      emit(state.copyWith(errorMessage: 'Please grant Bluetooth and location permissions.'));
      return;
    }

    emit(state.copyWith(isScanning: true, scanResults: [], errorMessage: null));

    StreamSubscription<List<ScanResult>>? scanResultsSubscription;
    scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (kDebugMode) {
        print('BleBloc: Scan results updated: ${results.length} devices');
      }
      emit(state.copyWith(scanResults: results));
    });

    try {
      // Start scan with 5-second timeout
      await _bleService.startScan(timeout: const Duration(seconds: 5));
      await FlutterBluePlus.isScanning.where((isScanning) => !isScanning).first;
      if (kDebugMode) {
        print('BleBloc: Scan completed');
      }
      emit(state.copyWith(isScanning: false));
    } catch (e) {
      if (kDebugMode) {
        print('BleBloc: Scan failed: $e');
      }
      emit(state.copyWith(errorMessage: 'Scan failed: $e', isScanning: false));
      scanResultsSubscription?.cancel();
    }
  }

  Future<void> _onStopScanRequested(StopScanRequested event, Emitter<BleAppState> emit) async {
    if (kDebugMode) {
      print('BleBloc: Stopping scan...');
    }
    await _bleService.stopScan();
    emit(state.copyWith(isScanning: false));
  }

  void _onDeviceSelected(DeviceSelected event, Emitter<BleAppState> emit) {
    if (kDebugMode) {
      print('BleBloc: Device selected: ${event.device.platformName}');
    }
    emit(state.copyWith(selectedDevice: event.device, errorMessage: null));
  }

  Future<void> _onConnectRequested(ConnectRequested event, Emitter<BleAppState> emit) async {
    if (kDebugMode) {
      print('BleBloc: Connecting to ${event.device.platformName}...');
    }
    emit(state.copyWith(isConnected: false, errorMessage: null));
    try {
      await _bleService.connectToDevice(event.device);
      if (kDebugMode) {
        print('BleBloc: Connected to ${event.device.platformName}');
      }
      emit(state.copyWith(
          selectedDevice: event.device, isConnected: true, errorMessage: null));
      _setupDeviceConnectionListener(event.device);
    } catch (e) {
      if (kDebugMode) {
        print('BleBloc: Connection failed: $e');
      }
      emit(state.copyWith(
          errorMessage: 'Connection failed: $e', isConnected: false));
    }
  }

  Future<void> _onDisconnectRequested(DisconnectRequested event, Emitter<BleAppState> emit) async {
    if (kDebugMode) {
      print('BleBloc: Disconnecting device...');
    }
    await _bleService.disconnectDevice();
    if (kDebugMode) {
      print('BleBloc: Device disconnected');
    }
    emit(state.copyWith(isConnected: false, errorMessage: null));
    _deviceConnectionSubscription?.cancel();
  }

  void _onDataReceived(DataReceived event, Emitter<BleAppState> emit) {
    if (kDebugMode) {
      print('BleBloc: Processing received data: ${event.data}');
    }
    String formattedData = event.data.map((val) => val.toStringAsFixed(2)).join(' | ');
    Message newMessage = Message(formattedData, 0);
    List<Message> newBuffer = List.from(state.buffer)..add(newMessage);
    if (newBuffer.length > 50) {
      newBuffer = newBuffer.sublist(newBuffer.length - 50);
    }
    emit(state.copyWith(buffer: newBuffer, errorMessage: null));
  }

  void _onBleError(BleError event, Emitter<BleAppState> emit) {
    if (kDebugMode) {
      print('BleBloc: Error occurred: ${event.message}');
    }
    emit(state.copyWith(errorMessage: event.message));
  }

  void _setupDeviceConnectionListener(BluetoothDevice device) {
    if (kDebugMode) {
      print('BleBloc: Setting up connection listener for ${device.platformName}');
    }
    _deviceConnectionSubscription?.cancel();
    _deviceConnectionSubscription = device.connectionState.listen((connectionState) {
      if (kDebugMode) {
        print('BleBloc: Device connection state changed to $connectionState');
      }
      if (connectionState == BluetoothConnectionState.disconnected) {
        add(DisconnectRequested());
      }
    });
  }

  Future<bool> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      bool bleScanGranted = await Permission.bluetoothScan.request().isGranted;
      bool bleConnectGranted = await Permission.bluetoothConnect.request().isGranted;
      bool locationGranted = await Permission.location.request().isGranted;
      if (kDebugMode) {
        print('BleBloc: Permissions - Scan: $bleScanGranted, Connect: $bleConnectGranted, Location: $locationGranted');
      }
      return bleScanGranted && bleConnectGranted && locationGranted;
    }

    return true;
  }

  @override
  Future<void> close() {
    if (kDebugMode) {
      print('BleBloc: Closing and cleaning up...');
    }
    _dataSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _deviceConnectionSubscription?.cancel();
    return super.close();
  }
}