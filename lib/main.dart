import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(home: ToDoApp()));
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  List<Map<String, dynamic>> todos = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('todos', jsonEncode(todos));
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('todos');
    if (data != null) {
      setState(() {
        todos = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  void addOrEditTodo({int? index}) {
    if (index != null) {
      titleController.text = todos[index]['title'] ?? '';
      descController.text = todos[index]['desc'] ?? '';
    } else {
      titleController.clear();
      descController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(index == null ? 'Add Todo' : 'Edit Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              final createdTime = DateTime.now().toString().split(
                '.',
              )[0]; // time added

              if (title.isNotEmpty && desc.isNotEmpty) {
                final todo = {
                  'title': title,
                  'desc': desc,
                  'createdTime': createdTime,
                  'isDone': false,
                };

                setState(() {
                  if (index == null) {
                    todos.add(todo);
                  } else {
                    todos[index] = {...todo, 'isDone': todos[index]['isDone']};
                  }
                });

                saveData();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
    saveData();
  }

  void toggleDone(int index) {
    setState(() {
      todos[index]['isDone'] = !(todos[index]['isDone'] ?? false);
    });
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic To-Do App')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (_, index) {
          final todo = todos[index];
          final isDone = todo['isDone'] ?? false;

          return ListTile(
            leading: Checkbox(
              value: isDone,
              onChanged: (_) => toggleDone(index),
            ),
            title: Text(
              todo['title'] ?? '',
              style: TextStyle(
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo['desc'] ?? '',
                  style: TextStyle(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text('Added: ${todo['createdTime'] ?? ''}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => addOrEditTodo(index: index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteTodo(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditTodo(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
