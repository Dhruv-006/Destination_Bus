import 'package:flutter/material.dart';

enum BusStatus { active, maintenance, inactive }

class Bus {
  final String name;
  final String license;
  final String driver;
  final BusStatus status;

  const Bus({
    required this.name,
    required this.license,
    required this.driver,
    required this.status,
  });
}

class BusesPage extends StatefulWidget {
  const BusesPage({super.key});

  @override
  State<BusesPage> createState() => _BusesPageState();
}

class _BusesPageState extends State<BusesPage> {
  // Placeholder data
  final List<Bus> _buses = const [
    Bus(name: 'Alpha Bus-07', license: 'ABC-1234', driver: 'John Doe', status: BusStatus.active),
    Bus(name: 'City Runner-02', license: 'DEF-5678', driver: 'Jane Smith', status: BusStatus.maintenance),
    Bus(name: 'Metro Express-11', license: 'GHI-9012', driver: 'Unassigned', status: BusStatus.inactive),
  ];

  final List<String> _filters = ['All', 'Active', 'Inactive', 'Maintenance'];
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D1F3C);
    const cardBackgroundColor = Color(0xFF1C2A44);

    // This page is now just the content, not a full Scaffold with an AppBar.
    // The main Scaffold is in dashboard_page.dart
    return Container(
      color: primaryColor,
      child: Column(
        children: [
          _buildSearchBar(cardBackgroundColor),
          _buildFilterChips(),
          Expanded(child: _buildBusList(cardBackgroundColor)),
        ],
      ),
      // The FloatingActionButton should also be moved to the main dashboard page
      // to be managed along with the AppBar title.
    );
  }

  Widget _buildSearchBar(Color searchBarColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by license plate or name...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: searchBarColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              backgroundColor: const Color(0xFF1C2A44),
              selectedColor: const Color(0xFF4A90E2),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white.withOpacity(0.7)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBusList(Color cardBackgroundColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _buses.length,
      itemBuilder: (context, index) {
        return _BusListItem(bus: _buses[index], cardBackgroundColor: cardBackgroundColor);
      },
    );
  }
}

class _BusListItem extends StatelessWidget {
  const _BusListItem({required this.bus, required this.cardBackgroundColor});

  final Bus bus;
  final Color cardBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(bus.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                _BusStatusChip(status: bus.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('License: ${bus.license}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Driver: ${bus.driver}', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                Row(
                  children: [
                    _ActionButton(icon: Icons.edit, onPressed: () {}),
                    const SizedBox(width: 8),
                    _ActionButton(icon: Icons.delete_outline, onPressed: () {}),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BusStatusChip extends StatelessWidget {
  const _BusStatusChip({required this.status});

  final BusStatus status;

  Color _getStatusColor() {
    switch (status) {
      case BusStatus.active: return Colors.green;
      case BusStatus.maintenance: return Colors.orange;
      case BusStatus.inactive: return Colors.grey;
    }
  }

  String _getStatusText() {
    final text = status.toString().split('.').last;
    if (text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: _getStatusColor(), size: 10),
          const SizedBox(width: 6),
          Text(_getStatusText(), style: TextStyle(color: _getStatusColor(), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
      ),
    );
  }
}
