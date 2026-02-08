// 在 ListView.builder 中添加了 GestureDetector 实现跳转
// 在文件末尾添加了 IssueDetailPage 类

import 'package:flutter/material.dart';

class IssuePage extends StatefulWidget {
  const IssuePage({super.key});

  @override
  State<IssuePage> createState() => _IssuePageState();
}

class _IssuePageState extends State<IssuePage> {
  String selectedCategory = "Urgent";

  final Map<String, List<Map<String, String>>> issueData = {
    "Urgent": [
      {
        "title": "Tree has fallen",
        "desc": "Tree at Sungai Petani has fallen result in traffic jam, delay work could increase the severity to emergency.",
        "time": "Urgent - Today 1:31pm"
      },
      {
        "title": "Flash Flood",
        "desc": "Heavy rain caused flooding in the basement parking area.",
        "time": "Urgent - 2 hours ago"
      },
    ],
    "Improvement": [
      {
        "title": "Better Street Lighting",
        "desc": "The park area needs more LED lights for safety during night walks.",
        "time": "Improvement - Yesterday"
      },
      {
        "title": "Add Recycling Bins",
        "desc": "Suggesting to add more plastic recycling bins near the entrance.",
        "time": "Improvement - 3 days ago"
      },
    ],
    "Normal Urgency": [
      {
        "title": "Broken Bench",
        "desc": "A wooden bench in the community garden has a broken leg.",
        "time": "Normal - Today 10:00am"
      },
      {
        "title": "Pothole on Main Road",
        "desc": "Small pothole starting to form near the guard house.",
        "time": "Normal - 5 hours ago"
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> currentIssues = issueData[selectedCategory] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5BB8),
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Text("CommUnity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 16),
          Icon(Icons.notifications, color: Colors.white),
          SizedBox(width: 16),
          CircleAvatar(radius: 14, backgroundColor: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("All Issues", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip("Urgent"),
                const SizedBox(width: 8),
                _buildFilterChip("Improvement"),
                const SizedBox(width: 8),
                _buildFilterChip("Normal Urgency"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: currentIssues.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                var issue = currentIssues[index];
                // --- 修改部分：添加点击跳转逻辑 ---
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IssueDetailPage(issue: issue),
                      ),
                    );
                  },
                  child: _buildIssueCard(issue['title']!, issue['desc']!, issue['time']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueCard(String title, String desc, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 16),
          Text(
            time,
            style: TextStyle(
              fontSize: 12, 
              color: time.contains("Urgent") ? Colors.red : Colors.blue,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}

// --- 新增部分：Issue 详情页面 UI ---
class IssueDetailPage extends StatelessWidget {
  final Map<String, String> issue;

  const IssueDetailPage({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5BB8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Issue Detail", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部问题卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(issue['title']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      issue['time']!.split(' - ')[0],
                      style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(issue['desc']!, style: const TextStyle(color: Colors.black87, height: 1.5)),
                  const SizedBox(height: 16),
                  Text("Created at ${issue['time']!.split(' - ')[1]}", 
                    style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 上传证明区域
            const Text("Done? Upload Proof of Work!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 32),
                  const SizedBox(height: 8),
                  Text("Select Photos", style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE4E8),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("+ Submit"),
            ),
            const SizedBox(height: 32),

            // 状态时间轴
            _buildTimelineItem(Colors.yellow, "Send worker to site", "Today 10:30 a.m."),
            _buildTimelineItem(Colors.greenAccent, "Assign issue to myself", "Today 8:30 a.m."),
            _buildTimelineItem(Colors.greenAccent, "Issue raised by Mandy Hoo", "Today 1:00 a.m.", isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Color color, String title, String time, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
              ),
            ),
            if (!isLast) Container(width: 2, height: 40, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}