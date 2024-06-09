import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

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

  Box? _box;
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
            task.timestamp.toString(),
          ),
          trailing: Icon(
            task.done
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_outlined,
            color: Colors.red,
          ),
          onTap: () {
            task.done = !task.done;
            _box!.putAt(_index, task.toMap());
            setState(() {});
          },
          onLongPress: () {
            _displayDeltePopup(_index);
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

  void _displayDeltePopup(int _index) {
    showDialog(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
            title: const Text("Do you want Delete ?"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    child: const Text("NO")),
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      _box!.deleteAt(_index);
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "YES",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
          );
        });
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: const Center(child: Text("Add New Task!")),
          content: SizedBox(
            height: _deviceHeight * 0.2,
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
                SizedBox(
                  width: _deviceWidth * 0.4,
                  child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        if (_newTaskContent != null) {
                          var task = Task(
                            content: _newTaskContent!,
                            timestamp: DateTime.now(),
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
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
