class ApiFollowedPartnerProfile {
  final String businessName;
  final String? businessType;
  final String? baseCity;

  const ApiFollowedPartnerProfile({
    required this.businessName,
    this.businessType,
    this.baseCity,
  });

  factory ApiFollowedPartnerProfile.fromJson(Map<String, dynamic> j) =>
      ApiFollowedPartnerProfile(
        businessName: j['business_name'] as String? ?? '',
        businessType: j['business_type'] as String?,
        baseCity: j['base_city'] as String?,
      );
}

class ApiFollowedPartnerExtended {
  final String? bio;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? operatingCities;

  const ApiFollowedPartnerExtended({
    this.bio,
    this.logoUrl,
    this.coverImageUrl,
    this.operatingCities,
  });

  factory ApiFollowedPartnerExtended.fromJson(Map<String, dynamic> j) {
    final oc = j['operating_cities'];
    final operatingCities = oc is List
        ? (oc).map((e) => e.toString()).join(', ')
        : oc?.toString();
    return ApiFollowedPartnerExtended(
      bio: j['bio'] as String?,
      logoUrl: j['logo_url'] as String?,
      coverImageUrl: j['cover_image_url'] as String?,
      operatingCities: operatingCities,
    );
  }
}

class ApiFollowedPartnerCategory {
  final int id;
  final String name;

  const ApiFollowedPartnerCategory({required this.id, required this.name});

  factory ApiFollowedPartnerCategory.fromJson(Map<String, dynamic> j) =>
      ApiFollowedPartnerCategory(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
      );
}

class ApiFollowedPartner {
  final String partnerId;
  final bool isVerified;
  final int followerCount;
  final ApiFollowedPartnerProfile profile;
  final ApiFollowedPartnerExtended? extendedProfile;
  final List<ApiFollowedPartnerCategory> categories;
  final String followedAt;

  const ApiFollowedPartner({
    required this.partnerId,
    required this.isVerified,
    required this.followerCount,
    required this.profile,
    this.extendedProfile,
    required this.categories,
    required this.followedAt,
  });

  factory ApiFollowedPartner.fromJson(Map<String, dynamic> j) {
    final ext = j['extended_profile'];
    return ApiFollowedPartner(
      partnerId: j['partner_id'] as String? ?? '',
      isVerified: j['is_verified'] as bool? ?? false,
      followerCount: (j['follower_count'] as num?)?.toInt() ?? 0,
      profile: ApiFollowedPartnerProfile.fromJson(
          j['profile'] as Map<String, dynamic>? ?? {}),
      extendedProfile: ext != null
          ? ApiFollowedPartnerExtended.fromJson(ext as Map<String, dynamic>)
          : null,
      categories: (j['categories'] as List<dynamic>? ?? [])
          .map((e) => ApiFollowedPartnerCategory.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      followedAt: j['followed_at'] as String? ?? '',
    );
  }
}
