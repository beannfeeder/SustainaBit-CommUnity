import 'package:flutter/material.dart';

class AISentimentScreen extends StatelessWidget {
  const AISentimentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // 保持你要求的蓝色顶栏风格
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A80F0),
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white), // AI 图标
            SizedBox(width: 8),
            Text('AI Insights', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: const [
          Icon(Icons.refresh, color: Colors.white),
          SizedBox(width: 15),
          Icon(Icons.account_circle, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Public Sentiment Overview', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            const SizedBox(height: 16),
            
            // 1. 情绪得分看板 (Quantification) 
            _buildSentimentScoreCard(),
            
            const SizedBox(height: 24),
            const Text('AI Generated Summary', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // 2. AI 洞察简报 (Insight Generation) 
            _buildAIInsightCard(
              title: "Rising Tension: Bukit Jalil",
              topic: "Traffic Lights / Road Safety",
              severity: "High",
              summary: "Multiple residents are expressing frustration over the persistent malfunction of traffic lights near the main junction. Negative sentiment increased by 25% in the last 24 hours.",
              color: Colors.red,
            ),
            
            _buildAIInsightCard(
              title: "Community Praise: Waste Mgmt",
              topic: "New Recycling Bins",
              severity: "Low",
              summary: "Positive feedback regarding the new smart recycling bins installed last week. Users appreciate the ease of use and rewards system.",
              color: Colors.green,
            ),
          ],
        ),
      ),

      // 保持一致的底部大加号导航
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

  // 情绪得分卡片
  Widget _buildSentimentScoreCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sentiment Score', style: TextStyle(color: Colors.grey)),
                Text('Last 24h', style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('6.5', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('/ 10', style: TextStyle(color: Colors.grey)),
                    Row(
                      children: const [
                        Icon(Icons.trending_up, color: Colors.red, size: 16),
                        Text(' 12% Negative increase', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.65,
                backgroundColor: Colors.grey[200],
                color: Colors.orange,
                minHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AI 洞察条目卡片
  Widget _buildAIInsightCard({required String title, required String topic, required String severity, required String summary, required Color color}) {
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Chip(
                  label: Text(severity, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: color,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            Text('Topic: $topic', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w500)),
            const Divider(height: 24),
            Text(summary, style: const TextStyle(color: Colors.black87, height: 1.4)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.forum_outlined, size: 18),
              label: const Text('View Discussion'),
            )
          ],
        ),
      ),
    );
  }
}