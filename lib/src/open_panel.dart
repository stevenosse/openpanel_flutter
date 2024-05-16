import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:openpanel_flutter/src/constants/constants.dart';
import 'package:openpanel_flutter/src/models/open_panel_event_options.dart';
import 'package:openpanel_flutter/src/models/open_panel_options.dart';
import 'package:openpanel_flutter/src/models/open_panel_state.dart';
import 'package:openpanel_flutter/src/models/post_event_payload.dart';
import 'package:openpanel_flutter/src/models/tracked_device_data.dart';
import 'package:openpanel_flutter/src/models/update_profile_payload.dart';
import 'package:openpanel_flutter/src/network/openpanel_http_client.dart';
import 'package:package_info_plus/package_info_plus.dart';

// TODO: Setup logger
class Openpanel {
  static final Openpanel instance = Openpanel._internal();

  factory Openpanel() {
    return instance;
  }

  Openpanel._internal();

  late final OpenpanelOptions options;

  late final OpenpanelHttpClient _httpClient;

  bool _isClientInitialised = false;

  OpenpanelState state = const OpenpanelState();

  Future<void> initialize({required OpenpanelOptions options}) async {
    this.options = options;

    // TODO: Store state properties locally
    final deviceData = await getTrackedDeviceData();
    if (deviceData != null) {
      setGlobalProperties(deviceData.toJson());
    }

    // HTTP CLient
    final dio = Dio(
      BaseOptions(
        baseUrl: options.url ?? kDefaultBaseUrl,
        headers: {
          'openpanel-client-id': options.clientId,
          if (options.clientSecret != null) 'openpanel-client-secret': options.clientSecret,
          'User-Agent': Platform.operatingSystem,
        },
      ),
    );
    dio.interceptors.add(RetryInterceptor(dio: dio));
    _httpClient = OpenpanelHttpClient(
      dio: dio,
      verbose: options.verbose,
    );

    _isClientInitialised = true;
  }

  void setCollectionEnabled(bool enabled) => state = state.copyWith(isCollectionEnabled: enabled);

  void setProfileId(String profileId) => state = state.copyWith(profileId: profileId);

  void updateProfile({required UpdateProfilePayload payload}) {
    _execute(() {
      setProfileId(payload.profileId);
      _httpClient.updateProfile(
        payload: payload,
        stateProperties: state.properties,
      );
    });
  }

  void increment({required String property, required int value, OpenpanelEventOptions? eventOptions}) {
    _execute(() {
      final profileId = eventOptions?.profileId ?? state.profileId;
      if (profileId == null) {
        log('No profile id found');
        return;
      }

      _httpClient.increment(
        profileId: profileId,
        property: property,
        value: value,
      );
    });
  }

  void decrement({required String property, required int value, OpenpanelEventOptions? eventOptions}) {
    _execute(() {
      final profileId = eventOptions?.profileId ?? state.profileId;
      if (profileId == null) {
        log('No profile id found');
        return;
      }

      _httpClient.decrement(
        profileId: profileId,
        property: property,
        value: value,
      );
    });
  }

  void event({required String name, Map<String, dynamic> properties = const {}}) {
    _execute(() async {
      final profileId = properties['profileId'] ?? state.profileId;

      final deviceId = await _httpClient.event(
        payload: PostEventPayload(
          name: name,
          timestamp: DateTime.timestamp().toIso8601String(),
          deviceId: state.deviceId,
          properties: properties..remove('profileId'),
          profileId: profileId,
        ),
      );

      if (deviceId != null) {
        state = state.copyWith(deviceId: deviceId);
      }
    });
  }

  void setGlobalProperties(Map<String, dynamic> properties) {
    state = state.copyWith(properties: {
      ...state.properties,
      ...properties,
    });
  }

  void clear() {
    state = const OpenpanelState();
  }

  void _execute<T>(T Function() action) {
    if (!_isClientInitialised) {
      throw Exception('You need to call Openpanel.init(...) first.');
    }

    if (!state.isCollectionEnabled) {
      return;
    }

    action();
  }

  Future<TrackedDeviceData?> getTrackedDeviceData() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _getAndroidDeviceData(packageInfo, deviceInfo),
      TargetPlatform.iOS => _getIOSDeviceData(packageInfo, deviceInfo),
      _ => null,
    };
  }

  Future<TrackedDeviceData> _getAndroidDeviceData(PackageInfo packageInfo, DeviceInfoPlugin deviceInfo) async {
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    return TrackedDeviceData(
      deviceId: androidInfo.id,
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      os: 'android',
    );
  }

  Future<TrackedDeviceData> _getIOSDeviceData(PackageInfo packageInfo, DeviceInfoPlugin deviceInfo) async {
    final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    return TrackedDeviceData(
      deviceId: iosDeviceInfo.identifierForVendor ?? '',
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      os: 'iOS',
    );
  }
}
