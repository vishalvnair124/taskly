import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;

  String? _newTaskContent;

  DateTime _selectedDateTime = DateTime.now();

  Box? _box;
  List<int> _indexMap = [];
  _HomePageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.1,
        backgroundColor: Colors.red,
        centerTitle: true,
        title: const Text(
          "Taskly!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
      ),
      body: _tasksView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _tasksView() {
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (_snapshot.hasData) {
          _box = _snapshot.data;
          return _tasksList();
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _tasksList() {
    List tasks = _box!.values.toList();

    _indexMap = List<int>.generate(
        tasks.length, (index) => index); // Initialize the index map

    // Selection sort with index mapping
    for (int i = 0; i < tasks.length - 1; i++) {
      int minIndex = i;
      for (int j = i + 1; j < tasks.length; j++) {
        if (Task.fromMap(tasks[j])
            .timestamp
            .isBefore(Task.fromMap(tasks[minIndex]).timestamp)) {
          minIndex = j;
        }
      }
      if (minIndex != i) {
        // Swap tasks
        var tempTask = tasks[minIndex];
        tasks[minIndex] = tasks[i];
        tasks[i] = tempTask;

        // Swap indices in the index map
        int tempIndex = _indexMap[minIndex];
        _indexMap[minIndex] = _indexMap[i];
        _indexMap[i] = tempIndex;
      }
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext _context, int _index) {
        var task = Task.fromMap(tasks[_index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            DateFormat('dd-MM-yyyy hh:mm a').format(task.timestamp),
          ),
          trailing: Icon(
            task.done
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_outlined,
            color: Colors.red,
          ),
          onTap: () {
            task.done = !task.done;
            _box!.putAt(_indexMap[_index], task.toMap());
            setState(() {});
          },
          onLongPress: () {
            _displayDeletePopup(_indexMap[_index]);
          },
        );
      },
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: _displayTaskPopup,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  void _displayDeletePopup(int _index) {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: const Text("Do you want to delete?"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: const Text("NO"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  _box!.deleteAt(_index);
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text(
                  "YES",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _displayTaskPopup() {
    _selectedDateTime = DateTime.now();
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Center(child: Text("Add New Task!")),
              content: SizedBox(
                height: _deviceHeight * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextField(
                      onChanged: (_value) {
                        setState(() {
                          _newTaskContent = _value;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _selectDate(context, setState),
                          child: Text(DateFormat('yyyy-MM-dd')
                              .format(_selectedDateTime)),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectTime(context, setState),
                          child: Text(
                              DateFormat('hh:mm a').format(_selectedDateTime)),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: _deviceWidth * 0.6,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          if (_newTaskContent != null) {
                            // print("Selected dateTime : $_selectedDateTime");
                            var task = Task(
                              content: _newTaskContent!,
                              timestamp: _selectedDateTime,
                              done: false,
                            );
                            _box!.add(task.toMap());
                            setState(() {
                              _newTaskContent = null;

                              Navigator.pop(context);
                            });
                          }
                        },
                        child: const Text(
                          "ADD",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, StateSetter setState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        DateTime selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );

        _selectedDateTime = selectedDateTime;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        DateTime selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
        _selectedDateTime = selectedDateTime;
      });
    }
  }
}
