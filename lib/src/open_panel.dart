import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:openpanel_flutter/src/constants/constants.dart';
import 'package:openpanel_flutter/src/models/open_panel_event_options.dart';
import 'package:openpanel_flutter/src/models/open_panel_options.dart';
import 'package:openpanel_flutter/src/models/open_panel_state.dart';
import 'package:openpanel_flutter/src/models/post_event_payload.dart';
import 'package:openpanel_flutter/src/models/update_profile_payload.dart';
import 'package:openpanel_flutter/src/services/openpanel_http_client.dart';
import 'package:openpanel_flutter/src/services/preferences_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Openpanel {
  static final Openpanel instance = Openpanel._internal();

  factory Openpanel() {
    return instance;
  }

  Openpanel._internal();

  final Logger _logger = Logger();

  late final OpenpanelOptions options;
  late final PreferencesService _preferencesService;

  late final OpenpanelHttpClient _httpClient;

  bool _isClientInitialised = false;

  OpenpanelState state = const OpenpanelState();

  Future<void> initialize({required OpenpanelOptions options}) async {
    if (_isClientInitialised) {
      return;
    }
    this.options = options;

    _preferencesService = PreferencesService(await SharedPreferences.getInstance());

    final OpenpanelState? savedState = await _preferencesService.getSavedState();
    if (savedState != null) {
      state = savedState;
    } else {
      final deviceData = await getTrackedDeviceData();
      if (deviceData.isNotEmpty) {
        setGlobalProperties(deviceData);
        state = state.copyWith(
          profileId: const Uuid().v4(),
          deviceId: deviceData['deviceId'] ?? const Uuid().v4(),
        );
      }

      _preferencesService.persistState(state);
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
    if (options.verbose) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }

    _httpClient = OpenpanelHttpClient(dio: dio, verbose: options.verbose, logger: _logger);

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

      _httpClient.increment(profileId: profileId, property: property, value: value);
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

      _httpClient.event(
        payload: PostEventPayload(
          name: name,
          timestamp: DateTime.timestamp().toIso8601String(),
          deviceId: state.deviceId,
          properties: {
            ...state.properties,
            ...properties..remove('profileId'),
          },
          profileId: profileId,
        ),
      );
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
    _preferencesService.persistState(state);
  }

  void _execute<T>(T Function() action) {
    if (!_isClientInitialised) {
      throw Exception('Openpanel is not initialised. You must initialize Openpanel before using Openpanel.instance.');
    }

    if (!state.isCollectionEnabled) {
      return;
    }

    action();

    _preferencesService.persistState(state);
  }

  Future<Map<String, dynamic>> getTrackedDeviceData() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    Map<String, dynamic> properties = {
      '__version': packageInfo.version,
      '__buildNumber': packageInfo.buildNumber,
      '__referrer': '',
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      properties.addAll({
        'deviceId': androidInfo.id,
        'brand': androidInfo.brand,
        'model': androidInfo.model,
        'device': androidInfo.isPhysicalDevice ? 'android' : 'android-emulator',
        'manufacturer': androidInfo.manufacturer,
        'osVersion': androidInfo.version.release,
      });
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      properties.addAll({
        'deviceId': iosDeviceInfo.identifierForVendor,
        'brand': 'iPhone',
        'device': iosDeviceInfo.isPhysicalDevice ? 'ios' : 'ios-simulator',
        'model': iosDeviceInfo.model,
        'osVersion': iosDeviceInfo.systemVersion,
      });
    }

    return properties;
  }
}
