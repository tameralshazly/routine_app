// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:routine_app/collections/category.dart';
import 'package:routine_app/collections/routine.dart';
import 'package:routine_app/main.dart';

class UpdateRoutine extends StatefulWidget {
  final Isar isar;
  final Routine routine;
  const UpdateRoutine({super.key, required this.isar, required this.routine});

  @override
  State<UpdateRoutine> createState() => _UpdateRoutineState();
}

class _UpdateRoutineState extends State<UpdateRoutine> {
  List<Category>? categories;
  Category? dropdownValue;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _newCatController = TextEditingController();
  List<String> days = [
    'Saturday',
    'Suday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thirsday',
    'Friday'
  ];
  String dropdownDay = 'Saturday';

  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _setRoutineInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        title: const Text('Update routine'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text('Delete content'),
                          content:
                              const Text('Are you sure you want to delete?'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  deleteRoutine();
                                },
                                child: const Text(
                                  "Yes",
                                  style: TextStyle(color: Colors.green),
                                )),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "No",
                                  style: TextStyle(color: Colors.red),
                                ))
                          ],
                        ));
              },
              icon: const Icon(Icons.delete)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: DropdownButton(
                    focusColor: const Color(0xffffffff),
                    dropdownColor: const Color(0xffffffff),
                    isExpanded: true,
                    value: dropdownValue,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: categories
                        ?.map<DropdownMenuItem<Category>>((Category nValue) {
                      return DropdownMenuItem<Category>(
                          value: nValue, child: Text(nValue.name));
                    }).toList(),
                    onChanged: (Category? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: const Text('New Category'),
                                content: TextFormField(
                                    autofocus: true,
                                    controller: _newCatController),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        if (_newCatController.text.isNotEmpty) {
                                          _addCategory(widget.isar);
                                        }
                                      },
                                      child: const Text('Add'))
                                ],
                              ));
                    },
                    icon: const Icon(Icons.add))
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child:
                  Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextFormField(
              controller: _titleController,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text('Start Time',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: _timeController,
                    enabled: false,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _selectedTime(context);
                    },
                    icon: const Icon(Icons.calendar_month))
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text('Day', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: DropdownButton(
                isExpanded: true,
                value: dropdownDay,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: days.map<DropdownMenuItem<String>>((String day) {
                  return DropdownMenuItem<String>(value: day, child: Text(day));
                }).toList(),
                onChanged: (String? newDay) {
                  setState(() {
                    dropdownDay = newDay!;
                  });
                },
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                    onPressed: () {
                      updateRoutine();
                    },
                    child: const Text('Update')))
          ]),
        ),
      ),
    );
  }

  _selectedTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        initialEntryMode: TimePickerEntryMode.dial);

    if (timeOfDay != null && timeOfDay != selectedTime) {
      selectedTime = timeOfDay;
      setState(() {
        _timeController.text =
            "${selectedTime.hour}:${selectedTime.minute} ${selectedTime.period.name}";
      });
    }
  }

  //create category record
  _addCategory(Isar isar) async {
    final categories = isar.categorys;
    final newCategory = Category()..name = _newCatController.text;
    await isar.writeTxnSync(() async {
      await categories.put(newCategory);
    });

    _newCatController.clear();
    _readCategory();
  }

  _readCategory() async {
    final categoryCollection = widget.isar.categorys;
    final getCategories = await categoryCollection.where().findAll();
    setState(() {
      dropdownValue = null;
      categories = getCategories;
    });
  }

  _setRoutineInfo() async {
    await _readCategory();
    _titleController.text = widget.routine.title;
    _timeController.text = widget.routine.startTime;
    dropdownDay = widget.routine.day;

    await widget.routine.category.load();

    int? getId = widget.routine.category.value?.id;

    setState(() {
      dropdownValue = categories?[getId! - 1];
    });
  }

  updateRoutine() async {
    final routineCollection = widget.isar.routines;
    await widget.isar.writeTxn(() async {
      final routine = await routineCollection.get(widget.routine.id);
      await widget.routine.category.load();

      routine!
        ..title = _titleController.text
        ..startTime = _timeController.text
        ..day = dropdownDay
        ..category.value!.name = dropdownValue!.name;

      await routineCollection.put(routine);
    });
    Navigator.pop(context);
  }

  deleteRoutine() async {
    final routineCollection = widget.isar.routines;

    await widget.isar.writeTxn(() async {
      routineCollection.delete(widget.routine.id);
    });
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return MainPage(isar: widget.isar);
      },
    ));
  }
}
