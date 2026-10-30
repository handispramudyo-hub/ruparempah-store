import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cart_item.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.items,
    required this.totalItems,
    required this.total,
    required this.paid,
    required this.change,
  });

  final List<CartItem> items;
  final int totalItems;
  final int total;
  final int paid;
  final int change;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppGradients.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGreen.withValues(alpha: 0.3),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pembayaran Berhasil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.heading,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Terima kasih telah berbelanja di Rupa Rempah Store.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.body,
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _row('Total Barang', '$totalItems'),
                    const Divider(),
                    _row('Total Transaksi', currency.format(total)),
                    _row('Jumlah Pembayaran', currency.format(paid)),
                    _row('Kembalian', currency.format(change), highlight: true),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Rincian Barang',
                style: TextStyle(
                  fontFamily: AppTheme.heading,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              ...items.map(
                (i) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${i.product.name} x${i.quantity}',
                          style: const TextStyle(
                              fontFamily: AppTheme.body, fontSize: 13),
                        ),
                      ),
                      Text(
                        currency.format(i.subtotal),
                        style: const TextStyle(
                          fontFamily: AppTheme.heading,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              GradientButton(
                label: 'Kembali ke Dashboard',
                icon: Icons.home_outlined,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontFamily: AppTheme.body, color: AppColors.muted)),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: AppTheme.heading,
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.darkGreen : AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
