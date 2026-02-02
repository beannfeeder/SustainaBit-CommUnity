import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'John Doe',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Sustainability Enthusiast',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            CustomCard(
              title: 'Impact Score',
              subtitle: '1,250 points',
              icon: Icons.star,
              onTap: () {
                // View impact details
              },
            ),
            const SizedBox(height: 12),
            CustomCard(
              title: 'Challenges Completed',
              subtitle: '15 challenges',
              icon: Icons.check_circle,
              onTap: () {
                // View completed challenges
              },
            ),
            const SizedBox(height: 12),
            CustomCard(
              title: 'Community Contributions',
              subtitle: '42 posts',
              icon: Icons.forum,
              onTap: () {
                // View contributions
              },
            ),
          ],
        ),
      ),
    );
  }
}
