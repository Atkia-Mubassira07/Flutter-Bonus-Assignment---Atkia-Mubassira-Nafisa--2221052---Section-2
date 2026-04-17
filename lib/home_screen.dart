import 'package:flutter/material.dart';
import 'task_model.dart';
import 'task_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Connect to the repository you made in Task 4
  final TaskRepository _repository = TaskRepository();
  
  // Controllers to grab the text the user types
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // TASK 5: ADD TASK UI INTEGRATION
  // This function shows a pop-up dialog for the user to type task details
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Task Title"),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // If both fields have text, create a Task and send it to Firebase!
                if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(), // Generates a random ID based on time
                    title: _titleController.text,
                    description: _descriptionController.text,
                    createdAt: DateTime.now(),
                  );
                  
                  await _repository.addTask(newTask); // Saves to Firebase
                  
                  _titleController.clear();
                  _descriptionController.clear();
                  if (context.mounted) Navigator.pop(context); // Closes the dialog
                }
              },
              child: const Text("Add Task"),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Firebase Tasks"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      
      // TASK 6: FETCH & DISPLAY TASKS
      // StreamBuilder listens to Firebase in real-time
      body: StreamBuilder<List<Task>>(
        stream: _repository.getTasksStream(),
        builder: (context, snapshot) {
          // Show a loading spinner while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Show a message if the database is empty
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tasks yet. Click the + to add one!"));
          }

          // Build a list of tasks
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(task.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _repository.deleteTask(task.id), // Deletes from Firebase
                  ),
                ),
              );
            },
          );
        },
      ),
      
      // The Floating button at the bottom right that opens the Add Task dialog
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}