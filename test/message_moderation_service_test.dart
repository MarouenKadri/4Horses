import 'package:flutter_test/flutter_test.dart';
import 'package:fourhorses/features/messaging/data/services/message_moderation_service.dart';

void main() {
  final service = MessageModerationService.instance;

  ModerationResult check(String text) => service.check(text);

  group('Emails', () {
    test('email simple bloqué', () {
      expect(check('écris-moi sur jean@gmail.com').blocked, isTrue);
    });
    test('email espacé bloqué', () {
      expect(check('jean @ gmail . com').blocked, isTrue);
    });
    test('arobase en toutes lettres bloqué', () {
      expect(check('jean arobase mondomaine point fr').blocked, isTrue);
    });
    test('(at) bloqué', () {
      expect(check('jean (at) mondomaine').blocked, isTrue);
    });
    test('point com sans provider bloqué', () {
      expect(check('jean dupont point com').blocked, isTrue);
    });
    test('provider sans @ bloqué', () {
      expect(check('cherche moi sur GMAIL').blocked, isTrue);
    });
  });

  group('Téléphones', () {
    test('format FR classique bloqué', () {
      expect(check('06 12 34 56 78').blocked, isTrue);
    });
    test('+33 bloqué', () {
      expect(check('+33 6 12 34 56 78').blocked, isTrue);
    });
    test('tunisien bloqué', () {
      expect(check('appelle le 25 123 456').blocked, isTrue);
    });
    test('lettre O comme zéro bloqué', () {
      expect(check('O6 12 34 56 78').blocked, isTrue);
    });
    test('chiffres arabes bloqués', () {
      expect(check('٠٦١٢٣٤٥٦٧٨').blocked, isTrue);
    });
    test('chiffres pleine chasse bloqués', () {
      expect(check('０６１２３４５６７８').blocked, isTrue);
    });
    test('caractères invisibles retirés puis bloqué', () {
      expect(check('06​12​34​56​78').blocked, isTrue);
    });
    test('nombres en toutes lettres bloqués', () {
      expect(
        check('zero six douze trente quatre cinquante six soixante dix huit')
            .blocked,
        isTrue,
      );
    });
    test('mix chiffres et lettres bloqué', () {
      expect(check('06 douze 34 cinquante-six 78').blocked, isTrue);
    });
  });

  group('Apps externes', () {
    test('whatsapp bloqué', () {
      expect(check('passe sur WhatsApp').blocked, isTrue);
    });
    test('faute volontaire watsap bloquée', () {
      expect(check('t es sur watsap ?').blocked, isTrue);
    });
    test('lettres espacées bloquées', () {
      expect(check('w h a t s a p p ?').blocked, isTrue);
    });
    test('lettres avec points bloquées', () {
      expect(check('w.h.a.t.s.a.p.p').blocked, isTrue);
    });
    test('insta bloqué', () {
      expect(check('mon insta cest xxx').blocked, isTrue);
    });
    test('telegram accentué bloqué', () {
      expect(check('sur Télégram ?').blocked, isTrue);
    });
  });

  group('Numéro fractionné', () {
    test('fragments cumulés bloqués au seuil', () {
      final conv = 'conv-test-${DateTime.now().microsecondsSinceEpoch}';
      expect(
        service
            .check('06 12', conversationId: conv, recordFragment: true)
            .blocked,
        isFalse,
      );
      expect(
        service
            .check('34 56', conversationId: conv, recordFragment: true)
            .blocked,
        isFalse,
      );
      expect(
        service
            .check('78', conversationId: conv, recordFragment: true)
            .blocked,
        isTrue,
      );
    });
    test('prix isolé non bloqué', () {
      final conv = 'conv-prix-${DateTime.now().microsecondsSinceEpoch}';
      expect(
        service.check('50', conversationId: conv, recordFragment: true).blocked,
        isFalse,
      );
    });
  });

  group('Messages légitimes', () {
    test('message normal autorisé', () {
      expect(check('Bonjour, je suis disponible demain à 14h').blocked, isFalse);
    });
    test('prix autorisé', () {
      expect(check('Je propose 50€ pour cette mission').blocked, isFalse);
    });
    test('heure autorisée', () {
      expect(check('Rendez-vous à 14h30 ?').blocked, isFalse);
    });
    test('un/deux dans une phrase autorisés', () {
      expect(check('un rendez-vous et deux questions').blocked, isFalse);
    });
    test('position partagée autorisée', () {
      expect(check('📍 48.8566,2.3522').blocked, isFalse);
    });
    test('durée autorisée', () {
      expect(check('la mission dure 3 heures').blocked, isFalse);
    });
  });
}
