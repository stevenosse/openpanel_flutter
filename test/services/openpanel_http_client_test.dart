import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:openpanel_flutter/openpanel_flutter.dart';
import 'package:openpanel_flutter/src/models/post_event_payload.dart';
import 'package:openpanel_flutter/src/services/openpanel_http_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OpenpanelHttpClient.event', () {
    late HttpServer server;

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        await request.drain<void>();
        request.response.headers.contentType = ContentType.json;
        request.response.write('{"success":true}');
        await request.response.close();
      });
    });

    tearDown(() => server.close(force: true));

    test('accepts a JSON object response', () async {
      final realHttpOverrides = _RealHttpOverrides();
      await HttpOverrides.runZoned(() async {
        final client = OpenpanelHttpClient(verbose: false, logger: Logger());
        await client.init(
          OpenpanelOptions(
            url: 'http://${server.address.host}:${server.port}',
            clientId: 'test-client',
            clientSecret: 'test-secret',
          ),
        );

        final response = await client.event(
          payload: PostEventPayload(
            name: 'test_event',
            timestamp: DateTime.utc(2026).toIso8601String(),
          ),
        );

        expect(response, '{success: true}');
      }, createHttpClient: realHttpOverrides.createHttpClient);
    });
  });
}

class _RealHttpOverrides extends HttpOverrides {}
