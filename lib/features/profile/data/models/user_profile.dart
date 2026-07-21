import '../utils/service_categories_resolver.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? gender;
  final String? avatarUrl;
  final String? bio;
  final String? address;
  final String userType; // 'client' or 'freelancer'
  final double? hourlyRate;
  final bool isVerified;
  final List<String> serviceCategories; // e.g. ['plomberie', 'jardinage']

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.birthDate,
    this.gender,
    this.avatarUrl,
    this.bio,
    this.address,
    required this.userType,
    this.hourlyRate,
    this.isVerified = false,
    this.serviceCategories = const [],
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get isFreelancer => userType == 'freelancer';

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    firstName: json['first_name'] as String? ?? '',
    lastName: json['last_name'] as String? ?? '',
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    birthDate: json['birth_date'] != null
        ? DateTime.tryParse(json['birth_date'] as String)
        : null,
    gender: json['gender'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    bio: json['bio'] as String?,
    address: json['address'] as String?,
    userType: json['user_type'] as String? ?? 'client',
    hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
    isVerified: json['is_verified'] as bool? ?? false,
    serviceCategories: ServiceCategoriesResolver.parse(
      json['service_categories'],
    ),
  );

  Map<String, dynamic> toUpdateJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    if (birthDate != null)
      'birth_date': birthDate!.toIso8601String().split('T').first,
    if (gender != null) 'gender': gender,
    'bio': bio,
    'address': address,
    'service_categories': serviceCategories,
    if (hourlyRate != null) 'hourly_rate': hourlyRate,
  };

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? avatarUrl,
    String? bio,
    String? address,
    double? hourlyRate,
    List<String>? serviceCategories,
  }) => UserProfile(
    id: id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email,
    phone: phone ?? this.phone,
    birthDate: birthDate ?? this.birthDate,
    gender: gender ?? this.gender,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    bio: bio ?? this.bio,
    address: address ?? this.address,
    userType: userType,
    hourlyRate: hourlyRate ?? this.hourlyRate,
    isVerified: isVerified,
    serviceCategories: serviceCategories ?? this.serviceCategories,
  );
}
