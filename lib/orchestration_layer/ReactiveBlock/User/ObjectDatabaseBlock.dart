import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/PersonBlock.dart';
import 'package:signals/signals.dart';

class UserObjectResource {
  final String avatarImage;
  final String coverImage;
  static String baseObjectUrl = 'https://backend.duylong.art';
  UserObjectResource({required this.avatarImage, required this.coverImage});
}

class ObjectDatabaseBlock {
  final userObjectResource = signal<UserObjectResource>(
    UserObjectResource(avatarImage: '', coverImage: ''),
  );

  Future<void> updateUrlOfUser(PersonBlock personBlock) async {
    String alias = personBlock.information.value.profiles.alias;
    print("alias: $alias");

    if (alias.isEmpty) {
      userObjectResource.value = UserObjectResource(
        avatarImage: '',
        coverImage: '',
      );
      return;
    }

    // Ensure baseObjectUrl doesn't end with slash, prevent double slashes
    final baseUrl = UserObjectResource.baseObjectUrl.endsWith('/')
        ? UserObjectResource.baseObjectUrl.substring(
            0,
            UserObjectResource.baseObjectUrl.length - 1,
          )
        : UserObjectResource.baseObjectUrl;

    userObjectResource.value = UserObjectResource(
      avatarImage:
          "$baseUrl/object/duylongwebappobjectdatabase/$alias/admin.png",
      coverImage:
          "$baseUrl/object/duylongwebappobjectdatabase/$alias/cover.png",
    );
  }
}
