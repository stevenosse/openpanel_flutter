import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openpanel_flutter/src/models/open_panel_state.dart';
import 'package:openpanel_flutter/src/services/preferences_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('PreferencesService', () {
    late PreferencesService preferencesService;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      preferencesService = PreferencesService(mockSharedPreferences);
    });

    test('persistState should save state as JSON string', () async {
      const state = OpenpanelState(
        profileId: 'testProfile',
        properties: {'role': 'admin'},
        isCollectionEnabled: true,
        isTracingSampled: true,
      );
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      await preferencesService.persistState(state);

      verify(() => mockSharedPreferences.setString(any(), any())).called(1);
    });

    test('getSavedState should return null when no state is saved', () async {
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);

      final result = await preferencesService.getSavedState();

      expect(result, isNull);
    });

    test('getSavedState should return OpenpanelState when state is saved',
        () async {
      const jsonString =
          '{"profileId":"testProfile","properties":{"role":"admin"},"isCollectionEnabled":true,"isTracingSampled":true}';
      when(() => mockSharedPreferences.getString(any())).thenReturn(jsonString);

      final result = await preferencesService.getSavedState();

      expect(result, isA<OpenpanelState>());
      expect(result?.profileId, equals('testProfile'));
      expect(result?.properties, equals({'role': 'admin'}));
      expect(result?.isCollectionEnabled, isTrue);
      expect(result?.isTracingSampled, isTrue);
    });
  });
}
