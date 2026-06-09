#!/bin/bash

# Tabunganku - Quick Setup Script
# Untuk Linux/macOS

echo "🎉 Selamat datang di Tabunganku!"
echo "=================================="
echo ""

# Check Flutter installation
echo "📦 Checking Flutter installation..."
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter not found. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version)"
echo ""

# Navigate to project
echo "📂 Setting up project..."
cd "$(dirname "$0")" || exit 1

# Clean and get dependencies
echo "🔄 Installing dependencies..."
flutter clean
flutter pub get

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Android: flutter run -d emulator-5554"
echo "2. iOS:     flutter run -d 'iPhone 15'"
echo "3. Generic: flutter run"
echo ""
