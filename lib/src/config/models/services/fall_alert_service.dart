import 'dart:async';
import 'package:capstone_mobile_app/src/config/models/services/ble_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

class FallAlertService {
  // Singleton pattern
  static final FallAlertService _instance = FallAlertService._internal();
  factory FallAlertService() => _instance;

  // Audio player for alarm sound
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Notification plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Alert state
  bool isAlertActive = false;
  Timer? _escalationTimer;

  // Create a stream to notify UI about alert status changes
  final StreamController<bool> _alertStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get alertStatusStream => _alertStatusController.stream;

  FallAlertService._internal() {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.actionId == 'CANCEL_ALERT') {
      cancelAlert();
    }
  }

  Future<void> triggerFallAlert() async {
    if (isAlertActive) return; // Don't trigger if already active

    isAlertActive = true;
    _alertStatusController.add(true);

    if (kDebugMode) {
      print("Fall alert triggered!");
    }

    bool isMuted = await VolumeController.instance.isMuted();
    if (isMuted) {
      await VolumeController.instance.setMute(false);
    }

    // Start with a gentle alert
    await VolumeController.instance.setVolume(1);
    await _playLowAlert();

    // Schedule escalation ONLY if initial setup succeeded
    _escalationTimer = Timer(const Duration(seconds: 20), () async {
      if (isAlertActive) {
        await _playHighAlert();
      }
    });

    // Show notification with cancel action
    await _showAlertNotification();
  }

  Future<void> _playLowAlert() async {
    try {
      // Vibrate phone with pattern
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(
            duration: 20000, pattern: [500, 750, 1000, 750, 500, 1000]);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error playing alert sound: $e");
      }
    }
  }

  // Update the high alert method similarly
  Future<void> _playHighAlert() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset('assets/sounds/fall_alert_high.mp3');
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.play();
    } catch (e) {
      print("Error playing HIGH alert sound: $e"); // Ensure errors are printed
    }
  }

  Future<void> _showAlertNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'fall_detection_channel',
      'Fall Detection Alerts',
      channelDescription: 'Notifications for fall detection alerts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Fall detected',
      ongoing: true,
      autoCancel: false,
      fullScreenIntent: true,
      actions: [
        AndroidNotificationAction(
          'CANCEL_ALERT',
          'I\'m OK',
          showsUserInterface: true,
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Fall Detected!',
      'Are you okay? Tap "I\'m OK" to cancel the alert.',
      notificationDetails,
    );
  }

  Future<void> cancelAlert() async {
    if (!isAlertActive) return;

    isAlertActive = false;
    _alertStatusController.add(false);

    // Cancel the escalation timer if it's active
    _escalationTimer?.cancel();

    // Stop audio and vibration
    try {
      await _audioPlayer.stop();
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.cancel();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error stopping audio/vibration: $e");
      }
    }

    // Cancel notification
    await _notificationsPlugin.cancel(0);

    // Write value 1 to fall reset characteristic
    bool writeSuccess = await BleService().writeFallResetValue();

    if (kDebugMode) {
      if (writeSuccess) {
        print("Fall alert canceled and reset command sent to device");
      } else {
        print("Fall alert canceled but reset command failed");
      }
    }
  }
}
