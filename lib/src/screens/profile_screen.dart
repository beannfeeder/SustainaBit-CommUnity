import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if we are on a small screen to adjust layout if needed
    // For now, assuming mobile portrait as per design.
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surface, // M3 Surface
        body: SafeArea(
          child: Column(
            children: [
              // 1. Header Section
              _buildHeader(context),

              // 2. Tab Bar
              TabBar(
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent, // M3 often removes the divider or keeps it subtle
                tabs: const [
                  Tab(icon: Icon(Icons.grid_view, size: 28)), // Grid icon
                  Tab(icon: Icon(Icons.archive_outlined, size: 28)), // Box icon (using archive as proxy)
                ],
              ),
              const Divider(height: 1),

              // 3. Tab Content
              Expanded(
                child: TabBarView(
                  children: [
                    _buildCommunitySharingTab(context),
                    _buildIssuesTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 4. Bottom Navigation Bar
        bottomNavigationBar: NavigationBar(
          selectedIndex: 2, // Profile is the 3rd item (index 2)
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                // TODO: Navigate to Create/Add screen
                break;
              case 2:
                // current screen
                break;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, size: 30), // Prominent add button
              selectedIcon: Icon(Icons.add_circle, size: 30),
              label: 'Create',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: theme.colorScheme.surfaceContainerLow, // Slight background tint if defined, else surface
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: theme.colorScheme.primary, // Use primary color for background
                  child: const Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              // Edit Icon
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300], // As per design
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.surface, width: 2),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.black87),
                  onPressed: () {
                    // Edit profile action
                  },
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Hello, Joe!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitySharingTab(BuildContext context) {
    // Helper to build a "Community Sharing" card
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeedCard(
          context,
          title: 'Free Herbs at Block A Garden – Take What You Need!',
          author: 'Block A Garden',
          timeAgo: '5 hours ago',
          tag: 'Community Sharing',
          tagColor: Colors.green,
          content: 'Hi neighbours! The community herb garden at Block A is growing really well 🌱\n'
                   'We currently have mint, pandan, and curry leaves. Feel free to take some, just don\'t uproot the plants please 😊',
        ),
      ],
    );
  }

  Widget _buildIssuesTab(BuildContext context) {
    return Column(
      children: [
        // Filter Dropdown
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Filter by...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            items: const [],
            onChanged: (value) {},
          ),
        ),
        // List of Issues
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildIssueCard(
                context,
                title: 'Drainage blocked at Jalan 6/7, Persiaran Tujuan',
                date: 'First reported 25/12/2025',
                status: 'Completed',
                statusColor: Colors.green,
                onTap: () {
                   // Navigate to issue details
                },
              ),
              const SizedBox(height: 12),
              _buildIssueCard(
                context,
                title: 'Tree Fallen at 29, Jalan 2/12, Taman Mayang',
                date: 'First reported 2/1/2026',
                status: 'In Progress',
                statusColor: Colors.amber,
                onTap: () {
                   // Navigate to issue details
                },
              ),
              const SizedBox(height: 12),
              _buildIssueCard(
                context,
                title: 'Sinkhole formed at Bukit Jalil Recreational Park',
                date: 'First reported 1/2/2026',
                status: 'In Progress',
                statusColor: Colors.red,
                onTap: () {
                   // Navigate to issue details
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedCard(
    BuildContext context, {
    required String title,
    required String author,
    required String timeAgo,
    required String tag,
    required Color tagColor,
    required String content,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer, // M3 Card color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.spa, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Metadata
            Text(
              '$author  $timeAgo',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            // Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            // Content
            Text(
              content,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueCard(
    BuildContext context, {
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias, // Needed for InkWell ripple to respect border radius
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                         color: Colors.brown[700], // Example color from screenshot
                         fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                 decoration: BoxDecoration(
                   color: statusColor,
                   borderRadius: BorderRadius.circular(20),
                 ),
                 child: Text(
                   status,
                   style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                 ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
