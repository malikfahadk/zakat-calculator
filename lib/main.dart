import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'zakat_calculator_screen.dart';

void main() {
  runApp(const ZakatCalculatorApp());
}

class ZakatCalculatorApp extends StatelessWidget {
  const ZakatCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zakat Calculator',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const ZakatCalculatorScreen(),
    );
  }
}
