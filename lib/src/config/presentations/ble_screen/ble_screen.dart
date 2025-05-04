import 'package:capstone_mobile_app/src/config/presentations/ble_screen/bloc/ble_bloc.dart';
import 'package:capstone_mobile_app/src/config/presentations/ble_screen/bloc/ble_event.dart';
import 'package:capstone_mobile_app/src/config/presentations/ble_screen/bloc/ble_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_mobile_app/src/config/models/objects/ble_object.dart';

class BleScreen extends StatelessWidget {
  const BleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleBloc, BleAppState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('BLE Communication'),
            backgroundColor: const Color(0xFF015164),
            leading: GestureDetector(
              onTap: () => context.go('/'),
              child: const Icon(Icons.arrow_back),
            ),
          ),
          body: Column(
            children: [
              // Device selection and connection
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.isScanning
                            ? null
                            : () async {
                          // Trigger auto-scan
                          context.read<BleBloc>().add(StartScanRequested());
                          final result = await context
                              .push<SelectedDevice>('/select_device');
                          if (result != null) {
                            context
                                .read<BleBloc>()
                                .add(DeviceSelected(result.device!));
                            if (result.state == 1) {
                              context.read<BleBloc>().add(
                                  ConnectRequested(result.device!));
                            }
                          }
                          // Stop scan after selection
                          context.read<BleBloc>().add(StopScanRequested());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF015164),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          state.isScanning ? 'Scanning...' : 'Select Device',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.selectedDevice == null
                            ? null
                            : (state.isConnected
                            ? () => context
                            .read<BleBloc>()
                            .add(DisconnectRequested())
                            : () => context.read<BleBloc>().add(
                            ConnectRequested(state.selectedDevice!))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.isConnected
                              ? Colors.red
                              : (state.selectedDevice == null
                              ? Colors.grey
                              : Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          state.isConnected ? 'Disconnect' : 'Connect',
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
                      state.selectedDevice == null
                          ? 'No device selected'
                          : (state.isConnected
                          ? 'Connected to ${state.selectedDevice!.platformName}'
                          : 'Disconnected'),
                      style: TextStyle(
                        fontSize: 16,
                        color: state.isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              // Error message display
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              // Data display
              Expanded(
                child: state.buffer.isEmpty
                    ? const Center(child: Text('No data received yet'))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.buffer.length,
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
                              state.buffer[index].sender == 0
                                  ? 'Received Data:'
                                  : 'Sent:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: state.buffer[index].sender == 0
                                    ? Colors.blue
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.buffer[index].text ?? '',
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
              if (state.isConnected)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Send data to device...',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              // Placeholder: Actual send functionality requires BleService modification
                              context.read<BleBloc>().add(
                                  DataReceived([double.parse(value)]));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Send functionality to be implemented in BleService
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

class SelectBluetoothDevice extends StatelessWidget {
  const SelectBluetoothDevice({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleBloc, BleAppState>(
      builder: (context, state) {
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
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No connected devices'),
                      );
                    }
                    return Column(
                      children: snapshot.data!
                          .map(
                            (d) => Column(
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
                                      context
                                          .read<BleBloc>()
                                          .add(DeviceSelected(d));
                                      context.pop(SelectedDevice(d, connected ? 1 : 0));
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
                        ),
                      )
                          .toList(),
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
                SizedBox(
                  height: 400,
                  child: state.isScanning && state.scanResults.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Scanning for devices...',
                            style: TextStyle(fontSize: 16))
                      ],
                    ),
                  )
                      : state.scanResults.isEmpty
                      ? const Center(
                    child: Text(
                      'No devices found.\nMake sure your device is powered on and in range.',
                      textAlign: TextAlign.center,
                    ),
                  )
                      : ListView.builder(
                    itemCount: state.scanResults.length,
                    itemBuilder: (context, index) {
                      final result = state.scanResults[index];
                      if (result.device.platformName.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          ListTile(
                            title: Text(result.device.platformName),
                            subtitle: Text(
                                '${result.device.remoteId}\nRSSI: ${result.rssi} dBm'),
                            leading:
                            const Icon(Icons.bluetooth_searching),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(8)),
                                  side:
                                  BorderSide(color: Colors.orange),
                                ),
                              ),
                              onPressed: () {
                                context.read<BleBloc>().add(
                                    DeviceSelected(result.device));
                                context.pop(
                                    SelectedDevice(result.device, 0));
                              },
                              child: const Text('Connect'),
                            ),
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (state.isScanning) {
                context.read<BleBloc>().add(StopScanRequested());
              } else {
                context.read<BleBloc>().add(StartScanRequested());
              }
            },
            backgroundColor: Colors.white,
            child: Icon(
              state.isScanning ? Icons.stop : Icons.search,
              color: state.isScanning ? Colors.red : Colors.blue,
            ),
          ),
        );
      },
    );
  }
}