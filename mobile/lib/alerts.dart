import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'nearby_policy.dart';

class Alerts {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _policy = const NearbyPolicy();
  bool enabled = false, _ready = false;
  void Function(String)? onTap;
  String? pending;
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  Future<void> initialize() async {
    if (!supported || _ready) return;
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload != null) {
          if (onTap != null) {
            onTap!(r.payload!);
          } else {
            pending = r.payload;
          }
        }
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      pending = launch?.notificationResponse?.payload;
    }
    _ready = true;
  }

  Future<bool> enable() async {
    if (!supported) return false;
    await initialize();
    final android = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    enabled = android ?? ios ?? false;
    return enabled;
  }

  Future<void> check(List<Place> places, String userId) async {
    if (!enabled) return;
    final prefs = await SharedPreferences.getInstance(), now = DateTime.now();
    for (final p in places) {
      final key = 'alert.$userId.${p.id}',
          last = prefs.getInt('alert.$userId.${p.id}');
      if (!_policy.shouldNotify(
        distance: p.distance ?? double.infinity,
        now: now,
        last: last == null ? null : DateTime.fromMillisecondsSinceEpoch(last),
      )) {
        continue;
      }
      await _plugin.show(
        p.id.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff),
        'Tem uma descoberta perto de você',
        '${p.name} está a ${p.distanceLabel}.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nearby',
            'Locais próximos',
            channelDescription: 'Descobertas durante o uso do aplicativo',
            importance: Importance.defaultImportance,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: p.id,
      );
      await prefs.setInt(key, now.millisecondsSinceEpoch);
      break; // No máximo um alerta por atualização de posição.
    }
  }

  Future<void> clear() async {
    enabled = false;
    if (_ready) await _plugin.cancelAll();
  }
}
