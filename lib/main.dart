import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/config/app_theme.dart';
import 'src/routes/app_router.dart';
import 'src/services/storage_service.dart';
import 'src/screens/issue_page.dart';
// import 'firebase_options.dart'; // TODO: Uncomment after running flutterfire configure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await StorageService.init();

  // Initialize Firebase
  try {
      // TODO: Add options: DefaultFirebaseOptions.currentPlatform after running flutterfire configure
      await Firebase.initializeApp();
      runApp(const MyApp());
  } catch (e) {
      debugPrint("Firebase initialization failed: $e");
      runApp(InitializationErrorApp(error: e.toString()));
  }
}

class InitializationErrorApp extends StatelessWidget {
  final String error;
  const InitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Firebase Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please ensure google-services.json is present in android/app/',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 必须确保 home 指向的是你的 IssuePage
      home: const IssuePage(), 
    );
  }

  }

