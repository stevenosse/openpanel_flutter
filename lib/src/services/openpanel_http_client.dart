import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:openpanel_flutter/src/models/post_event_payload.dart';
import 'package:openpanel_flutter/src/models/update_profile_payload.dart';

typedef ApiResponse<T, E> = ({T? response, E? error});

class OpenpanelHttpClient {
  final Dio dio;
  final bool verbose;
  final Logger _logger;

  OpenpanelHttpClient({
    required this.dio,
    required this.verbose,
    required Logger logger,
  }) : _logger = logger;

  void updateProfile({required UpdateProfilePayload payload, required Map<String, dynamic> stateProperties}) {
    runApiCall(() async {
      await dio.post('/profile', data: {
        ...payload.toJson(),
        'properties': {
          ...payload.properties,
          ...stateProperties,
        }
      });
    });
  }

  void increment({required String profileId, required String property, required int value}) {
    runApiCall(() async {
      dio.post('/profile/increment', data: {
        'profileId': profileId,
        'property': property,
        'value': value,
      });
    });
  }

  void decrement({required String profileId, required String property, required int value}) {
    runApiCall(() async {
      dio.post('/profile/decrement', data: {
        'profileId': profileId,
        'property': property,
        'value': value,
      });
    });
  }

  Future<String?> event({required PostEventPayload payload}) async {
    final response = await runApiCall(() async {
      final response = await dio.post('/event', data: payload.toJson());
      return response.data as String;
    });

    if (response.error != null) {
      return null;
    }

    return response.response;
  }

  Future<ApiResponse> runApiCall<T, E>(Future<T> Function() apiCall) async {
    try {
      final response = await apiCall();

      return (response: response, error: null);
    } on DioException catch (e) {
      _logger.err(e.message);
      return (response: null, error: e);
    } on SocketException catch (e) {
      _logError('Failed to connect to the internet.');
      return (response: null, error: e);
    }
  }

  void _logError(String message) {
    if (verbose) {
      _logger.err(message);
    }
  }
}
