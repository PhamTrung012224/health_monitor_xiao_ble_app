import 'dart:async';

import 'package:capstone_mobile_app/src/config/models/services/ble_data_service.dart';
import 'package:capstone_mobile_app/src/config/presentations/ble_screen/bloc/ble_bloc.dart';
import 'package:capstone_mobile_app/src/config/presentations/ble_screen/bloc/ble_event.dart';
import 'package:capstone_mobile_app/src/config/presentations/ble_screen/bloc/ble_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:user_repository/user_repository.dart';

class StepCountCard extends StatefulWidget {
  const StepCountCard({super.key});

  @override
  State<StepCountCard> createState() => _StepCountCardState();
}

class _StepCountCardState extends State<StepCountCard> {
  final UserRepository _userRepository = FirebaseUserRepository();
  int _stepCount = 0;
  StreamSubscription?
      _stepCountSubscription; // Add this line to track subscription

  @override
  void initState() {
    super.initState();
    _setupStepCountListener();
  }

  // Add this dispose method to cancel subscription when widget is removed
  @override
  void dispose() {
    _stepCountSubscription?.cancel(); // Cancel subscription on dispose
    super.dispose();
  }

  void _setupStepCountListener() {
    // Store the subscription reference
    _stepCountSubscription = BleDataService().imuDataStream.listen((data) {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _stepCount = data.stepCount;
        });
      }
    });
  }

  // Save steps on disconnect
  Future<void> _saveSteps() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && _stepCount > 0) {
        await _userRepository.updateStepCount(currentUser.uid, _stepCount);
        if (kDebugMode) {
          print('Steps saved: $_stepCount');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving steps: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleBloc, BleAppState>(
      builder: (context, state) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Step Count',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildConnectionButton(context, state),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.directions_walk,
                        size: 48, color: Color(0xFF015164)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_stepCount',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('steps'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: (_stepCount / 10000).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _getColorForSteps(_stepCount)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.go('/pedometer');
                      },
                      child: const Text('View History'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionButton(BuildContext context, BleAppState state) {
    final bool isConnected = state.isConnected;

    return ElevatedButton.icon(
      icon: const Icon(Icons.bluetooth_connected),
      label: Text(isConnected ? 'Disconnect' : 'Connect'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isConnected ? Colors.red : const Color(0xFF015164),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: () {
        if (isConnected) {
          context.read<BleBloc>().add(DisconnectRequested());
        } else {
          context.go('/ble');
        }
      },
    );
  }

  Color _getColorForSteps(int steps) {
    if (steps >= 10000) return Colors.green;
    if (steps >= 7500) return Colors.blue;
    if (steps >= 5000) return Colors.orange;
    return Colors.red;
  }

  // String _getStatusText(int steps) {
  //   if (steps >= 10000) return 'Goal reached!';
  //   if (steps >= 7500) return 'Almost there!';
  //   if (steps >= 5000) return 'Halfway there';
  //   if (steps >= 2500) return 'Keep going';
  //   return 'Just starting';
  // }
}
