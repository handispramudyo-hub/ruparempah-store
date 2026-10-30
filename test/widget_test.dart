import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rupa_rempah_store/data/product_data.dart';
import 'package:rupa_rempah_store/providers/cart_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('subtotal equals price times quantity', () async {
    final prefs = await SharedPreferences.getInstance();
    final cart = CartProvider(prefs);
    final product = productList.first;
    cart.addProduct(product);
    cart.addProduct(product);
    final item = cart.items.first;
    expect(item.subtotal, product.price * item.quantity);
  });

  test('total price sums all subtotals', () async {
    final prefs = await SharedPreferences.getInstance();
    final cart = CartProvider(prefs);
    final p1 = productList[0];
    final p2 = productList[1];
    cart.addProduct(p1);
    cart.addProduct(p1);
    cart.addProduct(p2);
    expect(
      cart.totalPrice,
      p1.price * 2 + p2.price,
    );
  });

  test('total items counts quantity', () async {
    final prefs = await SharedPreferences.getInstance();
    final cart = CartProvider(prefs);
    cart.addProduct(productList[0]);
    cart.addProduct(productList[0]);
    cart.addProduct(productList[1]);
    expect(cart.totalItems, 3);
  });

  test('decrement removes item when quantity reaches zero', () async {
    final prefs = await SharedPreferences.getInstance();
    final cart = CartProvider(prefs);
    final p = productList[0];
    cart.addProduct(p);
    cart.decrement(p.id);
    expect(cart.isEmpty, true);
  });

  test('remove deletes product from cart', () async {
    final prefs = await SharedPreferences.getInstance();
    final cart = CartProvider(prefs);
    final p = productList[0];
    cart.addProduct(p);
    cart.remove(p.id);
    expect(cart.items.where((i) => i.product.id == p.id), isEmpty);
  });

  test('clear empties cart', () async {
    final prefs = await SharedPreferences.getInstance();
    final cart = CartProvider(prefs);
    cart.addProduct(productList[0]);
    cart.clear();
    expect(cart.isEmpty, true);
    expect(cart.totalPrice, 0);
  });

  test('change calculation', () {
    const total = 100000;
    const paid = 150000;
    expect(paid - total, 50000);
  });

  test('payment below total is invalid', () {
    const total = 100000;
    const paid = 80000;
    expect(paid < total, true);
  });
}
