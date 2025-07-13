import 'dart:async';

import 'package:capstone_mobile_app/src/config/components/step_count_card.dart';
import 'package:capstone_mobile_app/src/config/components/ui_icon.dart';
import 'package:capstone_mobile_app/src/config/constants/constants.dart';
import 'package:capstone_mobile_app/src/config/models/services/ble_data_service.dart';
import 'package:capstone_mobile_app/src/config/models/services/fall_alert_service.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_in_screen/sign_in_bloc/sign_in_bloc.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_in_screen/sign_in_bloc/sign_in_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  BuildContext? _context;
  ColorScheme? _colorScheme;
  // bool isDarkMode = false;
  bool _isLoadingLogOut = false;
  // Add to maintain subscription
  StreamSubscription<IMUData>? _dataSubscription;
  // Add IMU data variable
  IMUData _imuData = IMUData();

  @override
  void initState() {
    super.initState();
    _context = context;
    _setupDataSubscription();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor:
            Colors.transparent // Set the navigation bar color to transparent
        ));
  }

  @override
  void didChangeDependencies() {
    // isDarkMode = (Theme.of(context).brightness == Brightness.dark);

    _colorScheme = Theme.of(context).colorScheme;
    super.didChangeDependencies();
  }

  void _setupDataSubscription() {
    _dataSubscription?.cancel();

    // Create a new subscription
    _dataSubscription = BleDataService().imuDataStream.listen((data) {
      if (mounted) {
        setState(() {
          _imuData = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          color: _colorScheme!.background,
        ),
        CustomScrollView(
          slivers: [
            SliverAppBar(
              toolbarHeight: 70,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      context.go('/ble');
                    },
                    child: const UIIcon(
                        size: 32,
                        icon: IconConstants.bluetoothIcon,
                        color: Colors.white),
                  ),
                  GestureDetector(
                      onTap: () async {
                        setState(() {
                          _isLoadingLogOut = true;
                        });
                        _context!.read<SignInBloc>().add(SignOutRequired());
                        setState(() {
                          _isLoadingLogOut = false;
                        });
                      },
                      child: const UIIcon(
                          size: 32,
                          icon: IconConstants.logoutIcon,
                          color: Colors.white)),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Center(
                    child: Text(
                  "IMU Data Dashboard",
                  style: TextStyleConstants.tabBarTitle,
                )),
              ),
              pinned: true,
              backgroundColor: _colorScheme!.tertiaryContainer,
              expandedHeight: MediaQuery.of(context).size.height * 0.24,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  "assets/images/background.jpg",
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const StepCountCard(),
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Fall Detection',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  UIIcon(
                                    size: 32,
                                    icon: IconConstants.fallingIcon,
                                    color: Color(0xFF015164),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: _imuData.fallDetected
                                        ? Colors.red
                                        : Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _imuData.fallDetected
                                        ? 'Fall Detected!'
                                        : 'No Fall Detected',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Last monitored: ${DateTime.now().hour}:${DateTime.now().minute}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        StreamBuilder<bool>(
          stream: FallAlertService().alertStatusStream,
          initialData: FallAlertService().isAlertActive,
          builder: (context, snapshot) {
            final isAlertActive = snapshot.data ?? false;

            return isAlertActive
                ? Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.red.shade800,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'FALL DETECTED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Are you okay?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                FallAlertService().cancelAlert();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'I\'M OKAY - CANCEL ALERT',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
        _isLoadingLogOut
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: _colorScheme!.primary, size: 90),
              )
            : const SizedBox()
      ],
    );
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _context = null;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
