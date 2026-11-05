import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openpanel_flutter/openpanel_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'native SDK preserves queue, collection state and property types',
    (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final requests = <Map<String, dynamic>>[];
        final subscription = server.listen((request) async {
          requests.add(
            jsonDecode(await utf8.decoder.bind(request).join())
                as Map<String, dynamic>,
          );
          request.response.write('ok');
          await request.response.close();
        });
        try {
          final preferences = await SharedPreferences.getInstance();
          await preferences.remove('openpanel_state');
          final client = Openpanel.instance;
          await client.initialize(
            options: OpenpanelOptions(
              clientId: 'native-regression-test',
              apiUrl: 'http://127.0.0.1:${server.port}',
              waitForProfile: true,
            ),
          );

          client.setGlobalProperties({'globalFlag': true, 'plan': 'pro'});
          client.track(
            name: 'before_login',
            properties: {
              'enabled': true,
              'disabled': false,
              'nested': {
                'flags': [true, false],
                'count': 2,
              },
            },
          );
          await Future<void>.delayed(const Duration(milliseconds: 300));
          expect(requests, isEmpty);

          client.identify(
            profileId: 'user-1',
          properties: {'subscribed': true, 'globalFlag': false},
          );
          final first = await _waitFor(requests, 'track', name: 'before_login');
          expect(first['profileId'], 'user-1');
          expect(first['properties'], containsPair('enabled', true));
          expect(first['properties'], containsPair('disabled', false));
          expect(first['properties'], containsPair('globalFlag', true));
          expect(first['properties']['nested'], {
            'flags': [true, false],
            'count': 2,
          });
          final identified = await _waitFor(requests, 'identify');
          expect(identified['properties'], containsPair('subscribed', true));
        expect(identified['properties'], containsPair('globalFlag', false));

          client.setCollectionEnabled(false);
          client.track(name: 'disabled_event');
          client.setCollectionEnabled(true);
          client.track(name: 'after_resume');
          final resumed = await _waitFor(
            requests,
            'track',
            name: 'after_resume',
          );
          expect(resumed['profileId'], 'user-1');
          expect(resumed['properties'], containsPair('plan', 'pro'));
          expect(resumed['properties'], containsPair('globalFlag', true));
          expect(
            requests.where((r) => r['payload']['name'] == 'disabled_event'),
            isEmpty,
          );

          await client.clear();
          client.track(name: 'waiting_again');
          client.flush();
          await Future<void>.delayed(const Duration(milliseconds: 300));
          expect(
            requests.where((r) => r['payload']['name'] == 'waiting_again'),
            isEmpty,
          );
          client.ready();
          final anonymous = await _waitFor(
            requests,
            'track',
            name: 'waiting_again',
          );
          expect(anonymous['profileId'], isNull);
          expect(anonymous['properties'], isNot(contains('plan')));
          if (Platform.isIOS) {
            for (final payload in [first, anonymous]) {
              expect(
                payload['properties'],
                containsPair('appVersion', '1.0.0'),
              );
              expect(payload['properties'], containsPair('buildNumber', '1'));
            }
          }
        } finally {
          await subscription.cancel();
          await server.close(force: true);
        }
      });
    },
    timeout: const Timeout(Duration(seconds: 90)),
  );
}

Future<Map<String, dynamic>> _waitFor(
  List<Map<String, dynamic>> requests,
  String type, {
  String? name,
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    for (final request in requests) {
      final payload = request['payload'] as Map<String, dynamic>;
      if (request['type'] == type &&
          (name == null || payload['name'] == name)) {
        return payload;
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('No $type request for $name. Received: $requests');
}
