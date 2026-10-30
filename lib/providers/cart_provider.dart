import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../data/product_data.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._prefs);

  final SharedPreferences _prefs;
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);

  int get totalPrice => _items.fold(0, (sum, i) => sum + i.subtotal);

  bool get isEmpty => _items.isEmpty;

  CartItem? _find(String productId) {
    for (final item in _items) {
      if (item.product.id == productId) return item;
    }
    return null;
  }

  void addProduct(Product product) {
    final existing = _find(product.id);
    if (existing != null) {
      existing.quantity += 1;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    _persist();
    notifyListeners();
  }

  void increment(String productId) {
    final item = _find(productId);
    if (item == null) return;
    item.quantity += 1;
    _persist();
    notifyListeners();
  }

  void decrement(String productId) {
    final item = _find(productId);
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(item);
    } else {
      item.quantity -= 1;
    }
    _persist();
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    _persist();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _persist();
    notifyListeners();
  }

  /// Menyelaraskan produk pada keranjang setelah katalog diubah.
  void updateProduct(Product product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index == -1) return;
    _items[index] = CartItem(
      product: product,
      quantity: _items[index].quantity,
    );
    _persist();
    notifyListeners();
  }

  Future<void> load([List<Product>? catalog]) async {
    final source = catalog ?? productList;
    final raw = _prefs.getString(AppConfig.keyCart);
    if (raw == null || raw.isEmpty) return;
    _items.clear();
    try {
      // stored as "id:qty,id:qty"
      for (final part in raw.split(',')) {
        if (part.isEmpty) continue;
        final kv = part.split(':');
        if (kv.length != 2) continue;
        final index = source.indexWhere((p) => p.id == kv[0]);
        if (index == -1) continue;
        final qty = int.tryParse(kv[1]) ?? 1;
        _items.add(CartItem(product: source[index], quantity: qty));
      }
      _persist();
      notifyListeners();
    } catch (_) {
      // ignore corrupt cart
    }
  }

  void _persist() {
    final value = _items.map((i) => '${i.product.id}:${i.quantity}').join(',');
    _prefs.setString(AppConfig.keyCart, value);
  }
}
