import 'package:flutter/material.dart';
import './task.dart' show Task; // Import class Task từ task.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskHomePage(),
    );
  }
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  // Khởi tạo đối tượng từ Task
  final Task _task = Task();
  late String _taskInfo;

  @override
  void initState() {
    super.initState();
    _taskInfo = _task.getTaskInfo();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Công việc & Lịch'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Container(
          color: const Color(0xFFE9F5F8),
          width: width * 0.95,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month,
                size: 60,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 12),
              Text(
                'Công việc: ${_task.getTitle()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hạn chót: ${_task.getDeadline()}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _taskInfo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}