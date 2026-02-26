import 'package:flutter/material.dart';

// 1. 定义超期工单模型
class OverdueIssue {
  final String id;
  final String category;
  final String reportedBy;
  final int daysOpen;
  final String currentTeam;

  const OverdueIssue({
    required this.id,
    required this.category,
    required this.reportedBy,
    required this.daysOpen,
    required this.currentTeam,
  });
}

class IssueInterventionScreen extends StatelessWidget {
  const IssueInterventionScreen({super.key});

  // 2. 模拟超期工单数据 (即 SLA 超过 7 天的)
  final List<OverdueIssue> _overdueIssues = const [
    OverdueIssue(id: "TKT-1024", category: "Pothole", reportedBy: "Ali", daysOpen: 12, currentTeam: "Cheras Unit"),
    OverdueIssue(id: "TKT-1055", category: "Streetlight", reportedBy: "Siti", daysOpen: 9, currentTeam: "Puchong Central"),
    OverdueIssue(id: "TKT-1102", category: "Drainage", reportedBy: "John", daysOpen: 15, currentTeam: "Bukit Jalil Team"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // 保持与 image_7b047b.png 一致的顶栏
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A80F0),
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Row(
          children: [
            Icon(Icons.home, color: Colors.white),
            SizedBox(width: 8),
            Text('CommUnity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 15),
          Icon(Icons.notifications, color: Colors.white),
          SizedBox(width: 15),
          Icon(Icons.account_circle, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Manual Intervention', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C))), // 红色标题提示紧急
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _overdueIssues.length,
              itemBuilder: (context, index) => _buildInterventionCard(context, _overdueIssues[index]),
            ),
          ),
        ],
      ),

      // 底部导航保持一致
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4A80F0),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: const Icon(Icons.home), onPressed: () {}),
              const SizedBox(width: 40),
              IconButton(icon: const Icon(Icons.person), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  // 3. 构建干预卡片
  Widget _buildInterventionCard(BuildContext context, OverdueIssue issue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(issue.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(4)),
                  child: Text('${issue.daysOpen} Days Overdue', 
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(issue.category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Reported by: ${issue.reportedBy}', style: const TextStyle(color: Colors.grey)),
            Text('Current Team: ${issue.currentTeam}', style: const TextStyle(color: Colors.blueGrey)),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                    onPressed: () => _showOverrideDialog(context, issue),
                    child: const Text('Manual Reassign'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Call Team'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 4. 弹出强制派单对话框
  void _showOverrideDialog(BuildContext context, OverdueIssue issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Override Authority: ${issue.id}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('As a Super-Admin, you are overriding the current assignment. Select a new rapid response team:'),
            SizedBox(height: 16),
            // 这里以后可以换成 Dropdown
            ListTile(title: Text('Emergency Task Force A'), leading: Icon(Icons.bolt, color: Colors.amber)),
            ListTile(title: Text('External Contractor B'), leading: Icon(Icons.build)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Force Dispatch'),
          ),
        ],
      ),
    );
  }
}