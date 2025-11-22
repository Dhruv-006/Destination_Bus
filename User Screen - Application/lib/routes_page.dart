import 'package:flutter/material.dart';

enum RouteStatus { active, delayed, inactive }

class RouteInfo {
  final String name;
  final RouteStatus status;
  final String path;
  final String schedule;
  final List<String> stops;
  final String assignedBus;
  final String assignedDriver;

  const RouteInfo({
    required this.name,
    required this.status,
    required this.path,
    required this.schedule,
    required this.stops,
    required this.assignedBus,
    required this.assignedDriver,
  });
}

class RoutesPage extends StatelessWidget {
  const RoutesPage({super.key});

  final List<RouteInfo> _routes = const [
    RouteInfo(
      name: 'Route 5A',
      status: RouteStatus.active,
      path: 'Downtown Hub → Northside Mall',
      schedule: 'Daily: 6:00 AM - 11:00 PM',
      stops: ['Central Station', 'Library', 'Parkside Ave', 'Northside Mall'],
      assignedBus: 'Bus #102',
      assignedDriver: 'John Doe',
    ),
    RouteInfo(
      name: 'Route 12C',
      status: RouteStatus.delayed,
      path: 'City Center → Airport Terminal',
      schedule: 'Daily: 5:30 AM - 1:00 AM',
      stops: ['City Hall', 'Convention Center', 'Terminal A', 'Terminal B'],
      assignedBus: 'Bus #205',
      assignedDriver: 'Jane Smith',
    ),
    RouteInfo(
      name: 'Route 3B',
      status: RouteStatus.inactive,
      path: 'West End → University Campus',
      schedule: 'Weekdays: 7:00 AM - 8:00 PM',
      stops: ['West End Station', 'Arts Building', 'Science Lab', 'Campus Hub'],
      assignedBus: 'Bus #301',
      assignedDriver: 'Unassigned',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1F3C),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _routes.length,
        itemBuilder: (context, index) {
          return _RouteListItem(route: _routes[index]);
        },
      ),
    );
  }
}

class _RouteListItem extends StatefulWidget {
  final RouteInfo route;

  const _RouteListItem({required this.route});

  @override
  State<_RouteListItem> createState() => _RouteListItemState();
}

class _RouteListItemState extends State<_RouteListItem> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // By default, expand the first active route
    if (widget.route.status == RouteStatus.active) {
      _isExpanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1C2A44),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          children: [
            _buildHeader(),
            if (_isExpanded) _buildDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.route.name,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: widget.route.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(widget.route.path, style: TextStyle(color: Colors.white.withOpacity(0.8))),
                const SizedBox(height: 4),
                Text(widget.route.schedule, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.white.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Container(
      color: Colors.black.withOpacity(0.15),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stops:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            widget.route.stops.join(', '),
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          const Divider(color: Colors.white24, height: 32),
          const Text('Assignments:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _AssignmentRow(icon: Icons.directions_bus, text: widget.route.assignedBus),
          const SizedBox(height: 8),
          _AssignmentRow(icon: Icons.person, text: widget.route.assignedDriver),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final RouteStatus status;

  const _StatusChip({required this.status});

  Color _getStatusColor() {
    switch (status) {
      case RouteStatus.active: return Colors.green;
      case RouteStatus.delayed: return Colors.orange;
      case RouteStatus.inactive: return Colors.grey;
    }
  }

  String _getStatusText() {
    return status.toString().split('.').last.replaceFirstMapped((m) => m[0]!.toUpperCase(), (m) => '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AssignmentRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: Colors.white.withOpacity(0.9))),
      ],
    );
  }
}
