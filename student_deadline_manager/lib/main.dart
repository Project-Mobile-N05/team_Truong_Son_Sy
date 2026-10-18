import 'package:flutter/material.dart';
import './task.dart';
import './base_entity.dart';

void main() {
  runApp(const SyApp());
}

class SyApp extends StatelessWidget {
  const SyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý Công việc & Lịch - Sỹ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SyMainScreen(),
    );
  }
}

class SyMainScreen extends StatefulWidget {
  const SyMainScreen({super.key});

  @override
  State<SyMainScreen> createState() => _SyMainScreenState();
}

class _SyMainScreenState extends State<SyMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarTaskScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Công việc & Lịch'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Lịch & Deadline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Thông tin',
          ),
        ],
      ),
    );
  }
}

// Khung Layout chung (Body + Footer)
class BaseScreenLayout extends StatelessWidget {
  final Widget bodyContent;

  const BaseScreenLayout({super.key, required this.bodyContent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. BODY (Nội dung chính)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: bodyContent,
          ),
        ),

        // 2. FOOTER (Thông tin trường & Sinh viên)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          color: Colors.blueAccent,
          child: Column(
            children: const [
              Text(
                'Phenikaa University',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(height: 2),
              Text(
                'Sinh viên thực hiện: Sỹ',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Màn hình 1: Home
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan Tiến độ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Column(
                    children: [
                      Text('Sắp tới', style: TextStyle(color: Colors.grey)),
                      Text('2', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Hoàn thành', style: TextStyle(color: Colors.grey)),
                      Text('5', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Màn hình 2: CalendarTaskScreen
class CalendarTaskScreen extends StatefulWidget {
  const CalendarTaskScreen({super.key});

  @override
  State<CalendarTaskScreen> createState() => _CalendarTaskScreenState();
}

class _CalendarTaskScreenState extends State<CalendarTaskScreen> {
  // Sử dụng GenericManager để quản lý danh sách Task
  final GenericManager<Task> _taskManager = GenericManager<Task>();

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách dữ liệu bằng GenericManager
    _taskManager.add(Task(
      id: "TASK_01",
      title: "Báo cáo Đồ án Flutter",
      deadline: "16/09/2026",
      description: "Xây dựng giao diện và lớp quản lý deadline",
      isCompleted: false,
    ));
    _taskManager.add(Task(
      id: "TASK_02",
      title: "Nộp bài tập Tuần 4",
      deadline: "20/09/2026",
      description: "Áp dụng Generics và Object Class",
      isCompleted: true,
    ));

    // Gọi phương thức kiểm tra Class metadata (Class class / Type)
    _taskManager.printManagerInfo();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _taskManager.items;

    return BaseScreenLayout(
      bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giao diện Lịch & Deadline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F5F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_month, size: 50, color: Colors.blueAccent),
                const SizedBox(height: 6),
                const Text('Lịch Học & Lịch Nộp Bài', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Tháng 09 / 2026', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                // Hiển thị tên Class runtime đại diện (Class/Type Metadata)
                Text(
                  'Thực thể quản lý: ${_taskManager.entityClass}',
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('Danh sách công việc (Generic List):', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Hiển thị danh sách Task lấy từ GenericManager
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Công việc [ID: ${task.id}]: ${task.getTitle()}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hạn chót: ${task.getDeadline()}',
                        style: const TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.getTaskInfo(),
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Màn hình 3: AboutScreen
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Thông tin Màn hình',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          SizedBox(height: 12),
          Text('- Chức năng: Quản lý công việc/deadline & Lịch'),
          Text('- Sinh viên phát triển: Sỹ'),
          Text('- Trường Đại học Phenikaa'),
          Text('- Bài thực hành: Áp dụng Generics & OOP Generalization'),
        ],
      ),
    );
  }
}