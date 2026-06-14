import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const RubikApp());
}

class RubikApp extends StatelessWidget {
  const RubikApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مكعب روبيك',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}
