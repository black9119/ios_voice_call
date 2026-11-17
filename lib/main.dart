import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/dial_page.dart';
import 'service/zego_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ZegoService(),
      child: MaterialApp(
        title: 'iOS Voice Call',
        theme: ThemeData(
          primarySwatch: Colors.grey,
          scaffoldBackgroundColor: Colors.black,
        ),
        debugShowCheckedModeBanner: false,
        home: const DialPage(),
      ),
    );
  }
}
