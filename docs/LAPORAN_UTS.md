# LAPORAN UTS — RUPA REMPAH STORE

## 1. Identitas Project
- **Nama Aplikasi:** Rupa Rempah Store
- **Studi Kasus:** UMKM Rupa Rempah Solo
- **Mata Kuliah:** Pemrograman Perangkat Bergerak (PPB)
- **Universitas:** Universitas Dian Nuswantoro (UDINUS)
- **Platform Target:** Android (APK), dengan Web (Chrome) untuk preview/pengujian
- **Jenis Aplikasi:** Aplikasi penjualan produk UMKM

## 2. Tujuan Aplikasi
Membangun aplikasi sederhana untuk menampilkan katalog produk UMKM, memberikan informasi produk, melakukan simulasi transaksi penjualan, menghitung pembayaran, serta menyediakan akses komunikasi dan lokasi penjual.

## 3. Teknologi yang Digunakan
| Teknologi | Fungsi |
|-----------|--------|
| Flutter | Framework UI lintas platform |
| Dart | Bahasa pemrograman |
| Material Design 3 | Sistem desain antarmuka |
| SharedPreferences | Penyimpanan kredensial, status login, dan keranjang |
| Flutter Navigator | Navigasi antar halaman |
| URL Launcher | Membuka telepon, SMS, dan Google Maps |
| Intl | Format mata uang Rupiah |
| Provider | Pengelolaan state keranjang |
| Crypto (SHA-256) | Hashing password |

## 4. Struktur Project
```
lib/
├── main.dart                     # Entry point + inisialisasi service
├── app.dart                      # Setup Provider + MaterialApp
├── models/
│   ├── product.dart              # Model produk
│   └── cart_item.dart            # Model item keranjang
├── data/
│   └── product_data.dart         # Data katalog produk lokal
├── screens/
│   ├── splash_screen.dart        # Splash + cek status login
│   ├── login_screen.dart         # Login + validasi
│   ├── dashboard_screen.dart     # Katalog + pencarian + filter + menu
│   ├── product_detail_screen.dart# Detail produk
│   ├── payment_screen.dart       # Form pembayaran + kembalian
│   ├── payment_success_screen.dart # Bukti transaksi
│   └── update_account_screen.dart# Update user & password
├── widgets/
│   └── product_card.dart         # Kartu produk (grid)
├── services/
│   ├── auth_service.dart         # Autentikasi + SharedPreferences + hashing
│   └── launcher_service.dart     # URL Launcher (tel, sms, maps)
├── providers/
│   └── cart_provider.dart        # State keranjang + persistensi
├── config/
│   └── app_config.dart           # Konfigurasi toko (mudah diubah)
├── utils/
│   └── product_visual.dart       # Placeholder ikon & warna produk
└── theme/
    └── app_theme.dart            # Tema Material 3 (Sage Green)
```

## 5. Penjelasan Fitur
1. **Splash Screen** — Logo, nama aplikasi, "Selamat Datang", identitas UMKM, transisi otomatis ke Login/Dashboard sesuai status login.
2. **Login** — Validasi input kosong, cek username/password terhadap data ter-hash (SHA-256), tombol lihat/sembunyikan password, pesan error Bahasa Indonesia. Akun awal: `admin` / `admin123`.
3. **Status Login** — Disimpan di SharedPreferences (`auth_is_logged_in`) sehingga tidak perlu login ulang.
4. **Dashboard** — Halaman dapat di-scroll penuh (header, kategori, promo, katalog), grid produk responsif, pencarian nama, filter kategori dinamis, total penjualan di bawah, menu pojok kanan (Call Center, SMS Center, Lokasi/Maps, Kelola Produk, Update User & Password, Logout).
5. **Interaksi Produk**
   - **Klik nama produk** → membuka **Detail Produk** (tidak menambah transaksi).
   - **Klik gambar produk** → **menambahkan produk ke keranjang** (produk sama menambah jumlah) + snackbar feedback.
6. **Detail Produk** — Hero gambar (placeholder/luaran), nama, kategori, harga, deskripsi, info tambahan, tombol tambah ke keranjang, dan tombol kembali.
7. **Keranjang** — Tambah/kurangi jumlah, hapus item, subtotal & total otomatis.
8. **Pembayaran** — Total transaksi, input nominal (angka saja), validasi uang kurang, kembalian otomatis, proses pembayaran, bukti transaksi, keranjang dikosongkan setelah berhasil.
9. **Call Center / SMS Center** — Di Android/iOS langsung membuka aplikasi telepon/SMS via `tel:` dan `sms:`. Di browser desktop, tampil **bottom sheet kontak** dengan opsi Telepon, Chat WhatsApp (`wa.me`), Kirim SMS, dan Salin Nomor — sehingga tetap berfungsi meski perangkat tidak punya aplikasi telepon/SMS.
10. **Lokasi/Maps** — Membuka Google Maps dengan query lokasi yang dapat dikonfigurasi.
11. **Kelola Produk (CRUD)** — Menu **Kelola** / **Kelola Produk** untuk menambah, mengedit, dan menghapus produk. Data tersimpan di SharedPreferences (bertahan setelah aplikasi ditutup), kategori dashboard menyesuaikan otomatis, dan perubahan/hapus produk ikut disinkronkan ke keranjang. Hapus produk memakai dialog konfirmasi + aksi **Urungkan**. Gambar produk bisa diambil dari galeri (image_picker) dan path-nya ikut tersimpan di katalog produk.
12. **Update User & Password** — Ubah username/password dengan validasi & konfirmasi; akun baru langsung dapat dipakai login.
13. **Logout** — Menghapus status login dan kembali ke halaman login.

## 6. Hasil Pengujian
### Otomatis
- `flutter analyze` → **No issues found**
- `flutter test` → **15 tests passed**
  - Subtotal = harga × jumlah
  - Total = jumlah seluruh subtotal
  - Total item menghitung kuantitas
  - Decrement menghapus item saat jumlah 0
  - Remove menghapus produk
  - Clear mengosongkan keranjang
  - Perhitungan kembalian
  - Validasi pembayaran kurang
  - Produk: katalog awal dimuat, tambah/edit/hapus tersimpan, keranjang ikut update harga
  - UI: Dashboard dapat di-scroll tanpa overflow, klik gambar menambah keranjang, klik nama membuka detail
  - UI: Alur tambah, edit, dan hapus produk dari menu Kelola
  - UI: Menu Call Center menampilkan opsi Telepon/WhatsApp/SMS/Salin Nomor
  - UI: Alur pembayaran "Uang Pas" menampilkan bukti transaksi

### Manual (Chrome)
- Aplikasi berhasil dijalankan dengan `flutter run -d chrome`.
- `flutter build web --release` → **√ Built build\web**
- Splash → Login → Dashboard → Detail → Keranjang → Pembayaran → Bukti transaksi berjalan.

> Catatan: Screenshot aplikasi perlu diambil manual saat demonstrasi (belum disertakan sebagai bukti fiktif).

## 7. Status Build APK
**BERHASIL DIBANGUN di mesin ini.** File APK: `build\app\outputs\flutter-apk\app-release.apk` (49.2MB).
(`C:\Users\sandi\AppData\Local\Android\Sdk`) tidak lengkap — tidak memiliki
`cmdline-tools`, `platform-tools`, `build-tools`, dan `platforms`.
APK **tidak** diklaim berhasil sebelum file benar-benar ada.

Ikuti `docs/PANDUAN_BUILD_APK.md` untuk membuat APK.

## 8. Kesimpulan
Aplikasi Rupa Rempah Store telah diimplementasikan lengkap dengan Flutter +
Material 3, autentikasi lokal berbasis SharedPreferences dengan hashing,
katalog produk, keranjang, pembayaran, menu komunikasi/lokasi, serta update akun.
Kode lolos analyzer dan unit test, serta berhasil dijalankan dan di-build untuk web.
Build APK menunggu kelengkapan Android SDK di perangkat pengembang.

---

## Lampiran A — Skenario Presentasi
1. Buka aplikasi → tampil **Splash Screen**.
2. Login dengan `admin` / `admin123`.
3. Tampilkan **katalog produk**.
4. **Klik nama produk** → lihat deskripsi → kembali.
5. **Klik gambar produk** → tambah ke keranjang (lakukan beberapa kali).
6. Tunjukkan **total transaksi** di bawah.
7. Buka **halaman pembayaran**.
8. Uji nominal **kurang** (ditolak) → masukkan nominal **cukup**.
9. Tampilkan **kembalian** + **bukti transaksi**.
10. Tunjukkan **Call Center**, **SMS Center**, **Maps**.
11. Ubah **username/password**.
12. **Logout** lalu **login kembali** dengan akun baru.

## Lampiran B — Penjelasan Teknologi (untuk tanya jawab)
- **Flutter/Dart:** membangun UI deklaratif lintas platform dengan null safety.
- **Material 3:** tema warna Sage Green + Cream, komponen modern.
- **SharedPreferences:** menyimpan username (hash), status login, dan keranjang secara lokal.
- **Hashing SHA-256:** password tidak disimpan sebagai teks biasa (keterbatasan: hashing lokal tanpa salt, hanya untuk demo).
- **Navigator:** perpindahan halaman (push/pushReplacement/pop).
- **Provider:** menyimpan state keranjang agar total ter-update otomatis di seluruh UI.
- **URL Launcher:** membuka `tel:`, `sms:`, dan URL Google Maps.
- **Perhitungan:** Subtotal = harga × jumlah; Total = Σ subtotal; Kembalian = bayar − total.
