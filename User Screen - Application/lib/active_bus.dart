import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ActiveBusesScreen(),
    );
  }
}

class ActiveBusesScreen extends StatelessWidget {
  const ActiveBusesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (You can replace with map img or color)
          Positioned.fill(
            child: Image.asset(
              "assets/map_bg.jpg", // Or use: Container(color: Colors.blueGrey.shade900)
              fit: BoxFit.cover,
            ),
          ),

          // LEFT SIDE BLUR PANEL
          Align(
            alignment: Alignment.centerLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.all(20),
                  color: Colors.black.withOpacity(0.35),
                  child: const ActiveBusList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveBusList extends StatelessWidget {
  const ActiveBusList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        const Text(
          "Active Buses (15)",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        // SEARCH BAR
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              hintText: "Search Bus, Driver, Route...",
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // LIST
        Expanded(
          child: ListView(
            children: const [
              BusTile(
                busNumber: "BUS-101",
                route: "Route 5 - Downtown Express",
                status: "On Time",
                statusColor: Colors.lightBlueAccent,
                isHighlighted: true,
              ),
              BusTile(
                busNumber: "BUS-204",
                route: "Route 12 - Crosstown",
                status: "Delayed",
                statusColor: Colors.orange,
              ),
              BusTile(
                busNumber: "BUS-315",
                route: "Route 3 - University Loop",
                status: "On Time",
                statusColor: Colors.lightBlueAccent,
              ),
              BusTile(
                busNumber: "BUS-408",
                route: "Route 8A - Northbound",
                status: "Stopped",
                statusColor: Colors.red,
              ),
              BusTile(
                busNumber: "BUS-112",
                route: "Route 9 - Airport Shuttle",
                status: "Offline",
                statusColor: Colors.grey,
              ),
              BusTile(
                busNumber: "BUS-221",
                route: "Route 2 - City Center",
                status: "On Time",
                statusColor: Colors.lightBlueAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BusTile extends StatelessWidget {
  final String busNumber;
  final String route;
  final String status;
  final Color statusColor;
  final bool isHighlighted;

  const BusTile({
    super.key,
    required this.busNumber,
    required this.route,
    required this.status,
    required this.statusColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isHighlighted
            ? const LinearGradient(
          colors: [Color(0xff1565C0), Color(0xff1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isHighlighted ? null : Colors.white.withOpacity(0.06),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_bus, color: Colors.white),
          ),

          const SizedBox(width: 15),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  busNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  route,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // STATUS
          Row(
            children: [
              Icon(Icons.circle, color: statusColor, size: 12),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(color: statusColor, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
