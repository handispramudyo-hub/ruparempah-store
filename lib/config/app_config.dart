/// Konfigurasi aplikasi yang mudah diubah.
///
/// Nilai placeholder di bawah ini disediakan untuk kebutuhan demonstrasi UTS.
/// Ganti dengan data resmi UMKM Rupa Rempah Solo sebelum rilis.
class AppConfig {
  AppConfig._();

  static const String appName = 'Rupa Rempah Store';
  static const String storeName = 'UMKM Rupa Rempah Solo';

  /// Nomor telepon placeholder. Ganti dengan nomor resmi toko.
  static const String storePhone = '081234567890';

  /// Pesan awal SMS.
  static const String smsMessage =
      'Halo Rupa Rempah Store, saya ingin bertanya tentang produk.';

  /// Query pencarian lokasi toko di Google Maps (bukan koordinat palsu).
  static const String mapsQuery = 'UMKM Rupa Rempah Solo';

  /// Kategori yang disarankan pada form produk.
  static const List<String> productCategories = [
    'Sabun',
    'Scrub',
    'Lotion',
    'Face Wash',
    'Skin Care',
    'Minyak',
    'Paket',
  ];

  // SharedPreferences keys
  static const String keyUsername = 'auth_username';
  static const String keyPasswordHash = 'auth_password_hash';
  static const String keyIsLoggedIn = 'auth_is_logged_in';
  static const String keyCart = 'cart_items';
  static const String keyProducts = 'product_catalog';

  // Akun awal demonstrasi.
  static const String defaultUsername = 'admin';
  static const String defaultPassword = 'admin123';

  static String mapsUrl() =>
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mapsQuery)}';

  static String telUrl() => 'tel:$storePhone';

  static String smsUrl() =>
      'sms:$storePhone?body=${Uri.encodeComponent(smsMessage)}';
}
