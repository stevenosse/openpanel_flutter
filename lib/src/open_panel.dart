// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart' show MissingPluginException;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:openpanel_flutter/src/models/open_panel_event_options.dart';
import 'package:openpanel_flutter/src/models/open_panel_options.dart';
import 'package:openpanel_flutter/src/models/open_panel_state.dart';
import 'package:openpanel_flutter/src/models/update_profile_payload.dart';
import 'package:openpanel_flutter/src/observers/referrer_observer.dart';
import 'package:openpanel_flutter/src/services/method_channel_openpanel_backend.dart';
import 'package:openpanel_flutter/src/services/openpanel_backend.dart';
import 'package:openpanel_flutter/src/services/preferences_service.dart';

/// OpenPanel analytics for Flutter.
///
/// This package is a wrapper around the official OpenPanel Kotlin and Swift
/// SDKs. Android events are sent by the Kotlin SDK and iOS events are sent by
/// the Swift SDK.
///
/// Example:
/// ```dart
/// await Openpanel.instance.initialize(
///   options: OpenpanelOptions(clientId: '<YOUR_CLIENT_ID>'),
/// );
///
/// Openpanel.instance.track(
///   name: 'button_clicked',
///   properties: {'button_id': 'submit_form'},
/// );
/// ```
class Openpanel {
  /// The shared OpenPanel instance.
  static final Openpanel instance = Openpanel._internal();

  factory Openpanel() => instance;

  Openpanel._internal()
    : _backend = MethodChannelOpenpanelBackend(),
      _providedPreferencesService = null;

  /// Creates an isolated instance for tests.
  @visibleForTesting
  Openpanel.forTesting({
    required OpenpanelBackend backend,
    required PreferencesService preferencesService,
    OpenpanelOptions? options,
    OpenpanelState state = const OpenpanelState(profileId: 'test-profile'),
    bool isInitialised = true,
  }) : _backend = backend,
       _providedPreferencesService = preferencesService,
       _state = state,
       _isClientInitialised = isInitialised {
    if (isInitialised) {
      this.options = options ?? OpenpanelOptions(clientId: 'test-client-id');
      _preferencesService = preferencesService;
    }
  }

  late final OpenpanelOptions options;
  final PreferencesService? _providedPreferencesService;
  late final PreferencesService _preferencesService;
  final OpenpanelBackend _backend;

  bool _isClientInitialised = false;

  /// Whether the OpenPanel client has been initialized.
  bool get isInitialised => _isClientInitialised;

  OpenpanelState _state = const OpenpanelState();

  /// Initializes OpenPanel.
  ///
  /// This must be called before using the SDK.
  ///
  /// ```dart
  /// await Openpanel.instance.initialize(
  ///   options: OpenpanelOptions(
  ///     clientId: '<YOUR_CLIENT_ID>',
  ///     clientSecret: '<YOUR_CLIENT_SECRET>',
  ///   ),
  /// );
  /// ```
  Future<void> initialize({required OpenpanelOptions options}) async {
    if (_isClientInitialised) {
      return;
    }

    this.options = options;
    WidgetsFlutterBinding.ensureInitialized();

    _preferencesService =
        _providedPreferencesService ??
        PreferencesService(await SharedPreferences.getInstance());

    final savedState = await _preferencesService.getSavedState();
    if (savedState != null) {
      _state = options.disabled
          ? savedState.copyWith(isCollectionEnabled: false)
          : savedState;
    } else {
      final rate = options.tracingSampleRate.clamp(0.0, 1.0);
      final sampled = rate >= 1.0 || Random().nextDouble() < rate;

      _state = OpenpanelState(
        profileId: const Uuid().v4(),
        properties: _state.properties,
        isCollectionEnabled: !options.disabled,
        isTracingSampled: sampled,
      );
      await _preferencesService.persistState(_state);
    }

    // The native SDKs are the only transport. On unsupported platforms the
    // method channel is unavailable and there is no Dart fallback.
    try {
      await _backend.initialize(
        options.copyWith(
          disabled: !_state.isCollectionEnabled || !_state.isTracingSampled,
        ),
      );
    } on MissingPluginException {
      throw UnsupportedError(
        'openpanel_flutter only supports Android and iOS. '
        'The native OpenPanel SDK is not available on this platform.',
      );
    }

    // Older versions of this package stored device data as global properties.
    // The native SDKs collect this information themselves, so remove the old
    // keys before restoring the persisted properties.
    final filtered = Map<String, dynamic>.of(_state.properties)
      ..removeWhere((key, _) => _legacyDevicePropertyKeys.contains(key));
    if (filtered.length != _state.properties.length) {
      _state = _state.copyWith(properties: filtered);
      await _preferencesService.persistState(_state);
    }

    if (_state.properties.isNotEmpty) {
      await _backend.setGlobalProperties(_state.properties);
    }
    if (_currentProfileId != null) {
      // The native SDKs ignore events while they are disabled, but they still
      // keep the profile id in memory.
      await _backend.setProfileId(_currentProfileId!);
    }

    _isClientInitialised = true;

    WidgetsBinding.instance.addObserver(ReferrerObserver());
  }

  /// Enables or disables event collection.
  ///
  /// Collection is enabled by default. This only affects events sent through
  /// this SDK; it can be changed at runtime.
  void setCollectionEnabled(bool enabled) {
    _ensureInitialised();
    _state = _state.copyWith(isCollectionEnabled: enabled);

    final nativeEnabled = enabled && _state.isTracingSampled;
    unawaited(_runSafely(() => _backend.setCollectionEnabled(nativeEnabled)));
  }

  /// Sets the current profile id.
  ///
  /// Profile ids are automatically generated on first launch. Use this method
  /// to associate events with your own user id.
  void setProfileId(String profileId) {
    _ensureInitialised();
    _state = _state.copyWith(profileId: profileId, isProfileIdentified: true);

    unawaited(_runSafely(() => _backend.setProfileId(profileId)));
  }

  /// Updates an existing profile.
  ///
  /// Prefer [identify] for new code.
  void updateProfile({required UpdateProfilePayload payload}) {
    identify(
      profileId: payload.profileId,
      firstName: payload.firstName,
      lastName: payload.lastName,
      email: payload.email,
      avatar: payload.avatar,
      properties: payload.properties,
    );
  }

  /// Creates or updates a profile.
  ///
  /// ```dart
  /// Openpanel.instance.identify(
  ///   profileId: 'user-123',
  ///   firstName: 'John',
  ///   lastName: 'Doe',
  ///   email: 'john@example.com',
  ///   properties: {'plan': 'premium'},
  /// );
  /// ```
  void identify({
    required String profileId,
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
    Map<String, dynamic> properties = const {},
  }) {
    _ensureInitialised();
    _state = _state.copyWith(profileId: profileId, isProfileIdentified: true);

    unawaited(
      _runSafely(
        () => _backend.identify(
          UpdateProfilePayload(
            profileId: profileId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            avatar: avatar,
            properties: properties,
          ),
        ),
      ),
    );
  }

  /// Increments a numeric profile property.
  void increment({
    required String property,
    required int value,
    OpenpanelEventOptions? eventOptions,
  }) {
    _execute(() {
      final profileId = eventOptions?.profileId ?? _currentProfileId;
      if (profileId != null) {
        return _backend.increment(
          profileId: profileId,
          property: property,
          value: value,
        );
      }
    });
  }

  /// Decrements a numeric profile property.
  void decrement({
    required String property,
    required int value,
    OpenpanelEventOptions? eventOptions,
  }) {
    _execute(() {
      final profileId = eventOptions?.profileId ?? _currentProfileId;
      if (profileId != null) {
        return _backend.decrement(
          profileId: profileId,
          property: property,
          value: value,
        );
      }
    });
  }

  /// Creates an alias for a profile.
  void alias({required String profileId, required String alias}) {
    _execute(() => _backend.alias(profileId: profileId, alias: alias));
  }

  /// Sends an event.
  ///
  /// You can send events with any name and any properties. On Android and iOS
  /// device information is added automatically by the native SDKs.
  ///
  /// Prefer [track] for new code. [event] is kept as a backwards-compatible
  /// alias.
  void event({
    required String name,
    Map<String, dynamic> properties = const {},
    String? profileId,
  }) {
    track(name: name, properties: properties, profileId: profileId);
  }

  /// Sends an event.
  ///
  /// ```dart
  /// Openpanel.instance.track(
  ///   name: 'button_clicked',
  ///   properties: {'button_id': 'submit_form'},
  /// );
  /// ```
  void track({
    required String name,
    Map<String, dynamic> properties = const {},
    String? profileId,
  }) {
    _execute(() {
      final propertyProfileId = properties['profileId'];
      final resolvedProfileId =
          profileId ??
          (propertyProfileId is String ? propertyProfileId : null) ??
          _currentProfileId;

      final eventProperties = Map<String, dynamic>.of(properties)
        ..remove('profileId');

      return _backend.track(
        name: name,
        properties: eventProperties,
        profileId: resolvedProfileId,
      );
    });
  }

  /// Sets global properties that are sent with every event.
  void setGlobalProperties(Map<String, dynamic> properties) {
    _state = _state.copyWith(properties: {..._state.properties, ...properties});

    if (_isClientInitialised) {
      unawaited(_runSafely(() => _backend.setGlobalProperties(properties)));
    }
  }

  /// Clears the current profile id and global properties.
  ///
  /// Collection settings and tracing sampling are preserved.
  Future<void> clear() async {
    _ensureInitialised();

    _state = OpenpanelState(
      isCollectionEnabled: _state.isCollectionEnabled,
      isTracingSampled: _state.isTracingSampled,
    );

    await _backend.clear();
    await _preferencesService.persistState(_state);
  }

  /// Flushes any queued events.
  void flush() {
    _execute(() => _backend.flush());
  }

  /// Flushes queued events and stops waiting for a profile.
  ///
  /// This is useful when [OpenpanelOptions.waitForProfile] is enabled and the
  /// user is anonymous.
  void ready() {
    _execute(() => _backend.ready());
  }

  // Do not give the native SDK an anonymous UUID while it is waiting for an
  // explicit identification. Queued events must inherit the eventual user id.
  String? get _currentProfileId =>
      options.waitForProfile && !_state.isProfileIdentified
      ? null
      : _state.profileId;

  void _execute(FutureOr<void> Function() action) {
    _ensureInitialised();

    if (!_state.isCollectionEnabled || !_state.isTracingSampled) {
      return;
    }

    unawaited(_runSafely(action));
  }

  Future<void> _runSafely(FutureOr<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      _log('OpenPanel error', error, stackTrace);
    }

    try {
      await _preferencesService.persistState(_state);
    } catch (error, stackTrace) {
      _log('Unable to persist OpenPanel state', error, stackTrace);
    }
  }

  void _ensureInitialised() {
    if (!_isClientInitialised) {
      throw StateError(
        'Openpanel is not initialised. You must initialize Openpanel before using Openpanel.instance.',
      );
    }
  }

  void _log(String message, [Object? error, StackTrace? stackTrace]) {
    if (!options.verbose) {
      return;
    }

    debugPrint('OpenPanel: $message${error == null ? '' : ' ($error)'}');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  static const _legacyDevicePropertyKeys = <String>{
    'appVersion',
    'buildNumber',
    'installerStore',
    'deviceId',
    'brand',
    'model',
    'manufacturer',
    'osVersion',
    'platform',
  };
}
