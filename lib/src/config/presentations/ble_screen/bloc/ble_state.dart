// ble_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BleState extends Equatable {
  const BleState();

  @override
  List<Object?> get props => [];
}

class BleInitial extends BleState {}

class BleScanning extends BleState {}

class BleScanStopped extends BleState {}

class DeviceSelectedState extends BleState {
  final BluetoothDevice device;

  const DeviceSelectedState(this.device);

  @override
  List<Object?> get props => [device];
}

class BleConnecting extends BleState {}

class BleConnected extends BleState {
  final BluetoothDevice device;

  const BleConnected(this.device);

  @override
  List<Object?> get props => [device];
}

class BleDisconnected extends BleState {}

class BleDataAvailable extends BleState {
  final List<double> data;

  const BleDataAvailable(this.data);

  @override
  List<Object?> get props => [data];
}

class BleErrorState extends BleState {
  final String message;

  const BleErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
class BluetoothStateChange extends BleState{
  final BluetoothAdapterState state;
  const BluetoothStateChange(this.state);
  @override
  List<Object?> get props => [state];
}

class BleScanCompleted extends BleState {
  final List<ScanResult> results;
  
  BleScanCompleted(this.results);
  
  @override
  List<Object?> get props => [results];
}