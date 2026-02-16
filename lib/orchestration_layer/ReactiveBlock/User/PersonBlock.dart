import 'package:ice_shield/initial_layer/CoreLogics/CustomAuthService.dart';
import 'package:signals/signals.dart';

// --- Interfaces for State ---
class UserDetails {
  final int? informationId;
  final int? identityId;
  final String githubUrl;
  final String websiteUrl;
  final String company;
  final String university;
  final String location;
  final String country;
  final String bio;
  final String occupation;
  final String educationLevel;
  final String linkedinUrl;

  const UserDetails({
    this.informationId,
    this.identityId,
    this.githubUrl = '',
    this.websiteUrl = '',
    this.company = '',
    this.university = '',
    this.location = '',
    this.country = '',
    this.bio = '',
    this.occupation = '',
    this.educationLevel = '',
    this.linkedinUrl = '',
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      informationId: json['information_id'] as int?, // Assuming exact key match
      identityId: json['identity_id'] as int?, // Check backend structure
      githubUrl: json['github_url'] ?? '',
      websiteUrl: json['website_url'] ?? '',
      company: json['company'] ?? '',
      university: json['university'] ?? '',
      location: json['location'] ?? '',
      country: json['country'] ?? '',
      bio: json['bio'] ?? '',
      occupation: json['occupation'] ?? '',
      educationLevel: json['education_level'] ?? '',
      linkedinUrl: json['linkedin_url'] ?? '',
    );
  }

  // Helper for updates
  UserDetails copyWith({
    String? githubUrl,
    String? websiteUrl,
    String? company,
    String? university,
    String? location,
    String? country,
    String? bio,
    String? occupation,
    String? educationLevel,
    String? linkedinUrl,
  }) {
    return UserDetails(
      informationId: informationId,
      identityId: identityId,
      githubUrl: githubUrl ?? this.githubUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      company: company ?? this.company,
      university: university ?? this.university,
      location: location ?? this.location,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      occupation: occupation ?? this.occupation,
      educationLevel: educationLevel ?? this.educationLevel,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
    );
  }
}

class UserProfile {
  final int? id;
  final String firstName;
  final String lastName;
  final int friends;
  final int mutual;
  final String profileImageUrl;
  final String alias;

  const UserProfile({
    this.id,
    this.firstName = '',
    this.lastName = '',
    this.friends = 0,
    this.mutual = 0,
    this.profileImageUrl = '',
    this.alias = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      friends: json['friends'] ?? 0,
      mutual: json['mutual'] ?? 0,
      profileImageUrl: json['profileImageUrl'] ?? '',
      alias: json['alias'] ?? '',
    );
  }

  UserProfile copyWith({String? profileImageUrl}) {
    return UserProfile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      friends: friends,
      mutual: mutual,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      alias: alias,
    );
  }
}

class UserInformation {
  final UserDetails details;
  final UserProfile profiles;

  const UserInformation({required this.details, required this.profiles});
}

class UserAccount {
  final String role; // 'ADMIN', 'USER', etc.
  const UserAccount({this.role = 'USER'});
}

class SkillType {
  final int id;
  final String category;
  final String name;
  final String description;

  const SkillType({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
  });

  factory SkillType.fromJson(Map<String, dynamic> json) {
    return SkillType(
      id: json['id'] ?? 0,
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

// --- Person Block ---
class PersonBlock {
  final CustomAuthService _authService;

  // State Signals
  final information = signal<UserInformation>(
    UserInformation(
      details: const UserDetails(),
      profiles: const UserProfile(
        firstName: 'Initial',
        lastName: 'Loading...',
        profileImageUrl:
            'https://backend.duylong.art/object/publish/default_avatar.png',
      ),
    ),
  );

  final account = signal<UserAccount>(const UserAccount());
  final skills = signal<List<SkillType>>([]);

  PersonBlock({required CustomAuthService authService})
    : _authService = authService;

  // --- ACTIONS ---

  /// Fetch user profile and details together
  Future<void> fetchFromDatabase(String token) async {
    if (token.isEmpty) return;
    // print("🔄 Syncing Person Information...");

    try {
      // 1. Fetch Person Information
      final personAllData = await _authService.fetchPersonInformation(token);

      // 2. Fetch Details
      // final detailsData = await _authService.fetchInformationDetails(token);

      // print("✅ Profile Sync: $personAllData");

      // // Update state
      information.value = UserInformation(
        profiles: UserProfile.fromJson(personAllData['identity']),
        details: UserDetails.fromJson(personAllData),
      );
      print(
        "✅ Profile ${information.value.profiles.alias} ${information.value.details.bio}",
      );
    } catch (e) {
      print("❌ Failed to fetch user profile: $e");
      // Fallback: Use some default data if currently in 'Initial' state to avoid blank screens
      if (information.value.profiles.firstName == 'Initial') {
        print("🔄 Applying default fallback data...");
        information.value = UserInformation(
          profiles: const UserProfile(
            firstName: 'DuyLong',
            lastName: 'Art',
            alias: 'Guest-Shield',
            profileImageUrl:
                'https://backend.duylong.art/object/publish/default_avatar.png',
          ),
          details: const UserDetails(
            bio: 'Securing the digital frontier.',
            occupation: 'Core Security Agent',
            location: 'Unknown Sector',
          ),
        );
      }
    }
  }

  // Update local profile image URL
  void updateProfileImageUrl(String url) {
    information.value = UserInformation(
      details: information.value.details,
      profiles: information.value.profiles.copyWith(profileImageUrl: url),
    );
  }

  // Optimistic update for edit
  void editProfile({
    String? university,
    String? location,
    String? bio,
    String? occupation,
    String? websiteUrl,
    String? company,
    String? country,
    String? githubUrl,
    String? linkedinUrl,
    String? educationLevel,
  }) {
    information.value = UserInformation(
      profiles: information.value.profiles,
      details: information.value.details.copyWith(
        university: university,
        location: location,
        bio: bio,
        occupation: occupation,
        websiteUrl: websiteUrl,
        company: company,
        country: country,
        githubUrl: githubUrl,
        linkedinUrl: linkedinUrl,
        educationLevel: educationLevel,
      ),
    );
  }

  // Persist edits to database
  Future<void> updateProfileDatabase(String token) async {
    try {
      final details = information.value.details;
      await _authService.updateInformationDetails(
        token: token,
        university: details.university,
        location: details.location,
        bio: details.bio,
        occupation: details.occupation,
        websiteUrl: details.websiteUrl,
        company: details.company,
        country: details.country,
        githubUrl: details.githubUrl,
        linkedinUrl: details.linkedinUrl,
        educationLevel: details.educationLevel,
      );
      print("✅ Database Update Successful");
    } catch (e) {
      print("❌ Failed to update profile in database: $e");
    }
  }

  // Fetch User Role
  Future<void> getUserRole(String token) async {
    try {
      // Reusing fetchCurrentUser to get role, assuming it's in the response
      // Or if there is a specific /account/information endpoint that returns role:
      final userData = await _authService.fetchCurrentUser(token);

      final role = userData['role'] ?? 'USER';

      account.value = UserAccount(role: role);
      print("✅ User Role Fetched: $role");
    } catch (e) {
      print("❌ Failed to get user role: $e");
    }
  }

  // Fetch Skills
  Future<void> getUserSkill(String token) async {
    try {
      final skillsData = await _authService.fetchUserSkills(token);
      final skillList = skillsData.map((s) => SkillType.fromJson(s)).toList();

      skills.value = skillList;
      // print("✅ Database Skill Successful: ${skillList.length} skills found.");
    } catch (e) {
      print("❌ Failed to get user skills: $e");
    }
  }

  // Unified Fetch Method
  Future<void> fetchInitialData(String token) async {
    if (token.isEmpty) {
      print("⚠️ No token provided for initial data fetch");
      return;
    }
    print("🚀 Starting Initial Data Fetch...");
    try {
      await Future.wait([
        fetchFromDatabase(token),
        getUserRole(token),
        getUserSkill(token),
      ]);
      print("✅ Initial Data Fetch Completed");
    } catch (e) {
      print("❌ Error during initial data fetch: $e");
    }
  }
}
