import 'package:flutter/material.dart';
import 'buses_page.dart';
import 'routes_page.dart';
import 'drivermanagement.dart';
import 'active_bus.dart'; // Import the active bus page

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // Add the new page to the list of navigable pages
  static const List<Widget> _pages = <Widget>[
    _DashboardView(),
    BusesPage(),
    RoutesPage(),
    DriverManagementPage(),
    ActiveBusPage(), // Added active bus page
  ];

  // Add a title for the new page
  static const List<String> _pageTitles = <String>[
    'Dashboard',
    'Bus Management',
    'Routes & Schedules',
    'Driver Management',
    'Active Buses', // Added title for active bus page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D1F3C);
    const cardBackgroundColor = Color(0xFF1A2B47);
    const accentColor = Color(0xFF4A90E2);
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(_pageTitles[_selectedIndex], style: const TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: textColor),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Add the new item to the navigation bar
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Buses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alt_route),
            label: 'Routes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Drivers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bus_alert_rounded), // Added icon for active bus page
            label: 'Active Bus',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey[400],
        backgroundColor: cardBackgroundColor,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

// This new private widget holds the original dashboard UI for better organization.
class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    const cardBackgroundColor = Color(0xFF1A2B47);
    const accentColor = Color(0xFF4A90E2);
    const textColor = Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: [
              _buildStatCard(
                icon: Icons.directions_bus,
                count: '150',
                label: 'Total Buses',
                color: cardBackgroundColor,
                iconColor: accentColor,
              ),
              _buildStatCard(
                icon: Icons.alt_route,
                count: '25',
                label: 'Active Routes',
                color: cardBackgroundColor,
                iconColor: accentColor,
              ),
              _buildStatCard(
                icon: Icons.accessibility,
                count: '45',
                label: 'Active Drivers',
                color: cardBackgroundColor,
                iconColor: accentColor,
              ),
              _buildStatCard(
                icon: Icons.bar_chart_rounded,
                count: '30',
                label: 'Buses on Road',
                color: cardBackgroundColor,
                iconColor: accentColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTripsChart(cardBackgroundColor, accentColor, textColor),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const Spacer(),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsChart(Color cardBackgroundColor, Color accentColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trips Per Day (Last 7 Days)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('Mon', 0.5, false, accentColor, textColor),
                _buildBar('Tue', 0.6, false, accentColor, textColor),
                _buildBar('Wed', 0.75, false, accentColor, textColor),
                _buildBar('Thu', 0.9, true, accentColor, textColor),
                _buildBar('Fri', 0.4, false, accentColor, textColor),
                _buildBar('Sat', 0.65, false, accentColor, textColor),
                _buildBar('Sun', 0.55, false, accentColor, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double heightFraction, bool isHighlighted, Color accentColor, Color textColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 120 * heightFraction,
          width: 25,
          decoration: BoxDecoration(
            color: isHighlighted ? accentColor : accentColor.withOpacity(0.5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: isHighlighted ? accentColor : textColor.withOpacity(0.7),
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
