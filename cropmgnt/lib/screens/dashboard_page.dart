import 'package:flutter/material.dart';
import 'profile_page.dart'; // Import your ProfilePage
import 'task_page.dart'; // Import your TasksPage
import 'notifications_page.dart'; // Import your NotificationsPage
import 'inventory_page.dart'; // Import your InventoryPage
import 'dataentry_page.dart'; // Import your DataEntryPage
import 'assistant_page.dart'; // Import your AssistantPage
import 'settings_page.dart'; // Import your SettingsPage
import 'help_page.dart'; // Import your HelpPage

class DashboardPage extends StatefulWidget {
  final String username;

  const DashboardPage({super.key, required this.username});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0; // Current index of the selected item

  // Define a list of pages
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // Initialize the list of pages
    _pages.add(DashboardContent(username: widget.username));
    _pages.add(
      ProfilePage(
        username: widget.username,
        location: 'Harare',
        farmSize: '10 acres',
      ),
    );
    _pages.add(TaskPage()); // Your TasksPage widget
    _pages.add(NotificationsPage());
    _pages.add(InventoryPage());
    _pages.add(DataentryPage());
    _pages.add(AssistantPage()); // Your NotificationsPage widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Welcome, ',
            style: const TextStyle(fontSize: 20, color: Colors.white),
            children: [
              TextSpan(
                text: widget.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/farmer.jpg'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Welcome!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex], // Display the current page

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        currentIndex: _currentIndex, // Current index of the selected item
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        unselectedLabelStyle: const TextStyle(color: Colors.black),
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index
          });
        },
      ),
    );
  }
}

// Example content of your Dashboard
class DashboardContent extends StatelessWidget {
  final String username;
  const DashboardContent({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fieldlamdscape.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Main content
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Weather Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(
                      0.8,
                    ), // Glassy dark silver effect
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Row
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Harare',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Date and Time
                      const Text(
                        'Wed, Mar 17, 2025 - 12:45 PM',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      // Weekly Weather Forecast
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildWeatherCard('Mon', Icons.wb_sunny, 'Sunny'),
                          _buildWeatherCard('Tue', Icons.cloud, 'Cloudy'),
                          _buildWeatherCard('Wed', Icons.umbrella, 'Rainy'),
                          _buildWeatherCard(
                            'Thu',
                            Icons.wb_sunny_outlined,
                            'Sunny',
                          ),
                          _buildWeatherCard('Fri', Icons.cloud, 'Cloudy'),
                          _buildWeatherCard('Sat', Icons.umbrella, 'Rainy'),
                          _buildWeatherCard('Sun', Icons.wb_sunny, 'Sunny'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Modern layout for quick actions
              Center(
                child: Column(
                  children: [
                    // First row (2 icons in a row)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionCard(
                          context,
                          icon: Icons.inventory,
                          label: 'Inventory',
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InventoryPage(),
                              ),
                            );
                          },
                        ),
                        _buildActionCard(
                          context,
                          icon: Icons.assistant,
                          label: 'FarmAI',
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssistantPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Single centered icon
                    _buildActionCard(
                      context,
                      icon: Icons.data_usage,
                      label: 'Data Entry',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DataentryPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method for weather cards
  static Widget _buildWeatherCard(String day, IconData icon, String condition) {
    return Column(
      children: [
        Text(day, style: const TextStyle(fontSize: 12, color: Colors.white)),
        const SizedBox(height: 4),
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          condition,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  // Helper method for cards in Quick Actions
  static Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120, // Fixed width for consistency
        height: 120, // Fixed height for consistency
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 3,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
