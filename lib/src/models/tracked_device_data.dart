import 'package:equatable/equatable.dart';

class TrackedDeviceData extends Equatable {
  final String deviceId;
  final String appVersion;
  final String buildNumber;
  final String os;

  const TrackedDeviceData({
    required this.deviceId,
    required this.appVersion,
    required this.buildNumber,
    required this.os,
  });

  Map<String, dynamic> toJson() {
    return {
      '__version': appVersion,
      '__buildNumbe': buildNumber,
      '__referrer': os,
      'deviceId': deviceId,
    };
  }

  @override
  List<Object?> get props => [deviceId, appVersion, os];
}
