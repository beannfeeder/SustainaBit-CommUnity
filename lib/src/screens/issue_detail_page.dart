import 'package:flutter/material.dart';

class IssueDetailPage extends StatelessWidget {
  final Map<String, String> issue;

  const IssueDetailPage({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
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
            // 1. 问题主卡片
            _buildMainInfoCard(),
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

  Widget _buildMainInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(issue['title']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(4)),
            child: const Text("Urgent", style: TextStyle(color: Colors.red, fontSize: 10)),
          ),
          const SizedBox(height: 12),
          Text(issue['desc']!, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 16),
          Text("Created at ${issue['time']}", style: const TextStyle(color: Colors.red, fontSize: 12)),
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