import 'package:flutter_test/flutter_test.dart';
import 'package:fourhorses/features/auth/presentation/utils/auth_formatters.dart';
import 'package:fourhorses/features/auth/data/models/registration_data.dart';
import 'package:fourhorses/features/auth/data/models/user_type.dart';

void main() {
  // ─── maskEmail ─────────────────────────────────────────────────────────────

  group('maskEmail', () {
    test('masque la partie locale au-delà des 2 premiers caractères', () {
      final result = maskEmail('jean.dupont@gmail.com');
      expect(result, startsWith('je'));
      expect(result, endsWith('@gmail.com'));
      expect(result, contains('•'));
      expect(result, isNot(contains('an.dupon')));
    });

    test('préserve le domaine intact', () {
      expect(maskEmail('test@inkern.fr'), startsWith('te'));
      expect(maskEmail('test@inkern.fr'), contains('@inkern.fr'));
    });

    test('email court (≤ 2 caractères avant @) → retourné tel quel', () {
      expect(maskEmail('ab@gmail.com'), 'ab@gmail.com');
    });

    test('sans @ → retourné tel quel', () {
      expect(maskEmail('pasdearobase'), 'pasdearobase');
    });

    test('email vide → retourné tel quel', () {
      expect(maskEmail(''), '');
    });
  });

  // ─── maskPhone ─────────────────────────────────────────────────────────────

  group('maskPhone', () {
    test('masque les chiffres du milieu', () {
      final result = maskPhone('+33612345678');
      expect(result, contains('+33'));
      expect(result, contains('••'));
      expect(result, endsWith('78'));
    });

    test('contient toujours le préfixe +33', () {
      expect(maskPhone('0612345678'), contains('+33'));
    });

    test('numéro trop court (< 4 chiffres) → retourné tel quel', () {
      expect(maskPhone('123'), '123');
    });

    test('les 2 derniers chiffres sont visibles', () {
      final result = maskPhone('+33698765432');
      expect(result, endsWith('32'));
    });
  });

  // ─── friendlyAuthError ─────────────────────────────────────────────────────

  group('friendlyAuthError', () {
    test('Invalid login credentials → message français', () {
      expect(
        friendlyAuthError('Invalid login credentials'),
        'Email ou mot de passe incorrect',
      );
    });

    test('Email not confirmed → demande de confirmation', () {
      expect(
        friendlyAuthError('Email not confirmed'),
        'Confirmez votre email avant de vous connecter',
      );
    });

    test('User already registered → email déjà utilisé', () {
      expect(
        friendlyAuthError('User already registered'),
        'Cet email est déjà utilisé',
      );
    });

    test('Password should be → mot de passe trop court', () {
      expect(
        friendlyAuthError('Password should be at least 8 characters'),
        'Mot de passe trop court (minimum 8 caractères)',
      );
    });

    test('erreur inconnue → message générique', () {
      expect(
        friendlyAuthError('some_unknown_error_code'),
        'Une erreur est survenue',
      );
    });

    test('message vide → message générique', () {
      expect(friendlyAuthError(''), 'Une erreur est survenue');
    });
  });

  // ─── RegistrationData.toJson ───────────────────────────────────────────────

  group('RegistrationData.toJson', () {
    test('contient tous les champs requis', () {
      final data = RegistrationData()
        ..userType = UserType.client
        ..email = 'jean@test.fr'
        ..phone = '+33612345678'
        ..firstName = 'Jean'
        ..lastName = 'Dupont'
        ..birthDate = DateTime(1990, 5, 15);

      final json = data.toJson();

      expect(json['user_type'], 'client');
      expect(json['email'], 'jean@test.fr');
      expect(json['phone'], '+33612345678');
      expect(json['first_name'], 'Jean');
      expect(json['last_name'], 'Dupont');
      expect(json['birth_date'], isNotNull);
    });

    test('birthDate sérialisé en ISO8601', () {
      final data = RegistrationData()..birthDate = DateTime(1990, 5, 15);
      expect(data.toJson()['birth_date'], startsWith('1990-05-15'));
    });

    test('gender homme → "homme"', () {
      final data = RegistrationData()..gender = Gender.homme;
      expect(data.toJson()['gender'], 'homme');
    });

    test('gender femme → "femme"', () {
      final data = RegistrationData()..gender = Gender.femme;
      expect(data.toJson()['gender'], 'femme');
    });

    test('champs non renseignés → null dans le json', () {
      final data = RegistrationData();
      final json = data.toJson();
      expect(json['email'], isNull);
      expect(json['phone'], isNull);
    });
  });

  // ─── passwordStrength ──────────────────────────────────────────────────────

  group('passwordStrength', () {
    test('vide → 0', () {
      expect(passwordStrength(''), 0);
    });

    test('moins de 4 caractères → 0', () {
      expect(passwordStrength('abc'), 0);
    });

    test('4 caractères sans critères → 0', () {
      expect(passwordStrength('abcd'), 0);
    });

    test('8+ caractères minuscules → 1', () {
      expect(passwordStrength('motdepasse'), 1);
    });

    test('8+ caractères + majuscule → 2', () {
      expect(passwordStrength('Motdepasse'), 2);
    });

    test('8+ caractères + majuscule + chiffre → 3', () {
      expect(passwordStrength('Motdepasse1'), 3);
    });

    test('tous les critères → 4 (score max)', () {
      expect(passwordStrength('Motdepasse1!'), 4);
    });

    test('court avec majuscule + chiffre + spécial → 0 (< 4 chars)', () {
      expect(passwordStrength('A1!'), 0);
    });
  });

  // ─── isPhoneComplete ───────────────────────────────────────────────────────

  group('isPhoneComplete', () {
    test('numéro complet (10 chiffres) → true', () {
      expect(isPhoneComplete('0612345678', 10), true);
    });

    test('numéro avec espaces et +33 → true si assez de chiffres', () {
      expect(isPhoneComplete('+33 6 12 34 56 78', 10), true);
    });

    test('numéro trop court → false', () {
      expect(isPhoneComplete('061234', 10), false);
    });

    test('numéro vide → false', () {
      expect(isPhoneComplete('', 10), false);
    });

    test('exactement le nombre requis → true', () {
      expect(isPhoneComplete('1234567890', 10), true);
    });
  });

  // ─── Gender labels ─────────────────────────────────────────────────────────

  group('Gender.label', () {
    test('homme → "Homme"', () => expect(Gender.homme.label, 'Homme'));
    test('femme → "Femme"', () => expect(Gender.femme.label, 'Femme'));
    test('autre → "Autre"', () => expect(Gender.autre.label, 'Autre'));
  });

  // ─── UserType ──────────────────────────────────────────────────────────────

  group('UserType', () {
    test('client → 4 étapes', () {
      expect(UserType.client.totalSteps, 4);
    });

    test('freelancer → 6 étapes', () {
      expect(UserType.freelancer.totalSteps, 6);
    });

    test('client → label "Client"', () {
      expect(UserType.client.label, 'Client');
    });

    test('freelancer → label "Prestataire"', () {
      expect(UserType.freelancer.label, 'Prestataire');
    });

    test('client → description cherche un prestataire', () {
      expect(UserType.client.description, contains('prestataire'));
    });

    test('freelancer → description propose des services', () {
      expect(UserType.freelancer.description, contains('services'));
    });
  });
}
