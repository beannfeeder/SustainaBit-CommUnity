import 'package:flutter/material.dart';

// 1. 严格定义的表现模型 (修复了构造函数字段缺失问题)
class TeamPerformance {
  final String teamName;
  final int totalIssues;
  final int resolvedIssues;
  final double avgResponseTime;
  final double slaCompliance;

  const TeamPerformance({
    required this.teamName,
    required this.totalIssues,
    required this.resolvedIssues,
    required this.avgResponseTime,
    required this.slaCompliance,
  });
}

class KPIMonitorScreen extends StatelessWidget {
  const KPIMonitorScreen({super.key});

  // 2. 模拟数据 (符合 SLA 逻辑)
  final List<TeamPerformance> _mockData = const [
    TeamPerformance(teamName: 'Bukit Jalil Team', totalIssues: 45, resolvedIssues: 42, avgResponseTime: 1.5, slaCompliance: 93.3),
    TeamPerformance(teamName: 'Puchong Central', totalIssues: 80, resolvedIssues: 75, avgResponseTime: 4.2, slaCompliance: 93.7),
    TeamPerformance(teamName: 'Cheras Unit', totalIssues: 30, resolvedIssues: 12, avgResponseTime: 8.5, slaCompliance: 40.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // 3. 仿 image_7b047b.png 风格的顶部导航栏
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A80F0), 
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Row(
          children: [
            Icon(Icons.home, color: Colors.white),
            SizedBox(width: 8),
            Text('CommUnity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          const Icon(Icons.monetization_on, color: Colors.yellow),
          const SizedBox(width: 15),
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 15),
          const Icon(Icons.notifications, color: Colors.white),
          const SizedBox(width: 15),
          const Icon(Icons.account_circle, color: Colors.white),
          const SizedBox(width: 10),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Management KPI Monitor', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mockData.length,
              itemBuilder: (context, index) => _buildTeamCard(_mockData[index]),
            ),
          ),
        ],
      ),

      // 4. 仿 image_7b047b.png 风格的底部导航栏
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4A80F0),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home, 'Home', true),
              const SizedBox(width: 40), 
              _buildBottomNavItem(Icons.person, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(TeamPerformance team) {
    // SLA 判定逻辑: <3d Good, 3-7d Warning, >7d Critical
    Color statusColor = team.avgResponseTime < 3 ? Colors.green : (team.avgResponseTime <= 7 ? Colors.orange : Colors.red);
    IconData statusIcon = team.avgResponseTime < 3 ? Icons.check_circle : (team.avgResponseTime <= 7 ? Icons.warning : Icons.error);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 24),
                    const SizedBox(width: 8),
                    Text(team.teamName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text('${team.slaCompliance}% SLA', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Total', team.totalIssues.toString()),
                _buildStat('Resolved', team.resolvedIssues.toString()),
                _buildStat('Avg. Time', '${team.avgResponseTime}d'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF4A80F0) : Colors.grey),
        Text(label, style: TextStyle(color: isActive ? const Color(0xFF4A80F0) : Colors.grey, fontSize: 12)),
      ],
    );
  }
}