import 'package:flutter/material.dart';

class KaelTabBar extends StatelessWidget {
  final String leadingLabel;
  final List<String> tabs;
  final String activeTab;
  final Function(String) onTabTap;
  final Function(String) onTabClose;
  final VoidCallback? onExit; // Optional "X" button for the CV screen

  const KaelTabBar({
    super.key,
    required this.leadingLabel,
    required this.tabs,
    required this.activeTab,
    required this.onTabTap,
    required this.onTabClose,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 18, 18, 18),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Text(leadingLabel, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(width: 15),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: tabs.map((tab) => _buildTab(tab)).toList(),
            ),
          ),
          if (onExit != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white24, size: 18),
              onPressed: onExit,
            )
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    bool selected = activeTab == label;
    return GestureDetector(
      onTap: () => onTabTap(label),
      child: Container(
        margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2A241B) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: selected ? const Color(0xFFD4C3A3) : Colors.white24, fontSize: 11)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onTabClose(label),
              child: const Icon(Icons.close, size: 10, color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }
}