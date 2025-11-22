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
      home: const DriverManagementScreen(),
    );
  }
}

class DriverManagementScreen extends StatelessWidget {
  const DriverManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0E1A2E),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff4CF0C0),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              // BACK BUTTON + TITLE
              Row(
                children: const [
                  Icon(Icons.arrow_back, color: Colors.white, size: 26),
                  SizedBox(width: 20),
                  Text(
                    "Driver Management",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // SEARCH BAR
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff152238),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.white54),
                    hintText: "Search by name or ID",
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // BUTTON
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff2BAE9F),
                      Color(0xff187A6B),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "View Attendance Summary",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // HEADER ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Driver Name",
                    style: TextStyle(
                      color: Color(0xff4CF0C0),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Assigned\nRoute",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    "Status",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Container(
                height: 2,
                width: 120,
                color: const Color(0xff4CF0C0),
              ),

              const SizedBox(height: 15),

              // DRIVER LIST
              Expanded(
                child: ListView(
                  children: const [
                    DriverTile(
                      name: "Eleanor",
                      id: "DRV-001",
                      route: "42-North",
                      status: "Active",
                      statusColor: Colors.green,
                      avatar: "assets/driver1.png",
                    ),
                    DriverTile(
                      name: "Cody",
                      id: "DRV-002",
                      route: "15-East",
                      status: "On Leave",
                      statusColor: Colors.red,
                      avatar: "assets/driver2.png",
                    ),
                    DriverTile(
                      name: "Jenna",
                      id: "DRV-003",
                      route: "28-South",
                      status: "Active",
                      statusColor: Colors.green,
                      avatar: "assets/driver3.png",
                    ),
                    DriverTile(
                      name: "Robert",
                      id: "DRV-004",
                      route: "07-West",
                      status: "Inactive",
                      statusColor: Colors.grey,
                      avatar: "assets/driver4.png",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DriverTile extends StatelessWidget {
  final String name;
  final String id;
  final String route;
  final String status;
  final Color statusColor;
  final String avatar;

  const DriverTile({
    super.key,
    required this.name,
    required this.id,
    required this.route,
    required this.status,
    required this.statusColor,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xff152238),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // AVATAR
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white12,
            backgroundImage: AssetImage(avatar),
          ),

          const SizedBox(width: 15),

          // NAME + ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "ID: $id",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ROUTE
          SizedBox(
            width: 70,
            child: Text(
              route,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // STATUS DOT + TEXT
          Row(
            children: [
              Icon(Icons.circle, color: statusColor, size: 12),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
