import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

class RupaRempahApp extends StatelessWidget {
  const RupaRempahApp({
    super.key,
    required this.authService,
    required this.cartProvider,
    required this.productProvider,
  });

  final AuthService authService;
  final CartProvider cartProvider;
  final ProductProvider productProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
