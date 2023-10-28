import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'task_model.dart'; // Import the Task model

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyApplicationId = 'yWrrWp63VOnoPhv2Q3rk7ZEpjhlOJRd3laVlVVwX';
  final keyClientKey = 'CNFQVqSYOZJt8ZJTyRTOTmU3Pc8xKVJYqzfnXIWj';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set TaskListScreen as the initial route
      home: TaskListScreen(),
    );
  }
}
// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Your home screen content goes here
//       appBar: AppBar(
//         title: Text('My Flutter App'),
//       ),
//       body: Center(
//         child: Text('Hello, World!'),
//       ),
//     );
//   }
// }
class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('Task'));

    try {
      final ParseResponse apiResponse = await queryBuilder.query();

      if (apiResponse.success && apiResponse.results != null) {
        setState(() {
          tasks = apiResponse.results!.map((result) {
            return Task(
              title: result['title'] ?? '',
              description: result['description'] ?? '',
            );
          }).toList();
        });
      } else {
        print('API response not successful: ${apiResponse.error?.message}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
          );
        },
      ),
    );
  }
}

class TaskCreationScreen extends StatefulWidget {
  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}
class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Function to create and save a task
  Future<void> createTask() async {
    final ParseObject taskObject = ParseObject('Task')
      ..set('title', titleController.text)
      ..set('description', descriptionController.text);

    try {
      final ParseResponse apiResponse = await taskObject.save();

      if (apiResponse.success) {
        // Task creation successful
        Navigator.pop(context); // Close the task creation screen
      } else {
        print('Error creating task: ${apiResponse.error?.message}');
      }
    } catch (e) {
      print('Error creating task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: createTask,
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
