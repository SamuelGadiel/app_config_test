import 'package:app_config_test/test_with_manual_implementation.dart';
import 'package:app_config_test/test_with_package.dart';
import 'package:flutter/material.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const TestWithManualImplementation(),
    );
  }
}
