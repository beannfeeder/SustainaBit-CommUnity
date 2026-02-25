import 'package:flutter/material.dart';

class BroadcastCenterScreen extends StatefulWidget {
  const BroadcastCenterScreen({super.key});

  @override
  State<BroadcastCenterScreen> createState() => _BroadcastCenterScreenState();
}

class _BroadcastCenterScreenState extends State<BroadcastCenterScreen> {
  String _selectedTarget = 'Entire Jurisdiction'; // 預設發送全境 
  String _selectedTemplate = 'General';
  final TextEditingController _messageController = TextEditingController();

  // 預設範本內容 
  final Map<String, String> _templates = {
    'General': '',
    'Dengue Fogging': 'Dear residents, please be informed that dengue fogging will take place in your area tomorrow at 9 AM. Please keep your windows closed.',
    'Water Disruption': 'Emergency water disruption notice: Maintenance work will be conducted. Expected recovery time is 6 hours.',
    'Emergency': 'URGENT: Please follow the local safety guidelines immediately. Stay indoors until further notice.',
  };

  void _applyTemplate(String? template) {
    if (template != null) {
      setState(() {
        _selectedTemplate = template;
        _messageController.text = _templates[template]!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A80F0),
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Row(
          children: [
            Icon(Icons.campaign, color: Colors.white), // 廣播圖標
            SizedBox(width: 8),
            Text('Broadcast Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Announcement', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            const SizedBox(height: 16),

            // 1. 目標選擇 (Targeting) 
            _buildSectionTitle('1. Select Audience'),
            _buildTargetSelector(),

            const SizedBox(height: 20),

            // 2. 範本選擇 (Templates) 
            _buildSectionTitle('2. Use a Template'),
            _buildTemplateDropdown(),

            const SizedBox(height: 20),

            // 3. 訊息編輯
            _buildSectionTitle('3. Message Details'),
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Enter announcement content...',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 30),

            // 4. 發送按鈕 (Execution) 
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _confirmBroadcast(context),
                icon: const Icon(Icons.send),
                label: const Text('Broadcast to All Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),

      // 底部導航保持一致
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
    );
  }

  Widget _buildTargetSelector() {
    return Row(
      children: [
        _buildChoiceChip('Entire Jurisdiction'),
        const SizedBox(width: 10),
        _buildChoiceChip('Specific Zone'),
      ],
    );
  }

  Widget _buildChoiceChip(String label) {
    bool isSelected = _selectedTarget == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedTarget = label),
      selectedColor: const Color(0xFF4A80F0),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _buildTemplateDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTemplate,
          isExpanded: true,
          items: _templates.keys.map((String key) {
            return DropdownMenuItem<String>(value: key, child: Text(key));
          }).toList(),
          onChanged: _applyTemplate,
        ),
      ),
    );
  }

  void _confirmBroadcast(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Broadcast?'),
        content: Text('This message will be sent as a High-Priority notification to all users in "$_selectedTarget".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Push notifications triggered and pinned to Forum!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Confirm & Send'),
          ),
        ],
      ),
    );
  }
}