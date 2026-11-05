import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:openpanel_flutter/openpanel_flutter.dart';
import 'package:openpanel_flutter/src/models/open_panel_state.dart';
import 'package:openpanel_flutter/src/services/openpanel_backend.dart';
import 'package:openpanel_flutter/src/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockOpenpanelBackend extends Mock implements OpenpanelBackend {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const OpenpanelState(profileId: 'fallback'),
    );
    registerFallbackValue(
      const UpdateProfilePayload(profileId: 'fallback'),
    );
  });

  group('Openpanel', () {
    late MockOpenpanelBackend mockBackend;
    late MockSharedPreferences mockSharedPreferences;
    late PreferencesService preferencesService;
    late Openpanel openpanel;

    setUp(() {
      mockBackend = MockOpenpanelBackend();
      mockSharedPreferences = MockSharedPreferences();
      preferencesService = PreferencesService(mockSharedPreferences);

      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);
      when(() => mockBackend.track(
            name: any(named: 'name'),
            properties: any(named: 'properties'),
            profileId: any(named: 'profileId'),
          )).thenAnswer((_) async {});
      when(() => mockBackend.identify(any())).thenAnswer((_) async {});
      when(() => mockBackend.increment(
            profileId: any(named: 'profileId'),
            property: any(named: 'property'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});
      when(() => mockBackend.decrement(
            profileId: any(named: 'profileId'),
            property: any(named: 'property'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});
      when(() => mockBackend.alias(
            profileId: any(named: 'profileId'),
            alias: any(named: 'alias'),
          )).thenAnswer((_) async {});
      when(() => mockBackend.setCollectionEnabled(any()))
          .thenAnswer((_) async {});
      when(() => mockBackend.setProfileId(any())).thenAnswer((_) async {});
      when(() => mockBackend.setGlobalProperties(any()))
          .thenAnswer((_) async {});
      when(() => mockBackend.clear()).thenAnswer((_) async {});
      when(() => mockBackend.flush()).thenAnswer((_) async {});
      when(() => mockBackend.ready()).thenAnswer((_) async {});

      openpanel = Openpanel.forTesting(
        backend: mockBackend,
        preferencesService: preferencesService,
        options: OpenpanelOptions(clientId: 'test-client', verbose: false),
        state: const OpenpanelState(
          profileId: 'user-123',
          isCollectionEnabled: true,
          isTracingSampled: true,
        ),
        isInitialised: true,
      );
    });

    test('track calls backend.track with profileId and properties', () async {
      openpanel.track(
        name: 'test_event',
        properties: {'foo': 'bar'},
      );

      verify(() => mockBackend.track(
            name: 'test_event',
            properties: {'foo': 'bar'},
            profileId: 'user-123',
          )).called(1);
    });

    test('event is an alias for track', () async {
      openpanel.event(
        name: 'aliased_event',
        properties: {'key': 'val'},
      );

      verify(() => mockBackend.track(
            name: 'aliased_event',
            properties: {'key': 'val'},
            profileId: 'user-123',
          )).called(1);
    });

    test('identify delegates to backend.identify and persists state', () async {
      openpanel.identify(
        profileId: 'user-456',
        firstName: 'Alice',
        lastName: 'Smith',
        email: 'alice@example.com',
        avatar: 'https://example.com/alice.png',
        properties: {'plan': 'free'},
      );
      await pumpEventQueue();

      verify(() => mockBackend.identify(
            const UpdateProfilePayload(
              profileId: 'user-456',
              firstName: 'Alice',
              lastName: 'Smith',
              email: 'alice@example.com',
              avatar: 'https://example.com/alice.png',
              properties: {'plan': 'free'},
            ),
          )).called(1);

      verify(() => mockSharedPreferences.setString(any(), any())).called(1);
    });

    test('updateProfile calls identify', () async {
      openpanel.updateProfile(
        payload: const UpdateProfilePayload(
          profileId: 'user-789',
          firstName: 'Bob',
        ),
      );

      verify(() => mockBackend.identify(
            const UpdateProfilePayload(
              profileId: 'user-789',
              firstName: 'Bob',
            ),
          )).called(1);
    });

    test('increment calls backend.increment', () async {
      openpanel.increment(property: 'points', value: 5);

      verify(() => mockBackend.increment(
            profileId: 'user-123',
            property: 'points',
            value: 5,
          )).called(1);
    });

    test('decrement calls backend.decrement', () async {
      openpanel.decrement(property: 'lives', value: 1);

      verify(() => mockBackend.decrement(
            profileId: 'user-123',
            property: 'lives',
            value: 1,
          )).called(1);
    });

    test('alias calls backend.alias', () async {
      openpanel.alias(profileId: 'user-123', alias: 'alias-abc');

      verify(() => mockBackend.alias(
            profileId: 'user-123',
            alias: 'alias-abc',
          )).called(1);
    });

    test('setProfileId updates profileId on backend and state', () async {
      openpanel.setProfileId('user-new');
      await pumpEventQueue();

      verify(() => mockBackend.setProfileId('user-new')).called(1);
      verify(() => mockSharedPreferences.setString(any(), any())).called(1);
    });

    test('setCollectionEnabled updates collection on backend', () async {
      openpanel.setCollectionEnabled(false);

      verify(() => mockBackend.setCollectionEnabled(false)).called(1);
    });

    test('clear calls backend.clear and resets state', () async {
      await openpanel.clear();

      verify(() => mockBackend.clear()).called(1);
      verify(() => mockSharedPreferences.setString(any(), any())).called(1);
    });

    test('flush calls backend.flush', () async {
      openpanel.flush();

      verify(() => mockBackend.flush()).called(1);
    });

    test('ready calls backend.ready', () async {
      openpanel.ready();

      verify(() => mockBackend.ready()).called(1);
    });

    test('throws StateError when uninitialized', () {
      final uninit = Openpanel.forTesting(
        backend: mockBackend,
        preferencesService: preferencesService,
        isInitialised: false,
      );

      expect(() => uninit.track(name: 'event'), throwsStateError);
      expect(() => uninit.identify(profileId: 'p'), throwsStateError);
      expect(() => uninit.setProfileId('p'), throwsStateError);
      expect(() => uninit.setCollectionEnabled(false), throwsStateError);
      expect(() => uninit.clear(), throwsStateError);
    });
  });
}
