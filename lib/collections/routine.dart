/* we will need the following in routine collection
    category, title, start time, day
*/

import 'package:isar/isar.dart';
import 'package:routine_app/collections/category.dart';
part 'routine.g.dart';

@collection
class Routine {
  Id id = Isar.autoIncrement;

  late String title;

  @Index()
  late DateTime startTime;

  @Index(caseSensitive: false)
  late String day;

  @Index(composite: [CompositeIndex('title')])
  final category = IsarLink<Category>();
}
