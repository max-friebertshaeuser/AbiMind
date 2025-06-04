import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // todo: remove and work out the recaptcha stuff
  );

  if (!kIsWeb) {
    await TeXRenderingServer.start();
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abimind',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF7916FF)).copyWith(
          surfaceContainer: Color(0xFFF1DFD9),
        )
      ),
      initialRoute:
      FirebaseAuth.instance.currentUser == null ? AppRoutes.welcome :
      AppRoutes.start,
      routes: appRoutes,
    );
  }
}
