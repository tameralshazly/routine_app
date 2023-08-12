import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:routine_app/collections/category.dart';

class CreateRoutine extends StatefulWidget {
  final Isar isar;
  const CreateRoutine({super.key, required this.isar});

  @override
  State<CreateRoutine> createState() => _CreateRoutineState();
}

class _CreateRoutineState extends State<CreateRoutine> {
  List<Category>? categories;
  Category? dropdownValue;
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

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _newCatController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  @override
  void initState() {
    super.initState();
    _readCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        title: const Text('Create routine'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                                  controller: _newCatController,
                                ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        if (_newCatController.text.isNotEmpty) {
                                          _addCategoy(widget.isar);
                                          Navigator.of(context).pop(true);
                                        }
                                      },
                                      child: const Text('Add'))
                                ],
                              ));
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  'Title',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: _titleController,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  'Start Time',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                    icon: const Icon(Icons.calendar_month),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  'Day',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: DropdownButton(
                  isExpanded: true,
                  value: dropdownDay,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: days
                      .map<DropdownMenuItem<String>>(
                          (String day) => DropdownMenuItem<String>(
                                value: day,
                                child: Text(day),
                              ))
                      .toList(),
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
                  onPressed: () {},
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _selectedTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (timeOfDay != null && timeOfDay != selectedTime) {
      selectedTime = timeOfDay;
      setState(
        () {
          _timeController.text =
              "${selectedTime.hour} : ${selectedTime.minute} ${selectedTime.period.name}";
        },
      );
    }
  }

  // create category record
  _addCategoy(Isar isar) async {
    final categories = isar.categorys;
    final newCategory = Category()..name = _newCatController.text;
    await isar.writeTxn(() async {
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
}
