import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = await AuthService.create();
  final prefs = await SharedPreferences.getInstance();
  final productProvider = ProductProvider(prefs);
  await productProvider.load();
  final cartProvider = CartProvider(prefs);
  await cartProvider.load(productProvider.products);
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => RupaRempahApp(
        authService: authService,
        cartProvider: cartProvider,
        productProvider: productProvider,
      ),
    ),
  );
}
