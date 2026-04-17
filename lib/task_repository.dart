import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_model.dart'; // This links to the model you just created!

class TaskRepository {
  // This is the reference to your specific "tasks" collection in Firebase
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');

  // 1. Add Task Function
  Future<void> addTask(Task task) async {
    try {
      // We use the task's ID as the document ID in Firebase
      await _tasksCollection.doc(task.id).set(task.toJson());
      print("Task added successfully!");
    } catch (e) {
      print("Failed to add task: $e");
    }
  }

  // 2. Delete Task Function
  Future<void> deleteTask(String taskId) async {
    try {
      // Finds the document by its ID and deletes it
      await _tasksCollection.doc(taskId).delete();
      print("Task deleted successfully!");
    } catch (e) {
      print("Failed to delete task: $e");
    }
  }

  // Bonus/Helper Function for Task 6 (Fetching real-time data)
  Stream<List<Task>> getTasksStream() {
    return _tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}