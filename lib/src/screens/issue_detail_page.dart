import 'package:flutter/material.dart';

class IssueDetailPage extends StatelessWidget {
  // 🌟 1. 核心修改：改成接收从 Router 传过来的 String ID
  final String issueId;

  const IssueDetailPage({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    // 🌟 2. Prototype 阶段：因为我们只拿到了 ID，先造一个假数据让页面能显示。
    // 以后连了 Firebase，你就可以用 issueId 去数据库里拿真实数据替换掉这段了！
    final Map<String, String> dummyIssue = {
      'title': 'Tree has fallen (ID: $issueId)', // 把 ID 显示在标题上证明传值成功
      'desc': 'Tree at Sungai Besi highway fallen due to traffic jam, delays work model increases the severity to emergency.',
      'time': 'Today 1:30pm',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5BB8),
        title: const Text("Issue Detail", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 问题主卡片 (把假数据传给卡片)
            _buildMainInfoCard(dummyIssue),
            const SizedBox(height: 24),
            
            // 2. 证明上传区域
            const Text("Done? Upload Proof of Work!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildUploadPlaceholder(),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text("Submit"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[50], foregroundColor: Colors.black),
            ),
            const SizedBox(height: 24),

            // 3. 状态时间轴
            _buildTimeline(),
          ],
        ),
      ),
    );
  }

  // 🌟 3. 修改这里，让它接收传进来的数据
  Widget _buildMainInfoCard(Map<String, String> issueData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(issueData['title']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(4)),
            child: const Text("Urgent", style: TextStyle(color: Colors.red, fontSize: 10)),
          ),
          const SizedBox(height: 12),
          Text(issueData['desc']!, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 16),
          Text("Created at ${issueData['time']}", style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.image_outlined, color: Colors.grey), Text("Select Photos", style: TextStyle(color: Colors.grey))],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _buildTimelineItem(Colors.yellow, "Send worker to site", "Today 10:30 a.m."),
        _buildTimelineItem(Colors.greenAccent, "Assign issue to myself", "Today 8:30 a.m."),
        _buildTimelineItem(Colors.greenAccent, "Issue raised by Mandy Hoo", "Today 1:00 a.m.", isLast: true),
      ],
    );
  }

  Widget _buildTimelineItem(Color color, String title, String time, {bool isLast = false}) {
    return Row(
      children: [
        Column(
          children: [
            CircleAvatar(radius: 8, backgroundColor: color, child: CircleAvatar(radius: 6, backgroundColor: Colors.white, child: CircleAvatar(radius: 4, backgroundColor: color))),
            if (!isLast) Container(width: 2, height: 30, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      ],
    );
  }
}