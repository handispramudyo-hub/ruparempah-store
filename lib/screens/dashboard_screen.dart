import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../services/auth_service.dart';
import '../services/launcher_service.dart';
import '../theme/app_theme.dart';
import '../widgets/contact_sheet.dart';
import '../widgets/product_card.dart';
import 'login_screen.dart';
import 'manage_products_screen.dart';
import 'payment_screen.dart';
import 'product_detail_screen.dart';
import 'update_account_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _query = '';
  String _selectedCategory = 'Semua';

  List<Product> _filtered(List<Product> products) {
    final q = _query.trim().toLowerCase();
    return products.where((p) {
      final matchQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      final matchCat =
          _selectedCategory == 'Semua' || p.category == _selectedCategory;
      return matchQuery && matchCat;
    }).toList();
  }

  Future<void> _handleMenu(String value) async {
    switch (value) {
      case 'call':
        await showContactSheet(context, highlight: 'call');
        break;
      case 'sms':
        await showContactSheet(context, highlight: 'sms');
        break;
      case 'maps':
        await LauncherService.openMaps(AppConfig.mapsQuery);
        break;
      case 'kelola':
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
        );
        break;
      case 'update':
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpdateAccountScreen()),
        );
        break;
      case 'logout':
        final auth = context.read<AuthService>();
        await auth.setLoggedIn(false);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productProvider = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final products = productProvider.products;
    final categories = <String>['Semua', ...productProvider.categories];
    final filtered = _filtered(products);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.primaryColorDark,
                      child: ClipOval(
                        child: Image.asset('assets/images/ikon.png',
                            width: 28, height: 24),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            AppConfig.storeName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert,
                          color: theme.appBarTheme.iconTheme?.color),
                      onSelected: _handleMenu,
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'call', child: Text('Call Center')),
                        PopupMenuItem(value: 'sms', child: Text('SMS Center')),
                        PopupMenuItem(value: 'maps', child: Text('Lokasi/Maps')),
                        PopupMenuDivider(),
                        PopupMenuItem(value: 'kelola', child: Text('Kelola Produk')),
                        PopupMenuItem(value: 'update', child: Text('Update User & Password')),
                        PopupMenuItem(value: 'logout', child: Text('Logout')),
                      ],
                    ),
                  ],
                ).animate().fade(duration: 300.ms),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColorDark,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search category',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: theme.hintColor,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(8),
                        child: SvgPicture.asset('assets/vectors/search.svg',
                            width: 20, height: 20),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ),
                ),
              ).animate().fade(duration: 300.ms).slideY(begin: 1, duration: 300.ms),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 158,
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    initialPage: 1,
                    viewportFraction: 0.9,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                  ),
                  itemCount: 3,
                  itemBuilder: (context, index, _) {
                    final cards = [
                      'assets/images/card1.png',
                      'assets/images/card2.png',
                      'assets/images/card3.png',
                    ];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(cards[index], fit: BoxFit.cover),
                    );
                  },
                ),
              ).animate().fade(duration: 400.ms),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('Categories', style: theme.textTheme.titleLarge)),
                    Text(
                      'See all',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    final selected = _selectedCategory == c;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = c),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: selected
                                  ? theme.primaryColor
                                  : theme.primaryColorDark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.grain,
                              color: selected ? Colors.white : theme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            c,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('Best selling', style: theme.textTheme.titleLarge)),
                    Text(
                      'See all',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 260,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = filtered[index];
                    return ProductCard(
                      product: p,
                      onNameTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: p),
                        ),
                      ),
                      onImageTap: () {
                        context.read<CartProvider>().addProduct(p);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text('${p.name} ditambahkan.'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                      },
                    ).animate(delay: (80 * index).ms).fade().slideY(begin: 0.2);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total', style: theme.textTheme.bodySmall),
                        Text(
                          'Rp ${_formatPrice(cart.totalPrice)}',
                          style: TextStyle(
                            fontFamily: AppTheme.heading,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PaymentScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Bayar (${cart.totalItems})',
                        style: TextStyle(
                          fontFamily: AppTheme.heading,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
