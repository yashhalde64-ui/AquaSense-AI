import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';
import 'package:watermangment/providers/user_provider.dart';
import 'package:watermangment/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showPersonalInformation(BuildContext context, UserProvider user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Personal Information', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                user.setUser(nameController.text, emailController.text, user.area);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Personal Information Updated!'), backgroundColor: AppTheme.statusGreen),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showInfoModal(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassContainer(
          borderRadius: 25,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                  child: const Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 110.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Header
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryBlue,
                child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                user.email,
                style: const TextStyle(fontSize: 14, color: Colors.white54),
              ),
              const SizedBox(height: 30),
              
              // Settings List
              GlassContainer(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.person_outline, 
                      title: 'Personal Information',
                      onTap: () => _showPersonalInformation(context, user),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.location_on_outlined, 
                      title: 'Saved Areas',
                      onTap: () => _showInfoModal(context, 'Saved Areas', 'Primary Service Area: ${user.area}, Thane, Maharashtra.'),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.notifications_outlined, 
                      title: 'Notification Preferences',
                      onTap: () => _showInfoModal(context, 'Notification Preferences', 'Water Outage Alerts: Enabled\nDaily Report Reminders: Enabled\nComplaint Updates: Enabled'),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.history, 
                      title: 'My Reports History',
                      onTap: () => _showInfoModal(context, 'Reports History', 'You have submitted 3 water reports this week for ${user.area}.'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GlassContainer(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.help_outline, 
                      title: 'Help & Support',
                      onTap: () => _showInfoModal(context, 'Help & Support', 'CivicPulse Municipal Helpline: 1800-233-4567\nEmail Support: support@civicpulse.org'),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.info_outline, 
                      title: 'About CivicPulse',
                      onTap: () => _showInfoModal(context, 'About CivicPulse', 'CivicPulse v1.0.0\nSmart Urban Water Monitoring App built with Flutter & MongoDB.'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Logout button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    user.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.statusRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: AppTheme.statusRed, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon, 
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.1), height: 1);
  }
}
