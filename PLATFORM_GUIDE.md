# Panduan Menjalankan Tabunganku di Android dan iOS

## 1. Setup Awal (Wajib untuk Kedua Platform)

### Persyaratan
- Flutter SDK 3.0.0+
- Dart 3.0.0+
- Java Development Kit (JDK) 11+ untuk Android
- Xcode 14+ untuk iOS (di macOS)

### Install Dependencies
```bash
cd aplikasi
flutter pub get
```

---

## 2. Menjalankan di Android

### Persyaratan Android
- Android Studio atau Android SDK
- Emulator Android OR Device Android (untuk testing)
- Minimum API Level: 21 (Android 5.0)

### Langkah-langkah

#### Opsi 1: Menggunakan Emulator
```bash
# Jalankan emulator Android
flutter emulators --launch <emulator_id>

# Lihat daftar emulator yang tersedia
flutter emulators

# Jalankan aplikasi
flutter run
```

#### Opsi 2: Menggunakan Device Fisik
1. Hubungkan device Android via USB
2. Aktifkan "Developer Mode" dan "USB Debugging" di device
3. Jalankan:
```bash
flutter devices  # Lihat device yang terdeteksi
flutter run -d <device_id>
```

#### Build APK untuk Release
```bash
# Build APK
flutter build apk

# Build optimized APK untuk berbagai architecture
flutter build apk --split-per-abi

# File APK akan tersimpan di: build/app/outputs/flutter-apk/
```

#### Build App Bundle (untuk Google Play)
```bash
flutter build appbundle
# File akan tersimpan di: build/app/outputs/bundle/release/
```

---

## 3. Menjalankan di iOS

### Persyaratan iOS
- macOS (versi terbaru direkomendasikan)
- Xcode 14+
- CocoaPods
- iOS 11.0 atau lebih tinggi

### Langkah-langkah

#### Setup iOS (Jika pertama kali)
```bash
# Install dependencies iOS
cd ios
pod install
cd ..
```

#### Opsi 1: Menggunakan iOS Simulator
```bash
# Jalankan simulator iOS
open -a Simulator

# Atau jalankan langsung
flutter run
```

#### Opsi 2: Menggunakan Device Fisik
1. Connect device iOS via USB
2. Trust device di iOS settings
3. Setup code signing di Xcode:
   - Buka: `ios/Runner.xcworkspace`
   - Pilih Runner project
   - Pilih Runner target
   - Di "Signing & Capabilities", pilih development team Anda

4. Jalankan:
```bash
flutter run -d <device_id>
```

#### Build IPA untuk Release
```bash
flutter build ios --release

# Atau build untuk submission ke App Store
flutter build ios --release
# File akan tersimpan di: build/ios/iphoneos/
```

---

## 4. Perintah Umum Cross-Platform

```bash
# Jalankan di device default
flutter run

# Jalankan di device spesifik
flutter run -d <device_id>

# Jalankan dengan verbose output
flutter run -v

# Jalankan di mode release
flutter run --release

# Lihat semua device yang tersedia
flutter devices

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Clean project
flutter clean
```

---

## 5. Fitur yang Kompatibel di Kedua Platform

✅ Material Design UI - Bekerja sempurna di Android  
✅ Provider State Management - Cross-platform  
✅ Shared Preferences - Didukung Android & iOS  
✅ JSON serialization - Native support  
✅ Intl formatting - Cross-platform  
✅ UUID generation - Cross-platform  
✅ File I/O - Didukung keduanya  

---

## 6. Testing di Kedua Platform

### Testing UI
```bash
# Run di Android
flutter run -d emulator-5554

# Lalu di sesi terminal baru, run di iOS
flutter run -d "iPhone 15"
```

### Checklist Testing
- [ ] Aplikasi dapat dibuka
- [ ] Bisa menambah tabungan baru
- [ ] Data tersimpan dengan baik
- [ ] Tab Berlangsung/Tercapai berfungsi
- [ ] Pengisian tabungan bekerja
- [ ] Progress bar menampilkan dengan benar
- [ ] Formatting mata uang tampil benar
- [ ] Data persist setelah close app

---

## 7. Troubleshooting

### Android Issues

**Error: Unable to locate Android SDK**
```bash
flutter config --android-sdk <path-to-android-sdk>
```

**Emulator lambat**
- Pastikan Hardware Acceleration aktif (HAXM/KVM)
- Buat emulator baru dengan settings optimal

### iOS Issues

**Error: Pod install failed**
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
```

**Code signing issues**
- Buka `ios/Runner.xcworkspace` di Xcode
- Sesuaikan code signing di Build Settings

---

## 8. Struktur File untuk Multi-Platform

```
aplikasi/
├── lib/                    # Kode shared (Android & iOS)
├── android/               # Konfigurasi Android
├── ios/                   # Konfigurasi iOS
├── pubspec.yaml          # Dependencies
└── analysis_options.yaml  # Code analysis rules
```

---

## 9. Deployment

### Android (Google Play Store)
1. Build signed APK/App Bundle
2. Upload ke Google Play Console
3. Set release notes dan screenshots

### iOS (Apple App Store)
1. Build IPA untuk submission
2. Upload via Xcode atau Transporter
3. Tunggu review dari Apple

---

## Tips untuk Development

1. **Emulator/Simulator Performance**
   - Android: Enable Virtualization di BIOS
   - iOS: Gunakan Simulator terbaru

2. **Hot Reload**
   ```bash
   flutter run
   # Tekan 'r' untuk hot reload
   # Tekan 'R' untuk hot restart
   ```

3. **Debugging**
   ```bash
   flutter run -v  # Verbose output
   flutter logs     # Lihat logs
   ```

---

Selamat! Aplikasi Tabunganku Anda siap untuk berjalan di Android dan iOS! 🎉📱
