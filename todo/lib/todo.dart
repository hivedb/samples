import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late DateTime created;

  @HiveField(2)
  bool done = false;
}
