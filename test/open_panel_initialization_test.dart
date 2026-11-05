import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openpanel_flutter/openpanel_flutter.dart';
import 'package:openpanel_flutter/src/constants/constants.dart';
import 'package:openpanel_flutter/src/services/method_channel_openpanel_backend.dart';
import 'package:openpanel_flutter/src/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  late PreferencesService preferences;

  setUp(() {
    calls.clear();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(kOpenpanelMethodChannel),
          (call) async {
            calls.add(call);
            return null;
          },
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(kOpenpanelMethodChannel),
          null,
        );
  });

  Future<Openpanel> create({String? savedState}) async {
    if (savedState != null) {
      SharedPreferences.setMockInitialValues({'openpanel_state': savedState});
    }
    preferences = PreferencesService(await SharedPreferences.getInstance());
    return Openpanel.forTesting(
      backend: MethodChannelOpenpanelBackend(),
      preferencesService: preferences,
      isInitialised: false,
    );
  }

  OpenpanelOptions options({bool waitForProfile = true}) =>
      OpenpanelOptions(clientId: 'test-client', waitForProfile: waitForProfile);

  test('anonymous initialization leaves the native profile unset', () async {
    final client = await create();
    await client.initialize(options: options());

    expect(calls.map((call) => call.method), ['initialize']);
    client.track(name: 'before_login');
    await pumpEventQueue();

    expect(calls.last.arguments, {
      'name': 'before_login',
      'properties': <String, dynamic>{},
    });
    final saved = await preferences.getSavedState();
    expect(saved?.profileId, isNotEmpty);
    expect(saved?.isProfileIdentified, isFalse);
  });

  test(
    'an explicit identification is used by subsequent events and persisted',
    () async {
      final client = await create();
      await client.initialize(options: options());
      client.identify(profileId: 'signed-in-user');
      client.track(name: 'after_login');
      await pumpEventQueue();

      expect(calls.last.arguments['profileId'], 'signed-in-user');
      expect((await preferences.getSavedState())?.isProfileIdentified, isTrue);
    },
  );

  test('an explicit setProfileId is persisted as identified', () async {
    final client = await create();
    await client.initialize(options: options());
    client.setProfileId('signed-in-user');
    await pumpEventQueue();

    expect(calls.last.method, 'setProfileId');
    expect((await preferences.getSavedState())?.isProfileIdentified, isTrue);
  });

  test(
    'saved anonymous and legacy profiles do not release queued events',
    () async {
      for (final flag in ['', ',"isProfileIdentified":false']) {
        calls.clear();
        final client = await create(
          savedState: '{"profileId":"anonymous-uuid"$flag}',
        );
        await client.initialize(options: options());
        expect(calls.map((call) => call.method), ['initialize']);
      }
    },
  );

  test('a saved explicit profile is restored on launch', () async {
    final client = await create(
      savedState: '{"profileId":"user-1","isProfileIdentified":true}',
    );
    await client.initialize(options: options());

    expect(calls.last.method, 'setProfileId');
    expect(calls.last.arguments, {'profileId': 'user-1'});
  });

  test('default initialization still restores a stable anonymous id', () async {
    final client = await create();
    await client.initialize(options: options(waitForProfile: false));

    expect(calls.last.method, 'setProfileId');
    expect(calls.last.arguments['profileId'], isNotEmpty);
  });

  test('collection changes do not identify an anonymous profile', () async {
    final client = await create();
    await client.initialize(options: options());
    client.setCollectionEnabled(false);
    client.setCollectionEnabled(true);
    await pumpEventQueue();

    expect(calls.map((call) => call.method), [
      'initialize',
      'setCollectionEnabled',
      'setCollectionEnabled',
    ]);
  });

  test('clear resets the persisted identification status', () async {
    final client = await create();
    await client.initialize(options: options());
    client.identify(profileId: 'user-1');
    await pumpEventQueue();
    await client.clear();
    client.track(name: 'after_logout');
    await pumpEventQueue();

    final saved = await preferences.getSavedState();
    expect(saved?.isProfileIdentified, isFalse);
    expect(saved?.profileId, isNull);
    expect(calls.last.arguments.containsKey('profileId'), isFalse);
  });

  test('properties configured before initialization are restored', () async {
    final client = await create();
    client.setGlobalProperties({'plan': 'pro'});
    await client.initialize(options: options());

    expect(calls.last.method, 'setGlobalProperties');
    expect(calls.last.arguments, {
      'properties': {'plan': 'pro'},
    });
  });
}
