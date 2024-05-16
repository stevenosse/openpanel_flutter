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

  factory OpenpanelState.fromJson(Map<String, dynamic> json) {
    return OpenpanelState(
      deviceId: json['deviceId'],
      profileId: json['profileId'],
      properties: json['properties'],
      isCollectionEnabled: json['isCollectionEnabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'profileId': profileId,
      'properties': properties,
      'isCollectionEnabled': isCollectionEnabled,
    };
  }

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
