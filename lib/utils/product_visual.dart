import 'package:flutter/material.dart';

/// Helper visual untuk produk (placeholder gambar).
/// Menghindari ketergantungan pada file gambar eksternal.
class ProductVisual {
  ProductVisual._();

  static Color colorFor(String id) {
    const colors = <Color>[
      Color(0xFF8FAF8B),
      Color(0xFFB85C38),
      Color(0xFFD4AF37),
      Color(0xFF667C45),
      Color(0xFF5B8A72),
      Color(0xFFA0522D),
      Color(0xFF7B9E6B),
      Color(0xFFC9A227),
    ];
    final hash = id.hashCode.abs();
    return colors[hash % colors.length];
  }

  static IconData iconFor(String category) {
    switch (category) {
      case 'Sabun':
        return Icons.soap;
      case 'Scrub':
        return Icons.spa;
      case 'Lotion':
        return Icons.water_drop;
      case 'Face Wash':
        return Icons.face;
      case 'Skin Care':
        return Icons.self_improvement;
      case 'Minyak':
        return Icons.opacity;
      case 'Paket':
        return Icons.card_giftcard;
      default:
        return Icons.grain;
    }
  }
}
