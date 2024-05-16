import 'package:equatable/equatable.dart';

class OpenpanelState extends Equatable {
  final String? deviceId;
  final String? profileId;
  final Map<String, dynamic> properties;

  const OpenpanelState({
    this.deviceId,
    this.profileId,
    this.properties = const {},
  });

  @override
  List<Object?> get props => [deviceId, profileId, properties];

  OpenpanelState copyWith({
    String? deviceId,
    String? profileId,
    Map<String, dynamic>? properties,
  }) {
    return OpenpanelState(
      profileId: profileId ?? this.profileId,
      deviceId: deviceId ?? this.deviceId,
      properties: properties ?? this.properties,
    );
  }
}
