import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  String title;
  bool done;
  DateTime? due;

  Task(this.title, {this.done = false, this.due});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;

  final List<Task> tasks = [
    Task('Finish the session 15 shell'),
    Task(
      'Post the screen recording',
      done: true,
    ),
    Task('Sleep'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APP BAR
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          // PENDING TASK COUNT
          IconButton(
            icon: const Icon(Icons.pending_actions),
            onPressed: () {
              final left = tasks.where((t) => !t.done).length;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$left still to do'),
                ),
              );
            },
          ),

          // CLEAR FINISHED TASKS
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Clear finished tasks',
            onPressed: () async {
              final yes = await confirmClearFinished(context);

              if (yes) {
                setState(() {
                  tasks.removeWhere((task) => task.done);
                });
              }
            },
          ),
        ],
      ),

      // DRAWER
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Task Manager',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // BODY
      body: buildBody(),

      // ADD TASK
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final task = await showModalBottomSheet<Task>(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return const AddTaskSheet();
            },
          );

          if (task != null && task.title.isNotEmpty) {
            setState(() {
              tasks.add(task);
            });
          }
        },
        child: const Icon(Icons.add),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (i) {
          setState(() {
            tab = i;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            label: 'Done',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'You',
          ),
        ],
      ),
    );
  }

  // SHOW CONTENT BASED ON TAB
  Widget buildBody() {
    // DONE TAB
    if (tab == 1) {
      return buildList(
        tasks.where((t) => t.done).toList(),
      );
    }

    // YOU TAB
    if (tab == 2) {
      return const Center(
        child: Text(
          'Your profile goes here',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    // TASKS TAB
    return buildList(
      tasks.where((t) => !t.done).toList(),
    );
  }

  // TASK LIST
  Widget buildList(List<Task> shown) {
    if (shown.isEmpty) {
      return const Center(
        child: Text(
          'Nothing here yet',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: shown.length,
      itemBuilder: (context, index) {
        final task = shown[index];

        return ListTile(
          // CHECKBOX
          leading: Checkbox(
            value: task.done,
            onChanged: (value) {
              setState(() {
                task.done = value ?? false;
              });
            },
          ),

          // TASK TITLE
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.done
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),

          // DUE DATE
          subtitle: task.due == null
              ? null
              : Text(
            'Due ${task.due!.day}/'
                '${task.due!.month}/'
                '${task.due!.year}',
          ),

          // DELETE BUTTON
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final yes = await confirmDelete(context);

              if (yes) {
                setState(() {
                  tasks.remove(task);
                });
              }
            },
          ),
        );
      },
    );
  }
}

// DELETE ONE TASK
Future<bool> confirmDelete(BuildContext context) async {
  final yes = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Delete this task?',
        ),
        content: const Text(
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return yes ?? false;
}

// CLEAR ALL FINISHED TASKS
Future<bool> confirmClearFinished(BuildContext context) async {
  final yes = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Clear finished tasks?',
        ),
        content: const Text(
          'All completed tasks will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Clear'),
          ),
        ],
      );
    },
  );

  return yes ?? false;
}

// ADD TASK SHEET
class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final controller = TextEditingController();

  DateTime? due;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TITLE
          const Text(
            'New task',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // TASK NAME
          TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'What needs doing?',
            ),
          ),

          const SizedBox(height: 8),

          // PICK DATE
          TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2026),
                lastDate: DateTime(2027),
              );

              if (picked != null) {
                setState(() {
                  due = picked;
                });
              }
            },
            icon: const Icon(Icons.event),
            label: Text(
              due == null
                  ? 'Pick a due date'
                  : 'Due ${due!.day}/'
                  '${due!.month}/'
                  '${due!.year}',
            ),
          ),

          const SizedBox(height: 16),

          // ADD BUTTON
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                Task(
                  controller.text,
                  due: due,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}