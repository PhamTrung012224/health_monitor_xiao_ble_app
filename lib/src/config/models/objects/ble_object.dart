import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SelectedDevice {
  BluetoothDevice? device;
  int? state;

  SelectedDevice(this.device, this.state);
}

class Message {
  String? text;
  int? sender; // 0 for received, 1 for sent

  Message(this.text, this.sender);
}