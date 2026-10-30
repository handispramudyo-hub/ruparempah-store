# PANDUAN BUILD APK — TANPA ANDROID STUDIO

Status: Android SDK kini sudah cukup untuk build APK dari mesin ini (build berhasil).
Ikuti langkah berikut (Command-Line Tools saja, tanpa membuka Android Studio).

## 1. Unduh Command-Line Tools
Unduh `commandlinetools-win-*.zip` dari:
https://developer.android.com/studio#command-line-tools-only

## 2. Ekstrak ke folder SDK
Contoh lokasi SDK: `C:\Android\Sdk`
Struktur yang benar (WAJIB ada folder `latest`):
```
C:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat
```
Jika hasil ekstrak masih bernama `cmdline-tools`, buat folder `latest` lalu pindahkan isinya ke dalamnya.

## 3. Set Android SDK untuk Flutter
```
flutter config --android-sdk "C:\Android\Sdk"
```

## 4. Terima lisensi & pasang komponen wajib
Jalankan satu per satu:
```
& "C:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" --licenses
& "C:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

## 5. Verifikasi
```
flutter doctor -v
```
Pastikan `[√] Android toolchain` sudah tercentang.

## 6. Build APK
Dari folder project:
```
cd "D:\data dio\SMT VII\PPB\UTS\rupa_rempah_store"
flutter build apk --release
```

## 7. Verifikasi file APK
```
Test-Path "build\app\outputs\flutter-apk\app-release.apk"
```
Jika `True`, APK berhasil dibuat di:
`build\app\outputs\flutter-apk\app-release.apk`

> Jangan menandai APK berhasil sebelum file di atas benar-benar ada.
