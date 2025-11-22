import 'package:flutter/material.dart';
import 'api_service.dart';

enum RouteStatus { active, delayed, inactive }

class RouteInfo {
  final int routeId;
  final String name;
  final String startStop;
  final String endStop;
  final String? firstBus;
  final String? lastBus;
  final int? frequencyMin;

  RouteInfo({
    required this.routeId,
    required this.name,
    required this.startStop,
    required this.endStop,
    this.firstBus,
    this.lastBus,
    this.frequencyMin,
  });

  String get path => '$startStop → $endStop';
  String get schedule {
    if (firstBus != null && lastBus != null) {
      return 'Daily: $firstBus - $lastBus';
    }
    return 'Schedule not set';
  }

  RouteStatus get status => RouteStatus.active; // Default to active

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      routeId: json['route_id'] ?? 0,
      name: json['name'] ?? '',
      startStop: json['start_stop'] ?? '',
      endStop: json['end_stop'] ?? '',
      firstBus: json['first_bus'],
      lastBus: json['last_bus'],
      frequencyMin: json['frequency_min'],
    );
  }
}

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  List<RouteInfo> _routes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getRoutes();
      setState(() {
        _routes = data.map((json) => RouteInfo.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load routes: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1F3C),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRoutes,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRoutes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _routes.length,
                    itemBuilder: (context, index) {
                      return _RouteListItem(route: _routes[index]);
                    },
                  ),
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
          const Text('Route Details:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _DetailRow(label: 'Start Stop', value: widget.route.startStop),
          _DetailRow(label: 'End Stop', value: widget.route.endStop),
          if (widget.route.frequencyMin != null)
            _DetailRow(label: 'Frequency', value: '${widget.route.frequencyMin} minutes'),
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
      case RouteStatus.active:
        return Colors.green;
      case RouteStatus.delayed:
        return Colors.orange;
      case RouteStatus.inactive:
        return Colors.grey;
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
