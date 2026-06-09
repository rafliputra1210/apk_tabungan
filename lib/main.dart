import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/savings_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  // Baris ini WAJIB ada agar Flutter siap sebelum Firebase dijalankan
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menyalakan Firebase menggunakan pengaturan yang tadi dibuat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
      ],
      child: MaterialApp(
        title: 'Tabunganku',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00B4D8), // Cyan/Teal modern
            primary: const Color(0xFF0077B6),
            secondary: const Color(0xFF48CAE4),
            surface: const Color(0xFFF8F9FA),
            background: const Color(0xFFF3F4F6),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF03045E),
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Color(0xFF03045E)),
            titleTextStyle: TextStyle(
              color: Color(0xFF03045E),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color(0xFF0077B6),
              foregroundColor: Colors.white,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
}