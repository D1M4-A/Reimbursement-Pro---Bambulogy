# Reimburse Pro Flutter Web

Aplikasi Flutter Web ini membungkus flow HTML `ReimbursementPro.html` tanpa mengubah proses bisnis dan alur existing.

## Jalankan lokal

```bash
flutter pub get
flutter run -d chrome
```

## Build untuk GitHub Pages

Gunakan base href sesuai nama repository:

```bash
flutter build web --release --base-href /Reimbursement-Pro---Bambulogy/
```

## Deploy GitHub Pages (otomatis)

Repository ini menyediakan workflow `.github/workflows/flutter-pages.yml`.
Setelah push ke `main`, workflow akan:

1. Build Flutter Web dari folder `flutter_web`
2. Publish `flutter_web/build/web` ke GitHub Pages

Pastikan GitHub Pages repository diarahkan ke **GitHub Actions** sebagai source deployment.
