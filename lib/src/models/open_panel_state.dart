import 'package:equatable/equatable.dart';

class OpenpanelState extends Equatable {
  final String? deviceId;
  final String? profileId;
  final bool isCollectionEnabled;
  final Map<String, dynamic> properties;

  const OpenpanelState({
    this.deviceId,
    this.profileId,
    this.isCollectionEnabled = true,
    this.properties = const {},
  });

  @override
  List<Object?> get props => [deviceId, profileId, properties, isCollectionEnabled];

  OpenpanelState copyWith({
    String? deviceId,
    String? profileId,
    Map<String, dynamic>? properties,
    bool? isCollectionEnabled,
  }) {
    return OpenpanelState(
      profileId: profileId ?? this.profileId,
      deviceId: deviceId ?? this.deviceId,
      properties: properties ?? this.properties,
      isCollectionEnabled: isCollectionEnabled ?? this.isCollectionEnabled,
    );
  }
}
