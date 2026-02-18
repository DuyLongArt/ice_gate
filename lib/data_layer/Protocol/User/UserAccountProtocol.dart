import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ice_shield/orchestration_layer/IDGen.dart';

part 'UserAccountProtocol.freezed.dart';
part 'UserAccountProtocol.g.dart';

@freezed
abstract class UserAccountProtocol with _$UserAccountProtocol {
  const UserAccountProtocol._();

  const factory UserAccountProtocol({
    required int accountID,
    required int personID,
    required String username,
    String? primaryEmail,
    @Default('user') String role,
    @Default(false) bool isLocked,
    DateTime? lastLoginAt,
  }) = _UserAccountProtocol;

  factory UserAccountProtocol.create({
    int? accountID,
    required int personID,
    required String username,
    String? primaryEmail,
    String role = 'user',
    bool isLocked = false,
    DateTime? lastLoginAt,
  }) {
    return UserAccountProtocol(
      accountID: accountID ?? IDGen.generate(),
      personID: personID,
      username: username,
      primaryEmail: primaryEmail,
      role: role,
      isLocked: isLocked,
      lastLoginAt: lastLoginAt,
    );
  }

  factory UserAccountProtocol.fromJson(Map<String, dynamic> json) =>
      _$UserAccountProtocolFromJson(json);
}
