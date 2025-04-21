// ble_state.dart
import 'package:capstone_mobile_app/src/config/models/objects/ble_object.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BleState extends Equatable {
  const BleState();
  @override
  List<Object?> get props => [];
}

class BleAppState extends BleState {
  final BluetoothDevice? selectedDevice;
  final bool isConnected;
  final List<Message> buffer;
  final BluetoothAdapterState adapterState;
  final String? errorMessage;
  final bool isScanning;
  final List<ScanResult> scanResults;

  const BleAppState({
    this.selectedDevice,
    this.isConnected = false,
    this.buffer = const [],
    this.adapterState = BluetoothAdapterState.unknown,
    this.errorMessage,
    this.isScanning = false,
    this.scanResults = const [],
  });

  BleAppState copyWith({
    BluetoothDevice? selectedDevice,
    bool? isConnected,
    List<Message>? buffer,
    BluetoothAdapterState? adapterState,
    String? errorMessage,
    bool? isScanning,
    List<ScanResult>? scanResults,
  }) {
    return BleAppState(
      selectedDevice: selectedDevice ?? this.selectedDevice,
      isConnected: isConnected ?? this.isConnected,
      buffer: buffer ?? this.buffer,
      adapterState: adapterState ?? this.adapterState,
      errorMessage: errorMessage ?? this.errorMessage,
      isScanning: isScanning ?? this.isScanning,
      scanResults: scanResults ?? this.scanResults,
    );
  }

  @override
  List<Object?> get props => [
        selectedDevice,
        isConnected,
        buffer,
        adapterState,
        errorMessage,
        isScanning,
        scanResults,
      ];
}