import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../data/product_data.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._prefs);

  final SharedPreferences _prefs;
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  List<String> get categories {
    final result = <String>{};
    for (final product in _products) {
      result.add(product.category);
    }
    final list = result.toList()..sort();
    return list;
  }

  Future<void> load() async {
    final raw = _prefs.getString(AppConfig.keyProducts);
    if (raw == null || raw.isEmpty) {
      _products
        ..clear()
        ..addAll(productList);
      await _persist();
      notifyListeners();
      return;
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final loaded = decoded
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      if (loaded.isNotEmpty) {
        _products
          ..clear()
          ..addAll(loaded);
      } else {
        _products
          ..clear()
          ..addAll(productList);
      }
    } catch (e) {
      debugPrint('Gagal memuat katalog produk: $e');
      _products
        ..clear()
        ..addAll(productList);
    }
    await _persist();
    notifyListeners();
  }

  String nextId() => 'p${DateTime.now().microsecondsSinceEpoch}';

  Future<void> add(Product product) async {
    if (_products.any((p) => p.id == product.id)) {
      await update(product);
      return;
    }
    _products.add(product);
    await _persist();
    notifyListeners();
  }

  Future<void> update(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index == -1) return;
    _products[index] = product;
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    await _persist();
    notifyListeners();
  }

  Future<void> restoreDefaults() async {
    _products
      ..clear()
      ..addAll(productList);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final raw = jsonEncode(_products.map((p) => p.toJson()).toList());
    await _prefs.setString(AppConfig.keyProducts, raw);
  }
}
