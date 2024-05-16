import 'package:equatable/equatable.dart';

class OpenpanelEventOptions extends Equatable {
  final String? profileId;

  const OpenpanelEventOptions({this.profileId});

  factory OpenpanelEventOptions.fromJson(Map<String, dynamic> json) {
    return OpenpanelEventOptions(profileId: json['profileId']);
  }

  @override
  List<Object?> get props => [profileId];

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
    };
  }
}
