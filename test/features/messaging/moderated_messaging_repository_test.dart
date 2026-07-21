import 'package:flutter_test/flutter_test.dart';
import 'package:fourhorses/features/messaging/data/repositories/moderated_messaging_repository.dart';
import 'helpers/fake_messaging_repository.dart';

void main() {
  late FakeMessagingRepository fake;
  late ModeratedMessagingRepository repo;

  setUp(() {
    fake = FakeMessagingRepository();
    repo = ModeratedMessagingRepository(fake);
  });

  group('sendMessage — messages autorisés', () {
    test('texte normal passe sans erreur', () async {
      final msg = await repo.sendMessage('c1', 'u1', 'Bonjour, comment ça va ?');
      expect(msg, isNotNull);
      expect(fake.sendCallCount, 1);
    });

    test('emoji seul est autorisé', () async {
      final msg = await repo.sendMessage('c1', 'u1', '👍');
      expect(msg, isNotNull);
    });

    test('localisation GPS est autorisée', () async {
      final msg = await repo.sendMessage('c1', 'u1', '📍 36.8065,10.1815');
      expect(msg, isNotNull);
    });

    test('localisation avec coordonnées négatives est autorisée', () async {
      final msg = await repo.sendMessage('c1', 'u1', '📍 -33.8688,151.2093');
      expect(msg, isNotNull);
    });
  });

  group('sendMessage — messages bloqués', () {
    test('numéro de téléphone français déclenche ModerationException', () {
      expect(
        () => repo.sendMessage('c1', 'u1', 'Mon numéro : 06 12 34 56 78'),
        throwsA(isA<ModerationException>()),
      );
    });

    test('numéro tunisien déclenche ModerationException', () {
      expect(
        () => repo.sendMessage('c1', 'u1', '+216 22 123 456'),
        throwsA(isA<ModerationException>()),
      );
    });

    test('adresse email est bloquée', () {
      expect(
        () => repo.sendMessage('c1', 'u1', 'Écris-moi à test@gmail.com'),
        throwsA(isA<ModerationException>()),
      );
    });

    test('mention de WhatsApp est bloquée', () {
      expect(
        () => repo.sendMessage('c1', 'u1', 'Contacte-moi sur WhatsApp'),
        throwsA(isA<ModerationException>()),
      );
    });

    test('intent de contact est bloqué', () {
      expect(
        () => repo.sendMessage('c1', 'u1', 'Appelle-moi'),
        throwsA(isA<ModerationException>()),
      );
    });

    test('delegate NOT appelé quand bloqué', () async {
      try {
        await repo.sendMessage('c1', 'u1', '06 12 34 56 78');
      } on ModerationException {
        // expected
      }
      expect(fake.sendCallCount, 0);
    });
  });

  group('autres méthodes — délèguent sans modification', () {
    test('getMessages délègue', () async {
      final msgs = await repo.getMessages('c1');
      expect(msgs, isEmpty);
    });

    test('markAsRead délègue', () async {
      await repo.markAsRead('c1', 'u1');
      expect(fake.markAsReadCallCount, 1);
    });

    test('getOrCreateConversation délègue', () async {
      final id = await repo.getOrCreateConversation(
        clientId: 'c1',
        freelancerId: 'f1',
      );
      expect(id, equals('conv_test'));
    });
  });
}
