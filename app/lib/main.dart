import 'package:flutter/material.dart';

void main() {
  runApp(const ZunoApp());
}

class ZunoApp extends StatelessWidget {
  const ZunoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF13211D);
    const green = Color(0xFF2CB88A);

    return MaterialApp(
      title: 'Zuno',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8F7),
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.hub_rounded, size: 28),
            SizedBox(width: 9),
            Text(
              'zuno',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile (coming soon)',
            onPressed: () => _showNotice('Optional profiles are planned.'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            _buildChats(),
            _buildNearby(),
            _buildTransfers(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() => _selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.radar_rounded),
            selectedIcon: Icon(Icons.radar_rounded),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_rounded),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Share',
          ),
        ],
      ),
    );
  }

  Widget _buildChats() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Text(
          'Stay connected.',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Nearby without data. Abroad through the internet.',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
        ),
        const SizedBox(height: 18),
        const _PrototypeNotice(),
        const SizedBox(height: 20),
        const _RouteCard(
          icon: Icons.bluetooth_connected_rounded,
          title: 'Nearby mode',
          description: 'Bluetooth discovery and local messaging',
          status: 'Transport not connected',
          color: Color(0xFF198565),
        ),
        const SizedBox(height: 12),
        const _RouteCard(
          icon: Icons.public_rounded,
          title: 'Zuno Anywhere',
          description: 'Internet relay for friends in other countries',
          status: 'Internet relay not connected',
          color: Color(0xFF3F6FBD),
        ),
        const SizedBox(height: 28),
        const Text(
          'Your conversations',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE7EAE8)),
          ),
          child: const Column(
            children: [
              Icon(Icons.forum_outlined, size: 42, color: Color(0xFF7A8580)),
              SizedBox(height: 12),
              Text(
                'No conversations yet',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'Find someone nearby or start an online conversation when messaging is connected.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF69736E), height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNearby() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          'Nearby',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 8),
        Text(
          'Discover people and devices around you without relying on mobile data.',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        SizedBox(height: 20),
        _PrototypeNotice(),
        SizedBox(height: 16),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Column(
              children: [
                Icon(Icons.radar_rounded, size: 64, color: Color(0xFF7A8580)),
                SizedBox(height: 12),
                Text(
                  'Nearby discovery is not connected yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text(
                  'The next milestone is testing discovery between real iPhone and Android devices.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransfers() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          'Share files',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 8),
        Text(
          'Send photos and documents over a compatible local connection, or share remotely when online transfer is implemented.',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        SizedBox(height: 20),
        _PrototypeNotice(),
        SizedBox(height: 16),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Column(
              children: [
                Icon(Icons.folder_copy_outlined, size: 64, color: Color(0xFF7A8580)),
                SizedBox(height: 12),
                Text(
                  'File transfer is coming next',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text(
                  'No files are sent or uploaded by this prototype.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _PrototypeNotice extends StatelessWidget {
  const _PrototypeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0D9A4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.construction_rounded, color: Color(0xFF8A6418)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Early UI prototype — wireless networking and internet delivery are not implemented yet.',
              style: TextStyle(color: Color(0xFF604A1D), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 7),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
