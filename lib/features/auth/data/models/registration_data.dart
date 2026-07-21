import 'dart:io';
import 'user_type.dart';

enum Gender { homme, femme, autre }

extension GenderExtension on Gender {
  String get label {
    switch (this) {
      case Gender.homme:
        return 'Homme';
      case Gender.femme:
        return 'Femme';
      case Gender.autre:
        return 'Autre';
    }
  }
}

class RegistrationData {
  UserType? userType;

  // Commun
  String? email;
  String? phone;
  String? password;

  // Client & Freelancer
  String? firstName;
  String? lastName;
  DateTime? birthDate;
  File? photo;

  // Freelancer
  Gender? gender;

  RegistrationData();

  Map<String, dynamic> toJson() {
    return {
      'user_type': userType?.name,
      'email': email,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender?.name,
    };
  }
}
