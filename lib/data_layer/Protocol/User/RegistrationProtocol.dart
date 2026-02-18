import 'package:freezed_annotation/freezed_annotation.dart';

part 'RegistrationProtocol.freezed.dart';
part 'RegistrationProtocol.g.dart';

@freezed
abstract class RegistrationPayload with _$RegistrationPayload {
  const factory RegistrationPayload({
    required String userName,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
    @Default('USER') String role,
  }) = _RegistrationPayload;

  factory RegistrationPayload.fromJson(Map<String, dynamic> json) =>
      _$RegistrationPayloadFromJson(json);
}
