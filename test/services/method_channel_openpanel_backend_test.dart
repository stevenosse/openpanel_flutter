import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openpanel_flutter/openpanel_flutter.dart';
import 'package:openpanel_flutter/src/constants/constants.dart';
import 'package:openpanel_flutter/src/services/method_channel_openpanel_backend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelOpenpanelBackend', () {
    late MethodChannelOpenpanelBackend backend;
    final log = <MethodCall>[];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(kOpenpanelMethodChannel),
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );
      backend = MethodChannelOpenpanelBackend();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(kOpenpanelMethodChannel),
        null,
      );
    });

    test('initialize invokes initialize method with options', () async {
      await backend.initialize(
        OpenpanelOptions(
          clientId: 'client-123',
          clientSecret: 'secret-456',
          apiUrl: 'https://custom.api.dev',
          verbose: true,
          disabled: false,
          automaticTracking: true,
          waitForProfile: true,
        ),
      );

      expect(log, hasLength(1));
      expect(log.single.method, 'initialize');
      expect(log.single.arguments, {
        'clientId': 'client-123',
        'clientSecret': 'secret-456',
        'apiUrl': 'https://custom.api.dev',
        'verbose': true,
        'disabled': false,
        'automaticTracking': true,
        'waitForProfile': true,
      });
    });

    test('setCollectionEnabled invokes setCollectionEnabled', () async {
      await backend.setCollectionEnabled(false);

      expect(log, hasLength(1));
      expect(log.single.method, 'setCollectionEnabled');
      expect(log.single.arguments, {'enabled': false});
    });

    test('track invokes track with sanitized properties and profileId',
        () async {
      final now = DateTime.utc(2026, 11, 2);
      await backend.track(
        name: 'test_event',
        properties: {
          'nullKey': null,
          'stringKey': 'value',
          'intKey': 42,
          'dateKey': now,
          'listKey': ['a', null, 1],
          'nested': {'child': 'nestedVal'},
        },
        profileId: 'prof-1',
      );

      expect(log, hasLength(1));
      expect(log.single.method, 'track');
      expect(log.single.arguments, {
        'name': 'test_event',
        'properties': {
          'stringKey': 'value',
          'intKey': 42,
          'dateKey': now.toIso8601String(),
          'listKey': ['a', 1],
          'nested': {'child': 'nestedVal'},
        },
        'profileId': 'prof-1',
      });
    });

    test('identify invokes identify with payload', () async {
      await backend.identify(
        const UpdateProfilePayload(
          profileId: 'user-1',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          avatar: 'https://example.com/avatar.png',
          properties: {'plan': 'pro'},
        ),
      );

      expect(log, hasLength(1));
      expect(log.single.method, 'identify');
      expect(log.single.arguments, {
        'profileId': 'user-1',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
        'avatar': 'https://example.com/avatar.png',
        'properties': {'plan': 'pro'},
      });
    });

    test('increment invokes increment', () async {
      await backend.increment(
        profileId: 'user-1',
        property: 'score',
        value: 10,
      );

      expect(log, hasLength(1));
      expect(log.single.method, 'increment');
      expect(log.single.arguments, {
        'profileId': 'user-1',
        'property': 'score',
        'value': 10,
      });
    });

    test('decrement invokes decrement', () async {
      await backend.decrement(
        profileId: 'user-1',
        property: 'credits',
        value: 5,
      );

      expect(log, hasLength(1));
      expect(log.single.method, 'decrement');
      expect(log.single.arguments, {
        'profileId': 'user-1',
        'property': 'credits',
        'value': 5,
      });
    });

    test('alias invokes alias', () async {
      await backend.alias(
        profileId: 'user-1',
        alias: 'user-alias',
      );

      expect(log, hasLength(1));
      expect(log.single.method, 'alias');
      expect(log.single.arguments, {
        'profileId': 'user-1',
        'alias': 'user-alias',
      });
    });

    test('setGlobalProperties invokes setGlobalProperties', () async {
      await backend.setGlobalProperties({'globalKey': 'globalValue'});

      expect(log, hasLength(1));
      expect(log.single.method, 'setGlobalProperties');
      expect(log.single.arguments, {
        'properties': {'globalKey': 'globalValue'},
      });
    });

    test('setProfileId invokes setProfileId', () async {
      await backend.setProfileId('user-99');

      expect(log, hasLength(1));
      expect(log.single.method, 'setProfileId');
      expect(log.single.arguments, {'profileId': 'user-99'});
    });

    test('clear invokes clear', () async {
      await backend.clear();

      expect(log, hasLength(1));
      expect(log.single.method, 'clear');
      expect(log.single.arguments, isNull);
    });

    test('flush invokes flush', () async {
      await backend.flush();

      expect(log, hasLength(1));
      expect(log.single.method, 'flush');
      expect(log.single.arguments, isNull);
    });

    test('ready invokes ready', () async {
      await backend.ready();

      expect(log, hasLength(1));
      expect(log.single.method, 'ready');
      expect(log.single.arguments, isNull);
    });
  });
}
