import 'package:dom_camera_example/utils/app_routes.dart';
import 'package:dom_camera_example/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('dom_camera_storage');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOM Camera',
      theme: ThemeData(
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
          // useMaterial3: true,
          // colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
          ),
      initialRoute: ScreenRoutes.homeScreen,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
