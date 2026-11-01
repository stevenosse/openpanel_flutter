import 'package:flutter/services.dart';
import 'package:openpanel_flutter/src/constants/constants.dart';
import 'package:openpanel_flutter/src/models/open_panel_options.dart';
import 'package:openpanel_flutter/src/models/update_profile_payload.dart';
import 'package:openpanel_flutter/src/services/openpanel_backend.dart';

/// An [OpenpanelBackend] that delegates to the official native SDKs.
///
/// On Android it calls the OpenPanel Kotlin SDK. On iOS it calls the OpenPanel
/// Swift SDK.
class MethodChannelOpenpanelBackend implements OpenpanelBackend {
  MethodChannelOpenpanelBackend({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(kOpenpanelMethodChannel);

  final MethodChannel _channel;

  @override
  Future<void> initialize(OpenpanelOptions options) {
    return _invoke('initialize', {
      'clientId': options.clientId,
      'clientSecret': options.clientSecret,
      'apiUrl': options.apiUrl,
      'verbose': options.verbose,
      'disabled': options.disabled,
      'automaticTracking': options.automaticTracking,
      'waitForProfile': options.waitForProfile,
    });
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) {
    return _invoke('setCollectionEnabled', {'enabled': enabled});
  }

  @override
  Future<void> track({
    required String name,
    required Map<String, dynamic> properties,
    String? profileId,
  }) {
    return _invoke('track', {
      'name': name,
      'properties': _sanitizeMap(properties),
      if (profileId != null) 'profileId': profileId,
    });
  }

  @override
  Future<void> identify(UpdateProfilePayload payload) {
    return _invoke('identify', {
      'profileId': payload.profileId,
      'firstName': payload.firstName,
      'lastName': payload.lastName,
      'email': payload.email,
      'avatar': payload.avatar,
      'properties': _sanitizeMap(payload.properties),
    });
  }

  @override
  Future<void> increment({
    required String profileId,
    required String property,
    required int value,
  }) {
    return _invoke('increment', {
      'profileId': profileId,
      'property': property,
      'value': value,
    });
  }

  @override
  Future<void> decrement({
    required String profileId,
    required String property,
    required int value,
  }) {
    return _invoke('decrement', {
      'profileId': profileId,
      'property': property,
      'value': value,
    });
  }

  @override
  Future<void> alias({
    required String profileId,
    required String alias,
  }) {
    return _invoke('alias', {
      'profileId': profileId,
      'alias': alias,
    });
  }

  @override
  Future<void> setGlobalProperties(Map<String, dynamic> properties) {
    return _invoke('setGlobalProperties', {
      'properties': _sanitizeMap(properties),
    });
  }

  @override
  Future<void> setProfileId(String profileId) {
    return _invoke('setProfileId', {'profileId': profileId});
  }

  @override
  Future<void> clear() => _invoke('clear');

  @override
  Future<void> flush() => _invoke('flush');

  @override
  Future<void> ready() => _invoke('ready');

  Future<void> _invoke(String method, [Map<String, dynamic>? arguments]) {
    return _channel.invokeMethod<void>(method, arguments);
  }

  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> input) {
    final result = <String, dynamic>{};
    for (final entry in input.entries) {
      final value = _sanitizeValue(entry.value);
      if (value != null) {
        result[entry.key] = value;
      }
    }
    return result;
  }

  static dynamic _sanitizeValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String || value is num || value is bool) {
      return value;
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        if (entry.key is! String) {
          continue;
        }
        final sanitized = _sanitizeValue(entry.value);
        if (sanitized != null) {
          result[entry.key as String] = sanitized;
        }
      }
      return result;
    }
    if (value is Iterable) {
      return value
          .map(_sanitizeValue)
          .where((element) => element != null)
          .toList(growable: false);
    }
    return value.toString();
  }
}
