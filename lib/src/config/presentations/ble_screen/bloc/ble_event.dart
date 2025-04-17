// ble_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BleEvent extends Equatable {
  const BleEvent();

  @override
  List<Object?> get props => [];
}

class BleInit extends BleEvent {}

class StartScanRequested extends BleEvent {}

class StopScanRequested extends BleEvent {}

class DeviceSelected extends BleEvent {
  final BluetoothDevice device;

  const DeviceSelected(this.device);

  @override
  List<Object?> get props => [device];
}

class ConnectRequested extends BleEvent {
  final BluetoothDevice device;

  const ConnectRequested(this.device);

  @override
  List<Object?> get props => [device];
}

class DisconnectRequested extends BleEvent {}

class DataReceived extends BleEvent {
  final List<double> data;

  const DataReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class BleError extends BleEvent {
  final String message;

  const BleError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdapterStateChanged extends BleEvent{
  final BluetoothAdapterState state;
  const AdapterStateChanged(this.state);
  @override
  List<Object?> get props => [state];
}