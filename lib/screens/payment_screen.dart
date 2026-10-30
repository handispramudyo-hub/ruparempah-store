import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _processing = false;

  final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _paid => int.tryParse(_controller.text.replaceAll('.', '')) ?? 0;

  void _setAmount(int value) {
    setState(() {
      _controller.text = value.toString();
      _error = null;
    });
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Kosongkan Transaksi?'),
        content: const Text('Seluruh item pada keranjang akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<CartProvider>().clear();
    }
  }

  Future<void> _process() async {
    final cart = context.read<CartProvider>();
    final total = cart.totalPrice;
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong.')),
      );
      return;
    }
    final paid = int.tryParse(_controller.text.replaceAll('.', '')) ?? 0;
    if (paid < total) {
      setState(() => _error = 'Uang pembayaran kurang.');
      return;
    }
    setState(() {
      _error = null;
      _processing = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final items = List.of(cart.items);
    final totalItems = cart.totalItems;
    cart.clear();
    if (!mounted) return;
    setState(() => _processing = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          items: items,
          totalItems: totalItems,
          total: total,
          paid: paid,
          change: paid - total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.totalPrice;
    final paid = _paid;
    final enough = paid >= total && total > 0;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Pembayaran'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              tooltip: 'Kosongkan transaksi',
              onPressed: _confirmClear,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 72, color: AppColors.muted.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text(
                    'Keranjang masih kosong.',
                    style: TextStyle(
                      fontFamily: AppTheme.heading,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tambahkan produk dengan mengetuk gambar produk.',
                    style: TextStyle(fontFamily: AppTheme.body,
                        color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkGreen.withValues(alpha: 0.3),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Transaksi',
                          style: TextStyle(
                            fontFamily: AppTheme.body,
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _currency.format(total),
                          style: const TextStyle(
                            fontFamily: AppTheme.heading,
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cart.totalItems} barang dalam keranjang',
                          style: const TextStyle(
                            fontFamily: AppTheme.body,
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Rincian Barang',
                    style: TextStyle(
                      fontFamily: AppTheme.heading,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...cart.items.map((i) => _itemRow(i.product.name, i.quantity, i.subtotal)),
                  const SizedBox(height: 18),
                  const Text(
                    'Jumlah Pembayaran',
                    style: TextStyle(
                      fontFamily: AppTheme.heading,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontFamily: AppTheme.heading,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masukkan nominal',
                      prefixText: 'Rp ',
                      errorText: _error,
                    ),
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _quickChip('Uang Pas',
                          () => _setAmount(total)),
                      _quickChip('Rp 50.000',
                          () => _setAmount(50000)),
                      _quickChip('Rp 100.000',
                          () => _setAmount(100000)),
                      _quickChip('Rp 200.000',
                          () => _setAmount(200000)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (enough)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.sageGreen.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kembalian',
                            style: TextStyle(
                              fontFamily: AppTheme.body,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _currency.format(paid - total),
                            style: const TextStyle(
                              fontFamily: AppTheme.heading,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 22),
                  GradientButton(
                    label: 'Proses Pembayaran',
                    icon: Icons.payments_outlined,
                    loading: _processing,
                    onPressed: _process,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _itemRow(String name, int qty, int subtotal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$name x$qty',
              style: const TextStyle(fontFamily: AppTheme.body, fontSize: 13),
            ),
          ),
          Text(
            _currency.format(subtotal),
            style: const TextStyle(
              fontFamily: AppTheme.heading,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: AppTheme.body,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGreen,
          ),
        ),
      ),
    );
  }
}
