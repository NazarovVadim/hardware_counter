import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:volume/db/saves.dart';
import 'package:volume/db/user_settings.dart';
import 'package:volume/themes/theme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:volume/db/hive_names.dart';

import 'package:flutter_beep/flutter_beep.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  static const platform = MethodChannel("com.example.volume/counter");

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 0;
  String nameOfCounter = 'Untitled';
  final TextEditingController _saveCountController = TextEditingController();


  Future<void> _changeCounter([int count = 0, bool isPrimary = false]) async {
    try {
      final int result = await MyHomePage.platform.invokeMethod('changeCount', {'count': count, 'isPrimary': isPrimary});
      if(counter != result) {
        if(UserSettings.isVibrationUsed) HapticFeedback.heavyImpact();
        //SystemSound.play(SystemSoundType.click);
        if(UserSettings.isSoundUsed) FlutterBeep.beep();
      }
      setState((){
        counter=result;
      });

    } on PlatformException catch (e) {
      throw Exception("Failed to set count: '${e.message}'.");
    }
  }

  // Future<String?> getDefaultName ()async{
  //   String PREF_KEY = 'defaultNameCounter';
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   return sharedPreferences.getString(PREF_KEY);
  // }

  @override
  void initState(){

    Timer.periodic(const Duration(milliseconds:20), (timer) {
      _changeCounter();
    });
    UserSettings.get();
    Timer(const Duration(seconds: 1), (){
      _saveCountController.text = UserSettings.defaultNameCounter;
    });

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel themeNotifier, child){
        return Scaffold(
          appBar: AppBar(
            title: Text(nameOfCounter),
            actions: [

              IconButton(
                  icon: const Icon(Icons.cached),
                  onPressed: () {
                    setState((){
                      counter = 0;
                    });
                    _changeCounter(counter, true);
                  }),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              reverse: false,
              children: [
                DrawerHeader(
                    decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.45)
                    ),
                    child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Flutter Counter', style: TextStyle(fontSize: 20),),

                          ],
                        )
                    )
                ),
                ListTile(
                  leading: const Icon(Icons.settings,),
                  title: const Text('Settings'),
                  onTap: ()async{
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(context, '/settings', (route) => true);
                  },
                ),
              ],
            ),
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
                    decoration: const InputDecoration(
                      labelText: 'Название',
                    ),
                  ),
                  actions: [
                    ElevatedButton(onPressed: () async{
                      //SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      //sharedPreferences.setStringList('', counter);
                      //var data = jsonDecode(data);
                      if(_saveCountController.text.trim() != ''){
                        Box<Saves> contactsBox = Hive.box<Saves>(HiveBoxes.saves);
                        contactsBox.add(Saves(name: _saveCountController.text, num: counter));
                        setState((){
                          nameOfCounter = _saveCountController.text;
                        });
                        _saveCountController.text = UserSettings.defaultNameCounter;
                        Navigator.of(context).pop(); // закрыть все модалки
                      }



                    }, child: const Text('Сохранить'))
                  ],
                );
              });

            },
            child: const Icon(Icons.save_alt),
          ),
          //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,// Th
        );
      },
    );
  }

  DraggableScrollableSheet _buildDraggableScrollableSheet(bool isEmpty, Box<Saves> box) {
    return DraggableScrollableSheet(
      initialChildSize: isEmpty ? 0.1 : 0.2,
      minChildSize: isEmpty ? 0.1 : 0.2,
      maxChildSize: isEmpty ? 0.1 : 0.4,
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
                if(!isEmpty) {
                  return Slidable(
                    key: Key(index.toString()),
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          label: 'Продолжить',
                          backgroundColor: Colors.blue.withOpacity(0.5),
                          icon: Icons.next_plan_outlined,
                          onPressed: (_){
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(
                                title: Text('Продолжить счетчик "${res?.name}": ${res?.num}?'),
                                actions: [
                                  ElevatedButton(onPressed: () async{
                                    _changeCounter(res?.num as int, true);
                                    setState((){
                                      nameOfCounter = res?.name as String;
                                    });
                                    Navigator.of(context).pop(); // закрыть все модалки
                                  }, child: const Text('Продолжить'))
                                ],
                              );
                            });
                          },
                        )
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          label: 'Удалить',
                          backgroundColor: Colors.red.withOpacity(0.5),
                          icon: Icons.delete_outline_outlined,
                          onPressed: (_){
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(
                                title: Text('Удалить счётчик "${res?.name}": ${res?.num}?'),
                                actions: [
                                  ElevatedButton(onPressed: () async{
                                    res?.delete();
                                    if (res?.name == nameOfCounter) nameOfCounter = 'Untitled';
                                    Navigator.of(context).pop(); // закрыть все модалки
                                  }, child: const Text('Удалить'))
                                ],
                              );
                            });
                          },
                        )
                      ],
                    ),
                    child: ListTile(
                      title: Text('${res?.name}: ${res?.num}'),
                      leading: const Icon(Icons.save_as_outlined),
                    ),

                  );
                } else{
                  return const ListTile(
                    title: Text('Нет сохранений'),
                    leading: Icon(Icons.close),
                  );
                }

              },
            ),
          ),
        );
      },
    );
  }

}
