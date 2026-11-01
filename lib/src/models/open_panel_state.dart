import 'package:equatable/equatable.dart';

/// The persisted state of the OpenPanel wrapper.
///
/// The native OpenPanel SDKs keep their state in memory. The wrapper persists
/// the profile id and global properties so they can be restored on the next
/// launch.
class OpenpanelState extends Equatable {
  final String? profileId;
  final bool isCollectionEnabled;
  final Map<String, dynamic> properties;
  final bool isTracingSampled;

  const OpenpanelState({
    this.profileId,
    this.isCollectionEnabled = true,
    this.properties = const {},
    this.isTracingSampled = true,
  });

  factory OpenpanelState.fromJson(Map<String, dynamic> json) {
    return OpenpanelState(
      profileId: json['profileId'] as String?,
      properties: (json['properties'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
      isCollectionEnabled: json['isCollectionEnabled'] as bool? ?? true,
      isTracingSampled: json['isTracingSampled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'properties': properties,
      'isCollectionEnabled': isCollectionEnabled,
      'isTracingSampled': isTracingSampled,
    };
  }

  OpenpanelState copyWith({
    String? profileId,
    Map<String, dynamic>? properties,
    bool? isCollectionEnabled,
    bool? isTracingSampled,
  }) {
    return OpenpanelState(
      profileId: profileId ?? this.profileId,
      properties: properties ?? this.properties,
      isCollectionEnabled: isCollectionEnabled ?? this.isCollectionEnabled,
      isTracingSampled: isTracingSampled ?? this.isTracingSampled,
    );
  }

  @override
  List<Object?> get props => [
        profileId,
        properties,
        isCollectionEnabled,
        isTracingSampled,
      ];
}
