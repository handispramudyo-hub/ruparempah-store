import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rupa_rempah_store/data/product_data.dart';
import 'package:rupa_rempah_store/models/product.dart';
import 'package:rupa_rempah_store/providers/cart_provider.dart';
import 'package:rupa_rempah_store/providers/product_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('katalog awal dimuat dari data produk', () async {
    final prefs = await SharedPreferences.getInstance();
    final provider = ProductProvider(prefs);
    await provider.load();
    expect(provider.products.length, productList.length);
    expect(provider.products.first.id, productList.first.id);
    expect(provider.categories.contains('Sabun'), true);
  });

  test('tambah, edit, dan hapus produk tersimpan', () async {
    final prefs = await SharedPreferences.getInstance();
    final provider = ProductProvider(prefs);
    await provider.load();

    const product = Product(
      id: 'test-1',
      name: 'Sabun Jahe',
      category: 'Sabun',
      price: 25000,
      description: 'Sabun jahe hangat.',
      imagePath: '',
      additionalInfo: 'Isi 100ml',
    );
    await provider.add(product);
    expect(provider.products.any((p) => p.id == 'test-1'), true);

    await provider.update(product.copyWith(price: 30000, name: 'Sabun Jahe 2'));
    final updated =
        provider.products.firstWhere((p) => p.id == 'test-1');
    expect(updated.price, 30000);
    expect(updated.name, 'Sabun Jahe 2');

    final reloaded = ProductProvider(prefs);
    await reloaded.load();
    expect(reloaded.products.any((p) => p.id == 'test-1'), true);
    expect(
      reloaded.products.firstWhere((p) => p.id == 'test-1').price,
      30000,
    );

    await provider.remove('test-1');
    expect(provider.products.any((p) => p.id == 'test-1'), false);
  });

  test('keranjang memakai katalog terbaru dan ikut update harga', () async {
    final prefs = await SharedPreferences.getInstance();
    final products = ProductProvider(prefs);
    await products.load();
    final cart = CartProvider(prefs);
    await cart.load(products.products);

    final first = products.products.first;
    cart.addProduct(first);

    final updated = first.copyWith(price: first.price + 5000);
    await products.update(updated);
    cart.updateProduct(updated);

    expect(cart.totalPrice, updated.price);
    expect(cart.items.first.product.name, updated.name);

    cart.remove(first.id);
    expect(cart.isEmpty, true);
  });
}
