import 'dart:async';
import 'dart:typed_data';
import 'package:capstone_mobile_app/src/config/models/objects/ble_object.dart';
import 'package:capstone_mobile_app/src/config/models/services/ble_data_service.dart';
import 'package:capstone_mobile_app/src/config/models/services/ble_service.dart';
import 'package:capstone_mobile_app/src/config/presentations/ble_screen/bloc/ble_bloc.dart';
import 'package:capstone_mobile_app/src/config/presentations/ble_screen/bloc/ble_event.dart';
import 'package:capstone_mobile_app/src/config/presentations/ble_screen/bloc/ble_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BleScreen extends StatefulWidget {
  const BleScreen({Key? key}) : super(key: key);

  @override
  State<BleScreen> createState() => _BleScreenState();
}

class _BleScreenState extends State<BleScreen> {
  bool connectionStatus = false;
  BluetoothDevice? selectedDevice;
  List<Message> buffer = [];
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription? _dataSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize the BLE bloc
    context.read<BleBloc>().add(BleInit());

    // Listen for data updates
    _subscribeToDataUpdates();
  }

  void _subscribeToDataUpdates() {
    _dataSubscription?.cancel();
    _dataSubscription = BleService().dataStream.listen((data) {
      if (data.isNotEmpty && mounted) {
        if (kDebugMode) {
          print("BleScreen received data: ${data.join(', ')}");
        }
        setState(() {
          // Format values for display
          String formattedValues =
              data.map((val) => val.toStringAsFixed(2)).join(' | ');
          buffer.add(Message(formattedValues, 0));

          // Limit buffer size
          if (buffer.length > 50) {
            buffer = buffer.sublist(buffer.length - 50);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {
        if (state is BleErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is BleConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connected to device')),
          );
        } else if (state is BleDisconnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Disconnected from device')),
          );
        }
      },
      builder: (context, state) {
        BluetoothDevice? connectedDevice;
        BluetoothAdapterState bleState = BluetoothAdapterState.unknown;

        if (state is BleConnected) {
          connectedDevice = state.device;
        }
        if (state is BluetoothStateChange) {
          bleState = state.state;
        }
        if (state is DeviceSelectedState) {
          selectedDevice = state.device;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('BLE Communication'),
            backgroundColor: const Color(0xFF015164),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<BleBloc>().add(BleInit());
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Bluetooth status toggle
              SizedBox(
                height: 50,
                child: SwitchListTile(
                  activeColor: const Color(0xFF015164),
                  activeTrackColor: const Color(0xFF0291B5),
                  inactiveTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.white,
                  title: const Text('Activate Bluetooth',
                      style: TextStyle(fontSize: 16)),
                  value: bleState == BluetoothAdapterState.on,
                  onChanged: (bool value) {
                    if (value) {
                      FlutterBluePlus.turnOn();
                    } else {
                      FlutterBluePlus.turnOff();
                    }
                  },
                ),
              ),

              // Device selection and connection
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Start scan before navigating
                          context.read<BleBloc>().add(StartScanRequested());

                          final SelectedDevice? poppedDevice =
                              await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SelectBluetoothDevice(),
                            ),
                          );

                          if (poppedDevice != null) {
                            setState(() {
                              selectedDevice = poppedDevice.device;
                              context
                                  .read<BleBloc>()
                                  .add(DeviceSelected(poppedDevice.device!));
                              connectionStatus = poppedDevice.state == 1;
                            });
                          }

                          // Stop scan after selection
                          context.read<BleBloc>().add(StopScanRequested());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF015164),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Select Device',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedDevice == null
                            ? null
                            : (state is BleConnected
                                ? () => context
                                    .read<BleBloc>()
                                    .add(DisconnectRequested())
                                : () {
                                    if (selectedDevice != null) {
                                      context.read<BleBloc>().add(
                                          ConnectRequested(selectedDevice!));
                                    }
                                  }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state is BleConnected
                              ? Colors.red
                              : (selectedDevice == null
                                  ? Colors.grey
                                  : Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          state is BleConnected ? "Disconnect" : "Connect",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Connection status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text('Status: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      selectedDevice == null
                          ? 'No device selected'
                          : (state is BleConnected
                              ? 'Connected to ${connectedDevice!.platformName}'
                              : 'Disconnected'),
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            state is BleConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // Data display
              Expanded(
                child: buffer.isEmpty
                    ? const Center(child: Text('No data received yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: buffer.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    buffer[index].sender == 0
                                        ? "Received Data:"
                                        : "Sent:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: buffer[index].sender == 0
                                          ? Colors.blue
                                          : Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    buffer[index].text ?? "",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Send message field
              if (state is BleConnected)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Send data to device...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Implement send functionality
                          if (_messageController.text.isNotEmpty) {
                            setState(() {
                              buffer.add(Message(_messageController.text, 1));
                            });
                            // Send data logic would go here
                            _messageController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF015164),
                        ),
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Device selection screen
class SelectBluetoothDevice extends StatelessWidget {
  const SelectBluetoothDevice({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleBloc, BleState>(
      builder: (context, state) {
        bool isScanning = state is BleScanning;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Select BLE Device'),
            backgroundColor: const Color(0xFF015164),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Connected devices section
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Connected Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF015164),
                    ),
                  ),
                ),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(const Duration(seconds: 10))
                      .asyncMap((_) => FlutterBluePlus.systemDevices([])),
                  initialData: const [],
                  builder: (c, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No connected devices'),
                      );
                    }

                    return Column(
                      children: snapshot.data!.map((d) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(d.platformName),
                              subtitle: Text(d.remoteId.toString()),
                              leading: const Icon(Icons.devices),
                              trailing: StreamBuilder<BluetoothConnectionState>(
                                stream: d.connectionState,
                                initialData:
                                    BluetoothConnectionState.disconnected,
                                builder: (c, snapshot) {
                                  bool connected = snapshot.data ==
                                      BluetoothConnectionState.connected;
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: connected
                                                ? Colors.green
                                                : Colors.red),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(SelectedDevice(d, 1));
                                    },
                                    child: Text(
                                      'Select',
                                      style: TextStyle(
                                          color: connected
                                              ? Colors.green
                                              : Colors.red),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),

                // Scan results section
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Available Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF015164),
                    ),
                  ),
                ),
                StreamBuilder<List<ScanResult>>(
                  stream: FlutterBluePlus.scanResults,
                  initialData: const [],
                  builder: (c, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    List<ScanResult> scanResults = snapshot.data ?? [];
                    if (kDebugMode && scanResults.isNotEmpty) {
                      print("UI showing ${scanResults.length} scan results");
                    }

                    // Filter for devices with names
                    List<ScanResult> validResults = scanResults
                        .where(
                            (element) => element.device.platformName.isNotEmpty)
                        .toList();

                    return SizedBox(
                      height: 400,
                      child: isScanning && validResults.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text("Scanning for devices...",
                                      style: TextStyle(fontSize: 16))
                                ],
                              ),
                            )
                          : validResults.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No devices found.\nMake sure your device is powered on and in range.',
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: validResults.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Text(validResults[index]
                                              .device
                                              .platformName),
                                          subtitle: Text(
                                              "${validResults[index].device.remoteId}\n"
                                              "RSSI: ${validResults[index].rssi} dBm"),
                                          leading: const Icon(
                                              Icons.bluetooth_searching),
                                          trailing: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                side: BorderSide(
                                                    color: Colors.orange),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop(
                                                SelectedDevice(
                                                    validResults[index].device,
                                                    0),
                                              );
                                            },
                                            child: const Text("Connect"),
                                          ),
                                        ),
                                        const Divider(),
                                      ],
                                    );
                                  },
                                ),
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (isScanning) {
                context.read<BleBloc>().add(StopScanRequested());
              } else {
                context.read<BleBloc>().add(StartScanRequested());
              }
            },
            backgroundColor: Colors.white,
            child: Icon(
              isScanning ? Icons.stop : Icons.search,
              color: isScanning ? Colors.red : Colors.blue,
            ),
          ),
        );
      },
    );
  }
}
