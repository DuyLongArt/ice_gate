import "package:freezed_annotation/freezed_annotation.dart";

part "AuthenticationProtocol.freezed.dart";
part "AuthenticationProtocol.g.dart";

@freezed
abstract class AuthenticationProtocol with _$AuthenticationProtocol {
  const factory AuthenticationProtocol({
    required String username,
    required String password,
    required String jwt,
  }) = _AuthenticationProtocol;

  factory AuthenticationProtocol.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationProtocolFromJson(json);
}
