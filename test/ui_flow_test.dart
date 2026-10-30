import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rupa_rempah_store/data/product_data.dart';
import 'package:rupa_rempah_store/providers/cart_provider.dart';
import 'package:rupa_rempah_store/providers/product_provider.dart';
import 'package:rupa_rempah_store/screens/dashboard_screen.dart';
import 'package:rupa_rempah_store/screens/payment_screen.dart';
import 'package:rupa_rempah_store/services/auth_service.dart';
import 'package:rupa_rempah_store/theme/app_theme.dart';
import 'package:rupa_rempah_store/widgets/gradient_button.dart';

Future<(Widget, CartProvider, ProductProvider)> _app(Widget home) async {
  SharedPreferences.setMockInitialValues({});
  final auth = await AuthService.create();
  final prefs = await SharedPreferences.getInstance();
  final products = ProductProvider(prefs);
  await products.load();
  final cart = CartProvider(prefs);
  await cart.load(products.products);
  final widget = MultiProvider(
    providers: [
      Provider<AuthService>.value(value: auth),
      ChangeNotifierProvider<ProductProvider>.value(value: products),
      ChangeNotifierProvider<CartProvider>.value(value: cart),
    ],
    child: MaterialApp(theme: AppTheme.light(), home: home),
  );
  return (widget, cart, products);
}

void main() {
  testWidgets('dashboard bisa di-scroll dan membuka detail produk',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final (widget, cart, _) = await _app(const DashboardScreen());
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.text('Rupa Rempah Store'), findsOneWidget);
    expect(find.text(productList.first.name), findsOneWidget);

    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -280),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, 280),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
    await tester.pumpAndSettle();
    expect(cart.totalItems, 1);

    await tester.tap(find.text(productList.first.name));
    await tester.pumpAndSettle();

    expect(find.text('Deskripsi'), findsOneWidget);
    expect(find.text(productList.first.name), findsOneWidget);
  });

  testWidgets('kelola produk: tambah, edit, dan hapus', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final (widget, _, products) = await _app(const DashboardScreen());
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kelola'));
    await tester.pumpAndSettle();
    expect(find.text('Kelola Produk'), findsOneWidget);

    await tester.tap(find.text('Tambah Produk'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Produk'),
      'Sabun Jahe',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kategori'),
      'Sabun',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Harga'),
      '25000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi'),
      'Sabun jahe hangat.',
    );
    final saveNew = find.widgetWithText(GradientButton, 'Tambah Produk');
    await tester.ensureVisible(saveNew);
    await tester.pumpAndSettle();
    await tester.tap(saveNew);
    await tester.pumpAndSettle();

    expect(products.products.any((p) => p.name == 'Sabun Jahe'), true);

    final target = products.products.first;
    final newPrice = target.price + 1000;
    await tester.tap(find.byTooltip('Edit produk').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Harga'),
      '$newPrice',
    );
    final saveEdit = find.widgetWithText(GradientButton, 'Simpan Perubahan');
    await tester.ensureVisible(saveEdit);
    await tester.pumpAndSettle();
    await tester.tap(saveEdit);
    await tester.pumpAndSettle();
    expect(
      products.products.firstWhere((p) => p.id == target.id).price,
      newPrice,
    );

    await tester.tap(find.byTooltip('Hapus produk').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(products.products.any((p) => p.id == target.id), false);
  });

  testWidgets('menu Call Center menampilkan opsi kontak', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    try {
      final (widget, _, _) = await _app(const DashboardScreen());
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Call Center'));
      await tester.pumpAndSettle();

      expect(find.text('Hubungi Kami'), findsOneWidget);
      expect(find.text('Telepon Sekarang'), findsOneWidget);
      expect(find.text('Chat WhatsApp'), findsOneWidget);
      expect(find.text('Kirim SMS'), findsOneWidget);
      expect(find.text('Salin Nomor'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('pembayaran dengan uang pas menampilkan bukti transaksi',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final (widget, cart, _) = await _app(const PaymentScreen());
    cart.addProduct(productList.first);

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Uang Pas'));
    await tester.pump();

    await tester.tap(find.text('Proses Pembayaran'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Pembayaran Berhasil'), findsOneWidget);
    expect(find.text('Kembali ke Dashboard'), findsOneWidget);
  });
}

