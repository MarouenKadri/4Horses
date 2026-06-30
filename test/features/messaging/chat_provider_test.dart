import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/messaging/data/models/message.dart';
import 'package:flutter_application_1/features/messaging/presentation/providers/chat_provider.dart';
import 'helpers/fake_messaging_repository.dart';

ChatProvider _makeProvider({
  FakeMessagingRepository? repo,
  String userId = 'user-1',
}) {
  return ChatProvider(
    repository: repo ?? FakeMessagingRepository(),
    testCurrentUserId: userId,
  );
}

void main() {
  group('ChatProvider — open()', () {
    test('charge les messages et passe isLoading à false', () async {
      final repo = FakeMessagingRepository(messages: [
        ChatMessage(
          id: 'm1',
          conversationId: 'c1',
          senderId: 'user-2',
          content: 'Bonjour',
          createdAt: DateTime.now(),
        ),
      ]);
      final provider = _makeProvider(repo: repo);

      await provider.open('c1');

      expect(provider.isLoading, isFalse);
      expect(provider.messages.length, 1);
      expect(provider.messages.first.content, 'Bonjour');
      expect(provider.error, isNull);
      provider.dispose();
    });

    test('expose une erreur si le réseau échoue', () async {
      final repo = FakeMessagingRepository(shouldThrow: true);
      final provider = _makeProvider(repo: repo);

      await provider.open('c1');

      expect(provider.error, isNotNull);
      expect(provider.messages, isEmpty);
      provider.dispose();
    });

    test('forceRefresh recharge même si conversationId identique', () async {
      // Use a repo that counts getMessages calls via override
      final countingRepo = _CountingRepo();
      final provider = _makeProvider(repo: countingRepo);

      await provider.open('c1');
      await provider.open('c1'); // same id, no force → skip
      await provider.open('c1', forceRefresh: true); // force → re-fetch

      expect(countingRepo.getMessagesCallCount, 2);
      provider.dispose();
    });
  });

  group('ChatProvider — sendMessage()', () {
    test('ajoute le message et retourne null (succès)', () async {
      final repo = FakeMessagingRepository();
      final provider = _makeProvider(repo: repo);
      await provider.open('c1');

      final error = await provider.sendMessage('Salut');

      expect(error, isNull);
      expect(provider.messages.length, 1);
      expect(provider.messages.first.status, MessageStatus.sent);
      expect(provider.messages.first.content, 'Salut');
    });

    test('marque le message en failed si le réseau échoue', () async {
      final repo = FakeMessagingRepository(sendError: 'Erreur réseau');
      final provider = _makeProvider(repo: repo);
      await provider.open('c1');

      final error = await provider.sendMessage('Test');

      expect(error, isNotNull);
      expect(provider.messages.length, 1);
      expect(provider.messages.first.status, MessageStatus.failed);
    });

    test('retourne erreur si non connecté (userId null)', () async {
      final provider = ChatProvider(
        repository: FakeMessagingRepository(),
        testCurrentUserId: null, // simule utilisateur déconnecté
      );
      // Bypass open() to set conversationId without network
      final error = await provider.sendMessage('Test');
      expect(error, equals('Non connecté'));
      provider.dispose();
    });
  });

  group('ChatProvider — retryMessage()', () {
    test('renvoie un message failed et le passe en sent', () async {
      final repo = FakeMessagingRepository();
      final provider = _makeProvider(repo: repo);
      await provider.open('c1');

      // Simuler un message failed
      repo.sendError = 'Erreur réseau';
      await provider.sendMessage('Hello');
      expect(provider.messages.first.status, MessageStatus.failed);

      // Activer le réseau et réessayer
      repo.sendError = null;
      await provider.retryMessage(provider.messages.first);

      expect(provider.messages.first.status, MessageStatus.sent);
    });
  });

  group('ChatProvider — close()', () {
    test('réinitialise tout l\'état', () async {
      final provider = _makeProvider();
      await provider.open('c1');

      provider.close();

      expect(provider.messages, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      provider.dispose();
    });
  });

  group('ChatProvider — loadMore()', () {
    test('ne fait rien si hasMore est false', () async {
      final repo = FakeMessagingRepository(); // getMessagesBefore retourne []
      final provider = _makeProvider(repo: repo);
      await provider.open('c1');
      // Après open avec < 100 messages, _hasMore = false
      expect(provider.hasMore, isFalse);

      await provider.loadMore();

      expect(provider.isLoadingMore, isFalse);
      provider.dispose();
    });
  });
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _CountingRepo extends FakeMessagingRepository {
  int getMessagesCallCount = 0;

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    getMessagesCallCount++;
    return const [];
  }
}
