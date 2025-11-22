import 'package:flutter/material.dart';
import 'api_service.dart';

enum BusStatus { active, maintenance, inactive }

class Bus {
  final int busId;
  final String number;
  final int? routeId;
  final String status;

  Bus({
    required this.busId,
    required this.number,
    this.routeId,
    required this.status,
  });

  BusStatus get busStatus {
    switch (status.toLowerCase()) {
      case 'active':
        return BusStatus.active;
      case 'breakdown':
      case 'in depot':
        return BusStatus.maintenance;
      default:
        return BusStatus.inactive;
    }
  }

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      busId: json['bus_id'] ?? 0,
      number: json['number'] ?? '',
      routeId: json['route_id'],
      status: json['status'] ?? 'Active',
    );
  }
}

class BusesPage extends StatefulWidget {
  const BusesPage({super.key});

  @override
  State<BusesPage> createState() => _BusesPageState();
}

class _BusesPageState extends State<BusesPage> {
  List<Bus> _buses = [];
  bool _isLoading = true;
  String? _error;
  final List<String> _filters = ['All', 'Active', 'Inactive', 'Maintenance'];
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBuses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getBuses();
      setState(() {
        _buses = data.map((json) => Bus.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load buses: $e';
        _isLoading = false;
      });
    }
  }

  List<Bus> get _filteredBuses {
    if (_selectedFilterIndex == 0) return _buses;
    
    final filter = _filters[_selectedFilterIndex].toLowerCase();
    return _buses.where((bus) {
      if (filter == 'active') return bus.status.toLowerCase() == 'active';
      if (filter == 'inactive') return bus.status.toLowerCase() == 'in depot';
      if (filter == 'maintenance') return bus.status.toLowerCase() == 'breakdown';
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D1F3C);
    const cardBackgroundColor = Color(0xFF1C2A44);

    return Container(
      color: primaryColor,
      child: Column(
        children: [
          _buildSearchBar(cardBackgroundColor),
          _buildFilterChips(),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadBuses,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(child: _buildBusList(cardBackgroundColor)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color searchBarColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search by bus number...',
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
    final filtered = _filteredBuses.where((bus) {
      final query = _searchController.text.toLowerCase();
      return bus.number.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'No buses found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBuses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _BusListItem(bus: filtered[index], cardBackgroundColor: cardBackgroundColor);
        },
      ),
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
                Text(
                  'Bus ${bus.number}',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _BusStatusChip(status: bus.busStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Route ID: ${bus.routeId ?? 'N/A'}',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const Divider(color: Colors.white24, height: 24),
            Text(
              'Status: ${bus.status}',
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
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
      case BusStatus.active:
        return Colors.green;
      case BusStatus.maintenance:
        return Colors.orange;
      case BusStatus.inactive:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status) {
      case BusStatus.active:
        return 'Active';
      case BusStatus.maintenance:
        return 'Maintenance';
      case BusStatus.inactive:
        return 'Inactive';
    }
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
          Text(
            _getStatusText(),
            style: TextStyle(color: _getStatusColor(), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
