import 'package:equatable/equatable.dart';

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
      profileId: json['profileId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatar: json['avatar'],
      email: json['email'],
      properties: json['properties'],
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
  List<Object?> get props => [profileId, firstName, lastName, avatar, email, properties];
}
