import 'package:equatable/equatable.dart';

/// Profile information sent to OpenPanel when identifying a user.
///
/// Prefer `Openpanel.identify` for new code. This class is kept for backwards
/// compatibility with `Openpanel.updateProfile`.
class UpdateProfilePayload extends Equatable {
  final String profileId;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String? email;
  final Map<String, dynamic> properties;

  const UpdateProfilePayload({
    required this.profileId,
    this.firstName,
    this.lastName,
    this.avatar,
    this.email,
    this.properties = const {},
  });

  factory UpdateProfilePayload.fromJson(Map<String, dynamic> json) {
    return UpdateProfilePayload(
      profileId: json['profileId'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
      properties: (json['properties'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'email': email,
      'properties': properties,
    };
  }

  @override
  List<Object?> get props =>
      [profileId, firstName, lastName, avatar, email, properties];
}
