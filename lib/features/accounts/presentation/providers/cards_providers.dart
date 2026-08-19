import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/mock_cards_data_source.dart';
import '../../data/models/account_transaction_model.dart';
import '../../data/models/payment_card_model.dart';

/// Backs the Cards screen with static demo data while the real card/account
/// APIs are not yet integrated. Swap the data source below for the live API
/// when wiring it up.
final mockCardsDataSourceProvider = Provider<MockCardsDataSource>(
  (ref) => const MockCardsDataSource(),
);

final cardsProvider = FutureProvider<List<PaymentCard>>((ref) async {
  return ref.watch(mockCardsDataSourceProvider).cards;
});

/// Static recent transactions shown on the Cards screen.
final cardTransactionsProvider =
    FutureProvider<List<AccountTransaction>>((ref) async {
  return ref.watch(mockCardsDataSourceProvider).recentTransactions;
});

/// Card ids that are currently frozen (local demo state only).
final frozenCardsProvider = StateProvider<Set<String>>(
  (ref) => const <String>{},
);

/// Toggles the frozen state of a card locally.
void toggleFrozenCard(WidgetRef ref, String cardId) {
  final notifier = ref.read(frozenCardsProvider.notifier);
  final current = notifier.state;
  final next = <String>{...current};
  if (!next.remove(cardId)) {
    next.add(cardId);
  }
  notifier.state = next;
}