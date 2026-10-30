import 'dart:io';

import 'package:flutter/widgets.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    required this.fallback,
  });

  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: FileImage(File(imagePath)),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
