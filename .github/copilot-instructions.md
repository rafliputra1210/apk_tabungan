# Tabunganku - Flutter Mobile App

Aplikasi pencatat tabungan dengan Flutter yang memiliki fitur penuh untuk mengelola tabungan dengan target dan rencana pengisian berkala.

## Project Status

- ✅ Project Setup Complete
- ✅ Core Models Implemented
- ✅ State Management (Provider) Configured
- ✅ Main Screens Created
- ✅ UI/UX Implemented
- ✅ Local Storage Integration

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0+
- Dart 3.0.0+

### Installation Steps

1. **Navigate to project directory**
   ```bash
   cd aplikasi
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                          # Application entry point
├── models/
│   └── savings.dart                   # Savings data model
├── providers/
│   └── savings_provider.dart          # State management
└── screens/
    ├── home_screen.dart               # Home screen with tabs
    ├── add_savings_screen.dart         # Add new savings form
    └── savings_detail_screen.dart      # View and edit savings details
```

## Key Features

### ✅ Completed Features
- Add new savings with goals and descriptions
- Track savings progress with visual progress bars
- Flexible savings plan (Daily, Weekly, Monthly)
- Add contributions to savings
- View ongoing and achieved savings in separate tabs
- Local data persistence with SharedPreferences
- Status tracking (Berlangsung/Tercapai)
- Remaining calculations

### 📋 Feature Details

**Savings Model Fields:**
- Title: Nama tabungan
- Notes: Catatan tambahan
- Target Amount: Target jumlah tabungan
- Current Amount: Jumlah yang sudah terkumpul
- Nominal Pengisian: Jumlah per transaksi
- Recurrence Type: Harian/Mingguan/Bulanan
- Status: Berlangsung (ongoing) / Tercapai (achieved)
- Created Date: Tanggal pembuatan
- Target Date: Target tanggal selesai

## Commands Reference

### Run Application
```bash
flutter run                    # Run on default device
flutter run -d <device_id>   # Run on specific device
```

### Build APK (Android)
```bash
flutter build apk
flutter build apk --split-per-abi  # Create optimized APK
```

### Build App Bundle (Android)
```bash
flutter build appbundle
```

### Build IPA (iOS)
```bash
flutter build ios
```

### Development Commands
```bash
flutter clean              # Clean build artifacts
flutter pub get           # Install dependencies
flutter pub upgrade       # Upgrade dependencies
flutter analyze           # Analyze code
flutter format .          # Format code
```

## Architecture Overview

### State Management
- Using **Provider** pattern for reactive state management
- Single `SavingsProvider` manages all application state
- Change notifications trigger UI rebuilds

### Data Persistence
- **SharedPreferences** for local storage
- JSON serialization for data models
- Automatic persistence on every change

### Navigation
- Tab-based navigation on home screen
- Push/Pop navigation for detail screens
- Return values for confirmation handling

## Development Guidelines

1. **Code Style**
   - Follow Dart conventions
   - Use meaningful variable names
   - Add comments for complex logic

2. **State Management**
   - Always use Provider for state changes
   - Call `notifyListeners()` after state updates
   - Persist data after each modification

3. **UI Components**
   - Use Material Design 3
   - Implement responsive layouts
   - Add proper error handling

4. **Testing**
   - Test state changes in Provider
   - Verify data persistence
   - Check UI rendering

## Future Enhancements

- 📊 Statistics and reports dashboard
- 🔔 Push notifications for savings reminders
- 📤 Export data (CSV/PDF)
- 🎨 Customizable themes
- ☁️ Cloud sync support
- 💹 Expense tracking integration

## Troubleshooting

### Issue: App crashes on startup
**Solution:** 
- Run `flutter clean`
- Run `flutter pub get`
- Rebuild the app

### Issue: Data not saving
**Solution:**
- Check SharedPreferences permissions
- Verify JSON serialization in model
- Check provider's _saveSavings() method

### Issue: UI not updating
**Solution:**
- Verify Consumer widget wraps the right widget
- Check if notifyListeners() is called
- Ensure Provider is initialized in main.dart

## Notes for Developers

- UUID package generates unique IDs for each savings entry
- Date formatting uses intl package with Indonesian locale
- Progress bar calculation: (currentAmount / targetAmount * 100)
- Remaining contributions: ceil(remainingAmount / nominalPengisian)

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Dart Language](https://dart.dev/guides)

---

Last Updated: May 2026
