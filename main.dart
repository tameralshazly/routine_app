import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:routine_app/collections/category.dart';
import 'package:routine_app/collections/routine.dart';
import 'package:path_provider/path_provider.dart';
import 'package:routine_app/screens/create_routine.dart';
import 'package:routine_app/screens/update_routine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  final isar =
      await Isar.open([RoutineSchema, CategorySchema], directory: dir.path);
  runApp(MyApp(isar: isar));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  const MyApp({Key? key, required this.isar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routine app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(isar: isar),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  final Isar isar;
  const MainPage({Key? key, required this.isar}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Routine>? routines;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Routine"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CreateRoutine(isar: widget.isar)));
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Widget>>(
            future: _buildWidgets(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(children: snapshot.data!);
              } else {
                return const SizedBox();
              }
            }),
      ),
    );
  }

  Future<List<Widget>> _buildWidgets() async {
    await _readRoutines();

    List<Widget> x = [];

    for (int i = 0; i < routines!.length; i++) {
      x.add(Card(
        elevation: 4.0,
        child: ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdateRoutine(
                          isar: widget.isar, routine: routines![i])));
            },
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 2.0),
                child: Text(
                  routines![i].title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: RichText(
                    text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                      const WidgetSpan(child: Icon(Icons.schedule, size: 16)),
                      TextSpan(text: routines![i].startTime)
                    ])),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: RichText(
                    text: TextSpan(
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                        children: [
                      const WidgetSpan(
                          child: Icon(
                        Icons.calendar_month,
                        size: 16,
                      )),
                      TextSpan(text: routines![i].day)
                    ])),
              )
            ]),
            trailing: const Icon(Icons.keyboard_arrow_right)),
      ));
    }
    return x;
  }

  _readRoutines() async {
    final routineCollection = widget.isar.routines;
    final getRoutines = await routineCollection.where().findAll();
    setState(() {
      routines = getRoutines;
    });
  }
}
