import 'package:flutter/foundation.dart';
import '../data/models/payment_method.dart';

class PaymentMethodsProvider extends ChangeNotifier {
  final List<PaymentMethod> _cards = [
    PaymentMethod(
      id: '1',
      brand: 'Visa',
      last4: '4242',
      expiry: '12/26',
      isDefault: true,
    ),
    PaymentMethod(
      id: '2',
      brand: 'Mastercard',
      last4: '8888',
      expiry: '08/25',
      isDefault: false,
    ),
  ];

  List<PaymentMethod> get cards => List.unmodifiable(_cards);

  void addCard({
    required String brand,
    required String last4,
    required String expiry,
  }) {
    final isFirst = _cards.isEmpty;
    _cards.add(
      PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        brand: brand,
        last4: last4,
        expiry: expiry,
        isDefault: isFirst,
      ),
    );
    notifyListeners();
  }

  void removeCard(String id) {
    final idx = _cards.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    final wasDefault = _cards[idx].isDefault;
    _cards.removeAt(idx);
    if (wasDefault && _cards.isNotEmpty) {
      _cards[0] = _cards[0].copyWith(isDefault: true);
    }
    notifyListeners();
  }

  void setDefault(String id) {
    for (int i = 0; i < _cards.length; i++) {
      _cards[i] = _cards[i].copyWith(isDefault: _cards[i].id == id);
    }
    notifyListeners();
  }
}
