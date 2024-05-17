import 'package:equatable/equatable.dart';

class OpenpanelEventOptions extends Equatable {
  final String? profileId;

  const OpenpanelEventOptions({this.profileId});

  @override
  List<Object?> get props => [profileId];
}
