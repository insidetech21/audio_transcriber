import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/home/home_screen.dart';
import 'viewmodel/audio_viewmodel.dart';
import 'viewmodel/transcription_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioViewModel()..init()),
        ChangeNotifierProvider(create: (_) => TranscriptionViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech Transcriber',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
