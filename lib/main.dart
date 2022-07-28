import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volume/db/saves.dart';
import 'package:volume/pages/home.dart';
import 'package:volume/pages/settings.dart';
import 'package:volume/themes/theme_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db/hive_names.dart';


void main() async{
  await Hive.initFlutter();
  Hive.registerAdapter(SavesAdapter());
  await Hive.openBox<Saves>(HiveBoxes.saves);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
          builder: (context, ThemeModel themeNotifier, child) {
            return MaterialApp(
              //title: 'Flutter Counter',
              theme: themeNotifier.isDark ? ThemeData.dark() : ThemeData.light(),
              debugShowCheckedModeBanner: false,
              //home: MyHomePage(),
              initialRoute: "/",
              routes: {
                '/': (context) => MyHomePage(),
                '/settings': (context) => const SettingsPage()
              },
            );
          }),
    );
  }
}




