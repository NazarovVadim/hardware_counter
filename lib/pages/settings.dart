import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volume/db/user_settings.dart';
import 'package:volume/themes/theme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _defaultNameController = TextEditingController();
  bool isVibrationUsed = UserSettings.isVibrationUsed;
  bool isSoundUsed = UserSettings.isSoundUsed;

  @override
  void initState(){
    _defaultNameController.text = UserSettings.defaultNameCounter;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel themeNotifier, child){
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Вибрация'),
                      const Padding(padding: EdgeInsets.only(right: 20)),
                      Switch(value: isVibrationUsed, onChanged: (value) async{
                        setState((){
                          isVibrationUsed = value;
                        });
                        UserSettings.isVibrationUsed = value;
                        String PREF_KEY = "vibration";
                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        sharedPreferences.setBool(PREF_KEY, UserSettings.isVibrationUsed);

                      })
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Звук'),
                      const Padding(padding: EdgeInsets.only(right: 20)),
                      Switch(value: isSoundUsed, onChanged: (value)async{
                        setState((){
                          isSoundUsed = value;
                        });
                        UserSettings.isSoundUsed = value;
                        String PREF_KEY = "sound";
                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        sharedPreferences.setBool(PREF_KEY, UserSettings.isSoundUsed);
                      })
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Имя счётчика по умолчанию:'),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    child: TextFormField(
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Введите название';
                        }
                        return null;
                      },
                      controller: _defaultNameController,
                      decoration: InputDecoration(
                        labelText: 'Имя',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(onPressed: () async{
                    if (_formKey.currentState!.validate()) {

                      String PREF_KEY = "defaultNameCounter";
                      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      sharedPreferences.setString(PREF_KEY, _defaultNameController.text);
                      UserSettings.defaultNameCounter = _defaultNameController.text;
                      //print(UserSettings.defaultNameCounter);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Применено'), duration: Duration(milliseconds: 600),)
                      );
                    }

                    },
                    child: const Text('Применить название'))

                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(themeNotifier.isDark
                ? Icons.nightlight_round
                : Icons.wb_sunny),
            onPressed: (){
                    themeNotifier.isDark
                        ? themeNotifier.isDark = false
                        : themeNotifier.isDark = true;
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        );
      }
    );
  }
}
