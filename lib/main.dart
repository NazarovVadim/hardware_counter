import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:volume/db/saves.dart';
import 'package:volume/themes/theme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
              title: 'Flutter Demo',
              theme: themeNotifier.isDark ? ThemeData.dark() : ThemeData.light(),
              debugShowCheckedModeBanner: false,
              home: MyHomePage(),
            );
          }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  static const platform = MethodChannel("com.example.volume/counter");

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 0;
  TextEditingController _saveCountController = TextEditingController();


  Future<void> _changeCounter() async {
    try {
      final int result = await MyHomePage.platform.invokeMethod('changeCount');
      //print('count change to $result.');
      setState((){
        counter=result;
      });

    } on PlatformException catch (e) {
      throw Exception("Failed to set count: '${e.message}'.");
    }
  }

  // @override
  // void dispose((){
  //   Hive.close();
  //   super.dispose();
  // });

  @override
  void initState(){

    Timer.periodic(const Duration(milliseconds:20), (timer) {
      _changeCounter();
    });

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel themeNotifier, child){
        return Scaffold(
          appBar: AppBar(
            title: Text('Untitled'),
            actions: [
              IconButton(
                  icon: Icon(themeNotifier.isDark
                      ? Icons.nightlight_round
                      : Icons.wb_sunny),
                  onPressed: () {
                    themeNotifier.isDark
                        ? themeNotifier.isDark = false
                        : themeNotifier.isDark = true;
                  })
            ],
          ),
          body: Center(
            child: Stack(
              children: <Widget>[
                SizedBox.expand(
                  child:  Center(child: Text('$counter', style: Theme.of(context).textTheme.headline4,),),
                ),
                //_buildDraggableScrollableSheet()
                ValueListenableBuilder(
                  valueListenable: Hive.box<Saves>(HiveBoxes.saves).listenable(),
                  builder: (context, Box<Saves> box, _) {
                    if (box.values.isEmpty) {
                      return _buildDraggableScrollableSheet(true, box);
                    }
                    return _buildDraggableScrollableSheet(false, box);
                  }


                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              showDialog(context: context, builder: (BuildContext context){
                return AlertDialog(
                  title: Text('Сохраните текущее значение: $counter'),
                  content: TextField(
                    controller: _saveCountController,
                    decoration: InputDecoration(
                      labelText: 'Название'
                    ),
                  ),
                  actions: [
                    ElevatedButton(onPressed: () async{
                      //SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      //sharedPreferences.setStringList('', counter);
                      //var data = jsonDecode(data);
                      Box<Saves> contactsBox = Hive.box<Saves>(HiveBoxes.saves);
                      contactsBox.add(Saves(name: _saveCountController.text, num: counter));
                      _saveCountController.text = '';
                      Navigator.of(context).pop(); // закрыть все модалки
                    }, child: const Text('Сохранить'))
                  ],
                );
              });

            },
            child: const Icon(Icons.save_alt),
          ), // Th
        );
      },
    );
  }

  DraggableScrollableSheet _buildDraggableScrollableSheet(bool isEmpty, Box<Saves> box) {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.4,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black12,
            // border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Scrollbar(
            child: ListView.builder(
              controller: scrollController,
              itemCount: isEmpty ? 1 : box.values.length,
              itemBuilder: (BuildContext context, int index) {
                Saves? res = isEmpty ? null : box.getAt(index);
                return Dismissible(
                  background: Container(color: Colors.red),
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    if(!isEmpty) res?.delete();
                  },
                  child: ListTile(
                      title: isEmpty ? const Text('Нет сохранений') : Text('${res?.name}: ${res?.num}'),
                      leading: const Icon(Icons.save_as_outlined),
                      onTap: () {
                        if(!isEmpty) res?.delete();
                      }),
                );
                // return ListTile(
                //   leading: const Icon(Icons.save_as_outlined),
                //   title: isEmpty ?  Text('Нет сохранений') : Text('Item $index'),
                // );
              },
            ),
          ),
        );
      },
    );
  }

}


