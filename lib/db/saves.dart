import 'package:hive/hive.dart';
part 'saves.g.dart';

@HiveType(typeId: 0)
class Saves extends HiveObject{
  @HiveField(0)
  String name;
  @HiveField(1)
  int num;

  Saves({this.name = '', this.num = 0});
}