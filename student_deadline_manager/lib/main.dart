import 'package:flutter/material.dart';
import 'task.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalendarTaskPage(),
    );
  }
}

class CalendarTaskPage extends StatefulWidget {
  const CalendarTaskPage({super.key});

  @override
  State<CalendarTaskPage> createState() => _CalendarTaskPageState();
}

class _CalendarTaskPageState extends State<CalendarTaskPage> {
  // Khởi tạo đối tượng Task tương tự ví dụ Myprofile()
  Task myTask = Task();

  @override
  void initState() {
    super.initState();
    // Gọi phương thức cập nhật dữ liệu
    myTask.setTask("Báo cáo đồ án nhóm", "30/12/2026", "Xây dựng giao diện Calendar & Quản lý Deadline");
  }

  @override
  Widget build(BuildContext context) {
    String taskSummary = myTask.getTaskSummary();
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Công Việc & Lịch'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Container(
          width: width * 0.95,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE9F5F8), // Màu nền giống ví dụ minh họa
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "📅 LỊCH CÔNG VIỆC TRONG NGÀY",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                taskSummary,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              Text(
                "Mô tả: ${myTask.description}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}