import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:openpanel_flutter/src/models/post_event_payload.dart';
import 'package:openpanel_flutter/src/models/update_profile_payload.dart';

class OpenpanelHttpClient {
  final Dio dio;
  final bool verbose;

  OpenpanelHttpClient({
    required this.dio,
    this.verbose = false,
  });

  void updateProfile({required UpdateProfilePayload payload, required Map<String, dynamic> stateProperties}) {
    dio.post('/profile', data: {
      ...payload.toJson(),
      'properties': {
        ...payload.properties,
        ...stateProperties,
      }
    });
  }

  void increment({required String profileId, required String property, required int value}) {
    dio.post('/profile/increment', data: {
      'profileId': profileId,
      'property': property,
      'value': value,
    });
  }

  void decrement({required String profileId, required String property, required int value}) {
    dio.post('/profile/decrement', data: {
      'profileId': profileId,
      'property': property,
      'value': value,
    });
  }

  Future<String?> event({required PostEventPayload payload}) async {
    try {
      final response = await dio.post('/event', data: payload.toJson());

      return response.data as String;
    } on DioException catch (e) {
      log('Http error: ', error: e);
      return null;
    } on SocketException catch (e) {
      log('Failed to connect to the internet.', error: e);
      return null;
    }
  }
}
