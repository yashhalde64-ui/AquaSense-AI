import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';
import 'package:watermangment/providers/user_provider.dart';
import 'package:watermangment/screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onSelectTab;
  const AppDrawer({super.key, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Drawer(
      backgroundColor: AppTheme.backgroundDark,
      child: SafeArea(
        child: Column(
          children: [
            // Header Profile Container
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.primaryBlue,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // Navigation Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                children: [
                  _buildDrawerTile(
                    icon: Icons.home,
                    title: 'Home Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(0);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.water_drop_outlined,
                    title: 'Daily Water Report',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(1);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.assignment_outlined,
                    title: 'My Complaints',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(2);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.map_outlined,
                    title: 'Live Water Map',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(3);
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.person_outline,
                    title: 'User Profile',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(4);
                    },
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  _buildDrawerTile(
                    icon: Icons.notifications_none,
                    title: 'Service Alerts',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Viewing latest service alerts')),
                      );
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.info_outline,
                    title: 'About AquaSense AI',
                    onTap: () {
                      Navigator.pop(context);
                      showAboutDialog(
                        context: context,
                        applicationName: 'AquaSense AI',
                        applicationVersion: '1.0.0',
                        applicationIcon: Image.asset('assets/images/logo.png', height: 40),
                        children: const [
                          Text('Smart Water Supply Monitoring & Citizen Engagement App powered by Gemini AI.'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Logout Option
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.statusRed),
                title: const Text('Log Out', style: TextStyle(color: AppTheme.statusRed, fontWeight: FontWeight.bold)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                tileColor: AppTheme.statusRed.withOpacity(0.1),
                onTap: () {
                  user.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white30, size: 18),
      onTap: onTap,
    );
  }
}
