import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../utils/product_visual.dart';
import '../widgets/gradient_button.dart';
import '../widgets/product_image.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _price;
  late final TextEditingController _description;
  late final TextEditingController _additionalInfo;
  bool _saving = false;
  String _pickedImagePath = '';

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _price = TextEditingController(text: p == null ? '' : '${p.price}');
    _description = TextEditingController(text: p?.description ?? '');
    _additionalInfo = TextEditingController(text: p?.additionalInfo ?? '');
    _pickedImagePath = p?.imagePath ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _price.dispose();
    _description.dispose();
    _additionalInfo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<ProductProvider>();
    final cart = context.read<CartProvider>();
    final product = Product(
      id: widget.product?.id ?? provider.nextId(),
      name: _name.text.trim(),
      category: _category.text.trim(),
      price: int.parse(_price.text.replaceAll('.', '')),
      description: _description.text.trim(),
      imagePath: _pickedImagePath.isNotEmpty
          ? _pickedImagePath
          : (widget.product?.imagePath ?? ''),
      additionalInfo: _additionalInfo.text.trim(),
    );
    if (_isEdit) {
      await provider.update(product);
      cart.updateProduct(product);
    } else {
      await provider.add(product);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop(product);
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 70,
    );
    if (image == null) return;
    setState(() => _pickedImagePath = image.path);
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>{
      ...context.watch<ProductProvider>().categories,
      ...AppConfig.productCategories,
    }.toList()..sort();
    final previewColor = ProductVisual.colorFor(
      widget.product?.id ?? _category.text,
    );
    final previewIcon = ProductVisual.iconFor(_category.text);
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      previewColor.withValues(alpha: 0.35),
                      previewColor.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(previewIcon, color: previewColor, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name.text.trim().isEmpty
                                ? 'Nama Produk'
                                : _name.text.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTheme.heading,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rp ${_formatPrice(int.tryParse(_price.text) ?? 0)}',
                            style: const TextStyle(
                              fontFamily: AppTheme.body,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.terracotta,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama produk wajib diisi';
                  }
                  if (v.trim().length < 3) return 'Minimal 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Kategori wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((c) {
                  final selected = _category.text.trim() == c;
                  return GestureDetector(
                    onTap: () {
                      _category.text = c;
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.darkGreen : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.darkGreen
                              : AppColors.line,
                        ),
                      ),
                      child: Text(
                        c,
                        style: TextStyle(
                          fontFamily: AppTheme.body,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.charcoal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_pickedImagePath.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        previewColor.withValues(alpha: 0.35),
                        previewColor.withValues(alpha: 0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: ProductImage(
                        imagePath: _pickedImagePath,
                        fit: BoxFit.cover,
                        fallback: Container(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _pickedImagePath.isNotEmpty
                      ? 'Ganti Gambar Produk'
                      : 'Tambah Gambar Produk',
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixText: 'Rp ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final price = int.tryParse(v ?? '');
                  if (price == null || price <= 0) {
                    return 'Harga harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _description,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _additionalInfo,
                minLines: 2,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Info Tambahan (opsional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 22),
              GradientButton(
                label: _isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                icon: _isEdit ? Icons.save_outlined : Icons.add,
                loading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
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
