class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imagePath,
    this.additionalInfo = '',
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final String description;
  final String imagePath;
  final String additionalInfo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'description': description,
        'imagePath': imagePath,
        'additionalInfo': additionalInfo,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        price: (json['price'] as num).toInt(),
        description: json['description'] as String? ?? '',
        imagePath: json['imagePath'] as String? ?? '',
        additionalInfo: json['additionalInfo'] as String? ?? '',
      );

  Product copyWith({
    String? id,
    String? name,
    String? category,
    int? price,
    String? description,
    String? imagePath,
    String? additionalInfo,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
