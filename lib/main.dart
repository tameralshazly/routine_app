import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:routine_app/collections/category.dart';
import 'package:routine_app/collections/routine.dart';
import 'package:routine_app/screens/create_routine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Directory dir = await getApplicationSupportDirectory();
  final isar =
      await Isar.open([RoutineSchema, CategorySchema], directory: dir.path);
  runApp(MyApp(
    isar: isar,
  ));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  const MyApp({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routine app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
        useMaterial3: true,
      ),
      home: MainPage(isar: isar),
    );
  }
}

class MainPage extends StatefulWidget {
  final Isar isar;
  const MainPage({super.key, required this.isar});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Routine>? routines;
  @override
  void initState() {
    super.initState();
    _readRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text('Routine'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateRoutine(isar: widget.isar),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: _buildWidgets(),
        ),
      ),
    );
  }

  _readRoutines() async {
    final routineCollection = widget.isar.routines;
    final getRoutines = await routineCollection.where().findAll();
    setState(() {
      routines = getRoutines;
    });
  }

  List<Widget> _buildWidgets() {
    List<Widget> x = [];

    for (var i = 0; i < routines!.length; i++) {
      x.add(Card(
        elevation: 4.0,
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      const WidgetSpan(
                          child: Icon(
                        Icons.schedule,
                        size: 16,
                      )),
                      TextSpan(
                        text: routines![i].startTime,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                    children: [
                      const WidgetSpan(
                          child: Icon(
                        Icons.calendar_month,
                        size: 16,
                      )),
                      TextSpan(
                        text: routines![i].day,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
        ),
      ));
    }
    return x;
  }
}
