import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IssuePage extends StatelessWidget {
  const IssuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      // 🌟 核心修改：删除了这里的 appBar: AppBar(...)
      // 现在它就不会和 MainShell 顶部的 AppTopBar 撞车双重显示了！
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("All Issues", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          
          // 标签栏区域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildTab("Pending", true),
                const SizedBox(width: 12),
                _buildTab("In-progress", false),
                const SizedBox(width: 12),
                _buildTab("Resolved", false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 问题列表区域
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4, // 暂时生成 4 个假数据卡片
              itemBuilder: (context, index) {
                return _buildIssueCard(context, index);
              }
            ),
          )
        ],
      ),
    );
  }

  // 辅助构建标签的函数
  Widget _buildTab(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? const Color(0xFF1E5BB8) : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // 辅助构建问题卡片的函数
  Widget _buildIssueCard(BuildContext context, int index) {
    // 为每个卡片生成一个模拟的 ID
    final String currentIssueId = "ISSUE_00${index + 1}";

    return GestureDetector(
      onTap: () {
        // 🌟 点击卡片时，带着 ID 跳转到你刚刚写的详情页！
        context.push('/issue-detail/$currentIssueId');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tree has fallen", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Tree at Sungai Besi highway fallen due to traffic jam, delays work model increases the severity to emergency.",
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text("Urgent - Today 1:30pm", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}