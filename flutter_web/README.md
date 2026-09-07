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

Lalu publish isi folder `build/web` ke branch/folder yang dipakai GitHub Pages.
