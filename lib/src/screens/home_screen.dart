import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // 已经去掉了之前的登出按钮，只保留设置图标
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to SustainaBit',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            CustomCard(
              title: 'Community',
              subtitle: 'Connect with sustainable living enthusiasts',
              icon: Icons.people,
              onTap: () {
                // Navigate to community section
              },
            ),
            const SizedBox(height: 12),
            CustomCard(
              title: 'Challenges',
              subtitle: 'Take on sustainability challenges',
              icon: Icons.emoji_events,
              onTap: () {
                // Navigate to challenges section
              },
            ),
            const SizedBox(height: 12),
            CustomCard(
              title: 'Resources',
              subtitle: 'Learn about sustainable practices',
              icon: Icons.menu_book,
              onTap: () {
                // Navigate to resources section
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'View Profile',
              onPressed: () => context.push('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}