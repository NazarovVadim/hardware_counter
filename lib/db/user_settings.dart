import 'package:shared_preferences/shared_preferences.dart';


class UserSettings{
  static bool isVibrationUsed = true;
  static bool isSoundUsed = true;
  static String defaultNameCounter = '';

  static void get()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isVibrationUsed = sharedPreferences.getBool('vibration') ?? false;
    isSoundUsed = sharedPreferences.getBool('sound') ?? false;
    defaultNameCounter = sharedPreferences.getString('defaultNameCounter')!;
  }
}