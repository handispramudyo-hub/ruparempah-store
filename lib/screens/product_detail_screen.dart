import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../utils/product_visual.dart';
import '../widgets/gradient_button.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final color = ProductVisual.colorFor(product.id);
    final icon = ProductVisual.iconFor(product.category);
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.darkGreen,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 3,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.arrow_back, color: AppColors.darkGreen),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.55), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Center(child: Icon(icon, size: 120, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.sageGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              fontFamily: AppTheme.body,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Rp ${_formatPrice(product.price)}',
                          style: const TextStyle(
                            fontFamily: AppTheme.heading,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.terracotta,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontFamily: AppTheme.heading,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle('Deskripsi'),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontFamily: AppTheme.body,
                        fontSize: 14,
                        height: 1.55,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle('Informasi Produk'),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        product.additionalInfo.isEmpty
                            ? 'Tidak ada informasi tambahan.'
                            : product.additionalInfo,
                        style: const TextStyle(
                          fontFamily: AppTheme.body,
                          fontSize: 13.5,
                          height: 1.5,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    GradientButton(
                      label: 'Tambah ke Keranjang',
                      icon: Icons.add_shopping_cart,
                      onPressed: () {
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
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali ke Dashboard'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppTheme.heading,
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: AppColors.charcoal,
      ),
    );
  }
}
