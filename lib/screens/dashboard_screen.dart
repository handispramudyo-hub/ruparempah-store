import 'package:flutter/material.dart';
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
  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filtered(List<Product> products, String category) {
    return products.where((p) {
      final matchCat = category == 'Semua' || p.category == category;
      final matchQuery =
          _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());
      return matchCat && matchQuery;
    }).toList();
  }

  Future<void> _handleMenu(String value) async {
    switch (value) {
      case 'call':
        if (LauncherService.isNativeMobile) {
          final ok = await LauncherService.makePhoneCall(AppConfig.storePhone);
          if (ok) return;
        }
        if (!mounted) return;
        await showContactSheet(context, highlight: 'call');
        break;
      case 'sms':
        if (LauncherService.isNativeMobile) {
          final ok = await LauncherService.sendSms(
            AppConfig.storePhone,
            AppConfig.smsMessage,
          );
          if (ok) return;
        }
        if (!mounted) return;
        await showContactSheet(context, highlight: 'sms');
        break;
      case 'maps':
        final ok = await LauncherService.openMaps(AppConfig.mapsQuery);
        if (!mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
          );
        }
        break;
      case 'products':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
        );
        break;
      case 'account':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpdateAccountScreen()),
        );
        break;
      case 'logout':
        await context.read<AuthService>().logout();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        break;
    }
  }

  void _openManageProducts() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final allProducts = context.watch<ProductProvider>().products;
    final topInset = MediaQuery.of(context).padding.top;

    final categorySet = <String>{'Semua'};
    for (final product in allProducts) {
      categorySet.add(product.category);
    }
    final categories = categorySet.toList();
    final activeCategory =
        categories.contains(_category) ? _category : 'Semua';
    final products = _filtered(allProducts, activeCategory);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header(context, topInset)),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: _categoriesRow(categories, activeCategory),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 6)),
          SliverToBoxAdapter(child: _promoBanner()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'Katalog Produk',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTheme.heading,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${products.length}',
                          style: const TextStyle(
                            fontFamily: AppTheme.body,
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _openManageProducts,
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('Kelola'),
                  ),
                ],
              ),
            ),
          ),
          if (products.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 64,
                        color: AppColors.muted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text(
                      allProducts.isEmpty
                          ? 'Katalog masih kosong.'
                          : 'Produk tidak ditemukan.',
                      style: const TextStyle(
                        fontFamily: AppTheme.heading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      allProducts.isEmpty
                          ? 'Tambahkan produk pertama lewat menu Kelola.'
                          : 'Coba kata kunci atau kategori lain.',
                      style: const TextStyle(
                        fontFamily: AppTheme.body,
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _openManageProducts,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Kelola Produk'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.76,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onNameTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      onImageTap: () {
                        context.read<CartProvider>().addProduct(product);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text('${product.name} ditambahkan.'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                      },
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _CartSummaryBar(
        totalItems: cart.totalItems,
        totalPrice: cart.totalPrice,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PaymentScreen()),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, double topInset) {
    final username = context.read<AuthService>().getUsername() ?? 'Admin';
    return Container(
      padding: EdgeInsets.fromLTRB(20, topInset + 14, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.spa,
                    color: AppColors.deepGreen, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $username',
                      style: const TextStyle(
                        fontFamily: AppTheme.body,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      'Rupa Rempah Store',
                      style: TextStyle(
                        fontFamily: AppTheme.heading,
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                offset: const Offset(0, 48),
                onSelected: _handleMenu,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'call',
                    child: _MenuRow(Icons.call, 'Call Center'),
                  ),
                  PopupMenuItem(
                    value: 'sms',
                    child: _MenuRow(Icons.sms, 'SMS Center'),
                  ),
                  PopupMenuItem(
                    value: 'maps',
                    child: _MenuRow(Icons.location_on, 'Lokasi / Maps'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'products',
                    child: _MenuRow(Icons.inventory_2_outlined,
                        'Kelola Produk'),
                  ),
                  PopupMenuItem(
                    value: 'account',
                    child: _MenuRow(Icons.manage_accounts,
                        'Update User & Password'),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: _MenuRow(Icons.logout, 'Logout'),
                  ),
                ],
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari rempah favoritmu...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoriesRow(List<String> categories, String activeCategory) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = categories[i] == activeCategory;
          return GestureDetector(
            onTap: () => setState(() => _category = categories[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected ? AppGradients.primary : null,
                color: selected ? null : AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? Colors.transparent : AppColors.line,
                ),
              ),
              child: Text(
                categories[i],
                style: TextStyle(
                  fontFamily: AppTheme.body,
                  color: selected ? Colors.white : AppColors.charcoal,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _promoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          gradient: AppGradients.gold,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.softGold.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Promo Spesial',
                    style: TextStyle(
                      fontFamily: AppTheme.body,
                      color: AppColors.deepGreen,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Diskon 20% Paket Herbal',
                    style: TextStyle(
                      fontFamily: AppTheme.heading,
                      color: AppColors.deepGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Text(
                        'Belanja Sekarang',
                        style: TextStyle(
                          fontFamily: AppTheme.body,
                          color: AppColors.deepGreen,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward,
                          size: 13, color: AppColors.deepGreen),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.local_offer, size: 54, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.darkGreen),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  const _CartSummaryBar({
    required this.totalItems,
    required this.totalPrice,
    required this.onTap,
  });

  final int totalItems;
  final int totalPrice;
  final VoidCallback onTap;

  String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkGreen.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total Penjualan',
                          style: TextStyle(
                            fontFamily: AppTheme.body,
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '$totalItems barang · Rp ${_formatPrice(totalPrice)}',
                          style: const TextStyle(
                            fontFamily: AppTheme.heading,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
